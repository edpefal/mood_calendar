// Screenshot-only entrypoint (not shipped): seeds sample data, unlocks every
// premium mood and skips the notification permission flow so the app can be
// captured in a clean, repeatable state.
//
//   flutter run -t tool/screenshots/main.dart -d <simulator>
//
// Pass --dart-define=REVENUECAT_IOS_API_KEY=<key> to use the real store
// catalog instead of the all-unlocked fake (needed for the store screenshot).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/logging/logger_app_logger.dart';
import 'package:mood_calendar/core/notifications/local_notification_service.dart';
import 'package:mood_calendar/core/rating/review_requester.dart';
import 'package:mood_calendar/core/settings/data/datasources/app_settings_local_datasource.dart';
import 'package:mood_calendar/core/settings/data/datasources/rating_prompt_local_datasource.dart';
import 'package:mood_calendar/core/settings/data/repositories/app_settings_repository_impl.dart';
import 'package:mood_calendar/core/settings/domain/repositories/app_settings_repository.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_config.dart';
import 'package:mood_calendar/core/telemetry/logger_app_telemetry.dart';
import 'package:mood_calendar/features/mood/data/models/mood_model.dart';
import 'package:mood_calendar/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:mood_calendar/features/mood/data/services/rating_prompt_service.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/get_moods_usecase.dart';
import 'package:mood_calendar/features/mood/domain/usecases/save_mood_usecase.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/calendar_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/bloc/mood_cubit.dart';
import 'package:mood_calendar/features/mood/presentation/screens/mood_screen.dart';
import 'package:mood_calendar/features/purchases/data/datasources/revenue_cat_datasource.dart';
import 'package:mood_calendar/features/purchases/data/repositories/mood_entitlements_repository_impl.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_offer.dart';
import 'package:mood_calendar/features/purchases/domain/entities/mood_pack.dart';
import 'package:mood_calendar/features/purchases/domain/repositories/mood_entitlements_repository.dart';
import 'package:mood_calendar/features/purchases/presentation/bloc/purchases_cubit.dart';

/// Every day of the previous month, in order. `null` = no entry that day, so
/// the monthly summary shows a realistic streak (days 10-23 = 14 in a row).
const List<String?> _previousMonthMoods = [
  'happy', 'calm', 'happy', 'confident', 'calm', 'neutral', 'sad', null, //
  null, 'happy', 'happy', 'romantic', 'calm', 'happy', 'confident', 'calm',
  'angry', 'happy', 'brave', 'happy', 'calm', 'happy', 'confident', null,
  'anxious', 'calm', 'happy', 'shy', 'happy', 'calm',
];

/// Today's entry carries a note so the note editor has real content.
const Map<String, String> _todayNote = {
  'en': 'Coffee with Ana and a long walk by the river. A really good day.',
  'es': 'Café con Ana y un largo paseo junto al río. Un día muy bueno.',
  'de': 'Kaffee mit Ana und ein langer Spaziergang am Fluss. Ein richtig guter Tag.',
  'fr': 'Un café avec Ana et une longue promenade au bord de la rivière. Une très bonne journée.',
  'it': 'Un caffè con Ana e una lunga passeggiata lungo il fiume. Una giornata davvero bella.',
};

class _AllUnlockedEntitlementsRepository implements MoodEntitlementsRepository {
  const _AllUnlockedEntitlementsRepository();

  @override
  bool isUnlocked(String moodId) => true;

  @override
  Stream<Set<String>> unlockedPremiumMoodIds() async* {
    yield premiumMoodDefinitions.map((mood) => mood.id).toSet();
  }

  @override
  Future<List<MoodOffer>> availableMoodOffers() async => const [];

  @override
  Future<List<MoodPack>> availablePacks() async => const [];

  @override
  Future<void> purchaseMood(String moodId) async {}

  @override
  Future<void> purchasePack(String packId) async {}

  @override
  Future<void> restorePurchases() async {}
}

