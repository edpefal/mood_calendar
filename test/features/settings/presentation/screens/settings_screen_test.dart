import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';

void main() {
  late _FakeSettingsRepository repository;
  late _FakeRatingPromptService ratingPromptService;
  late List<String> notificationCalls;
  late List<Uri> openedUrls;
  late Future<bool> Function(Uri) openUrl;

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    String version = '1.8.3 (28)',
  }) async {
    await tester.pumpWidget(
      RepositoryProvider<RatingPromptService>.value(
        value: ratingPromptService,
        child: BlocProvider(
          create: (_) => SettingsCubit(
            settingsRepository: repository,
            scheduleReminder: () async => notificationCalls.add('schedule'),
            cancelReminder: () async => notificationCalls.add('cancel'),
            loadAppVersion: () async => version,
            logger: const _SilentLogger(),
          )..load(),
          child: MaterialApp(
            locale: locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SettingsScreen(openUrl: (url) => openUrl(url)),
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
    ratingPromptService = _FakeRatingPromptService();
    notificationCalls = [];
    openedUrls = [];
    openUrl = (url) async {
      openedUrls.add(url);
      return true;
    };
  });

  testWidgets('shows the saved reminder values and the app version',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
    expect(find.text('6:00 PM'), findsOneWidget);
    expect(find.text('1.8.3 (28)'), findsOneWidget);
  });

  testWidgets('the switch saves right away and cancels the reminder',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(SwitchListTile));
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

  testWidgets('rate row opens the store listing', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Rate Mood Calendar'));
    await tester.pumpAndSettle();

    expect(ratingPromptService.openStoreListingCalls, 1);
  });

  testWidgets('privacy row opens the policy outside the app', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(openedUrls, [Uri.parse(privacyPolicyUrl)]);
  });

  testWidgets('privacy row tells the user when the link cannot be opened',
      (tester) async {
    openUrl = (_) async => false;
    await pumpScreen(tester);

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('privacy row survives a launcher that throws', (tester) async {
    openUrl = (_) async => throw StateError('no handler');
    await pumpScreen(tester);

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('a failed save reverts the switch and shows a message',
      (tester) async {
    await pumpScreen(tester);
    repository.failSaves = true;

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
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

  testWidgets('interactive rows expose semantics labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester);

    expect(find.bySemanticsLabel('Rate Mood Calendar on the App Store'),
        findsOneWidget);
    expect(find.bySemanticsLabel('Open the privacy policy in your browser'),
        findsOneWidget);
    handle.dispose();
  });
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

class _FakeRatingPromptService implements RatingPromptService {
  int openStoreListingCalls = 0;

  @override
  Future<void> openStoreListing() async {
    openStoreListingCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
