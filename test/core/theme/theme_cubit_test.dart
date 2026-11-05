import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_theme_preference.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/theme/theme_cubit.dart';

class _Repo implements AppSettingsRepository {
  _Repo(this.settings, {this.fails = false});
  AppSettings settings;
  final bool fails;

  @override
  Future<AppSettings> getSettings() async {
    if (fails) throw StateError('boom');
    return settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    this.settings = settings;
  }
}

void main() {
  test('starts on the system theme', () {
    final cubit = ThemeCubit();

    expect(cubit.state, AppThemePreference.system);
    expect(cubit.themeMode, ThemeMode.system);
  });

  test('loads the saved preference', () async {
    final cubit = ThemeCubit();

    await cubit.load(_Repo(
      AppSettings.defaults.copyWith(themePreference: AppThemePreference.dark),
    ));

    expect(cubit.state, AppThemePreference.dark);
    expect(cubit.themeMode, ThemeMode.dark);
  });

  test('keeps the system theme when settings cannot be read', () async {
    final cubit = ThemeCubit();

    await cubit.load(_Repo(AppSettings.defaults, fails: true));

    expect(cubit.state, AppThemePreference.system);
  });

  test('applies a new preference right away', () {
    final cubit = ThemeCubit()..apply(AppThemePreference.light);

    expect(cubit.themeMode, ThemeMode.light);
  });
}
