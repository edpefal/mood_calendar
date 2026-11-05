import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';

const happy = 'assets/icon/happy.svg'; // Positive, high
const calm = 'assets/icon/calm.svg'; // Peaceful, high
const neutral = 'assets/icon/neutral.svg'; // Neutral, medium
const sad = 'assets/icon/sad.svg'; // Hard, low

MoodEntry entryOn(DateTime date, String mood, {int intensity = 1}) =>
    MoodEntry(date: date, mood: mood, intensity: intensity);
