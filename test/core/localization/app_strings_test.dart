import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/localization/app_strings_de.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/localization/app_strings_es.dart';
import 'package:mood_calendar/core/localization/app_strings_fr.dart';
import 'package:mood_calendar/core/localization/app_strings_it.dart';

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
}
