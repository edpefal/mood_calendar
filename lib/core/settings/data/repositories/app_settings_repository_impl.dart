import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../datasources/app_settings_local_datasource.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._localDataSource);

  final AppSettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> getSettings() => _localDataSource.getSettings();

  @override
  Future<void> saveSettings(AppSettings settings) =>
      _localDataSource.saveSettings(settings);
}
