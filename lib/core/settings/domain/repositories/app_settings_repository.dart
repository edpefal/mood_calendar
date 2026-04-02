import '../entities/app_settings.dart';

abstract class AppSettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}
