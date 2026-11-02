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
  group('AppStrings.formatFullDate', () {
    final date = DateTime(2026, 10, 10);

    test('follows the order and capitalization of each language', () {
      expect(const AppStringsEn().formatFullDate(date), 'October 10, 2026');
      expect(
          const AppStringsEs().formatFullDate(date), '10 de octubre de 2026');
      expect(const AppStringsDe().formatFullDate(date), '10. Oktober 2026');
      expect(const AppStringsFr().formatFullDate(date), '10 octobre 2026');
      expect(const AppStringsIt().formatFullDate(date), '10 ottobre 2026');
    });

    test('does not pad the day with a leading zero', () {
      final firstOfMarch = DateTime(2026, 3, 1);
      expect(
          const AppStringsEn().formatFullDate(firstOfMarch), 'March 1, 2026');
      expect(const AppStringsEs().formatFullDate(firstOfMarch),
          '1 de marzo de 2026');
      expect(const AppStringsDe().formatFullDate(firstOfMarch), '1. März 2026');
      expect(const AppStringsFr().formatFullDate(firstOfMarch), '1 mars 2026');
      expect(const AppStringsIt().formatFullDate(firstOfMarch), '1 marzo 2026');
    });

    test('falls back to the English format for unsupported locales', () {
      expect(
        AppStrings.forLocale(const Locale('pt')).formatFullDate(date),
        'October 10, 2026',
      );
    });
  });

  group('AppStrings mood grid', () {
    test('every language defines the button label and sheet title', () {
      for (final strings in const <AppStrings>[
        AppStringsEn(),
        AppStringsEs(),
        AppStringsDe(),
        AppStringsFr(),
        AppStringsIt(),
      ]) {
        expect(strings.moodGridButtonLabel, isNotEmpty);
        expect(strings.moodGridTitle, isNotEmpty);
        expect(strings.previousMoodLabel, isNotEmpty);
        expect(strings.nextMoodLabel, isNotEmpty);
      }
    });
  });

  group('AppStrings.storeRetry', () {
    test('has a translation for every supported language', () {
      expect(const AppStringsEn().storeRetry, 'Try again');
      expect(const AppStringsEs().storeRetry, 'Reintentar');
      expect(const AppStringsDe().storeRetry, 'Erneut versuchen');
      expect(const AppStringsFr().storeRetry, 'Réessayer');
      expect(const AppStringsIt().storeRetry, 'Riprova');
    });
  });

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
          strings.openPremiumTooltip,
          strings.openSettingsTooltip,
        ];
        expect(strings.calendarTitle, isNotEmpty, reason: locale.languageCode);
        expect(labels, everyElement(isNotEmpty), reason: locale.languageCode);
        expect(labels.toSet(), hasLength(labels.length),
            reason: locale.languageCode);
      }
    });
  });

  group('Premium subscription strings', () {
    test('every language has all of them, with the price and period filled in',
        () {
      for (final locale in AppStrings.supportedLocales) {
        final strings = AppStrings.forLocale(locale);
        final reason = locale.languageCode;
        final labels = [
          strings.premiumTitle,
          strings.premiumHeadline,
          strings.premiumSubheadline,
          strings.premiumMoodsTitle,
          strings.weeklyPlanLabel,
          strings.monthlyPlanLabel,
          strings.annualPlanLabel,
          strings.weekUnit,
          strings.monthUnit,
          strings.yearUnit,
          strings.bestValueLabel,
          strings.startTrialButtonLabel,
          strings.termsLinkLabel,
          strings.privacyLinkLabel,
          strings.premiumActiveTitle,
          strings.manageSubscriptionButtonLabel,
          strings.closeLabel,
        ];
        expect(labels, everyElement(isNotEmpty), reason: reason);
        expect(
          {
            strings.weeklyPlanLabel,
            strings.monthlyPlanLabel,
            strings.annualPlanLabel
          },
          hasLength(3),
          reason: reason,
        );
        expect(strings.savePercentLabel(58), contains('58'), reason: reason);
        expect(strings.subscribeButtonLabel(r'$14.99'), contains(r'$14.99'),
            reason: reason);
        for (final legal in [
          strings.subscriptionLegalTrial(
              r'$14.99', strings.yearUnit, 'App Store'),
          strings.subscriptionLegalPaid(
              r'$14.99', strings.yearUnit, 'App Store'),
        ]) {
          expect(legal, contains(r'$14.99'), reason: reason);
          expect(legal, contains(strings.yearUnit), reason: reason);
          expect(legal, contains('App Store'), reason: reason);
          expect(legal, contains('24'), reason: reason);
        }
        expect(strings.subscriptionLegalTrial('1', 'x', 's'), contains('3'),
            reason: reason);
        expect(strings.premiumRenewsOn('D'), contains('D'), reason: reason);
        expect(strings.premiumTrialEndsOn('D'), contains('D'), reason: reason);
        expect(strings.premiumEndsOn('D'), contains('D'), reason: reason);
        expect(strings.premiumPlanLine('P'), contains('P'), reason: reason);
        expect(strings.planCardSemanticLabel('P', 'L'),
            allOf(contains('P'), contains('L')),
            reason: reason);
      }
    });

    test('the legal text without a trial never mentions it', () {
      final strings = AppStrings.forLocale(const Locale('en'));

      expect(strings.subscriptionLegalPaid(r'$2.99', 'month', 'Google Play'),
          isNot(contains('free')));
      expect(strings.subscriptionLegalTrial(r'$2.99', 'month', 'Google Play'),
          contains('Free for 3 days'));
    });

    test('plan price lines combine price and period', () {
      expect(
          AppStrings.forLocale(const Locale('en'))
              .planPriceLine(r'$14.99', 'year'),
          r'$14.99 / year');
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
