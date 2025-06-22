import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bloc/mood_cubit.dart';
import '../../domain/entities/mood_entry.dart';
import 'mood_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    // Cargar los estados de ánimo guardados cuando se abre la pantalla
    context.read<MoodCubit>().fetchAll();
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
                        return GestureDetector(
                          onTap: isFutureDate
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MoodScreen(selectedDate: date),
                                    ),
                                  ).then((_) {
                                    // Refresh moods after returning
                                    context.read<MoodCubit>().fetchAll();
                                  });
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
                                    SvgPicture.asset(
                                      emoji,
                                      height: 22,
                                      width: 22,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) =>
                                          const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading SVG: $error');
                                        return const Icon(
                                          Icons.error_outline,
                                          size: 24,
                                          color: Colors.red,
                                        );
                                      },
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
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
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
