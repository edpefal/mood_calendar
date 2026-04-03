import 'package:hive/hive.dart';

import '../../../../core/logging/app_logger.dart';
import '../datasources/mood_storage_keys.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../models/mood_model.dart';

class MoodRepositoryImpl implements MoodRepository {
  final Box<MoodModel> moodBox;
  final AppLogger logger;

  MoodRepositoryImpl(this.moodBox, {required this.logger});

  @override
  Future<void> saveMood(MoodEntry entry) async {
    await _migrateLegacyEntriesIfNeeded();
    final normalizedDate = MoodStorageKeys.normalizeDate(entry.date);
    logger.debug(
      'Saving mood entry for ${MoodStorageKeys.forDate(entry.date)} with intensity ${entry.intensity}',
      tag: 'MoodRepository',
    );

    final model = MoodModel(
      date: normalizedDate,
      mood: entry.mood,
      note: entry.note,
      intensity: entry.intensity,
    );
    await moodBox.put(MoodStorageKeys.forDate(normalizedDate), model);
    logger.debug(
      'Mood saved successfully. Stored entries: ${moodBox.length}',
      tag: 'MoodRepository',
    );
  }

  @override
  Future<List<MoodEntry>> getMoods() async {
    await _migrateLegacyEntriesIfNeeded();
    final moods = moodBox.values.map(_mapModelToEntity).toList();
    logger.debug(
      'Loaded ${moods.length} moods from local storage',
      tag: 'MoodRepository',
    );
    return moods;
  }

  @override
  Future<List<MoodEntry>> getMoodsForMonth(DateTime month) async {
    await _migrateLegacyEntriesIfNeeded();
    final normalized = DateTime(month.year, month.month);
    return moodBox.values
        .where(
          (mood) =>
              mood.date.year == normalized.year &&
              mood.date.month == normalized.month,
        )
        .map(_mapModelToEntity)
        .toList();
  }

  Future<void> _migrateLegacyEntriesIfNeeded() async {
    final canonicalEntries = <String, MoodModel>{};
    var needsMigration = false;

    for (final rawEntry in moodBox.toMap().entries) {
      final rawKey = rawEntry.key.toString();
      final mood = rawEntry.value;
      final normalizedDate = MoodStorageKeys.normalizeDate(mood.date);
      final normalizedKey = MoodStorageKeys.forDate(mood.date);
      final normalizedMood = MoodModel(
        date: normalizedDate,
        mood: mood.mood,
        note: mood.note,
        intensity: mood.intensity,
      );

      if (rawKey != normalizedKey || mood.date != normalizedDate) {
        needsMigration = true;
      }

      final existing = canonicalEntries[normalizedKey];
      if (existing == null || mood.date.isAfter(existing.date)) {
        if (existing != null) {
          needsMigration = true;
        }
        canonicalEntries[normalizedKey] = normalizedMood;
      } else {
        needsMigration = true;
      }
    }

    if (!needsMigration) {
      return;
    }

    await moodBox.clear();
    await moodBox.putAll(canonicalEntries);
    logger.debug(
      'Migrated mood storage to normalized daily keys. Entries: ${canonicalEntries.length}',
      tag: 'MoodRepository',
    );
  }

  MoodEntry _mapModelToEntity(MoodModel model) {
    final intensity = model.intensity == 3
        ? (MoodDefinitionResolver.intensityFromMoodPath(model.mood) ??
            model.intensity)
        : model.intensity;
    return MoodEntry(
      date: model.date,
      mood: model.mood,
      note: model.note,
      intensity: intensity,
    );
  }
}
