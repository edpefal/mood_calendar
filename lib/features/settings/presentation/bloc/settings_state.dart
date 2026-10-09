import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoading = true,
    this.remindersEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 18, minute: 0),
    this.appVersion = '',
    this.saveFailureCount = 0,
  });

  final bool isLoading;
  final bool remindersEnabled;
  final TimeOfDay reminderTime;
  final String appVersion;

  /// Incremented each time a change could not be saved, so the UI can react
  /// to every failure (including consecutive ones) with a listener.
  final int saveFailureCount;

  SettingsState copyWith({
    bool? isLoading,
    bool? remindersEnabled,
    TimeOfDay? reminderTime,
    String? appVersion,
    int? saveFailureCount,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      appVersion: appVersion ?? this.appVersion,
      saveFailureCount: saveFailureCount ?? this.saveFailureCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        remindersEnabled,
        reminderTime,
        appVersion,
        saveFailureCount,
      ];
}
