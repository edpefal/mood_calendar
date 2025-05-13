import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mood_cubit.dart';
import '../../domain/entities/mood_entry.dart';
import 'mood_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Calendar')),
      body: BlocBuilder<MoodCubit, MoodState>(
        builder: (context, state) {
          final now = DateTime.now();
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

          // Build the grid
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _CalendarHeader(month: now.month, year: now.year),
                const SizedBox(height: 8),
                _WeekDaysRow(),
                const SizedBox(height: 8),
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
                      final key = _dateKey(date);
                      final emoji = moodMap[key];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MoodScreen(selectedDate: date),
                            ),
                          ).then((_) {
                            // Refresh moods after returning
                            context.read<MoodCubit>().fetchAll();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: emoji != null
                                ? Colors.blue[50]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: emoji != null
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (emoji != null)
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 20),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MoodScreen(),
            ),
          ).then((_) {
            context.read<MoodCubit>().fetchAll();
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Register today\'s mood',
      ),
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _CalendarHeader extends StatelessWidget {
  final int month;
  final int year;
  const _CalendarHeader({required this.month, required this.year});

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
    return Text(
      '${months[month]} $year',
      style: Theme.of(context).textTheme.titleLarge,
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
