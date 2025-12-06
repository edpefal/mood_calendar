import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mood_calendar/features/ads/ad_service.dart';
import '../bloc/mood_cubit.dart';
import '../../domain/entities/mood_entry.dart';
import 'mood_screen.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? recentlySavedDate;

  const CalendarScreen({super.key, this.recentlySavedDate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late final AdService _adService;
  late AnimationController _animationController;
  DateTime? _recentlySavedDate;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _adService = AdService();
    _adService.loadInterstitialAd();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _recentlySavedDate = widget.recentlySavedDate;
    // Cargar los estados de ánimo guardados cuando se abre la pantalla
    context.read<MoodCubit>().fetchAll();
    // Iniciar animación si hay una fecha recién guardada
    if (_recentlySavedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!mounted) return;
    _animationController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _recentlySavedDate = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<MoodCubit, MoodState>(
          builder: (context, state) {
            final now = _focusedDay;
            final today = DateTime.now();
            final canGoNext = now.year < today.year ||
                (now.year == today.year && now.month < today.month);
            final firstDayOfMonth = DateTime(now.year, now.month, 1);
            final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
            final daysInMonth = lastDayOfMonth.day;
            final firstWeekday = firstDayOfMonth.weekday;

            // Get moods for the current month
            List<MoodEntry> moods = [];
            state.maybeWhen(
              loaded: (list) => moods = list,
              orElse: () {},
            );

            // Map date string (yyyy-MM-dd) to mood emoji
            final moodMap = <String, String>{};
            for (final mood in moods) {
              final key = _dateKey(mood.date);
              moodMap[key] = mood.mood;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _CalendarHeader(
                    month: now.month,
                    year: now.year,
                    onPreviousMonth: _onPreviousMonth,
                    onNextMonth: canGoNext ? _onNextMonth : null,
                  ),
                  const SizedBox(height: 4),
                  _WeekDaysRow(),
                  const SizedBox(height: 4),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: daysInMonth + (firstWeekday - 1),
                      itemBuilder: (context, index) {
                        if (index < firstWeekday - 1) {
                          return const SizedBox.shrink();
                        }
                        final day = index - (firstWeekday - 2);
                        final date = DateTime(now.year, now.month, day);
                        final isFutureDate = date.year > today.year ||
                            (date.year == today.year &&
                                date.month > today.month) ||
                            (date.year == today.year &&
                                date.month == today.month &&
                                date.day > today.day);
                        final key = _dateKey(date);
                        final emoji = moodMap[key];
                        final isRecentlySaved = _recentlySavedDate != null &&
                            _dateKey(_recentlySavedDate!) == key;
                        return GestureDetector(
                          onTap: isFutureDate
                              ? null
                              : () async {
                                  final result = await Navigator.push<DateTime>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MoodScreen(selectedDate: date),
                                    ),
                                  );
                                  // Refresh moods after returning
                                  context.read<MoodCubit>().fetchAll();
                                  // Si se guardó un mood, animar el icono
                                  if (result != null && mounted) {
                                    setState(() {
                                      _recentlySavedDate = result;
                                    });
                                    _startAnimation();
                                  }
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isFutureDate
                                  ? Colors.grey[100]
                                  : emoji != null
                                      ? Colors.blue[50]
                                      : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFutureDate
                                    ? Colors.grey[200]!
                                    : emoji != null
                                        ? Colors.blue
                                        : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$day',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isFutureDate
                                          ? Colors.grey[400]
                                          : null,
                                    ),
                                  ),
                                  if (emoji != null)
                                    _AnimatedMoodIcon(
                                      animation: _animationController,
                                      isAnimated: isRecentlySaved,
                                      emojiPath: emoji,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _onNextMonth() {
    final today = DateTime.now();
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    if (nextMonth.year > today.year ||
        (nextMonth.year == today.year && nextMonth.month > today.month)) {
      return;
    }
    setState(() {
      _focusedDay = nextMonth;
    });
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _CalendarHeader extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPreviousMonth;
  final VoidCallback? onNextMonth;

  const _CalendarHeader({
    required this.month,
    required this.year,
    required this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: onPreviousMonth,
        ),
        Text(
          '${months[month]} $year',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _AnimatedMoodIcon extends StatelessWidget {
  final Animation<double> animation;
  final bool isAnimated;
  final String emojiPath;

  const _AnimatedMoodIcon({
    required this.animation,
    required this.isAnimated,
    required this.emojiPath,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = isAnimated ? 1.0 + (animation.value * 0.9) : 1.0;
        final rotation = isAnimated ? (animation.value * 0.2) : 0.0;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: SvgPicture.asset(
              emojiPath,
              height: 22,
              width: 22,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error_outline,
                  size: 24,
                  color: Colors.red,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
