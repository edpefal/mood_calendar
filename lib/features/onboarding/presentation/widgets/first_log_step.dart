import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../../../mood/presentation/widgets/mood_category_grid.dart';
import '../../../mood/presentation/widgets/note_editor_sheet.dart';
import '../cubit/onboarding_state.dart';
import 'onboarding_frame.dart';

/// Step 4: log today for real. Only the base moods are offered (nothing is
/// locked yet), none is preselected and Save waits for a pick. Once saved it
/// turns into the "Day 1 of your calendar" confirmation.
class FirstLogStep extends StatefulWidget {
  const FirstLogStep({
    super.key,
    required this.state,
    required this.onMoodPicked,
    required this.onNoteChanged,
    required this.onSave,
    required this.onContinue,
  });

  final OnboardingState state;
  final ValueChanged<MoodDefinition> onMoodPicked;
  final ValueChanged<String> onNoteChanged;
  final ValueChanged<MoodDefinition> onSave;
  final VoidCallback onContinue;

  @override
  State<FirstLogStep> createState() => _FirstLogStepState();
}

class _FirstLogStepState extends State<FirstLogStep> {
  final TextEditingController _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _note.addListener(() => widget.onNoteChanged(_note.text));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  MoodDefinition? get _selected {
    final id = widget.state.moodId;
    return id == null ? null : MoodDefinitionResolver.byId(id);
  }

  @override
  Widget build(BuildContext context) {
    return widget.state.saved
        ? _Confirmation(mood: _selected!, onContinue: widget.onContinue)
        : _buildPicker(context);
  }

  Widget _buildPicker(BuildContext context) {
    final strings = AppStrings.of(context);
    final selected = _selected;
    final note = _note.text.trim();

    return OnboardingFrame(
      step: 4,
      tint: selected == null
          ? null
          : MoodDefinitionResolver.tintFor(context, selected).fill,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingTitleCard(
            title: strings.onboardingLogTitle,
            body: strings.onboardingLogBody,
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: MoodCategoryGrid(
              onlyTier: MoodTier.base,
              selectedId: selected?.id,
              isLocked: (_) => false,
              onMoodTap: widget.onMoodPicked,
            ),
          ),
        ],
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (selected != null) ...[
            _NotePill(
              text: note.isEmpty
                  ? strings.notePromptEmpty
                  : note.split('\n').first,
              hasNote: note.isNotEmpty,
              onTap: () async {
                await showNoteEditorSheet(
                  context,
                  controller: _note,
                  mood: selected,
                );
                if (mounted) setState(() {});
              },
            ),
            const SizedBox(height: 12),
          ],
          GradientPillButton(
            label: strings.onboardingSaveFirstDay,
            loading: widget.state.saving,
            enabled: selected != null,
            onPressed: selected == null ? null : () => widget.onSave(selected),
          ),
        ],
      ),
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
                Icon(Icons.edit_outlined,
                    size: 18, color: palette.textSecondary),
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

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.mood, required this.onContinue});

  final MoodDefinition mood;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return OnboardingFrame(
      step: 4,
      tint: MoodDefinitionResolver.tintFor(context, mood).fill,
      body: Semantics(
        liveRegion: true,
        child: Column(
          children: [
            const SizedBox(height: 32),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: palette.logLinearGradient,
              ),
              child: Center(
                child: SvgPicture.asset(
                  mood.assetPath,
                  width: 84,
                  height: 84,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            const SizedBox(height: 28),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Column(
                children: [
                  Text(
                    strings.onboardingDayOneTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.onboardingDayOneToday(strings.moodName(mood.id)),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 22 / 15,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: GradientPillButton(
        label: strings.continueLabel,
        onPressed: onContinue,
      ),
    );
  }
}
