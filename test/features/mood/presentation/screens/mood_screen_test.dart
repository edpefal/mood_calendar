import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/notifications/local_notification_service.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/data/models/mood_model.dart';
import 'package:mood_calendar/main.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/screens/mood_screen.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';

import '../../../../support/fake_mood_entitlements_repository.dart';

class _FakeMoodRepository implements MoodRepository {
  final savedEntries = <MoodEntry>[];

  @override
  Future<List<MoodEntry>> getMoods() async => savedEntries;

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async => savedEntries
      .where((entry) =>
          entry.date.year == month.year && entry.date.month == month.month)
      .toList();

  @override
  Future<void> saveMood(MoodEntry entry) async {
    savedEntries.add(entry);
  }
}

class _TestAppLogger implements AppLogger {
  const _TestAppLogger();

  @override
  void debug(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void error(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

class _FakeRatingPromptService implements RatingPromptService {
  int maybeRequestCalls = 0;

  @override
  Future<void> maybeRequestAfterSave() async {
    maybeRequestCalls++;
  }

  @override
  Future<void> openStoreListing() async {}
}

class _TestAppTelemetry implements AppTelemetry {
  const _TestAppTelemetry();

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {}
}

void main() {
  late Directory tempDir;
  late Box<MoodModel> moodBox;
  late _FakeMoodRepository moodRepository;
  late _FakeRatingPromptService ratingPromptService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('mood_screen_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodModelAdapter());
    }
  });

  setUp(() async {
    moodBox = await Hive.openBox<MoodModel>('moods');
    await moodBox.clear();
    moodRepository = _FakeMoodRepository();
    ratingPromptService = _FakeRatingPromptService();
  });

  tearDown(() async {
    await moodBox.clear();
    await moodBox.close();
    await Hive.deleteBoxFromDisk('moods');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets('saving a base mood persists the entry', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MoodScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 1; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Tranquilo'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(moodRepository.savedEntries, hasLength(1));
    expect(moodRepository.savedEntries.single.mood, 'assets/icon/calm.svg');
    expect(ratingPromptService.maybeRequestCalls, 1);
  });

  testWidgets('saving an unlocked premium mood persists the entry',
      (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(
              FakeMoodEntitlementsRepository(unlockedMoodIds: {'anxious'}),
            ),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MoodScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // base moods: happy, calm, neutral, sad, angry -> premium starts at index 5 (anxious)
    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Ansioso'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(moodRepository.savedEntries, hasLength(1));
    expect(moodRepository.savedEntries.single.mood, 'assets/icon/anxious.svg');
  });

  testWidgets(
      'tapping a locked premium mood opens the purchase flow instead of saving',
      (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MoodScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Ansioso'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(moodRepository.savedEntries, isEmpty);
    // The purchase bottom sheet opened instead of saving (the fake
    // repository returns no offers, so it shows the empty-catalog message).
    expect(find.text('No hay ánimos premium disponibles por ahora.'),
        findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  Widget buildApp() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MoodCubit(
            saveMood: SaveMoodUseCase(moodRepository),
            getMoods: GetMoodsUseCase(moodRepository),
            logger: const _TestAppLogger(),
            telemetry: const _TestAppTelemetry(),
          ),
        ),
        BlocProvider(
          create: (_) => CalendarCubit(
            initialMonth: DateTime(2026, 4, 1),
            getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
              GetMoodsForMonthUseCase(moodRepository),
            ),
          ),
        ),
        BlocProvider(
          create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('es'),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MoodScreen(),
      ),
    );
  }

  testWidgets(
      'tapping the inline note preview opens the note editor bottom sheet',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Toca para agregar una nota'), findsOneWidget);
    expect(find.text('Nota del día'), findsNothing);

    await tester.tap(find.text('Toca para agregar una nota'));
    await tester.pumpAndSettle();

    expect(find.text('Nota del día'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    expect(find.text('Cuéntame sobre tu día...'), findsOneWidget);
  });

  testWidgets('note editor sheet enforces the 500 character limit',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toca para agregar una nota'));
    await tester.pumpAndSettle();

    final longText = 'a' * 600;
    await tester.enterText(find.byType(TextField), longText);
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text.length, 500);
    expect(find.text('500/500'), findsOneWidget);
  });

  testWidgets(
      'closing the note editor sheet with Listo preserves the written text',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toca para agregar una nota'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hoy fue un buen día');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();

