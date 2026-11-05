import 'package:flutter/material.dart';

/// Formats [time] with the device's 12 or 24 hour setting and language.
String formatLoggedTime(BuildContext context, DateTime time) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(time),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
}