Future<void> _seed(Box<MoodModel> moodBox, Box<dynamic> settingsBox) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final languageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;

  await moodBox.clear();
  await settingsBox.clear();

  String keyFor(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> put(DateTime date, String moodId, {String? note}) {
    final definition = allMoodDefinitions.firstWhere((m) => m.id == moodId);
    return moodBox.put(
      keyFor(date),
      MoodModel(
        date: date,
        mood: definition.assetPath,
        note: note,
        intensity: definition.intensity,
      ),
    );
  }

  final previousMonth = DateTime(today.year, today.month - 1);
  for (var i = 0; i < _previousMonthMoods.length; i++) {
    final moodId = _previousMonthMoods[i];
    if (moodId == null) continue;
    await put(DateTime(previousMonth.year, previousMonth.month, i + 1), moodId);
  }

  const thisMonthMoods = ['happy', 'calm', 'confident', 'happy', 'calm'];
  for (var day = 1; day < today.day && day <= thisMonthMoods.length; day++) {
    await put(DateTime(today.year, today.month, day), thisMonthMoods[day - 1]);
  }

  await put(
    today,
    'happy',
    note: _todayNote[languageCode] ?? _todayNote['en'],
  );

  // Reminder shown as enabled at 8 PM, and the rating prompt already spent so
  // the system dialog never covers a screenshot.
  await settingsBox.put('daily_reminder_enabled', true);
  await settingsBox.put('daily_reminder_hour', 20);
  await settingsBox.put('daily_reminder_minute', 0);
  await settingsBox.put('rating_prompt_attempts', 2);
  await settingsBox.put(
    'rating_prompt_last_attempt_at',
    now.millisecondsSinceEpoch,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MoodModelAdapter());
  final moodBox = await Hive.openBox<MoodModel>('moods');
  final settingsBox =
      await Hive.openBox<dynamic>(AppSettingsLocalDataSource.boxName);
  await _seed(moodBox, settingsBox);

  final appLogger = LoggerAppLogger();
  final telemetry = LoggerAppTelemetry(
    logger: appLogger,
    config: AppTelemetryConfig.fromEnvironment(),
  );
  final repository = MoodRepositoryImpl(moodBox, logger: appLogger);
  final appSettingsRepository = AppSettingsRepositoryImpl(
    AppSettingsLocalDataSource(settingsBox),
  );
  // Never initialized on purpose: initialize() asks for notification
  // permission, which would put a system dialog on top of the screenshots.
  final notificationService = LocalNotificationService(
    onReminderTap: () async {},
    appSettingsRepository: appSettingsRepository,
    telemetry: telemetry,
  );
  final ratingPromptService = RatingPromptService(
    getMoods: GetMoodsUseCase(repository),
    stateDataSource: RatingPromptLocalDataSource(settingsBox),
    reviewRequester: InAppReviewRequester(),
    telemetry: telemetry,
  );

  const revenueCatApiKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  final MoodEntitlementsRepository entitlements;
  if (revenueCatApiKey.isNotEmpty) {
    await RevenueCatDatasource.configure(revenueCatApiKey);
    entitlements = MoodEntitlementsRepositoryImpl(RevenueCatDatasource());
  } else {
    entitlements = const _AllUnlockedEntitlementsRepository();
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppSettingsRepository>.value(
          value: appSettingsRepository,
        ),
        RepositoryProvider<LocalNotificationService>.value(
          value: notificationService,
        ),
        RepositoryProvider<RatingPromptService>.value(
          value: ratingPromptService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MoodCubit(
              saveMood: SaveMoodUseCase(repository),
              getMoods: GetMoodsUseCase(repository),
              logger: appLogger,
              telemetry: telemetry,
            ),
          ),
          BlocProvider(
            create: (context) => CalendarCubit(
              initialMonth: DateTime.now(),
              getMonthlyMoodSummary: GetMonthlyMoodSummaryUseCase(
                GetMoodsForMonthUseCase(repository),
              ),
            ),
          ),
          BlocProvider(create: (context) => PurchasesCubit(entitlements)),
        ],
        child: const _ScreenshotApp(),
      ),
    ),
  );
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme);

    return MaterialApp(
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: baseTheme.copyWith(
        textTheme: poppinsTextTheme,
        primaryTextTheme: poppinsTextTheme,
      ),
      home: const MoodScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
