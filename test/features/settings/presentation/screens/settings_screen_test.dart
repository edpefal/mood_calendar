import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_history_export_result.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_history_exporter.dart';
import 'package:mood_calendar/features/mood/domain/usecases/export_mood_history_usecase.dart';
import 'package:mood_calendar/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';

void main() {
  late _FakeSettingsRepository repository;
  late _FakeRatingPromptService ratingPromptService;
  late List<String> notificationCalls;
  late List<Uri> openedUrls;
  late Future<bool> Function(Uri) openUrl;
  late _FakeHistoryExporter exporter;
  late List<String> sharedFiles;

  Future<void> pumpScreen(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    String version = '1.8.3 (28)',
  }) async {
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
            home: SettingsScreen(
              openUrl: (url) => openUrl(url),
              shareFile: (path, origin) async => sharedFiles.add(path),
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
    ratingPromptService = _FakeRatingPromptService();
    exporter = _FakeHistoryExporter();
    sharedFiles = [];
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
  group('export history', () {
    testWidgets('has its own section with the export row', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Your data'), findsOneWidget);
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

    testWidgets('a share sheet that fails shows an error', (tester) async {
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
          child: BlocProvider(
            create: (_) => SettingsCubit(
              settingsRepository: repository,
              scheduleReminder: () async {},
              cancelReminder: () async {},
              loadAppVersion: () async => '1.0.0 (1)',
              logger: const _SilentLogger(),
            )..load(),
            child: MaterialApp(
              supportedLocales: AppStrings.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: SettingsScreen(
                shareFile: (_, __) async => throw StateError('no share sheet'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export history'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('the row exposes a semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester);

      expect(find.bySemanticsLabel('Export your mood history as a file'),
          findsOneWidget);
      handle.dispose();
    });

    testWidgets('shows the section and row in German', (tester) async {
      await pumpScreen(tester, locale: const Locale('de'));

      expect(find.text('Deine Daten'), findsOneWidget);
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
