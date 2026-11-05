import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/domain/entities/app_theme_preference.dart';
import '../settings/domain/repositories/app_settings_repository.dart';

/// Holds the theme preference at the root so `MaterialApp` rebuilds the
/// moment it changes. It does not persist: `SettingsCubit` saves the value
/// (with the rest of the settings, so no write undoes another) and reports
/// each change, and each revert, through [apply].
class ThemeCubit extends Cubit<AppThemePreference> {
  ThemeCubit([super.initial = AppThemePreference.system]);

  /// Loads the saved preference. A failure leaves [AppThemePreference.system].
  Future<void> load(AppSettingsRepository repository) async {
    try {
      final settings = await repository.getSettings();
      if (!isClosed) emit(settings.themePreference);
    } catch (_) {
      // The default is a valid theme; settings problems surface elsewhere.
    }
  }

  void apply(AppThemePreference preference) => emit(preference);

  ThemeMode get themeMode {
    switch (state) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}
