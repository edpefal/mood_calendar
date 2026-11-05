import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/features/mood/data/datasources/mood_storage_keys.dart';
import 'package:mood_calendar/features/mood/data/models/mood_model.dart';
import 'package:mood_calendar/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';

void main() {
  late Directory tempDir;
  late Box<MoodModel> moodBox;
  late MoodRepositoryImpl repository;

  setUpAll(() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodModelAdapter());
    }
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mood_repository_test_');
    Hive.init(tempDir.path);
    moodBox = await Hive.openBox<MoodModel>('moods_test');
    repository = MoodRepositoryImpl(
      moodBox,
      logger: const _TestAppLogger(),
    );
  });

  tearDown(() async {
    await moodBox.close();
    await tempDir.delete(recursive: true);
  });

  test('saveMood persists entries and getMoods returns them', () async {
    final entry = MoodEntry(
      date: DateTime(2026, 4, 2, 13, 45),
      mood: 'assets/icon/sad.svg',
      note: 'Long day',
      intensity: 4,
    );

    await repository.saveMood(entry);

    final moods = await repository.getMoods();

    expect(moods, hasLength(1));
    expect(moods.single.date, DateTime(2026, 4, 2));
    expect(moods.single.mood, entry.mood);
    expect(moods.single.note, entry.note);
    expect(moods.single.intensity, entry.intensity);
    expect(moodBox.keys.single, '2026-04-02');
  });

  test('getMoods remaps legacy intensity based on mood path', () async {
    await moodBox.put(
      DateTime(2026, 4, 1, 22, 30).toIso8601String(),
      MoodModel(
        date: DateTime(2026, 4, 1, 22, 30),
        mood: 'assets/icon/happy.svg',
        intensity: 3,
      ),
    );

    final moods = await repository.getMoods();

    expect(moods.single.intensity, 1);
    expect(moods.single.date, DateTime(2026, 4, 1));
    expect(
      moodBox.keys.single,
      MoodStorageKeys.forDate(DateTime(2026, 4, 1)),
    );
  });

  test('getMoodsForMonth only returns entries for the requested month',
      () async {
    await repository.saveMood(
      MoodEntry(
        date: DateTime(2026, 4, 1),
        mood: 'assets/icon/happy.svg',
        intensity: 1,
      ),
    );
    await repository.saveMood(
      MoodEntry(
        date: DateTime(2026, 4, 14),
        mood: 'assets/icon/calm.svg',
        intensity: 2,
      ),
    );
    await repository.saveMood(
      MoodEntry(
        date: DateTime(2026, 5, 1),
        mood: 'assets/icon/angry.svg',
        intensity: 5,
      ),
    );

    final aprilMoods = await repository.getMoodsForMonth(DateTime(2026, 4, 30));

    expect(aprilMoods, hasLength(2));
    expect(
      aprilMoods.map((entry) => entry.date.month),
      everyElement(4),
    );
  });

  test('saveMood overwrites the same day even if timestamps differ', () async {
    await repository.saveMood(
      MoodEntry(
        date: DateTime(2026, 4, 9, 8, 0),
        mood: 'assets/icon/happy.svg',
        intensity: 1,
      ),
    );
    await repository.saveMood(
      MoodEntry(
        date: DateTime(2026, 4, 9, 21, 45),
        mood: 'assets/icon/angry.svg',
        intensity: 5,
      ),
    );

    final moods = await repository.getMoods();

    expect(moods, hasLength(1));
    expect(moods.single.date, DateTime(2026, 4, 9));
    expect(moods.single.mood, 'assets/icon/angry.svg');
    expect(moodBox.keys.single, '2026-04-09');
  });

  group('loggedAt', () {
    const calm = 'assets/icon/calm.svg';
    const sad = 'assets/icon/sad.svg';
    final day = DateTime(2026, 11, 2);

    MoodEntry entryAt(String mood, DateTime? loggedAt, {String? note}) =>
        MoodEntry(
          date: day,
          mood: mood,
          note: note,
          intensity: 2,
          loggedAt: loggedAt,
        );

    test('a new entry stores the time it arrives with', () async {
      await repository.saveMood(entryAt(calm, DateTime(2026, 11, 2, 21, 2)));

      final saved = (await repository.getMoods()).single;
      expect(saved.loggedAt, DateTime(2026, 11, 2, 21, 2));
    });

    test('editing only the note keeps the original time', () async {
      await repository.saveMood(entryAt(calm, DateTime(2026, 11, 2, 21, 2)));
      await repository.saveMood(
        entryAt(calm, DateTime(2026, 11, 2, 23, 40), note: 'later'),
      );

      final saved = (await repository.getMoods()).single;
      expect(saved.note, 'later');
      expect(saved.loggedAt, DateTime(2026, 11, 2, 21, 2));
    });

    test('changing the mood takes the new time', () async {
      await repository.saveMood(entryAt(calm, DateTime(2026, 11, 2, 21, 2)));
      await repository.saveMood(entryAt(sad, DateTime(2026, 11, 2, 23, 40)));

      final saved = (await repository.getMoods()).single;
      expect(saved.mood, sad);
      expect(saved.loggedAt, DateTime(2026, 11, 2, 23, 40));
    });

    test('an entry saved before the field existed stays without a time',
        () async {
      await moodBox.put(
        MoodStorageKeys.forDate(day),
        MoodModel(date: day, mood: calm, intensity: 2),
      );

      await repository
          .saveMood(entryAt(calm, DateTime(2026, 11, 3, 9), note: 'x'));

      final saved = (await repository.getMoods()).single;
      expect(saved.note, 'x');
      expect(saved.loggedAt, isNull);
    });

    test('a box written with the previous schema still opens', () async {
      Hive.registerAdapter(_PreviousSchemaMoodAdapter(), override: true);
      final legacyBox = await Hive.openBox<MoodModel>('moods_previous');
      await legacyBox.put(
        '2026-11-01',
        MoodModel(date: DateTime(2026, 11, 1), mood: calm, intensity: 2),
      );
      await legacyBox.close();

      Hive.registerAdapter(MoodModelAdapter(), override: true);
      final reopened = await Hive.openBox<MoodModel>('moods_previous');
      final saved = await MoodRepositoryImpl(
        reopened,
        logger: const _TestAppLogger(),
      ).getMoods();

      expect(saved.single.mood, calm);
      expect(saved.single.loggedAt, isNull);
      await reopened.close();
    });
  });
}

class _TestAppLogger implements AppLogger {
  const _TestAppLogger();

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

/// Writes entries with the four fields the model had before `loggedAt`.
class _PreviousSchemaMoodAdapter extends TypeAdapter<MoodModel> {
  @override
  final int typeId = 0;

  @override
  MoodModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = reader.readByte(); i > 0; i--)
        reader.readByte(): reader.read(),
    };
    return MoodModel(
      date: fields[0] as DateTime,
      mood: fields[1] as String,
      note: fields[2] as String?,
      intensity: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MoodModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.mood)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.intensity);
  }
}
