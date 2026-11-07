import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/notifications/local_notification_service.dart';
import 'package:mood_calendar/core/settings/domain/entities/app_settings.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/telemetry/analytics_reporter.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/theme/app_theme.dart';
import 'package:mood_calendar/core/theme/theme_cubit.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/repositories/mood_repository.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/note_lock/presentation/bloc/note_lock_cubit.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';

import 'fake_mood_entitlements_repository.dart';
import 'fake_note_lock_authenticator.dart';
import 'in_memory_mood_repository.dart';

class TestAppLogger implements AppLogger {
  const TestAppLogger();

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

/// Telemetry that remembers the events it receives.
class RecordingTelemetry implements AppTelemetry {
  RecordingTelemetry();

  final List<({String name, Map<String, Object?> properties})> events = [];

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
  }) {
    events.add((name: name, properties: properties));
  }
}

class FakeRatingPromptService implements RatingPromptService {
  int maybeRequestCalls = 0;
  int openStoreListingCalls = 0;

  @override
  Future<void> maybeRequestAfterSave() async {
    maybeRequestCalls++;
  }

  @override
  Future<void> openStoreListing() async {
    openStoreListingCalls++;
  }
}

class FakeSettingsRepository implements AppSettingsRepository {
  FakeSettingsRepository([this.settings = AppSettings.defaults]);

  AppSettings settings;

  /// Los siguientes `saveSettings` fallan y decrementan este contador.
  int failNextSaves = 0;
  final List<AppSettings> saved = [];

  @override
  Future<AppSettings> getSettings() async => settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    if (failNextSaves > 0) {
      failNextSaves--;
      throw StateError('save failed');
    }
    saved.add(settings);
    this.settings = settings;
  }
}

/// The app's repositories and cubits around [child], as `main()` composes
/// them. [buildTestApp] adds a `MaterialApp`; tests of `MyApp` use this alone.
Widget buildTestProviders({
  required Widget child,
  MoodRepository? moods,
  FakeMoodEntitlementsRepository? entitlements,
  FakeRatingPromptService? ratingPromptService,
  FakeSettingsRepository? settingsRepository,
  ThemeCubit? themeCubit,
  NoteLockCubit? noteLockCubit,
  AppTelemetry telemetry = const _SilentTelemetry(),
  DateTime? calendarMonth,
}) {
  final repository = moods ?? InMemoryMoodRepository();
  final settings = settingsRepository ?? FakeSettingsRepository();
  final month = calendarMonth ?? DateTime.now();

  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<AppLogger>.value(value: const TestAppLogger()),
      RepositoryProvider<AnalyticsReporter>.value(
        value: const NoopAnalyticsReporter(),
      ),
      RepositoryProvider<AppSettingsRepository>.value(value: settings),
      RepositoryProvider<LocalNotificationService>.value(
        value: LocalNotificationService(
          onReminderTap: () async {},
          appSettingsRepository: settings,
          telemetry: const _SilentTelemetry(),
        ),
      ),
      RepositoryProvider<RatingPromptService>.value(
        value: ratingPromptService ?? FakeRatingPromptService(),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => themeCubit ?? ThemeCubit()),
        BlocProvider(
          create: (_) =>
              noteLockCubit ??
              NoteLockCubit(
                authenticator: FakeNoteLockAuthenticator(),
                telemetry: const _SilentTelemetry(),
                isSubscribed: () => false,
              ),
        ),
        BlocProvider(
          create: (_) => MoodCubit(
            saveMood: SaveMoodUseCase(repository),
            getMoods: GetMoodsUseCase(repository),
            logger: const TestAppLogger(),
            telemetry: const _SilentTelemetry(),
          ),
        ),
        BlocProvider(
          create: (_) => CalendarCubit(
            initialMonth: DateTime(month.year, month.month),
            getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
              GetMoodsForMonthUseCase(repository),
            ),
          ),
        ),
        BlocProvider(
          // Eager, like the app: the Log reads it as soon as it builds.
          lazy: false,
          create: (_) => PurchasesCubit(
            entitlements ?? FakeMoodEntitlementsRepository(),
            telemetry: telemetry,
          ),
        ),
      ],
      child: child,
    ),
  );
}

/// [buildTestProviders] around a `MaterialApp` showing [home].
Widget buildTestApp({
  required Widget home,
  MoodRepository? moods,
  FakeMoodEntitlementsRepository? entitlements,
  FakeRatingPromptService? ratingPromptService,
  FakeSettingsRepository? settingsRepository,
  ThemeCubit? themeCubit,
  NoteLockCubit? noteLockCubit,
  AppTelemetry telemetry = const _SilentTelemetry(),
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  DateTime? calendarMonth,
}) {
  return buildTestProviders(
    moods: moods,
    entitlements: entitlements,
    ratingPromptService: ratingPromptService,
    settingsRepository: settingsRepository,
    themeCubit: themeCubit,
    noteLockCubit: noteLockCubit,
    telemetry: telemetry,
    calendarMonth: calendarMonth,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: themeMode,
      home: home,
    ),
  );
}

class _SilentTelemetry implements AppTelemetry {
  const _SilentTelemetry();

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
