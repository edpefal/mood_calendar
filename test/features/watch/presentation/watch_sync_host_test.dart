import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings_en.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/watch/domain/entities/watch_mood_choice.dart';
import 'package:mood_calendar/features/watch/domain/services/watch_sync_coordinator.dart';
import 'package:mood_calendar/features/watch/domain/usecases/process_watch_inbox_usecase.dart';
import 'package:mood_calendar/features/watch/domain/usecases/publish_watch_state_usecase.dart';
import 'package:mood_calendar/features/watch/presentation/watch_sync_host.dart';

import '../../../support/fake_crash_reporter.dart';
import '../../../support/fake_watch_channel.dart';
import '../../../support/in_memory_mood_repository.dart';

class _RecordingTelemetry implements AppTelemetry {
  final List<String> events = [];

  @override
  void trackEvent(String name, {Map<String, Object?> properties = const {}}) {
    events.add(name);
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

void main() {
  testWidgets(
    'una elección del reloj recarga calendario y selector sin guardar por la '
    'ruta de la UI',
    (tester) async {
      final repository = InMemoryMoodRepository();
      final channel = FakeWatchChannel();
      final telemetry = _RecordingTelemetry();
      bool isUnlocked(String id) =>
          const {'happy', 'calm', 'neutral', 'sad', 'angry'}.contains(id);
      final coordinator = WatchSyncCoordinator(
        processInbox: ProcessWatchInboxUseCase(
          repository: repository,
          channel: channel,
          isUnlocked: isUnlocked,
        ),
        publishState: PublishWatchStateUseCase(
          repository: repository,
          channel: channel,
          isUnlocked: isUnlocked,
          strings: () => const AppStringsEn(),
        ),
        channel: channel,
        unlockedMoodIds: const Stream.empty(),
        logger: RecordingLogger(),
        publishDebounce: const Duration(milliseconds: 5),
      );

      final moodStates = <MoodState>[];
      late MoodCubit moodCubit;
      late CalendarCubit calendarCubit;

      await tester.pumpWidget(
        RepositoryProvider<WatchSyncCoordinator>.value(
          value: coordinator,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => moodCubit = MoodCubit(
                  saveMood: SaveMoodUseCase(repository),
                  getMoods: GetMoodsUseCase(repository),
                  logger: RecordingLogger(),
                  telemetry: telemetry,
                )..stream.listen(moodStates.add),
              ),
              BlocProvider(
                create: (_) => calendarCubit = CalendarCubit(
                  initialMonth: DateTime.now(),
                  getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                    GetMoodsForMonthUseCase(repository),
                  ),
                ),
              ),
            ],
            child: const WatchSyncHost(child: SizedBox()),
          ),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(
            const Duration(milliseconds: 40),
          ));
      moodStates.clear();

      final now = DateTime.now();
      channel.deliver(
        WatchMoodChoice(
          id: 'a',
          date: '${now.year.toString().padLeft(4, '0')}-'
              '${now.month.toString().padLeft(2, '0')}-'
              '${now.day.toString().padLeft(2, '0')}',
          mood: 'calm',
          chosenAt: now.millisecondsSinceEpoch,
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(
            const Duration(milliseconds: 80),
          ));

      final loaded = moodCubit.state.maybeWhen(
        loaded: (entries) => entries,
        orElse: () => null,
      );
      expect(loaded, isNotNull);
      expect(loaded!.single.mood, 'assets/icon/calm.svg');
      expect(calendarCubit.state.summary?.entries, hasLength(1));
      // No pasa por MoodCubit.save: ni estado `saved` (que cambia de pestaña y
      // cuenta para el pedido de calificación) ni evento de analíticas.
      expect(
          moodStates
              .any((s) => s.maybeWhen(saved: () => true, orElse: () => false)),
          isFalse);
      expect(telemetry.events, isEmpty);

      // Cancela el debounce de publicación antes de que termine el test.
      await tester.runAsync(coordinator.dispose);
    },
  );
}
