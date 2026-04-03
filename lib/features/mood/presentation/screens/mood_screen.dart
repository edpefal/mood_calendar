import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../premium/presentation/bloc/premium_cubit.dart';
import '../../../premium/presentation/bloc/premium_state.dart';
import '../../../premium/presentation/widgets/locked_mood_purchase_sheet.dart';
import '../../domain/entities/mood_definition.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/mood_cubit.dart';

class MoodScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const MoodScreen({super.key, this.selectedDate});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen>
    with SingleTickerProviderStateMixin {
  MoodDefinition selectedMood = allMoodDefinitions.first;
  int _currentPage = 0;
  final TextEditingController _noteController = TextEditingController();
  bool isLoading = true;
  bool _isSaving = false;
  bool _didHydrateInitialState = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didHydrateInitialState) {
      return;
    }
    _didHydrateInitialState = true;
    _hydrateFromState(context.read<MoodCubit>().state);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  DateTime get _selectedDate {
    final date = widget.selectedDate ?? DateTime.now();
    return DateTime(date.year, date.month, date.day);
  }

  void _hydrateFromState(MoodState state) {
    state.maybeWhen(
      loaded: (entries) {
        if (!mounted) {
          return;
        }
        _isSaving = false;
        _applyMoodEntry(_findMoodEntryForDate(entries, _selectedDate));
      },
      error: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          isLoading = false;
          _isSaving = false;
        });
      },
      orElse: () {},
    );
  }

  MoodEntry? _findMoodEntryForDate(List<MoodEntry> entries, DateTime date) {
    for (final entry in entries) {
      final normalizedEntryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      if (normalizedEntryDate == date) {
        return entry;
      }
    }
    return null;
  }

  void _applyMoodEntry(MoodEntry? entry) {
    final moodIndex = entry == null
        ? 0
        : allMoodDefinitions.indexWhere((mood) => mood.assetPath == entry.mood);
    final targetPage = moodIndex >= 0 ? moodIndex : 0;

    if (!mounted) {
      return;
    }

    setState(() {
      selectedMood = allMoodDefinitions[targetPage];
      _currentPage = targetPage;
      _noteController.text = entry?.note ?? '';
      isLoading = false;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(targetPage);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      selectedMood = allMoodDefinitions[index];
    });
  }

  bool _isOwned(PremiumState premiumState, MoodDefinition mood) {
    return premiumState.isOwned(mood);
  }

  Future<void> _showPurchaseSheet(MoodDefinition mood) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => LockedMoodPurchaseSheet(mood: mood),
    );
  }

  void _saveMood(PremiumState premiumState) {
    if (_isSaving) {
      return;
    }
    if (!_isOwned(premiumState, selectedMood)) {
      _showPurchaseSheet(selectedMood);
      return;
    }
    setState(() {
      _isSaving = true;
    });
    final moodEntry = MoodEntry(
      date: _selectedDate,
      mood: selectedMood.assetPath,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      intensity: selectedMood.intensity,
    );
    context.read<MoodCubit>().save(moodEntry);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<MoodCubit, MoodState>(
          listener: (context, state) {
            _hydrateFromState(state);
            state.maybeWhen(
              loading: () {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _isSaving = !isLoading;
                });
              },
              saved: () {
                final normalizedDate = _selectedDate;
                context.read<MoodCubit>().fetchAll();
                if (context.mounted) {
                  context.read<CalendarCubit>().refreshForDate(normalizedDate);
                }
                AppNavigator.popOrShowCalendar(
                  context,
                  recentlySavedDate: normalizedDate,
                );
              },
              error: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.saveMoodError),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              orElse: () {},
            );
          },
        ),
        BlocListener<PremiumCubit, PremiumState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ],
      child: BlocBuilder<PremiumCubit, PremiumState>(
        builder: (context, premiumState) {
          if (isLoading) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        strings.moodLoading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final selectedProduct = premiumState.productForMood(selectedMood.id);
          final isLocked = !_isOwned(premiumState, selectedMood);
          final isBusy = _isSaving || premiumState.isLoading;
          final primaryButtonLabel = isLocked
              ? 'Unlock ${selectedMood.label}${selectedProduct != null ? ' • ${selectedProduct.price}' : ''}'
              : strings.save;

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: MoodDefinitionResolver.backgroundGradientForMood(
                    selectedMood),
              ),
              child: SafeArea(
                child: SizedBox.expand(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDate(_selectedDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: isBusy
                                      ? null
                                      : () => context
                                          .read<PremiumCubit>()
                                          .restorePurchases(),
                                  child: const Text('Restore'),
                                ),
                                IconButton(
                                  tooltip: strings.openCalendarTooltip,
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF5F3DC4),
                                  ),
                                  onPressed: () {
                                    AppNavigator.popOrShowCalendar(context);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.moodQuestion,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5F3DC4),
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 260,
                              child: Semantics(
                                label: strings.selectedMood(
                                  selectedMood.label,
                                  _currentPage,
                                  allMoodDefinitions.length,
                                ),
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: allMoodDefinitions.length,
                                  onPageChanged: _onPageChanged,
                                  itemBuilder: (context, index) {
                                    final mood = allMoodDefinitions[index];
                                    final locked =
                                        !_isOwned(premiumState, mood);
                                    final product =
                                        premiumState.productForMood(mood.id);

                                    return GestureDetector(
                                      onTap: locked
                                          ? () => _showPurchaseSheet(mood)
                                          : null,
                                      child: Semantics(
                                        label: strings.selectedMood(
                                          mood.label,
                                          index,
                                          allMoodDefinitions.length,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Opacity(
                                                  opacity: locked ? 0.45 : 1,
                                                  child: SvgPicture.asset(
                                                    mood.assetPath,
                                                    height: 150,
                                                    width: 150,
                                                    fit: BoxFit.contain,
                                                    semanticsLabel: mood.label,
                                                    placeholderBuilder: (context) =>
                                                        const CircularProgressIndicator(),
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.error_outline,
                                                        size: 150,
                                                        color: Colors.red,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                if (locked)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black87,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        20,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      product?.price ??
                                                          '\$0.99',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              mood.label,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            if (locked)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.lock, size: 14),
                                                    SizedBox(width: 6),
                                                    Text('Tap to unlock'),
                                                  ],
                                                ),
                                              )
                                            else if (mood.isPremium)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: const Text('Unlocked'),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                allMoodDefinitions.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? const Color(0xFF5F3DC4)
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            TextField(
                              controller: _noteController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Write a note...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AbsorbPointer(
                              absorbing: isBusy,
                              child: Semantics(
                                button: true,
                                enabled: !isBusy,
                                label: strings.saveMoodButtonLabel,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minHeight: 56),
                                  child: GestureDetector(
                                    onTap: () => _saveMood(premiumState),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF5F3DC4),
                                            Color(0xFF6C63FF),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: isBusy
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                primaryButtonLabel,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isBusy) ...[
                              const SizedBox(height: 12),
                              Text(
                                _isSaving
                                    ? strings.savingMood
                                    : 'Processing...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = AppStrings.spanish.monthNames;
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
