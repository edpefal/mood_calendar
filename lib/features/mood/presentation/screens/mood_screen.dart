import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../domain/entities/mood_entry.dart';
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
  MoodOption selectedMood = moods.first;
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
        : moods.indexWhere((mood) => mood.animationPath == entry.mood);
    final targetPage = moodIndex >= 0 ? moodIndex : 0;

    if (!mounted) {
      return;
    }

    setState(() {
      selectedMood = moods[targetPage];
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
      selectedMood = moods[index];
    });
  }

  void _saveMood() {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    final moodEntry = MoodEntry(
      date: _selectedDate,
      mood: selectedMood.animationPath,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      intensity: _currentPage + 1,
    );
    context.read<MoodCubit>().save(moodEntry);
  }

  LinearGradient _backgroundGradientForMood(MoodOption mood) {
    switch (mood.animationPath) {
      case 'assets/icon/happy.svg':
        return const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'assets/icon/calm.svg':
        return const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'assets/icon/neutral.svg':
        return const LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'assets/icon/sad.svg':
        return const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'assets/icon/angry.svg':
        return const LinearGradient(
          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocConsumer<MoodCubit, MoodState>(
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
      builder: (context, state) {
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
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: _backgroundGradientForMood(selectedMood),
            ),
            child: SafeArea(
              child: SizedBox.expand(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header y pregunta
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(_selectedDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                tooltip: strings.openCalendarTooltip,
                                icon: const Icon(Icons.calendar_today,
                                    color: Color(0xFF5F3DC4)),
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
                      // Animación y label
                      Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: Semantics(
                              label: strings.selectedMood(
                                selectedMood.label,
                                _currentPage,
                                moods.length,
                              ),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: moods.length,
                                onPageChanged: _onPageChanged,
                                itemBuilder: (context, index) {
                                  final mood = moods[index];
                                  return Semantics(
                                    label: strings.selectedMood(
                                      mood.label,
                                      index,
                                      moods.length,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          mood.animationPath,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.contain,
                                          semanticsLabel: mood.label,
                                          placeholderBuilder: (context) =>
                                              const CircularProgressIndicator(),
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.error_outline,
                                              size: 150,
                                              color: Colors.red,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          mood.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
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
                              moods.length,
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
                      // Nota y botón
                      Column(
                        children: [
                          // TextField(
                          //   controller: _noteController,
                          //   maxLines: 3,
                          //   decoration: InputDecoration(
                          //     hintText: 'Write a note...',
                          //     filled: true,
                          //     fillColor: Colors.white,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //       borderSide: BorderSide.none,
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //         horizontal: 16, vertical: 12),
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          AbsorbPointer(
                            absorbing: _isSaving,
                            child: Semantics(
                              button: true,
                              enabled: !_isSaving,
                              label: strings.saveMoodButtonLabel,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minHeight: 56),
                                child: GestureDetector(
                                  onTap: _saveMood,
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
                                          Color(0xFF6C63FF)
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              strings.save,
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
                          if (_isSaving) ...[
                            const SizedBox(height: 12),
                            Text(
                              strings.savingMood,
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
    );
  }

  String _formatDate(DateTime date) {
    final months = AppStrings.spanish.monthNames;
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class MoodOption {
  final String animationPath;
  final String label;
  final Color color;

  const MoodOption({
    required this.animationPath,
    required this.label,
    required this.color,
  });
}

const List<MoodOption> moods = [
  MoodOption(
    animationPath: 'assets/icon/happy.svg',
    label: 'Feliz',
    color: Colors.green,
  ),
  MoodOption(
    animationPath: 'assets/icon/calm.svg',
    label: 'Calma',
    color: Colors.blue,
  ),
  MoodOption(
    animationPath: 'assets/icon/neutral.svg',
    label: 'Neutral',
    color: Colors.grey,
  ),
  MoodOption(
    animationPath: 'assets/icon/sad.svg',
    label: 'Triste',
    color: Colors.orange,
  ),
  MoodOption(
    animationPath: 'assets/icon/angry.svg',
    label: 'Enojado',
    color: Colors.red,
  ),
];
