import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_theme_preference.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/theme/app_theme.dart';
import 'package:mood_calendar/core/theme/theme_cubit.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_history_export_result.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_history_exporter.dart';
import 'package:mood_calendar/features/mood/domain/usecases/export_mood_history_usecase.dart';
import 'package:mood_calendar/features/note_lock/presentation/bloc/note_lock_cubit.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_status.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/fake_analytics_reporter.dart';
import '../../../../support/fake_mood_entitlements_repository.dart';
import '../../../../support/fake_note_lock_authenticator.dart';

void main() {
  late _FakeSettingsRepository repository;
  late FakeRatingPromptService ratingPromptService;
  late List<String> notificationCalls;
  late List<Uri> openedUrls;
  late Future<bool> Function(Uri) openUrl;
  late _FakeHistoryExporter exporter;
  late List<String> sharedFiles;
  late FakeAnalyticsReporter analytics;
  late ThemeCubit themeCubit;
  late FakeMoodEntitlementsRepository entitlements;
  late RecordingTelemetry telemetry;
  late FakeNoteLockAuthenticator authenticator;
  late NoteLockCubit noteLockCubit;
  late bool notificationPermission;

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    String version = '1.8.3 (28)',
  }) async {
    // Tall enough for every row, including the version at the bottom.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
          RepositoryProvider<ExportMoodHistoryUseCase>.value(
            value: ExportMoodHistoryUseCase(exporter),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeCubit),
            BlocProvider.value(value: noteLockCubit),
            BlocProvider(
              lazy: false,
              create: (_) => PurchasesCubit(entitlements, telemetry: telemetry),
            ),
            BlocProvider(
              create: (_) => SettingsCubit(
                settingsRepository: repository,
                scheduleReminder: () async => notificationCalls.add('schedule'),
                cancelReminder: () async => notificationCalls.add('cancel'),
                loadAppVersion: () async => version,
                logger: const _SilentLogger(),
                setUsageAnalyticsCollection: analytics.setCollectionEnabled,
                onThemeChanged: themeCubit.apply,
                requestNotificationPermission: () async =>
                    notificationPermission,
                onNoteLockChanged: noteLockCubit.setEnabled,
              )..load(),
            ),
          ],
          child: BlocBuilder<ThemeCubit, AppThemePreference>(
            builder: (context, _) => MaterialApp(
              locale: locale,
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: themeCubit.themeMode,
              home: SettingsScreen(
                openUrl: (url) => openUrl(url),
                shareFile: (path, origin) async => sharedFiles.add(path),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = _FakeSettingsRepository(
      const AppSettings(
        dailyReminderEnabled: true,
        dailyReminderHour: 18,
        dailyReminderMinute: 0,
      ),
    );
    ratingPromptService = FakeRatingPromptService();
    exporter = _FakeHistoryExporter();
    sharedFiles = [];
    analytics = FakeAnalyticsReporter();
    notificationCalls = [];
    openedUrls = [];
    themeCubit = ThemeCubit();
    entitlements = FakeMoodEntitlementsRepository();
    telemetry = RecordingTelemetry();
    authenticator = FakeNoteLockAuthenticator();
    notificationPermission = true;
    noteLockCubit = NoteLockCubit(
      authenticator: authenticator,
      telemetry: telemetry,
      isSubscribed: () => entitlements.currentSubscription.isActive,
    );
    openUrl = (url) async {
      openedUrls.add(url);
      return true;
    };
  });

  tearDown(() async {
    await themeCubit.close();
    await noteLockCubit.close();
  });

  /// The switch of the row titled [title].
  Finder switchOf(String title) => find.descendant(
        of: find
            .ancestor(of: find.text(title), matching: find.byType(InkWell))
            .first,
        matching: find.byType(Switch),
      );

  bool isOn(WidgetTester tester, String title) =>
      tester.widget<Switch>(switchOf(title)).value;

  group('layout', () {
    testWidgets('shows the five sections in order', (tester) async {
      await pumpScreen(tester);

      final titles = [
        'Premium',
        'Reminders',
        'Privacy and data',
        'Appearance',
        'Help',
      ];
      final tops = [
        for (final title in titles)
          tester.getTopLeft(find.text(title).first).dy,
      ];
      expect(tops, [...tops]..sort());
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('has none of the discarded rows', (tester) async {
      await pumpScreen(tester);

      for (final text in [
        'Message',
        'Language',
        'App icon',
        'iCloud',
        'Backup',
      ]) {
        expect(find.textContaining(text), findsNothing, reason: text);
      }
    });

    testWidgets('shows the saved reminder values and the app version',
        (tester) async {
      await pumpScreen(tester);

      expect(isOn(tester, 'Enable daily reminders'), isTrue);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('1.8.3 (28)'), findsOneWidget);
    });

    testWidgets('uses the device language', (tester) async {
      await pumpScreen(tester, locale: const Locale('de'));

      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('Datenschutzerklärung'), findsOneWidget);
    });

    testWidgets('falls back to English for unsupported languages',
        (tester) async {
      await pumpScreen(tester, locale: const Locale('pt'));

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });

    for (final locale in AppStrings.supportedLocales) {
      testWidgets('every title is localized (${locale.languageCode})',
          (tester) async {
        final strings = AppStrings.forLocale(locale);
        await pumpScreen(tester, locale: locale);

        for (final title in [
          strings.settingsTitle,
          strings.sectionPremium,
          strings.sectionReminders,
          strings.sectionPrivacyData,
          strings.sectionAppearance,
          strings.sectionHelp,
          strings.getPremiumTitle,
          strings.restorePurchasesButtonLabel,
          strings.reminderEnabledTitle,
          strings.exportHistoryTitle,
          strings.themeTitle,
          strings.rateAppTitle,
          strings.sendFeedbackTitle,
          strings.privacyPolicyTitle,
          strings.termsTitle,
        ]) {
          expect(find.text(title), findsWidgets,
              reason: '${locale.languageCode}: $title');
        }
      });
    }

    testWidgets('interactive rows expose semantics labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester);

      for (final label in [
        'Rate Mood Calendar on the App Store',
        'Open the privacy policy in your browser',
        'Send feedback by email',
        'Open the terms of use in the browser',
        'Restore purchases',
        'Theme, System',
        'Export your mood history as a file',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets('every row is at least 44 pt tall', (tester) async {
      await pumpScreen(tester);

      for (final inkWell in tester.widgetList<InkWell>(find.byType(InkWell))) {
        final size = tester.getSize(find.byWidget(inkWell));
        expect(size.height, greaterThanOrEqualTo(44));
      }
    });

    testWidgets('renders in the dark theme and at 200% text', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      repository.saved =
          repository.saved.copyWith(themePreference: AppThemePreference.dark);
      themeCubit.apply(AppThemePreference.dark);
      await pumpScreen(tester, locale: const Locale('de'));

      expect(tester.takeException(), isNull);
      expect(find.text('Dunkel'), findsOneWidget);
    });
  });

  group('premium', () {
    testWidgets('"Get Premium" opens the subscription sheet', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Get Premium'));
      await tester.pumpAndSettle();

      expect(find.text('Understand how you feel'), findsOneWidget);
      // From Settings there is no mood capsule, and it reports the source.
      final opened = telemetry.events.where((e) => e.name == 'store_opened');
      expect(opened.single.properties, {'source': 'settings'});
    });

    testWidgets('a subscriber sees the active state with plan and renewal',
        (tester) async {
      entitlements = FakeMoodEntitlementsRepository(
        subscription: SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.monthly,
          expiresAt: DateTime(2030, 1, 15),
          managementUrl: 'https://example.com/manage',
        ),
      );
      await pumpScreen(tester);

      expect(find.text('Premium · Active'), findsOneWidget);
      expect(find.text('Get Premium'), findsNothing);
      expect(find.textContaining('Monthly'), findsOneWidget);
      expect(find.textContaining('January 15, 2030'), findsOneWidget);
    });

    testWidgets('a subscriber in the trial sees when it ends', (tester) async {
      entitlements = FakeMoodEntitlementsRepository(
        subscription: SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.annual,
          expiresAt: DateTime(2030, 1, 15),
          isInTrial: true,
          managementUrl: 'https://example.com/manage',
        ),
      );
      await pumpScreen(tester);

      expect(find.textContaining('Free trial ends on'), findsOneWidget);
    });

    testWidgets('a subscriber tapping the row opens the store management',
        (tester) async {
      entitlements = FakeMoodEntitlementsRepository(
        subscription: const SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.annual,
          managementUrl: 'https://example.com/manage',
        ),
      );
      await pumpScreen(tester);

      await tester.tap(find.text('Premium · Active'));
      await tester.pumpAndSettle();

      expect(openedUrls, [Uri.parse('https://example.com/manage')]);
      expect(find.text('Understand how you feel'), findsNothing);
    });

    testWidgets('once the subscription ends the row offers Premium again',
        (tester) async {
      entitlements = FakeMoodEntitlementsRepository(
        subscription: const SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.annual,
          managementUrl: 'https://example.com/manage',
        ),
      );
      await pumpScreen(tester);
      expect(find.text('Premium · Active'), findsOneWidget);

      entitlements.expireSubscription();
      await tester.pumpAndSettle();

      expect(find.text('Get Premium'), findsOneWidget);
    });

    testWidgets('restore purchases runs the restore and says so',
        (tester) async {
      entitlements =
          FakeMoodEntitlementsRepository(restorableMoodIds: {'brave'});
      await pumpScreen(tester);

      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();

      expect(entitlements.restoreCount, 1);
      expect(find.text('Your purchases were restored.'), findsOneWidget);
      expect(entitlements.isUnlocked('brave'), isTrue);
    });

    testWidgets('restore stays available for a subscriber', (tester) async {
      entitlements = FakeMoodEntitlementsRepository(
        subscription: const SubscriptionStatus(
          isActive: true,
          plan: SubscriptionPlanType.annual,
        ),
      );
      await pumpScreen(tester);

      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();

      expect(entitlements.restoreCount, 1);
    });
  });

  group('reminders', () {
    testWidgets('the switch saves right away and cancels the reminder',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(switchOf('Enable daily reminders'));
      await tester.pumpAndSettle();

      expect(repository.saved.dailyReminderEnabled, isFalse);
      expect(notificationCalls, ['cancel']);
      expect(find.text('Save reminder settings'), findsNothing);
    });

    testWidgets('the time row is disabled while reminders are off',
        (tester) async {
      repository.saved = repository.saved.copyWith(dailyReminderEnabled: false);
      await pumpScreen(tester);

      await tester.tap(find.text('Reminder time'));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsNothing);
    });

    testWidgets('picking a time saves it and reschedules', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Reminder time'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(notificationCalls, ['schedule']);
      expect(repository.saved.dailyReminderHour, 18);
    });

    testWidgets('dismissing the time picker changes nothing', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Reminder time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(notificationCalls, isEmpty);
    });

    testWidgets('a failed save reverts the switch and shows a message',
        (tester) async {
      await pumpScreen(tester);
      repository.failSaves = true;

      await tester.tap(switchOf('Enable daily reminders'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Enable daily reminders'), isTrue);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('theme', () {
    testWidgets('starts on System', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('choosing Dark applies it at once and saves it',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeCubit.state, AppThemePreference.dark);
      expect(themeCubit.themeMode, ThemeMode.dark);
      expect(repository.saved.themePreference, AppThemePreference.dark);
      expect(find.text('Dark'), findsOneWidget);
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });

    testWidgets('choosing Light after Dark applies Light', (tester) async {
      repository.saved =
          repository.saved.copyWith(themePreference: AppThemePreference.dark);
      themeCubit.apply(AppThemePreference.dark);
      await pumpScreen(tester);
      expect(find.text('Dark'), findsOneWidget);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(themeCubit.themeMode, ThemeMode.light);
      expect(repository.saved.themePreference, AppThemePreference.light);
    });

    testWidgets('a failed save reverts the theme and shows a message',
        (tester) async {
      await pumpScreen(tester);
      repository.failSaves = true;

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeCubit.state, AppThemePreference.system);
      expect(repository.saved.themePreference, AppThemePreference.system);
      expect(find.text('System'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('a theme change does not touch the reminder', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(notificationCalls, isEmpty);
      expect(repository.saved.dailyReminderEnabled, isTrue);
    });
  });

  group('help', () {
    testWidgets('rate row opens the store listing', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Rate Mood Calendar'));
      await tester.pumpAndSettle();

      expect(ratingPromptService.openStoreListingCalls, 1);
    });

    testWidgets('feedback opens an email to support', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(openedUrls.single.scheme, 'mailto');
      expect(openedUrls.single.path, 'support@moodcalendar.app');
    });

    testWidgets('terms open the English page by default', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();

      expect(openedUrls, [Uri.parse('https://moodcalendar.app/terms/')]);
    });

    testWidgets('terms open the Spanish page on a Spanish device',
        (tester) async {
      await pumpScreen(tester, locale: const Locale('es'));
      final es = AppStrings.forLocale(const Locale('es'));

      await tester.tap(find.text(es.termsTitle));
      await tester.pumpAndSettle();

      expect(openedUrls, [Uri.parse('https://moodcalendar.app/es/terms/')]);
    });

    testWidgets('privacy row opens the policy outside the app', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Privacy policy'));
      await tester.pumpAndSettle();

      expect(openedUrls, [Uri.parse(privacyPolicyUrl)]);
    });

    for (final row in ['Privacy policy', 'Terms', 'Send feedback']) {
      testWidgets('$row tells the user when it cannot be opened',
          (tester) async {
        openUrl = (_) async => false;
        await pumpScreen(tester);

        await tester.tap(find.text(row));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });
    }

    testWidgets('survives a launcher that throws', (tester) async {
      openUrl = (_) async => throw StateError('no handler');
      await pumpScreen(tester);

      await tester.tap(find.text('Privacy policy'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('usage analytics switch', () {
    const title = 'Share anonymous usage data';

    testWidgets('starts on and does not touch the reminder', (tester) async {
      await pumpScreen(tester);

      expect(isOn(tester, title), isTrue);
      expect(find.textContaining('never included'), findsOneWidget);
    });

    testWidgets('turning it off saves it and stops collection', (tester) async {
      await pumpScreen(tester);

      await tester.tap(switchOf(title));
      await tester.pumpAndSettle();

      expect(repository.saved.usageAnalyticsEnabled, isFalse);
      expect(analytics.collectionChanges, [false]);
      expect(notificationCalls, isEmpty);
      expect(isOn(tester, title), isFalse);
    });

    testWidgets('turning it back on enables collection again', (tester) async {
      await pumpScreen(tester);

      await tester.tap(switchOf(title));
      await tester.pumpAndSettle();
      await tester.tap(switchOf(title));
      await tester.pumpAndSettle();

      expect(repository.saved.usageAnalyticsEnabled, isTrue);
      expect(analytics.collectionChanges, [false, true]);
    });

    testWidgets('a failed save reverts the switch and shows a message',
        (tester) async {
      await pumpScreen(tester);
      repository.failSaves = true;

      await tester.tap(switchOf(title));
      await tester.pumpAndSettle();

      expect(isOn(tester, title), isTrue);
      // The SDK is left at the saved value, never at the failed one.
      expect(analytics.collectionChanges, [true]);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows the saved preference', (tester) async {
      repository.saved =
          repository.saved.copyWith(usageAnalyticsEnabled: false);
      await pumpScreen(tester);

      expect(isOn(tester, title), isFalse);
    });

    for (final entry in {
      'es': 'Compartir datos de uso anónimos',
      'de': 'Anonyme Nutzungsdaten teilen',
      'fr': 'Partager des données d\'utilisation anonymes',
      'it': 'Condividi dati di utilizzo anonimi',
    }.entries) {
      testWidgets('is localized (${entry.key})', (tester) async {
        await pumpScreen(tester, locale: Locale(entry.key));

        expect(find.text(entry.value), findsOneWidget);
      });
    }
  });

  group('notification permission', () {
    testWidgets('turning the reminder on asks first and keeps it on',
        (tester) async {
      repository.saved = repository.saved.copyWith(dailyReminderEnabled: false);
      await pumpScreen(tester);

      await tester.tap(switchOf('Enable daily reminders'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Enable daily reminders'), isTrue);
      expect(repository.saved.dailyReminderEnabled, isTrue);
      expect(notificationCalls, ['schedule']);
    });

    testWidgets('a refused permission turns it back off and explains',
        (tester) async {
      notificationPermission = false;
      repository.saved = repository.saved.copyWith(dailyReminderEnabled: false);
      await pumpScreen(tester);

      await tester.tap(switchOf('Enable daily reminders'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Enable daily reminders'), isFalse);
      expect(repository.saved.dailyReminderEnabled, isFalse);
      expect(notificationCalls, isEmpty);
      expect(find.textContaining('Notifications are off'), findsOneWidget);
    });
  });

  group('note lock', () {
    final subscriber = FakeMoodEntitlementsRepository(
      subscription: const SubscriptionStatus(
        isActive: true,
        plan: SubscriptionPlanType.monthly,
      ),
    );

    testWidgets('sits in Privacy and data with the Pro badge for a free user',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('Lock notes'), findsOneWidget);
      expect(
        find.descendant(
          of: find
              .ancestor(
                  of: find.text('Lock notes'), matching: find.byType(InkWell))
              .first,
          matching: find.text('Pro'),
        ),
        findsOneWidget,
      );
      expect(isOn(tester, 'Lock notes'), isFalse);
    });

    testWidgets('a subscriber has no Pro badge', (tester) async {
      entitlements = subscriber;
      await pumpScreen(tester);

      expect(find.text('Pro'), findsNothing);
    });

    testWidgets(
        'without a subscription the switch opens the sheet and stays '
        'off', (tester) async {
      await pumpScreen(tester);

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(find.text('Understand how you feel'), findsOneWidget);
      expect(isOn(tester, 'Lock notes'), isFalse);
      expect(repository.saved.noteLockEnabled, isFalse);
      expect(authenticator.reasons, isEmpty);
    });

    testWidgets('a subscriber who authenticates turns it on and it is saved',
        (tester) async {
      entitlements = subscriber;
      await pumpScreen(tester);

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Lock notes'), isTrue);
      expect(repository.saved.noteLockEnabled, isTrue);
      expect(noteLockCubit.state.enabled, isTrue);
      expect(
          telemetry.events.map((e) => e.name), contains('note_lock_enabled'));
    });

    testWidgets('cancelling the authentication leaves it off', (tester) async {
      entitlements = subscriber;
      authenticator.succeeds = false;
      await pumpScreen(tester);

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Lock notes'), isFalse);
      expect(repository.saved.noteLockEnabled, isFalse);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a device without a passcode explains instead of enabling',
        (tester) async {
      entitlements = subscriber;
      authenticator.available = false;
      await pumpScreen(tester);

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Lock notes'), isFalse);
      expect(
          find.textContaining('Set a passcode or biometrics'), findsOneWidget);
    });

    testWidgets('a lapsed subscription still lets the user turn it off',
        (tester) async {
      repository.saved = repository.saved.copyWith(noteLockEnabled: true);
      noteLockCubit
        ..setEnabled(true)
        ..lock(); // as after a launch with the lock on
      await pumpScreen(tester);
      expect(isOn(tester, 'Lock notes'), isTrue);

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Lock notes'), isFalse);
      expect(repository.saved.noteLockEnabled, isFalse);
      expect(authenticator.reasons, ['Turn off the notes lock']);
    });

    testWidgets('an active lock the device cannot enforce says so',
        (tester) async {
      repository.saved = repository.saved.copyWith(noteLockEnabled: true);
      noteLockCubit
        ..setEnabled(true)
        ..lock(); // as after a launch with the lock on
      authenticator.available = false;
      await noteLockCubit.refreshAvailability();
      await pumpScreen(tester);

      expect(
        find.text('Set a passcode on your device to use the lock'),
        findsOneWidget,
      );
    });

    testWidgets('a failed save puts the lock back off', (tester) async {
      entitlements = subscriber;
      await pumpScreen(tester);
      repository.failSaves = true;

      await tester.tap(switchOf('Lock notes'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Lock notes'), isFalse);
      expect(noteLockCubit.state.enabled, isFalse);
    });

    testWidgets('shows the row in Spanish', (tester) async {
      await pumpScreen(tester, locale: const Locale('es'));

      expect(find.text('Bloquear notas'), findsOneWidget);
    });
  });

  group('export with the note lock', () {
    setUp(() {
      repository.saved = repository.saved.copyWith(noteLockEnabled: true);
      noteLockCubit
        ..setEnabled(true)
        ..lock(); // as after a launch with the lock on
    });

    testWidgets('asks to unlock first and exports on success', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(
          authenticator.reasons, ['Unlock your notes to export your history']);
      expect(exporter.calls, 1);
      expect(sharedFiles, hasLength(1));
    });

    testWidgets('cancelling generates nothing and leaves the row usable',
        (tester) async {
      authenticator.succeeds = false;
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(exporter.calls, 0);
      expect(sharedFiles, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Export history'), findsOneWidget);
    });

    testWidgets('an unlocked session does not ask again', (tester) async {
      await pumpScreen(tester);
      await noteLockCubit.unlock('r');
      authenticator.reasons.clear();

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(authenticator.reasons, isEmpty);
      expect(exporter.calls, 1);
    });
  });

  group('export history', () {
    testWidgets('lives under Privacy and data', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Privacy and data'), findsOneWidget);
      expect(find.text('Export history'), findsOneWidget);
    });

    testWidgets('exports and opens the share sheet with the file',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(exporter.calls, 1);
      expect(sharedFiles, ['/tmp/mood-history.json']);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an empty history does not share and says so', (tester) async {
      exporter.entryCount = 0;
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(sharedFiles, isEmpty);
      expect(find.text('There\'s no history to export yet.'), findsOneWidget);
    });

    testWidgets('a failed export shows an error and stays usable',
        (tester) async {
      exporter.failWith = StateError('disk full');
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(sharedFiles, isEmpty);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Export history'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      exporter.failWith = null;
      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();
      expect(sharedFiles, hasLength(1));
    });

    testWidgets('the row is disabled while exporting, with no double export',
        (tester) async {
      exporter.gate = Completer<void>();
      await pumpScreen(tester);

      await tester.tap(find.text('Export history'));
      await tester.pump();

      expect(find.text('Exporting your history...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Exporting your history...'));
      await tester.pump();
      expect(exporter.calls, 1);

      exporter.gate!.complete();
      await tester.pumpAndSettle();

      expect(find.text('Export history'), findsOneWidget);
      expect(sharedFiles, hasLength(1));
    });

    testWidgets('shows the section and row in German', (tester) async {
      await pumpScreen(tester, locale: const Locale('de'));

      expect(find.text('Datenschutz und Daten'), findsOneWidget);
      expect(find.text('Verlauf exportieren'), findsOneWidget);
    });
  });
}

class _FakeHistoryExporter implements MoodHistoryExporter {
  int calls = 0;
  int entryCount = 3;
  Object? failWith;
  Completer<void>? gate;

  @override
  Future<MoodHistoryExportResult> exportHistory() async {
    calls++;
    await gate?.future;
    final error = failWith;
    if (error != null) throw error;
    return MoodHistoryExportResult(
      filePath: '/tmp/mood-history.json',
      fileName: 'mood-history.json',
      entryCount: entryCount,
    );
  }
}

class _FakeSettingsRepository implements AppSettingsRepository {
  _FakeSettingsRepository(this.saved);

  AppSettings saved;
  bool failSaves = false;

  @override
  Future<AppSettings> getSettings() async => saved;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    if (failSaves) throw StateError('save failed');
    saved = settings;
  }
}

class _SilentLogger implements AppLogger {
  const _SilentLogger();

  @override
  void debug(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {}
}
