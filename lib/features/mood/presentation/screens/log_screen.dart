import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/floating_tab_bar.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/phone_column.dart';
import '../../../purchases/presentation/bloc/purchases_cubit.dart';
import '../../../purchases/presentation/widgets/premium_sheet.dart';
import '../../data/services/rating_prompt_service.dart';
import '../../domain/entities/mood_category.dart';
import '../../domain/entities/mood_definition.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/services/can_save_with_mood.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../../domain/services/mood_streak_calculator.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/mood_cubit.dart';
import '../widgets/mood_category_grid.dart';
import '../widgets/note_editor_sheet.dart';

/// The Log tab: pick today's mood on a grid grouped by category, and, once
/// saved (or when the date already has an entry), the "Saved" state with the
/// current streak.
///
/// It owns no date: [selectedDate] comes from the shell, which changes it
/// only when a calendar day is tapped, the reminder is opened or "Forgot
/// yesterday?" is tapped ([onRequestDate]).
class LogScreen extends StatefulWidget {
  const LogScreen({
    super.key,
    this.selectedDate,
    this.isActive = true,
    this.onOpenSettings,
    this.onRequestDate,
    this.clock,
  });

  final DateTime? selectedDate;

  /// Whether the Log tab is the visible one. The rating prompt is skipped
  /// when the user already left it.
  final bool isActive;

  /// The bell of the header: shows the Settings tab.
  final VoidCallback? onOpenSettings;

  /// "Forgot yesterday? Log it": asks the shell to show another date.
  final ValueChanged<DateTime>? onRequestDate;

  /// Current time, for the greeting and for telling "today" apart.
  final DateTime Function()? clock;

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _noteController = TextEditingController();

  MoodDefinition? _selected;
  List<MoodEntry> _entries = const [];

  /// The saved entry of the date, if any. Kept while editing so the
  /// "same expired mood" exception can compare against it.
  MoodEntry? _entry;
  bool _isLoading = true;
  bool _editing = false;
  bool _isSaving = false;
  MoodEntry? _pendingSave;
  bool _didHydrate = false;

  DateTime get _now => (widget.clock ?? DateTime.now)();
  DateTime get _date {
    final date = widget.selectedDate ?? _now;
    return DateTime(date.year, date.month, date.day);
  }

  bool get _isToday {
    final now = _now;
    return _date == DateTime(now.year, now.month, now.day);
  }

