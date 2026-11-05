import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/settings/domain/entities/app_theme_preference.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoading = true,
    this.remindersEnabled = false,
    this.usageAnalyticsEnabled = true,
    this.themePreference = AppThemePreference.system,
    this.reminderTime = const TimeOfDay(hour: 18, minute: 0),
    this.appVersion = '',
    this.saveFailureCount = 0,
  });

  final bool isLoading;
  final bool remindersEnabled;
  final bool usageAnalyticsEnabled;
  final AppThemePreference themePreference;
  final TimeOfDay reminderTime;
  final String appVersion;

  /// Incremented each time a change could not be saved, so the UI can react
  /// to every failure (including consecutive ones) with a listener.
  final int saveFailureCount;

  SettingsState copyWith({
    bool? isLoading,
    bool? remindersEnabled,
    bool? usageAnalyticsEnabled,
    AppThemePreference? themePreference,
    TimeOfDay? reminderTime,
    String? appVersion,
    int? saveFailureCount,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      usageAnalyticsEnabled:
          usageAnalyticsEnabled ?? this.usageAnalyticsEnabled,
      themePreference: themePreference ?? this.themePreference,
      reminderTime: reminderTime ?? this.reminderTime,
      appVersion: appVersion ?? this.appVersion,
      saveFailureCount: saveFailureCount ?? this.saveFailureCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        remindersEnabled,
        usageAnalyticsEnabled,
        themePreference,
        reminderTime,
        appVersion,
        saveFailureCount,
      ];
}