    expect(find.text('Nota del día'), findsNothing);
    expect(find.text('Hoy fue un buen día'), findsOneWidget);
  });

  testWidgets('opening a date with an entry positions the carousel on its mood',
      (tester) async {
    moodRepository.savedEntries.add(
      MoodEntry(
        date: DateTime(2026, 3, 10),
        mood: 'assets/icon/angry.svg',
        intensity: 5,
      ),
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 3, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MoodScreen(selectedDate: DateTime(2026, 3, 10)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enojado'), findsOneWidget);
    expect(find.text('Feliz'), findsNothing);
  });

  testWidgets('app title follows the device language', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Title>(find.byType(Title)).title, 'Stimmungskalender');
  });

  group('ordering by usage', () {
    MoodEntry entry(String moodId, DateTime date) => MoodEntry(
          date: date,
          mood: 'assets/icon/$moodId.svg',
          intensity: 1,
        );

    Widget buildOrderedApp({
      FakeMoodEntitlementsRepository? entitlements,
      DateTime? selectedDate,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) =>
                PurchasesCubit(entitlements ?? FakeMoodEntitlementsRepository()),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MoodScreen(selectedDate: selectedDate),
        ),
      );
    }

    Future<void> swipeNext(WidgetTester tester) async {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('without history keeps the catalog order', (tester) async {
      await tester.pumpWidget(buildOrderedApp());
      await tester.pumpAndSettle();

      expect(find.text('Feliz'), findsOneWidget);
      await swipeNext(tester);
      expect(find.text('Tranquilo'), findsOneWidget);
    });

    testWidgets('with history shows the most used mood first and preselects it',
        (tester) async {
      moodRepository.savedEntries.addAll([
        entry('sad', DateTime(2026, 3, 1)),
        entry('sad', DateTime(2026, 3, 2)),
        entry('calm', DateTime(2026, 3, 3)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(selectedDate: DateTime(2026, 3, 10)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Triste'), findsOneWidget);
      await swipeNext(tester);
      expect(find.text('Tranquilo'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(moodRepository.savedEntries.last.mood, 'assets/icon/calm.svg');
    });

    testWidgets('editing an entry positions the carousel on its mood',
        (tester) async {
      moodRepository.savedEntries.addAll([
        entry('sad', DateTime(2026, 3, 1)),
        entry('sad', DateTime(2026, 3, 2)),
        entry('angry', DateTime(2026, 3, 10)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(selectedDate: DateTime(2026, 3, 10)),
      );
      await tester.pumpAndSettle();

      // angry is catalog index 4 but sits second once ordered by usage.
      expect(find.text('Enojado'), findsOneWidget);
      expect(find.text('Triste'), findsNothing);
    });

    testWidgets('the order does not change when a mood is unlocked while open',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository();
      moodRepository.savedEntries.addAll([
        entry('anxious', DateTime(2026, 3, 1)),
        entry('anxious', DateTime(2026, 3, 2)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(
          entitlements: entitlements,
          selectedDate: DateTime(2026, 3, 10),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Feliz'), findsOneWidget);

      await entitlements.purchaseMood('anxious');
      await tester.pumpAndSettle();

      expect(find.text('Feliz'), findsOneWidget);
      expect(find.text('Ansioso'), findsNothing);
    });

    testWidgets('a purchased mood with history is ordered with unlocked moods',
        (tester) async {
      moodRepository.savedEntries.addAll([
        entry('anxious', DateTime(2026, 3, 1)),
        entry('anxious', DateTime(2026, 3, 2)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(
          entitlements:
              FakeMoodEntitlementsRepository(unlockedMoodIds: {'anxious'}),
          selectedDate: DateTime(2026, 3, 10),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ansioso'), findsOneWidget);
    });
  });

  group('returning from the calendar', () {
    final strings = AppStrings.forLocale(const Locale('es'));
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);

    String headerFor(DateTime date) =>
        '${strings.monthNames[date.month - 1]} ${date.day}, ${date.year}';

    Widget buildAppWithHome(Widget home) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(moodRepository),
              getMoods: GetMoodsUseCase(moodRepository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(now.year, now.month),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: home,
        ),
      );
    }

    Future<void> openCalendar(WidgetTester tester) async {
      await tester.tap(find.byTooltip(strings.openCalendarTooltip));
      await tester.pumpAndSettle();
    }

    Future<void> goToPreviousMonth(WidgetTester tester) async {
      await tester.tap(find.byTooltip(strings.previousMonthTooltip));
      await tester.pumpAndSettle();
    }

    Future<void> saveDay(WidgetTester tester, int day, {int swipes = 0}) async {
      await tester.tap(find.text('$day'));
      await tester.pumpAndSettle();
      for (var i = 0; i < swipes; i++) {
        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();
    }

    testWidgets('after editing another date, back opens that date',
        (tester) async {
      await tester.pumpWidget(buildAppWithHome(const MoodScreen()));
      await tester.pumpAndSettle();
      await openCalendar(tester);
      await goToPreviousMonth(tester);

      // 4 swipes -> angry, so the entry is distinguishable from the default.
      await saveDay(tester, 15, swipes: 4);

      await tester.tap(find.byTooltip(strings.backToMoodPickerTooltip));
      await tester.pumpAndSettle();

      expect(find.text(headerFor(DateTime(previousMonth.year, previousMonth.month, 15))),
          findsOneWidget);
      expect(find.text('Enojado'), findsOneWidget);
    });

    testWidgets('without opening any day, back opens today', (tester) async {
      await tester.pumpWidget(buildAppWithHome(const MoodScreen()));
      await tester.pumpAndSettle();
      await openCalendar(tester);

      expect(find.byTooltip(strings.backToTodayTooltip), findsOneWidget);
      expect(find.byTooltip(strings.backToMoodPickerTooltip), findsNothing);

      await tester.tap(find.byTooltip(strings.backToTodayTooltip));
      await tester.pumpAndSettle();

      expect(find.text(headerFor(now)), findsOneWidget);
    });

    testWidgets('after editing several dates, back opens the last one',
        (tester) async {
      await tester.pumpWidget(buildAppWithHome(const MoodScreen()));
      await tester.pumpAndSettle();
      await openCalendar(tester);
      await goToPreviousMonth(tester);

      await saveDay(tester, 15);
      await saveDay(tester, 16);

      await tester.tap(find.byTooltip(strings.backToMoodPickerTooltip));
      await tester.pumpAndSettle();

      expect(find.text(headerFor(DateTime(previousMonth.year, previousMonth.month, 16))),
          findsOneWidget);
    });

    testWidgets('calendar opened from another date returns to that date',
        (tester) async {
      final reminderDate = DateTime(previousMonth.year, previousMonth.month, 10);
      await tester.pumpWidget(
        buildAppWithHome(MoodScreen(selectedDate: reminderDate)),
      );
      await tester.pumpAndSettle();
      await openCalendar(tester);

      expect(find.byTooltip(strings.backToMoodPickerTooltip), findsOneWidget);

      await tester.tap(find.byTooltip(strings.backToMoodPickerTooltip));
      await tester.pumpAndSettle();

      expect(find.text(headerFor(reminderDate)), findsOneWidget);
    });

    testWidgets('saving today and going back keeps opening today',
        (tester) async {
      await tester.pumpWidget(buildAppWithHome(const MoodScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(find.byTooltip(strings.backToTodayTooltip), findsOneWidget);
      await tester.tap(find.byTooltip(strings.backToTodayTooltip));
      await tester.pumpAndSettle();

      expect(find.text(headerFor(now)), findsOneWidget);
    });
  });

  group('settings entry point', () {
    final strings = AppStrings.forLocale(const Locale('es'));

    Widget buildApp() {
      final settingsRepository = _FakeSettingsRepository();
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppLogger>.value(value: const _TestAppLogger()),
          RepositoryProvider<AppSettingsRepository>.value(
            value: settingsRepository,
          ),
          RepositoryProvider<LocalNotificationService>.value(
            value: LocalNotificationService(
              onReminderTap: () async {},
              appSettingsRepository: settingsRepository,
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          RepositoryProvider<RatingPromptService>.value(
            value: ratingPromptService,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => MoodCubit(
                saveMood: SaveMoodUseCase(moodRepository),
                getMoods: GetMoodsUseCase(moodRepository),
                logger: const _TestAppLogger(),
                telemetry: const _TestAppTelemetry(),
              ),
            ),
            BlocProvider(
              create: (_) => CalendarCubit(
                initialMonth: DateTime.now(),
                getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                  GetMoodsForMonthUseCase(moodRepository),
                ),
              ),
            ),
            BlocProvider(
              create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
            ),
          ],
          child: const MaterialApp(
            locale: Locale('es'),
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: MoodScreen(),
          ),
        ),
      );
    }

    testWidgets('header shows store, calendar and settings in that order',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final store = tester.getCenter(find.byTooltip(strings.openStoreTooltip));
      final calendar =
          tester.getCenter(find.byTooltip(strings.openCalendarTooltip));
      final settings =
          tester.getCenter(find.byTooltip(strings.openSettingsTooltip));

      expect(store.dx, lessThan(calendar.dx));
      expect(calendar.dx, lessThan(settings.dx));
    });

    testWidgets('the gear opens the settings screen and back returns',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(strings.openSettingsTooltip));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text(strings.settingsTitle), findsOneWidget);

      Navigator.of(tester.element(find.byType(SettingsScreen))).pop();
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(MoodScreen), findsOneWidget);
    });

    testWidgets('the calendar header no longer has the reminders bell',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(strings.openCalendarTooltip));
      await tester.pumpAndSettle();

      expect(find.byTooltip(strings.previousMonthTooltip), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_outlined), findsNothing);
    });
  });
}

class _FakeSettingsRepository implements AppSettingsRepository {
  @override
  Future<AppSettings> getSettings() async => AppSettings.defaults;

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}
