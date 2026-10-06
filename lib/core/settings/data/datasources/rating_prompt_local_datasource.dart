import 'package:hive/hive.dart';

import '../../domain/entities/rating_prompt_state.dart';

class RatingPromptLocalDataSource {
  RatingPromptLocalDataSource(this._settingsBox);

  static const String _attemptsKey = 'rating_prompt_attempts';
  static const String _lastAttemptAtKey = 'rating_prompt_last_attempt_at';

  final Box<dynamic> _settingsBox;

  RatingPromptState getState() {
    final attempts = _settingsBox.get(_attemptsKey, defaultValue: 0) as int;
    final lastAttemptMillis = _settingsBox.get(_lastAttemptAtKey) as int?;

    return RatingPromptState(
      attempts: attempts,
      lastAttemptAt: lastAttemptMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastAttemptMillis),
    );
  }

  Future<void> recordAttempt(DateTime at) async {
    final current = getState();
    await _settingsBox.put(_attemptsKey, current.attempts + 1);
    await _settingsBox.put(_lastAttemptAtKey, at.millisecondsSinceEpoch);
  }
}
