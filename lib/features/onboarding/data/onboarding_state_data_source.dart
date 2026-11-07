import 'package:hive/hive.dart';

/// Whether the first-run onboarding was already finished or skipped. Lives in
/// the settings box, like the rating prompt state; a missing key means "not
/// yet", so installs that predate the onboarding need no migration.
class OnboardingStateDataSource {
  OnboardingStateDataSource(this._settingsBox);

  static const String _completedKey = 'onboarding_completed';

  final Box<dynamic> _settingsBox;

  bool get isCompleted =>
      _settingsBox.get(_completedKey, defaultValue: false) as bool;

  Future<void> markCompleted() => _settingsBox.put(_completedKey, true);
}
