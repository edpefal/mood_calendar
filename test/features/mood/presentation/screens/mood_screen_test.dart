import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/navigation/main_shell.dart';
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
          home: MainShell(),
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

  Widget buildApp({
    DateTime? selectedDate,
    Locale locale = const Locale('es'),
    double textScale = 1,
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
          create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: MoodScreen(selectedDate: selectedDate),
      ),
    );
  }

  testWidgets('tapping the note button opens the note editor bottom sheet',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Nota'), findsOneWidget);
    expect(find.text('Nota del día'), findsNothing);

    await tester.tap(find.text('Nota'));
    await tester.pumpAndSettle();

    expect(find.text('Nota del día'), findsOneWidget);
    expect(find.text('Listo'), findsOneWidget);
    expect(find.text('Cuéntame sobre tu día...'), findsOneWidget);
  });

  testWidgets('note editor sheet enforces the 500 character limit',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nota'));
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

    await tester.tap(find.text('Nota'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hoy fue un buen día');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();

    expect(find.text('Nota del día'), findsNothing);
    expect(find.byIcon(Icons.sticky_note_2_rounded), findsOneWidget);

    // The text is not previewed outside the sheet; it is back when reopened.
    expect(find.text('Hoy fue un buen día'), findsNothing);
    await tester.tap(find.text('Nota'));
    await tester.pumpAndSettle();
    expect(find.text('Hoy fue un buen día'), findsOneWidget);
  });

  group('header date', () {
    testWidgets('follows the order of each language', (tester) async {
      final date = DateTime(2026, 10, 10);
      for (final entry in {
        const Locale('en'): 'October 10, 2026',
        const Locale('es'): '10 de octubre de 2026',
        const Locale('de'): '10. Oktober 2026',
        const Locale('fr'): '10 octobre 2026',
        const Locale('it'): '10 ottobre 2026',
      }.entries) {
        await tester.pumpWidget(
          buildApp(selectedDate: date, locale: entry.key),
        );
        await tester.pumpAndSettle();

        expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}');
      }
    });
  });

  group('text scale', () {
    void useNarrowPhone(WidgetTester tester) {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    ScrollableState verticalScrollable(WidgetTester tester) =>
        tester.state<ScrollableState>(find.byType(Scrollable).first);

    testWidgets('at 100% the picker does not scroll', (tester) async {
      useNarrowPhone(tester);
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(verticalScrollable(tester).position.maxScrollExtent, 0);
    });

    // German with a long date is the case that overflowed by 119 px before.
    Widget buildOverflowingApp() => buildApp(
          selectedDate: DateTime(2026, 9, 28),
          locale: const Locale('de'),
          textScale: 2,
        );

    testWidgets('at 200% the picker overflows nothing and scrolls',
        (tester) async {
      useNarrowPhone(tester);
      await tester.pumpWidget(buildOverflowingApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
          verticalScrollable(tester).position.maxScrollExtent, greaterThan(0));
    });

    testWidgets(
        'at 200% the carousel still changes mood with a horizontal swipe',
        (tester) async {
      final de = AppStrings.forLocale(const Locale('de'));
      useNarrowPhone(tester);
      await tester.pumpWidget(buildOverflowingApp());
      await tester.pumpAndSettle();
      expect(find.text(de.moodName('happy')), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text(de.moodName('happy')), findsNothing);
      expect(find.text(de.moodName('calm')), findsOneWidget);
    });
  });

  group('note button', () {
    testWidgets('has no inline note field above the save button',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Toca para agregar una nota'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('shows the outlined icon and no dot when there is no note',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_rounded), findsNothing);
    });

    testWidgets('shows the filled icon when the entry already has a note',
        (tester) async {
      moodRepository.savedEntries.add(
        MoodEntry(
          date: DateTime(2026, 3, 10),
          mood: 'assets/icon/angry.svg',
          note: 'Día largo',
          intensity: 5,
        ),
      );
      await tester.pumpWidget(buildApp(selectedDate: DateTime(2026, 3, 10)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sticky_note_2_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_outlined), findsNothing);
      expect(find.text('Día largo'), findsNothing);
    });

    testWidgets('clearing the note in the sheet returns to the empty state',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nota'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'algo');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sticky_note_2_rounded), findsOneWidget);

      await tester.tap(find.text('Nota'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sticky_note_2_outlined), findsOneWidget);
      expect(find.byIcon(Icons.sticky_note_2_rounded), findsNothing);
    });

    testWidgets('is announced as a button with the localized label',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.text('Nota')),
        matchesSemantics(label: 'Nota', isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('label follows the device language, English as fallback',
        (tester) async {
      await tester.pumpWidget(buildApp(locale: const Locale('de')));
      await tester.pumpAndSettle();
      expect(find.text('Notiz'), findsOneWidget);

      await tester.pumpWidget(buildApp(locale: const Locale('en')));
      await tester.pumpAndSettle();
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('stays visible with a long date and large text',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildApp(
          selectedDate: DateTime(2026, 9, 28),
          locale: const Locale('de'),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Notiz').hitTestable(), findsOneWidget);

      // The save button is reachable by scrolling.
      expect(find.text('Speichern').hitTestable(), findsNothing);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Speichern').hitTestable(), findsOneWidget);
    });
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
            create: (_) => PurchasesCubit(
                entitlements ?? FakeMoodEntitlementsRepository()),
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

  group('bottom navigation', () {
    final strings = AppStrings.forLocale(const Locale('es'));
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);

    String headerFor(DateTime date) => strings.formatFullDate(date);

    Widget buildApp({
      MoodRepository? repository,
      GlobalKey<MainShellState>? shellKey,
    }) {
      final moods = repository ?? moodRepository;
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
                saveMood: SaveMoodUseCase(moods),
                getMoods: GetMoodsUseCase(moods),
                logger: const _TestAppLogger(),
                telemetry: const _TestAppTelemetry(),
              ),
            ),
            BlocProvider(
              create: (_) => CalendarCubit(
                initialMonth: DateTime(now.year, now.month),
                getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                  GetMoodsForMonthUseCase(moods),
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
            home: MainShell(key: shellKey),
          ),
        ),
      );
    }

    Future<void> openTab(WidgetTester tester, String tooltip) async {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
    }

    Future<void> goToPreviousMonth(WidgetTester tester) async {
      await tester.tap(find.byTooltip(strings.previousMonthTooltip));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the four tabs in order and starts on today',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      final picker =
          tester.getCenter(find.byTooltip(strings.openMoodPickerTooltip));
      final calendar =
          tester.getCenter(find.byTooltip(strings.openCalendarTooltip));
      final store = tester.getCenter(find.byTooltip(strings.openStoreTooltip));
      final settings =
          tester.getCenter(find.byTooltip(strings.openSettingsTooltip));

      expect(picker.dx, lessThan(calendar.dx));
      expect(calendar.dx, lessThan(store.dx));
      expect(store.dx, lessThan(settings.dx));
      expect(find.text(headerFor(now)), findsOneWidget);
    });

    testWidgets('the picker header no longer has navigation buttons',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Each destination is reachable only through the bar.
      expect(find.byTooltip(strings.openCalendarTooltip), findsOneWidget);
      expect(find.byTooltip(strings.openStoreTooltip), findsOneWidget);
      expect(find.byTooltip(strings.openSettingsTooltip), findsOneWidget);
    });

    testWidgets('the settings tab has no back button', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await openTab(tester, strings.openSettingsTooltip);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text(strings.settingsTitle), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets(
        'the calendar tab has a title, no back button or reminders bell',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await openTab(tester, strings.openCalendarTooltip);

      expect(find.text(strings.calendarTitle), findsOneWidget);
      expect(find.byTooltip(strings.previousMonthTooltip), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.notifications_active_outlined), findsNothing);
    });

    testWidgets('tapping a calendar day opens the picker on that date',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await openTab(tester, strings.openCalendarTooltip);
      await goToPreviousMonth(tester);

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          headerFor(DateTime(previousMonth.year, previousMonth.month, 15)),
        ),
        findsOneWidget,
      );
    });

    testWidgets('calendar days announce the same date format as the picker',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await openTab(tester, strings.openCalendarTooltip);
      await goToPreviousMonth(tester);

      final label = strings.formatFullDate(
        DateTime(previousMonth.year, previousMonth.month, 15),
      );
      expect(
        find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the picker keeps its date when switching tabs',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await openTab(tester, strings.openCalendarTooltip);
      await goToPreviousMonth(tester);
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      await openTab(tester, strings.openSettingsTooltip);
      await openTab(tester, strings.openMoodPickerTooltip);

      expect(
        find.text(
          headerFor(DateTime(previousMonth.year, previousMonth.month, 15)),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the picker keeps an unsaved mood when switching tabs',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Tranquilo'), findsOneWidget);

      await openTab(tester, strings.openStoreTooltip);
      await openTab(tester, strings.openMoodPickerTooltip);

      expect(find.text('Tranquilo'), findsOneWidget);
    });

    testWidgets('saving switches to the calendar tab', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(moodRepository.savedEntries, hasLength(1));
      expect(find.byTooltip(strings.previousMonthTooltip), findsOneWidget);
      expect(find.text(strings.save), findsNothing);
      expect(ratingPromptService.maybeRequestCalls, 1);
    });

    testWidgets('a failed save stays on the picker', (tester) async {
      await tester.pumpWidget(buildApp(repository: _FailingSaveRepository()));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(find.text(strings.save), findsOneWidget);
      expect(find.byTooltip(strings.previousMonthTooltip), findsNothing);
      expect(ratingPromptService.maybeRequestCalls, 0);
    });

    testWidgets('showMoodPicker from another tab shows the given date',
        (tester) async {
      final shellKey = GlobalKey<MainShellState>();
      await tester.pumpWidget(buildApp(shellKey: shellKey));
      await tester.pumpAndSettle();
      await openTab(tester, strings.openSettingsTooltip);

      final date = DateTime(previousMonth.year, previousMonth.month, 10);
      shellKey.currentState!.showMoodPicker(date);
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.moodPicker);
      expect(find.text(headerFor(date)), findsOneWidget);
    });

    testWidgets('the picker does not overflow when the keyboard is open',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // The note editor opens a sheet over the picker with the keyboard up.
      tester.view.viewInsets = const FakeViewPadding(bottom: 350);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a modal sheet covers the bar', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.noteButtonLabel));
      await tester.pumpAndSettle();

      expect(
        find.byTooltip(strings.openCalendarTooltip).hitTestable(),
        findsNothing,
      );

      // Tapping the barrier closes the sheet and the bar is reachable again.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(
        find.byTooltip(strings.openCalendarTooltip).hitTestable(),
        findsOneWidget,
      );
    });
  });

  group('reminder tap', () {
    final strings = AppStrings.forLocale(const Locale('en'));
    final now = DateTime.now();
    String headerFor(DateTime date) => strings.formatFullDate(date);

    Widget buildMyApp() {
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
                initialMonth: DateTime(now.year, now.month),
                getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                  GetMoodsForMonthUseCase(moodRepository),
                ),
              ),
            ),
            BlocProvider(
              create: (_) => PurchasesCubit(FakeMoodEntitlementsRepository()),
            ),
          ],
          child: const MyApp(),
        ),
      );
    }

    testWidgets('from another tab it opens the picker on today',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(strings.openSettingsTooltip));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await handleReminderTap();
      await tester.pumpAndSettle();

      expect(mainShellKey.currentState!.currentTab, MainTab.moodPicker);
      expect(find.text(headerFor(now)), findsOneWidget);
    });

    testWidgets('it closes an open modal and shows today, not the viewed date',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      final past = DateTime(now.year, now.month - 1, 10);
      mainShellKey.currentState!.showMoodPicker(past);
      await tester.pumpAndSettle();
      expect(find.text(headerFor(past)), findsOneWidget);
      await tester.tap(find.text(strings.noteButtonLabel));
      await tester.pumpAndSettle();
      expect(find.text(strings.noteSheetTitle), findsOneWidget);

      await handleReminderTap();
      await tester.pumpAndSettle();

      expect(find.text(strings.noteSheetTitle), findsNothing);
      expect(find.text(headerFor(now)), findsOneWidget);
      expect(
        find.byTooltip(strings.openCalendarTooltip).hitTestable(),
        findsOneWidget,
      );
    });

    testWidgets('a tap that arrives before the shell exists is not lost',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final pending = handleReminderTap();
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      await pending;

      expect(mainShellKey.currentState!.currentTab, MainTab.moodPicker);
      expect(find.text(headerFor(now)), findsOneWidget);
    });
  });
}

class _FakeSettingsRepository implements AppSettingsRepository {
  @override
  Future<AppSettings> getSettings() async => AppSettings.defaults;

  @override
  Future<void> saveSettings(AppSettings settings) async {}
}

class _FailingSaveRepository extends _FakeMoodRepository {
  @override
  Future<void> saveMood(MoodEntry entry) async {
    throw Exception('save failed');
  }
}
