import 'package:hive/hive.dart';

import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../models/mood_model.dart';

/// Max app version for which legacy intensity mapping (mood path → intensity)
/// is applied when stored intensity is 3. Format: "a.b.c+d".
const String _legacyMappingMaxVersion = '1.2.3+15';

class MoodRepositoryImpl implements MoodRepository {
  final Box<MoodModel> moodBox;
  final String? Function()? getAppVersion;

  MoodRepositoryImpl(this.moodBox, {this.getAppVersion});

  @override
  Future<void> saveMood(MoodEntry entry) async {
    print('Saving mood for date: ${entry.date}');
    print('Mood path: ${entry.mood}');
    print('Note: ${entry.note}');
    print('Intensity: ${entry.intensity}');

    final model = MoodModel(
      date: entry.date,
      mood: entry.mood,
      note: entry.note,
      intensity: entry.intensity,
    );
    await moodBox.put(model.date.toIso8601String(), model);
    print('Mood saved successfully');

    // Print all moods after saving
    print('All moods after saving:');
    for (var mood in moodBox.values) {
      print('Date: ${mood.date}, Mood: ${mood.mood}');
    }
  }

  @override
  Future<List<MoodEntry>> getMoods() async {
    print('Getting all moods from box');
    final moods = moodBox.values.map(_mapModelToEntity).toList();
    print('Found ${moods.length} moods in box');
    print('Moods in box:');
    for (var mood in moods) {
      print('Date: ${mood.date}, Mood: ${mood.mood}');
    }
    return moods;
  }

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    final normalized = DateTime(month.year, month.month);
    final moods = moodBox.values
        .where((mood) =>
            mood.date.year == normalized.year &&
            mood.date.month == normalized.month)
        .map(_mapModelToEntity)
        .toList();
    return moods;
  }

  MoodEntry _mapModelToEntity(MoodModel model) {
    // Legacy: entries saved before we stored real intensity had intensity 3.
    // Only apply mood→intensity mapping when intensity is 3 and app version
    // is <= _legacyMappingMaxVersion (e.g. 1.2.3+15).
    final currentVersion = getAppVersion?.call();
    final shouldApplyLegacyMapping = model.intensity == 3 &&
        currentVersion != null &&
        _isVersionLessThanOrEqual(currentVersion, _legacyMappingMaxVersion);
    final intensity = shouldApplyLegacyMapping
        ? (_intensityFromMoodPath(model.mood) ?? model.intensity)
        : model.intensity;
    return MoodEntry(
      date: model.date,
      mood: model.mood,
      note: model.note,
      intensity: intensity,
    );
  }

  /// Maps mood asset path to intensity 1–5 (same order as MoodScreen: Happy→1,
  /// Calm→2, Neutral→3, Sad→4, Angry→5). Used for legacy data that had 3.
  static int? _intensityFromMoodPath(String moodPath) {
    const pathToIntensity = {
      'assets/icon/happy.svg': 1,
      'assets/icon/calm.svg': 2,
      'assets/icon/neutral.svg': 3,
      'assets/icon/sad.svg': 4,
      'assets/icon/angry.svg': 5,
    };
    return pathToIntensity[moodPath];
  }

  /// Returns true if [current] <= [maxVersion]. Format: "a.b.c+d" (e.g. 1.2.3+15).
  static bool _isVersionLessThanOrEqual(String current, String maxVersion) {
    final c = _parseVersion(current);
    final m = _parseVersion(maxVersion);
    if (c == null || m == null) return false;
    for (var i = 0; i < 4; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return true;
  }

  static List<int>? _parseVersion(String v) {
    final parts = v.split('+');
    if (parts.isEmpty) return null;
    final numbers = parts[0].split('.').map((e) => int.tryParse(e) ?? 0);
    final list = numbers.toList();
    if (list.length < 3) return null;
    final build = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return [list[0], list[1], list[2], build];
  }
}
