import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/settings/domain/entities/app_theme_preference.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isLoading = true,
    this.remindersEnabled = false,
    this.usageAnalyticsEnabled = true,
    this.themePreference = AppThemePreference.system,
    this.noteLockEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 18, minute: 0),
    this.appVersion = '',
    this.saveFailureCount = 0,
    this.notificationDeniedCount = 0,
  });

  final bool isLoading;
  final bool remindersEnabled;
  final bool usageAnalyticsEnabled;
  final AppThemePreference themePreference;
  final bool noteLockEnabled;
  final TimeOfDay reminderTime;
  final String appVersion;

  /// Incremented each time a change could not be saved, so the UI can react
  /// to every failure (including consecutive ones) with a listener.
  final int saveFailureCount;

  /// Incremented each time turning the reminder on was refused by the OS
  /// notification permission, so the UI can explain it.
  final int notificationDeniedCount;

  SettingsState copyWith({
    bool? isLoading,
    bool? remindersEnabled,
    bool? usageAnalyticsEnabled,
    AppThemePreference? themePreference,
    bool? noteLockEnabled,
    TimeOfDay? reminderTime,
    String? appVersion,
    int? saveFailureCount,
    int? notificationDeniedCount,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      usageAnalyticsEnabled:
          usageAnalyticsEnabled ?? this.usageAnalyticsEnabled,
      themePreference: themePreference ?? this.themePreference,
      noteLockEnabled: noteLockEnabled ?? this.noteLockEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      appVersion: appVersion ?? this.appVersion,
      saveFailureCount: saveFailureCount ?? this.saveFailureCount,
      notificationDeniedCount:
          notificationDeniedCount ?? this.notificationDeniedCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        remindersEnabled,
        usageAnalyticsEnabled,
        themePreference,
        noteLockEnabled,
        reminderTime,
        appVersion,
        saveFailureCount,
        notificationDeniedCount,
      ];
}
