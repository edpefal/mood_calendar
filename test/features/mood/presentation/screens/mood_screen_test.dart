import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/data/models/mood_model.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/screens/mood_screen.dart';
import 'package:mood_calendar/features/premium/domain/entities/mood_store_product.dart';
import 'package:mood_calendar/features/premium/domain/entities/premium_snapshot.dart';
import 'package:mood_calendar/features/premium/domain/repositories/premium_repository.dart';
import 'package:mood_calendar/features/premium/presentation/bloc/premium_cubit.dart';

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

class _FakePremiumRepository implements PremiumRepository {
  _FakePremiumRepository(this._snapshot);

  final _controller = StreamController<PremiumSnapshot>.broadcast();
  final PremiumSnapshot _snapshot;
  int restoreCalls = 0;
  final boughtMoodIds = <String>[];

  @override
  PremiumSnapshot get currentSnapshot => _snapshot;

  @override
  Future<void> buyMood(String moodId) async {
    boughtMoodIds.add(moodId);
  }

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<void> initialize() async {
    _controller.add(_snapshot);
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
  }

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

void main() {
  late Directory tempDir;
  late Box<MoodModel> moodBox;
  late _FakeMoodRepository moodRepository;

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

  testWidgets(
      'tapping save on a locked mood opens purchase sheet instead of saving',
      (tester) async {
    final premiumRepository = _FakePremiumRepository(
      const PremiumSnapshot(
        productsByMoodId: {
          'shy': MoodStoreProduct(
            moodId: 'shy',
            productId: 'mood_shy_unlock',
            title: 'Shy',
            description: 'Unlock Shy',
            price: '\$0.99',
            isAvailable: true,
          ),
        },
        isStoreAvailable: true,
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
              initialMonth: DateTime(2026, 4, 1),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(moodRepository),
              ),
            ),
          ),
          BlocProvider(
            create: (_) => PremiumCubit(repository: premiumRepository),
          ),
        ],
        child: const MaterialApp(home: MoodScreen()),
      ),
    );

    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    expect(find.text('Shy'), findsOneWidget);

    await tester.tap(find.textContaining('Unlock Shy'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock Shy'), findsAtLeastNWidgets(1));
    expect(
        find.text('Buy this mood once and use it everywhere in Mood Calendar.'),
        findsOneWidget);
    expect(moodRepository.savedEntries, isEmpty);
    expect(premiumRepository.boughtMoodIds, isEmpty);
  });

  testWidgets('restore button delegates to premium repository', (tester) async {
    final premiumRepository = _FakePremiumRepository(const PremiumSnapshot());

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
            create: (_) => PremiumCubit(repository: premiumRepository),
          ),
        ],
        child: const MaterialApp(home: MoodScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore'));
    await tester.pump();

    expect(premiumRepository.restoreCalls, 1);
  });
}
