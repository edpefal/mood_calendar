import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/localization/app_strings_de.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/localization/app_strings_es.dart';
import 'package:mood_calendar/core/localization/app_strings_fr.dart';
import 'package:mood_calendar/core/localization/app_strings_it.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';

void main() {
  group('AppStrings.forLocale', () {
    test('returns the matching language for each supported locale', () {
      expect(AppStrings.forLocale(const Locale('en')), isA<AppStringsEn>());
      expect(AppStrings.forLocale(const Locale('es')), isA<AppStringsEs>());
      expect(AppStrings.forLocale(const Locale('de')), isA<AppStringsDe>());
      expect(AppStrings.forLocale(const Locale('fr')), isA<AppStringsFr>());
      expect(AppStrings.forLocale(const Locale('it')), isA<AppStringsIt>());
    });

    test('falls back to English for unsupported locales', () {
      expect(AppStrings.forLocale(const Locale('pt')), isA<AppStringsEn>());
      expect(AppStrings.forLocale(const Locale('ja')), isA<AppStringsEn>());
    });
  });

  group('bottom bar tab labels', () {
    test('every tab has a distinct non-empty label in every language', () {
      for (final locale in AppStrings.supportedLocales) {
        final strings = AppStrings.forLocale(locale);
        final labels = [
          strings.openMoodPickerTooltip,
          strings.openCalendarTooltip,
          strings.openStoreTooltip,
          strings.openSettingsTooltip,
        ];
        expect(strings.calendarTitle, isNotEmpty, reason: locale.languageCode);
        expect(labels, everyElement(isNotEmpty), reason: locale.languageCode);
        expect(labels.toSet(), hasLength(labels.length),
            reason: locale.languageCode);
      }
    });
  });

  group('AppStrings.moodName', () {
    test('every mood has a non-empty name in every supported language', () {
      for (final locale in AppStrings.supportedLocales) {
        final strings = AppStrings.forLocale(locale);
        for (final mood in allMoodDefinitions) {
          expect(
            strings.moodNames[mood.id],
            isNotNull,
            reason: '${mood.id} missing in ${locale.languageCode}',
          );
          expect(strings.moodName(mood.id), isNotEmpty);
        }
      }
    });

    test('returns the localized name', () {
      expect(
          AppStrings.forLocale(const Locale('es')).moodName('happy'), 'Feliz');
      expect(
          AppStrings.forLocale(const Locale('de')).moodName('brave'), 'Mutig');
    });

    test('falls back to English and then to the id for unknown moods', () {
      expect(
          AppStrings.forLocale(const Locale('pt')).moodName('happy'), 'Happy');
      expect(AppStrings.forLocale(const Locale('es')).moodName('unknown'),
          'unknown');
    });
  });
}
