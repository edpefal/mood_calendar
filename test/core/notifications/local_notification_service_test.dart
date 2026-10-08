import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings_de.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/localization/app_strings_es.dart';
import 'package:mood_calendar/core/localization/app_strings_fr.dart';
import 'package:mood_calendar/core/localization/app_strings_it.dart';
import 'package:mood_calendar/core/notifications/local_notification_service.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';

void main() {
  LocalNotificationService serviceFor(Locale locale) =>
      LocalNotificationService(
        onReminderTap: () async {},
        appSettingsRepository: _UnusedSettingsRepository(),
        telemetry: _UnusedTelemetry(),
        localeResolver: () => locale,
      );

  test('uses the device language for notification strings', () {
    expect(serviceFor(const Locale('en')).strings, isA<AppStringsEn>());
    expect(serviceFor(const Locale('es')).strings, isA<AppStringsEs>());
    expect(serviceFor(const Locale('de')).strings, isA<AppStringsDe>());
    expect(serviceFor(const Locale('fr')).strings, isA<AppStringsFr>());
    expect(serviceFor(const Locale('it')).strings, isA<AppStringsIt>());
  });

  test('falls back to English for unsupported device languages', () {
    expect(serviceFor(const Locale('pt')).strings, isA<AppStringsEn>());
  });

  test('follows the locale at each use, not at construction', () {
    var locale = const Locale('de');
    final service = LocalNotificationService(
      onReminderTap: () async {},
      appSettingsRepository: _UnusedSettingsRepository(),
      telemetry: _UnusedTelemetry(),
      localeResolver: () => locale,
    );
    expect(service.strings, isA<AppStringsDe>());
    locale = const Locale('fr');
    expect(service.strings, isA<AppStringsFr>());
  });
}

class _UnusedSettingsRepository implements AppSettingsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedTelemetry implements AppTelemetry {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
