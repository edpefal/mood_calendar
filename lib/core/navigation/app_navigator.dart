import 'package:flutter/material.dart';

import '../../features/mood/presentation/screens/calendar_screen.dart';
import '../../features/mood/presentation/screens/mood_screen.dart';

class AppNavigator {
  const AppNavigator._();

  static MaterialPageRoute<T> _route<T>(WidgetBuilder builder) {
    return MaterialPageRoute<T>(builder: builder);
  }

  static Future<DateTime?> pushMoodScreen(
    BuildContext context, {
    required DateTime selectedDate,
  }) {
    return Navigator.of(context).push<DateTime>(
      _route((_) => MoodScreen(selectedDate: selectedDate)),
    );
  }

  static void openMoodFromReminder(
    NavigatorState navigator, {
    required DateTime selectedDate,
  }) {
    navigator.pushAndRemoveUntil(
      _route((_) => MoodScreen(selectedDate: selectedDate)),
      (route) => false,
    );
  }

  static void popOrShowCalendar(
    BuildContext context, {
    DateTime? recentlySavedDate,
  }) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, recentlySavedDate);
      return;
    }

    Navigator.of(context).pushReplacement<void, DateTime?>(
      _route(
        (_) => CalendarScreen(recentlySavedDate: recentlySavedDate),
      ),
    );
  }
}
