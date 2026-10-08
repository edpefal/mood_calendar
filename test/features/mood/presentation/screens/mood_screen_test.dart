import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
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
}
