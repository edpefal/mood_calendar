import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:path_provider/path_provider.dart';

import 'core/localization/app_strings.dart';
import 'core/logging/logger_app_logger.dart';
import 'core/navigation/app_navigator.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/settings/data/datasources/app_settings_local_datasource.dart';
import 'core/settings/data/repositories/app_settings_repository_impl.dart';
import 'core/settings/domain/repositories/app_settings_repository.dart';
import 'core/telemetry/app_telemetry_config.dart';
import 'core/telemetry/logger_app_telemetry.dart';
import 'features/mood/data/models/mood_model.dart';
import 'features/mood/data/repositories/mood_repository_impl.dart';
import 'features/mood/domain/usecases/get_moods_for_month_usecase.dart';
import 'features/mood/domain/usecases/get_monthly_mood_summary_usecase.dart';
import 'features/mood/domain/usecases/get_moods_usecase.dart';
import 'features/mood/domain/usecases/save_mood_usecase.dart';
import 'features/mood/presentation/bloc/calendar_cubit.dart';
import 'features/mood/presentation/bloc/mood_cubit.dart';
import 'features/mood/presentation/screens/mood_screen.dart';
import 'features/premium/data/datasources/premium_local_datasource.dart';
import 'features/premium/data/datasources/premium_purchase_datasource.dart';
import 'features/premium/data/repositories/premium_repository_impl.dart';
import 'features/premium/presentation/bloc/premium_cubit.dart';

final navigatorKey = GlobalKey<NavigatorState>();
bool _isHandlingReminderTap = false;

Future<void> _handleReminderTap() {
  if (_isHandlingReminderTap) {
    return Future.value();
  }
  _isHandlingReminderTap = true;
  final date = DateTime.now();
  final targetDate = DateTime(date.year, date.month, date.day);
  final completer = Completer<void>();

  void navigate() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
      return;
    }
    AppNavigator.openMoodFromReminder(
      navigator,
      selectedDate: targetDate,
    );
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
  await Hive.openBox<dynamic>('premium_entitlements');

  final moodBox = Hive.box<MoodModel>('moods');
  final settingsBox = Hive.box<dynamic>(AppSettingsLocalDataSource.boxName);
  final premiumEntitlementsBox = Hive.box<dynamic>('premium_entitlements');

  final appLogger = LoggerAppLogger();
  final telemetry = LoggerAppTelemetry(
    logger: appLogger,
    config: AppTelemetryConfig.fromEnvironment(),
  );
  final repository = MoodRepositoryImpl(moodBox, logger: appLogger);
  final appSettingsRepository = AppSettingsRepositoryImpl(
    AppSettingsLocalDataSource(settingsBox),
  );
  final premiumRepository = PremiumRepositoryImpl(
    localDataSource: PremiumLocalDataSource(premiumEntitlementsBox),
    purchaseDataSource: StorePremiumPurchaseDataSource(InAppPurchase.instance),
  );
  final notificationService = LocalNotificationService(
    onReminderTap: _handleReminderTap,
    appSettingsRepository: appSettingsRepository,
    telemetry: telemetry,
  );
  final launchedFromReminder = await notificationService.initialize();
  await notificationService.scheduleDailyReminder();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppSettingsRepository>.value(
          value: appSettingsRepository,
        ),
        RepositoryProvider<LocalNotificationService>.value(
          value: notificationService,
        ),
        RepositoryProvider.value(value: premiumRepository),
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
            create: (context) => PremiumCubit(
              repository: context.read<PremiumRepositoryImpl>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );

  if (launchedFromReminder) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_handleReminderTap());
    });
  }
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
      title: AppStrings.spanish.appTitle,
      navigatorKey: navigatorKey,
      locale: const Locale('es'),
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
      home: const MoodScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
