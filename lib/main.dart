import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/localization/app_strings.dart';
import 'core/logging/app_logger.dart';
import 'core/logging/logger_app_logger.dart';
import 'core/navigation/main_shell.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/rating/review_requester.dart';
import 'core/settings/data/datasources/app_settings_local_datasource.dart';
import 'core/settings/data/datasources/rating_prompt_local_datasource.dart';
import 'core/settings/data/repositories/app_settings_repository_impl.dart';
import 'core/settings/domain/repositories/app_settings_repository.dart';
import 'core/telemetry/app_telemetry_config.dart';
import 'core/telemetry/logger_app_telemetry.dart';
import 'features/mood/data/models/mood_model.dart';
import 'features/mood/data/repositories/mood_repository_impl.dart';
import 'features/mood/data/services/rating_prompt_service.dart';
import 'features/mood/data/services/json_mood_history_exporter.dart';
import 'features/mood/domain/usecases/export_mood_history_usecase.dart';
import 'features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'features/mood/domain/usecases/get_moods_usecase.dart';
import 'features/mood/domain/usecases/save_mood_usecase.dart';
import 'features/mood/presentation/bloc/calendar_cubit.dart';
import 'features/mood/presentation/bloc/mood_cubit.dart';
import 'features/purchases/data/datasources/revenue_cat_datasource.dart';
import 'features/purchases/data/repositories/mood_entitlements_repository_impl.dart';
import 'features/purchases/data/repositories/noop_mood_entitlements_repository.dart';
import 'features/purchases/domain/repositories/mood_entitlements_repository.dart';
import 'features/purchases/presentation/bloc/purchases_cubit.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final mainShellKey = GlobalKey<MainShellState>();
bool _isHandlingReminderTap = false;

/// Abre el selector de moods de hoy cuando el usuario toca el recordatorio.
@visibleForTesting
Future<void> handleReminderTap() {
  if (_isHandlingReminderTap) {
    return Future.value();
  }
  _isHandlingReminderTap = true;
  final date = DateTime.now();
  final targetDate = DateTime(date.year, date.month, date.day);
  final completer = Completer<void>();

  void navigate() {
    final navigator = navigatorKey.currentState;
    final shell = mainShellKey.currentState;
    if (navigator == null || shell == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
      return;
    }
    // Cierra los modales abiertos (editor de nota, hojas de compra) antes de
    // mostrar el selector de la fecha del recordatorio.
    navigator.popUntil((route) => route.isFirst);
    shell.showMoodPicker(targetDate);
    _isHandlingReminderTap = false;
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  navigate();
  return completer.future;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(MoodModelAdapter());

  await Hive.openBox<MoodModel>('moods');
  await Hive.openBox<dynamic>(AppSettingsLocalDataSource.boxName);

  final moodBox = Hive.box<MoodModel>('moods');
  final settingsBox = Hive.box<dynamic>(AppSettingsLocalDataSource.boxName);

  final appLogger = LoggerAppLogger();
  final telemetry = LoggerAppTelemetry(
    logger: appLogger,
    config: AppTelemetryConfig.fromEnvironment(),
  );
  final repository = MoodRepositoryImpl(moodBox, logger: appLogger);
  final appSettingsRepository = AppSettingsRepositoryImpl(
    AppSettingsLocalDataSource(settingsBox),
  );
  final notificationService = LocalNotificationService(
    onReminderTap: handleReminderTap,
    appSettingsRepository: appSettingsRepository,
    telemetry: telemetry,
  );
  final exportMoodHistory = ExportMoodHistoryUseCase(
    JsonMoodHistoryExporter(
      repository: repository,
      logger: appLogger,
      telemetry: telemetry,
    ),
  );
  final ratingPromptService = RatingPromptService(
    getMoods: GetMoodsUseCase(repository),
    stateDataSource: RatingPromptLocalDataSource(settingsBox),
    reviewRequester: InAppReviewRequester(),
    telemetry: telemetry,
  );

  const revenueCatApiKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  final MoodEntitlementsRepository moodEntitlementsRepository;
  if (revenueCatApiKey.isNotEmpty) {
    await RevenueCatDatasource.configure(revenueCatApiKey);
    moodEntitlementsRepository = MoodEntitlementsRepositoryImpl(
      RevenueCatDatasource(),
    );
  } else {
    // Never touch purchases_flutter before Purchases.configure() — doing so
    // crashes natively with an uncatchable Swift fatalError. Fall back to a
    // no-op repository (all premium moods locked) instead of taking down
    // the whole app when the key is missing, e.g. launching from VS Code's
    // "Run" button without a launch.json that sets --dart-define.
    appLogger.error(
      'REVENUECAT_IOS_API_KEY was not provided via --dart-define; '
      'purchases will not work.',
      tag: 'main',
    );
    moodEntitlementsRepository = const NoopMoodEntitlementsRepository();
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppLogger>.value(value: appLogger),
        RepositoryProvider<AppSettingsRepository>.value(
          value: appSettingsRepository,
        ),
        RepositoryProvider<LocalNotificationService>.value(
          value: notificationService,
        ),
        RepositoryProvider<RatingPromptService>.value(
          value: ratingPromptService,
        ),
        RepositoryProvider<ExportMoodHistoryUseCase>.value(
          value: exportMoodHistory,
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
          BlocProvider(
            create: (context) => PurchasesCubit(moodEntitlementsRepository),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );

  // Runs after runApp() on purpose: initialize() awaits the native OS
  // notification-permission dialog, which never resolves until the user
  // interacts with it. Awaiting it before runApp() left the app stuck on
  // the launch screen until that dialog was dismissed (see proposal.md).
  unawaited(
    notificationService.initialize().then((launchedFromReminder) async {
      await notificationService.scheduleDailyReminder();
      if (launchedFromReminder) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(handleReminderTap());
        });
      }
    }),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme);

    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appTitle,
      navigatorKey: navigatorKey,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: baseTheme.copyWith(
        textTheme: poppinsTextTheme,
        primaryTextTheme: poppinsTextTheme,
        colorScheme: baseTheme.colorScheme,
      ),
      home: MainShell(key: mainShellKey),
      debugShowCheckedModeBanner: false,
    );
  }
}
