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
import 'package:mood_calendar/core/telemetry/analytics_reporter.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/widgets/floating_tab_bar.dart';
import 'package:mood_calendar/core/widgets/gradient_pill_button.dart';
import 'package:mood_calendar/features/mood/data/models/mood_model.dart';
import 'package:mood_calendar/main.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/screens/mood_screen.dart';
import 'package:mood_calendar/features/mood/presentation/widgets/mood_grid_sheet.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';

import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import '../../../../support/drag_page.dart';
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
      await dragPage(tester);
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
      await dragPage(tester);
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
      await dragPage(tester);
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

      await tester.drag(find.byType(PageView), const Offset(-150, 0));
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
      ValueNotifier<bool>? active,
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
          home: active == null
              ? MoodScreen(selectedDate: selectedDate)
              : ValueListenableBuilder<bool>(
                  valueListenable: active,
                  builder: (_, isActive, __) => MoodScreen(
                    selectedDate: selectedDate,
                    isActive: isActive,
                  ),
                ),
        ),
      );
    }

    Future<void> swipeNext(WidgetTester tester) async {
      await dragPage(tester);
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

    Future<void> swipePrevious(WidgetTester tester) async {
      await dragPage(tester, forward: false);
      await tester.pumpAndSettle();
    }

    Future<void> leaveAndReturn(
      WidgetTester tester,
      ValueNotifier<bool> active, {
      Future<void> Function()? whileAway,
    }) async {
      active.value = false;
      await tester.pumpAndSettle();
      await whileAway?.call();
      await tester.pumpAndSettle();
      active.value = true;
      await tester.pumpAndSettle();
    }

    testWidgets('returning to the tab after a purchase moves the mood forward',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository();
      final active = ValueNotifier<bool>(true);
      addTearDown(active.dispose);
      moodRepository.savedEntries.addAll([
        entry('anxious', DateTime(2026, 3, 1)),
        entry('anxious', DateTime(2026, 3, 2)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(
          entitlements: entitlements,
          selectedDate: DateTime(2026, 3, 10),
          active: active,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Feliz'), findsOneWidget);

      await leaveAndReturn(
        tester,
        active,
        whileAway: () => entitlements.purchaseMood('anxious'),
      );

      // The selected mood stays, but anxious is now the first of the carousel.
      expect(find.text('Feliz'), findsOneWidget);
      await swipePrevious(tester);
      expect(find.text('Ansioso'), findsOneWidget);
    });

    testWidgets('returning to the tab after restoring purchases reorders',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository(
        restorableMoodIds: {'anxious'},
      );
      final active = ValueNotifier<bool>(true);
      addTearDown(active.dispose);
      moodRepository.savedEntries.addAll([
        entry('anxious', DateTime(2026, 3, 1)),
        entry('anxious', DateTime(2026, 3, 2)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(
          entitlements: entitlements,
          selectedDate: DateTime(2026, 3, 10),
          active: active,
        ),
      );
      await tester.pumpAndSettle();

      await leaveAndReturn(
        tester,
        active,
        whileAway: entitlements.restorePurchases,
      );

      expect(find.text('Feliz'), findsOneWidget);
      await swipePrevious(tester);
      expect(find.text('Ansioso'), findsOneWidget);
    });

    testWidgets('reordering keeps the mood the user had selected',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository();
      final active = ValueNotifier<bool>(true);
      addTearDown(active.dispose);
      moodRepository.savedEntries.addAll([
        entry('anxious', DateTime(2026, 3, 1)),
        entry('anxious', DateTime(2026, 3, 2)),
      ]);

      await tester.pumpWidget(
        buildOrderedApp(
          entitlements: entitlements,
          selectedDate: DateTime(2026, 3, 10),
          active: active,
        ),
      );
      await tester.pumpAndSettle();
      await swipeNext(tester);
      expect(find.text('Tranquilo'), findsOneWidget);

      await leaveAndReturn(
        tester,
        active,
        whileAway: () => entitlements.purchaseMood('anxious'),
      );

      expect(find.text('Tranquilo'), findsOneWidget);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(moodRepository.savedEntries.last.mood, 'assets/icon/calm.svg');
    });

    testWidgets('returning to the tab with nothing new keeps the carousel',
        (tester) async {
      final active = ValueNotifier<bool>(true);
      addTearDown(active.dispose);

      await tester.pumpWidget(
        buildOrderedApp(
          selectedDate: DateTime(2026, 3, 10),
          active: active,
        ),
      );
      await tester.pumpAndSettle();
      await swipeNext(tester);
      expect(find.text('Tranquilo'), findsOneWidget);

      await leaveAndReturn(tester, active);

      expect(find.text('Tranquilo'), findsOneWidget);
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

    group('mood grid sheet', () {
      final es = AppStrings.forLocale(const Locale('es'));
      final total = allMoodDefinitions.length;

      Future<void> openGrid(WidgetTester tester) async {
        await tester.tap(find.byTooltip(es.moodGridButtonLabel));
        await tester.pumpAndSettle();
      }

      Finder inGrid(String text) => find.descendant(
            of: find.byType(MoodGridSheet),
            matching: find.text(text),
          );

      List<String> gridOrder(WidgetTester tester) => tester
          .widget<MoodGridSheet>(find.byType(MoodGridSheet))
          .moods
          .map((mood) => mood.id)
          .toList();

      testWidgets('the counter shows the position and follows the carousel',
          (tester) async {
        await tester.pumpWidget(buildOrderedApp());
        await tester.pumpAndSettle();

        expect(find.text('1 / $total'), findsOneWidget);

        await swipeNext(tester);

        expect(find.text('2 / $total'), findsOneWidget);
      });

      group('swipe affordance', () {
        Future<void> tapArrow(WidgetTester tester, String tooltip) async {
          await tester.tap(find.byTooltip(tooltip));
          await tester.pumpAndSettle();
        }

        testWidgets('neighbors are visible but only the selected shows a name',
            (tester) async {
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();
          await swipeNext(tester);

          // Selected: calm. Its neighbors (happy, neutral) are built, smaller,
          // and have no visible name.
          expect(find.text(es.moodName('calm')), findsOneWidget);
          expect(find.text(es.moodName('happy')), findsNothing);
          expect(find.text(es.moodName('neutral')), findsNothing);
          final neighborSvgs = find.bySemanticsLabel(es.moodName('neutral'));
          expect(neighborSvgs, findsWidgets);
        });

        double fraction(WidgetTester tester) => tester
            .widget<PageView>(find.byType(PageView))
            .controller!
            .viewportFraction;

        void useScreen(WidgetTester tester, Size size) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
        }

        testWidgets('a phone shows half of each neighbor', (tester) async {
          useScreen(tester, const Size(390, 844));
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();

          expect(fraction(tester), 0.5);
        });

        testWidgets('a wide screen caps the page width so neighbors stay close',
            (tester) async {
          useScreen(tester, const Size(1032, 1376));
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();

          expect(fraction(tester), closeTo(240 / 1032, 0.001));
        });

        testWidgets(
            'the save button is full width on a phone and capped on iPad',
            (tester) async {
          useScreen(tester, const Size(390, 844));
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();
          final phone = tester.getSize(find.byType(GradientPillButton)).width;
          expect(phone, 390 - 32);

          useScreen(tester, const Size(1032, 1376));
          await tester.pumpAndSettle();
          final tablet = tester.getSize(find.byType(GradientPillButton)).width;
          expect(tablet, FloatingTabBar.maxWidth);
        });

        testWidgets('rotating keeps the selected mood and adapts the width',
            (tester) async {
          useScreen(tester, const Size(1032, 1376));
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();
          await tapArrow(tester, es.nextMoodLabel);
          await tapArrow(tester, es.nextMoodLabel);
          expect(find.text('3 / $total'), findsOneWidget);

          useScreen(tester, const Size(390, 844));
          await tester.pumpAndSettle();

          expect(fraction(tester), 0.5);
          expect(find.text('3 / $total'), findsOneWidget);
          expect(find.text(es.moodName('neutral')), findsOneWidget);
        });

        testWidgets('the arrows move one mood and disable at the ends',
            (tester) async {
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();

          IconButton arrow(String tooltip) => tester.widget<IconButton>(
                find.widgetWithIcon(
                  IconButton,
                  tooltip == es.previousMoodLabel
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                ),
              );
          expect(arrow(es.previousMoodLabel).onPressed, isNull);

          await tapArrow(tester, es.nextMoodLabel);
          expect(find.text('2 / $total'), findsOneWidget);
          expect(arrow(es.previousMoodLabel).onPressed, isNotNull);

          await tapArrow(tester, es.previousMoodLabel);
          expect(find.text('1 / $total'), findsOneWidget);
        });

        testWidgets('the next arrow is disabled on the last mood',
            (tester) async {
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();

          await tester.tap(find.byTooltip(es.moodGridButtonLabel));
          await tester.pumpAndSettle();
          await tester.ensureVisible(
            find.descendant(
              of: find.byType(MoodGridSheet),
              matching: find.text(es.moodName('stressed')),
            ),
          );
          await tester.tap(find.descendant(
            of: find.byType(MoodGridSheet),
            matching: find.text(es.moodName('stressed')),
          ));
          await tester.pumpAndSettle();
          // Locked: the sheet opens the purchase flow and keeps the pick, so
          // reach the end with the arrow instead.
          await tester.tap(find.text('Cancelar'));
          await tester.pumpAndSettle();
          for (var i = 0; i < total - 1; i++) {
            await tapArrow(tester, es.nextMoodLabel);
          }

          expect(find.text('$total / $total'), findsOneWidget);
          expect(
            tester
                .widget<IconButton>(find.widgetWithIcon(
                    IconButton, Icons.chevron_right_rounded))
                .onPressed,
            isNull,
          );
        });

        testWidgets('tapping a locked neighbor centers it without a purchase',
            (tester) async {
          // anxious (locked) is the neighbor of angry, the last unlocked one.
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();
          for (var i = 0; i < 4; i++) {
            await tapArrow(tester, es.nextMoodLabel);
          }
          expect(find.text('5 / $total'), findsOneWidget);

          // Tap on the right neighbor (page width is 240 on this 800 pt test view).
          await tester.tapAt(
            tester.getCenter(find.byType(PageView)) + const Offset(200, 0),
          );
          await tester.pumpAndSettle();

          expect(find.text('6 / $total'), findsOneWidget);
          expect(find.text('No hay ánimos premium disponibles por ahora.'),
              findsNothing);
        });

        testWidgets('tapping the selected locked mood opens the purchase flow',
            (tester) async {
          await tester.pumpWidget(buildOrderedApp());
          await tester.pumpAndSettle();
          for (var i = 0; i < 5; i++) {
            await tapArrow(tester, es.nextMoodLabel);
          }

          await tester.tap(find.text(es.moodName('anxious')));
          await tester.pumpAndSettle();

          expect(find.text('No hay ánimos premium disponibles por ahora.'),
              findsOneWidget);
        });
      });

      testWidgets('opens with every mood in the carousel order',
          (tester) async {
        moodRepository.savedEntries.addAll([
          entry('angry', DateTime(2026, 3, 1)),
          entry('angry', DateTime(2026, 3, 2)),
        ]);
        await tester.pumpWidget(
          buildOrderedApp(selectedDate: DateTime(2026, 3, 10)),
        );
        await tester.pumpAndSettle();

        await openGrid(tester);

        expect(find.text(es.moodGridTitle), findsOneWidget);
        final order = gridOrder(tester);
        expect(order, hasLength(total));
        expect(order.first, 'angry');
        expect(order.last, 'stressed');
      });

      testWidgets('jumping to a far mood selects it and keeps the note',
          (tester) async {
        await tester.pumpWidget(
          buildOrderedApp(
            entitlements: FakeMoodEntitlementsRepository(
              unlockedMoodIds: {'anxious', 'shy'},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Nota'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'sigue aquí');
        await tester.tap(find.text('Listo'));
        await tester.pumpAndSettle();

        await openGrid(tester);
        await tester.tap(inGrid(es.moodName('shy')));
        await tester.pumpAndSettle();

        expect(find.byType(MoodGridSheet), findsNothing);
        expect(find.text('7 / $total'), findsOneWidget);
        expect(find.text(es.moodName('shy')), findsOneWidget);

        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        expect(moodRepository.savedEntries.single.mood, 'assets/icon/shy.svg');
        expect(moodRepository.savedEntries.single.note, 'sigue aquí');
      });

      testWidgets('a locked mood opens the purchase flow and keeps the pick',
          (tester) async {
        await tester.pumpWidget(buildOrderedApp());
        await tester.pumpAndSettle();

        await openGrid(tester);
        await tester.tap(inGrid(es.moodName('brave')));
        await tester.pumpAndSettle();

        expect(find.byType(MoodGridSheet), findsNothing);
        expect(find.text('No hay ánimos premium disponibles por ahora.'),
            findsOneWidget);
        expect(find.text('1 / $total'), findsOneWidget);
      });

      testWidgets('the order does not change while the sheet is open',
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
        await openGrid(tester);
        final before = gridOrder(tester);

        await entitlements.purchaseMood('anxious');
        await tester.pumpAndSettle();

        expect(gridOrder(tester), before);
      });

      testWidgets('at 200% in German the sheet overflows nothing',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final de = AppStrings.forLocale(const Locale('de'));

        await tester.pumpWidget(
          buildApp(locale: const Locale('de'), textScale: 2),
        );
        await tester.pumpAndSettle();
        // At 200% the button is below the fold; the picker scrolls to it.
        await tester.ensureVisible(find.byTooltip(de.moodGridButtonLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(de.moodGridButtonLabel));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(de.moodGridTitle), findsOneWidget);
      });
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
      FakeMoodEntitlementsRepository? entitlements,
    }) {
      final moods = repository ?? moodRepository;
      final settingsRepository = _FakeSettingsRepository();
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppLogger>.value(value: const _TestAppLogger()),
          RepositoryProvider<AnalyticsReporter>.value(
            value: const NoopAnalyticsReporter(),
          ),
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
              create: (_) => PurchasesCubit(
                entitlements ?? FakeMoodEntitlementsRepository(),
              ),
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

    testWidgets('the store tab retries a catalog that failed at startup',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository(
        offers: const [
          MoodOffer(
            moodId: 'anxious',
            displayPrice: r'$0.99',
            productId: 'mood_anxious_unlock',
          ),
        ],
        failCatalogLoads: 1,
      );
      await tester.pumpWidget(buildApp(entitlements: entitlements));
      await tester.pumpAndSettle();
      expect(entitlements.catalogLoadCount, 1);

      await openTab(tester, strings.openStoreTooltip);

      expect(find.text(strings.storeLoadError), findsNothing);
      expect(find.text(strings.moodName('anxious')), findsOneWidget);
      expect(entitlements.catalogLoadCount, 2);
    });

    testWidgets('returning to the store tab retries after a failed retry',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository(
        offers: const [
          MoodOffer(
            moodId: 'anxious',
            displayPrice: r'$0.99',
            productId: 'mood_anxious_unlock',
          ),
        ],
        // Falla al arrancar y también en el reintento de la primera visita.
        failCatalogLoads: 2,
      );
      await tester.pumpWidget(buildApp(entitlements: entitlements));
      await tester.pumpAndSettle();

      await openTab(tester, strings.openStoreTooltip);
      expect(find.text(strings.storeLoadError), findsOneWidget);
      expect(entitlements.catalogLoadCount, 2);

      await openTab(tester, strings.openCalendarTooltip);
      await openTab(tester, strings.openStoreTooltip);

      expect(find.text(strings.storeLoadError), findsNothing);
      expect(find.text(strings.moodName('anxious')), findsOneWidget);
      expect(entitlements.catalogLoadCount, 3);
    });

    testWidgets('returning to the store tab does not reload a loaded catalog',
        (tester) async {
      final entitlements = FakeMoodEntitlementsRepository(
        offers: const [
          MoodOffer(
            moodId: 'anxious',
            displayPrice: r'$0.99',
            productId: 'mood_anxious_unlock',
          ),
        ],
      );
      await tester.pumpWidget(buildApp(entitlements: entitlements));
      await tester.pumpAndSettle();

      await openTab(tester, strings.openStoreTooltip);
      await openTab(tester, strings.openCalendarTooltip);
      await openTab(tester, strings.openStoreTooltip);

      expect(entitlements.catalogLoadCount, 1);
      expect(find.text(strings.moodName('anxious')), findsOneWidget);
    });

    for (final otherTab in ['calendar', 'store', 'settings']) {
      testWidgets(
          'a purchase made from the $otherTab tab reorders the picker on return',
          (tester) async {
        final entitlements = FakeMoodEntitlementsRepository();
        moodRepository.savedEntries.addAll([
          MoodEntry(
            date: DateTime(now.year, now.month - 1, 1),
            mood: 'assets/icon/anxious.svg',
            intensity: 1,
          ),
          MoodEntry(
            date: DateTime(now.year, now.month - 1, 2),
            mood: 'assets/icon/anxious.svg',
            intensity: 1,
          ),
        ]);

        await tester.pumpWidget(buildApp(entitlements: entitlements));
        await tester.pumpAndSettle();
        expect(find.text('Feliz'), findsOneWidget);

        await openTab(
          tester,
          switch (otherTab) {
            'calendar' => strings.openCalendarTooltip,
            'store' => strings.openStoreTooltip,
            _ => strings.openSettingsTooltip,
          },
        );
        await entitlements.purchaseMood('anxious');
        await tester.pumpAndSettle();
        await openTab(tester, strings.openMoodPickerTooltip);

        expect(tester.takeException(), isNull);
        expect(find.text('Feliz'), findsOneWidget);
        await dragPage(tester, forward: false);
        await tester.pumpAndSettle();
        expect(find.text('Ansioso'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
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
      await dragPage(tester);
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
          RepositoryProvider<AnalyticsReporter>.value(
            value: const NoopAnalyticsReporter(),
          ),
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
