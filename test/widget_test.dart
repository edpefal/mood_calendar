import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/screens/mood_screen.dart';
import 'package:mood_calendar/features/premium/domain/entities/premium_snapshot.dart';
import 'package:mood_calendar/features/premium/domain/repositories/premium_repository.dart';
import 'package:mood_calendar/features/premium/presentation/bloc/premium_cubit.dart';

void main() {
  testWidgets('Mood screen loads without reading Hive from the UI',
      (WidgetTester tester) async {
    final repository = _InMemoryMoodRepository(
      moods: [
        MoodEntry(
          date: DateTime(2026, 4, 1),
          mood: 'assets/icon/calm.svg',
          note: 'Existing note',
          intensity: 2,
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => MoodCubit(
              saveMood: SaveMoodUseCase(repository),
              getMoods: GetMoodsUseCase(repository),
              logger: const _TestAppLogger(),
              telemetry: const _TestAppTelemetry(),
            ),
          ),
          BlocProvider(
            create: (_) => CalendarCubit(
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(repository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PremiumCubit(repository: _FakePremiumRepository()),
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
          home: MoodScreen(selectedDate: DateTime(2026, 4, 1)),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Como te sientes hoy?'), findsOneWidget);
    expect(find.text('Abril 1, 2026'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Mood screen background gradient changes with selected mood',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        repository: _InMemoryMoodRepository(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final initialGradient = _currentBackgroundGradient(tester);
    expect(
      initialGradient.colors,
      const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    );

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    final nextGradient = _currentBackgroundGradient(tester);
    expect(
      nextGradient.colors,
      const [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    );
  });
}

Widget _buildTestApp({
  required MoodRepository repository,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => MoodCubit(
          saveMood: SaveMoodUseCase(repository),
          getMoods: GetMoodsUseCase(repository),
          logger: const _TestAppLogger(),
          telemetry: const _TestAppTelemetry(),
        ),
      ),
      BlocProvider(
        create: (_) => CalendarCubit(
          initialMonth: DateTime(2026, 4, 1),
          getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
            GetMoodsForMonthUseCase(repository),
          ),
        ),
      ),
      BlocProvider(
        create: (_) => PremiumCubit(repository: _FakePremiumRepository()),
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
      home: MoodScreen(selectedDate: DateTime(2026, 4, 1)),
    ),
  );
}

LinearGradient _currentBackgroundGradient(WidgetTester tester) {
  final animatedContainer =
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first);
  final decoration = animatedContainer.decoration! as BoxDecoration;
  return decoration.gradient! as LinearGradient;
}

class _InMemoryMoodRepository implements MoodRepository {
  _InMemoryMoodRepository({List<MoodEntry>? moods})
      : _moods = List<MoodEntry>.from(moods ?? const []);

  final List<MoodEntry> _moods;

  @override
  Future<List<MoodEntry>> getMoods() async => List<MoodEntry>.from(_moods);

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    return _moods.where((entry) {
      return entry.date.year == month.year && entry.date.month == month.month;
    }).toList();
  }

  @override
  Future<void> saveMood(MoodEntry entry) async {
    _moods.removeWhere((existing) {
      return existing.date.year == entry.date.year &&
          existing.date.month == entry.date.month &&
          existing.date.day == entry.date.day;
    });
    _moods.add(entry);
  }
}

class _FakePremiumRepository implements PremiumRepository {
  final _controller = StreamController<PremiumSnapshot>.broadcast();

  @override
  PremiumSnapshot get currentSnapshot => const PremiumSnapshot();

  @override
  Future<void> buyMood(String moodId) async {}

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<void> initialize() async {
    _controller.add(const PremiumSnapshot());
  }

  @override
  Future<void> restorePurchases() async {}

  @override
  Stream<PremiumSnapshot> watchSnapshot() => _controller.stream;
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