  bool get _showSaved => _entry != null && !_editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didHydrate) return;
    _didHydrate = true;
    _onMoodState(context.read<MoodCubit>().state);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool _isLocked(MoodDefinition mood) {
    if (mood.tier == MoodTier.base) return false;
    return !context.read<PurchasesCubit>().isMoodUnlocked(mood.id);
  }

  void _onMoodState(MoodState state) {
    state.maybeWhen(
      loaded: _onEntriesLoaded,
      error: (_) {
        if (!mounted) return;
        final failedSave = _pendingSave != null;
        setState(() {
          _isLoading = false;
          _isSaving = false;
          _pendingSave = null;
        });
        if (failedSave) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.of(context).saveMoodError)),
          );
        }
      },
      orElse: () {},
    );
  }

  void _onEntriesLoaded(List<MoodEntry> entries) {
    if (!mounted) return;
    final entry = _findEntry(entries, _date);
    final pending = _pendingSave;
    // A reload that does not carry the entry being saved (e.g. one the watch
    // triggered) must not be mistaken for the save finishing.
    final justSaved = pending != null &&
        entry != null &&
        entry.mood == pending.mood &&
        (entry.note ?? '') == (pending.note ?? '');

    setState(() {
      _entries = entries;
      _entry = entry;
      _isLoading = false;
      if (justSaved || pending == null) _isSaving = false;
      if (justSaved) _pendingSave = null;
      if (entry == null) {
        _editing = false;
      } else if (justSaved) {
        _editing = false;
        _adopt(entry);
      } else if (!_editing) {
        // First load, or an entry that arrived from elsewhere (the watch).
        _adopt(entry);
      }
    });

    if (justSaved) {
      context.read<CalendarCubit>().refreshForDate(_date);
      _requestRatingAfterSaved();
    }
  }

  void _adopt(MoodEntry entry) {
    _selected = MoodDefinitionResolver.byAssetPath(entry.mood);
    _noteController.text = entry.note ?? '';
  }

  MoodEntry? _findEntry(List<MoodEntry> entries, DateTime date) {
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (day == date) return entry;
    }
    return null;
  }

  /// Asks for a store rating once the Saved state is on screen. Skipped (and
  /// the attempt not recorded) when the user already left the tab or a modal
  /// covers it.
  void _requestRatingAfterSaved() {
    final service = context.read<RatingPromptService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !widget.isActive ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      unawaited(service.maybeRequestAfterSave());
    });
  }

  void _onMoodTap(MoodDefinition mood) {
    if (_isLocked(mood)) {
      showPremiumSheet(
        context,
        source: PremiumSource.lockedMood,
        mood: mood,
      );
      return;
    }
    setState(() => _selected = mood);
  }

  void _openNoteEditor() {
    showNoteEditorSheet(
      context,
      controller: _noteController,
      mood: _selected,
    );
  }

  void _save() {
    final mood = _selected;
    if (mood == null || _isSaving) return;
    if (!canSaveWithMood(
      mood: mood,
      isUnlocked: !_isLocked(mood),
      savedMoodAssetPath: _entry?.mood,
    )) {
      showPremiumSheet(
        context,
        source: PremiumSource.lockedMood,
        mood: mood,
      );
      return;
    }
    final note = _noteController.text;
    final entry = MoodEntry(
      date: _date,
      mood: mood.assetPath,
      note: note.isEmpty ? null : note,
      intensity: mood.intensity,
    );
    setState(() {
      _isSaving = true;
      _pendingSave = entry;
    });
    context.read<MoodCubit>().save(entry);
  }

  void _logYesterday() {
    final yesterday = DateTime(_date.year, _date.month, _date.day - 1);
    widget.onRequestDate?.call(yesterday);
  }

  String _greeting(AppStrings strings) {
    final hour = _now.hour;
    if (hour >= 5 && hour < 12) return strings.greetingMorning;
    if (hour >= 12 && hour < 19) return strings.greetingAfternoon;
    return strings.greetingEvening;
  }

  String _notePrompt(AppStrings strings) {
    final mood = _selected;
    if (mood == null) return strings.notePromptEmpty;
    switch (mood.category) {
      case MoodCategory.positive:
      case MoodCategory.peaceful:
        return strings.notePromptPositive;
      case MoodCategory.neutral:
        return strings.notePromptNeutral;
      case MoodCategory.hard:
        return strings.notePromptHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return BlocListener<MoodCubit, MoodState>(
      listener: (context, state) => _onMoodState(state),
      child: Builder(
        builder: (context) {
          final tint = _selected == null
              ? null
              : MoodDefinitionResolver.tintFor(context, _selected!).fill;

          return MeshBackground(
            tint: tint,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              // The note editor is a sheet that handles the keyboard itself.
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: palette.ink),
                            const SizedBox(height: 16),
                            Text(
                              strings.moodLoading,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _showSaved
                        ? _scrollable(_buildSaved(context, strings))
                        : Column(
                            children: [
                              Expanded(
                                child: _scrollable(
                                  _buildChoose(context, strings),
                                ),
                              ),
                              PhoneColumn(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                  child: _buildActions(strings),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// A tab body that scrolls when its content does not fit.
  Widget _scrollable(Widget child) {
    return CustomScrollView(
      primary: false,
      slivers: [
        SliverToBoxAdapter(
          child: PhoneColumn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppStrings strings) {
    final palette = BrandPalette.of(context);
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.formatFullDate(_date),
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: palette.textSecondary,
                  ),
                ),
                Text(
                  _greeting(strings),
                  style: const TextStyle(
                    fontSize: 22,
                    height: 28 / 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: strings.remindersBellLabel,
            onTap: widget.onOpenSettings,
            excludeSemantics: true,
            child: Tooltip(
              message: strings.remindersBellLabel,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onOpenSettings,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.glassFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.glassBorder),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: palette.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoose(BuildContext context, AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(strings),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            _isToday ? strings.moodQuestion : strings.moodQuestionPast,
            style: const TextStyle(
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: BlocBuilder<PurchasesCubit, PurchasesState>(
            builder: (context, _) => MoodCategoryGrid(
              selectedId: _selected?.id,
              isLocked: _isLocked,
              onMoodTap: _onMoodTap,
            ),
          ),
        ),
      ],
    );
  }

  /// The note pill and Save, pinned above the tab bar.
  Widget _buildActions(AppStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _noteController,
          builder: (context, _) {
            final note = _noteController.text.trim();
            return _NotePill(
              text:
                  note.isEmpty ? _notePrompt(strings) : note.split('\n').first,
              hasNote: note.isNotEmpty,
              onTap: _openNoteEditor,
            );
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: FloatingTabBar.maxWidth),
            child: GradientPillButton(
              label: strings.save,
              semanticsLabel: strings.saveMoodButtonLabel,
              loading: _isSaving,
              enabled: _selected != null,
              onPressed: _save,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaved(BuildContext context, AppStrings strings) {
    final palette = BrandPalette.of(context);
    final entry = _entry!;
    final mood = MoodDefinitionResolver.byAssetPath(entry.mood);
    final tint = MoodDefinitionResolver.tintFor(context, mood);
    final streak = MoodStreakCalculator.currentStreak(
      _entries.map((e) => e.date),
      _date,
    );
    final yesterday = DateTime(_date.year, _date.month, _date.day - 1);
    final yesterdayLogged = _findEntry(_entries, yesterday) != null;
    final note = entry.note?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(strings),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: GlassCard(
            radius: 999,
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: palette.logLinearGradient,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: palette.onLogGradient,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: strings.savedLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' · ${strings.savedStreak(streak)}'),
                      ],
                    ),
                    style: const TextStyle(fontSize: 15, height: 22 / 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: tint.fill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        mood.assetPath,
                        width: 52,
                        height: 52,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isToday ? strings.todayYouFeel : strings.pastYouFelt,
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: palette.textSecondary,
                          ),
                        ),
                        Text(
                          strings.moodName(mood.id),
                          style: const TextStyle(
                            fontSize: 22,
                            height: 28 / 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          moodCategoryName(strings, mood.category),
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                note.isEmpty ? strings.noNoteYet : note,
                style: TextStyle(
                  fontSize: 15,
                  height: 22 / 15,
                  color: note.isEmpty ? palette.textSecondary : palette.text,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: strings.editEntryButton,
                  onTap: () => setState(() => _editing = true),
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _editing = true),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: palette.ink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: palette.text),
                          const SizedBox(width: 8),
                          Text(
                            strings.editEntryButton,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isToday && !yesterdayLogged) ...[
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label:
                '${strings.forgotYesterdayPrefix} ${strings.forgotYesterdayAction}',
            onTap: _logYesterday,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _logYesterday,
              child: GlassCard(
                radius: 999,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${strings.forgotYesterdayPrefix} '),
                            TextSpan(
                              text: strings.forgotYesterdayAction,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 15, height: 22 / 15),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: palette.text),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotePill extends StatelessWidget {
  const _NotePill({
    required this.text,
    required this.hasNote,
    required this.onTap,
  });

  final String text;
  final bool hasNote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final strings = AppStrings.of(context);

    return Semantics(
      button: true,
      label: hasNote ? '$text. ${strings.noteExistsSemantics}' : text,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: GlassCard(
            radius: 999,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: palette.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: hasNote ? palette.text : palette.textSecondary,
                    ),
                  ),
                ),
                if (hasNote) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, size: 18, color: palette.ink),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
