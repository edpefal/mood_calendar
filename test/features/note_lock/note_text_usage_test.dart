import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every screen that shows a saved note must go through `NoteText` (or conceal
/// it itself, as the Log's note pill does). A new file reading `entry.note` in
/// the presentation layer fails here until it is reviewed against the
/// `note-lock` spec and added to the list.
void main() {
  test('only the reviewed presentation files read a saved note', () {
    final readers = <String>{};
    final notePattern = RegExp(r'\.note\b');
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (!entity.path.contains('/presentation/')) continue;
      if (entity.path.endsWith('.g.dart') ||
          entity.path.endsWith('.freezed.dart')) {
        continue;
      }
      if (notePattern.hasMatch(entity.readAsStringSync())) {
        readers.add(entity.path.split('/').last);
      }
    }

    expect(readers, {
      // Saved card and note pill: concealed through NoteText / the lock state.
      'log_screen.dart',
      // The day detail: NoteText.
      'day_detail_sheet.dart',
      // Only reads has_note for analytics, never shows the text.
      'mood_cubit.dart',
      // The onboarding's first day: the note being typed, never a saved one.
      'onboarding_state.dart',
      'onboarding_cubit.dart',
    });
  });

  test('the Saved card and the day detail render notes with NoteText', () {
    for (final path in [
      'lib/features/mood/presentation/screens/log_screen.dart',
      'lib/features/mood/presentation/widgets/day_detail_sheet.dart',
    ]) {
      expect(File(path).readAsStringSync(), contains('NoteText('),
          reason: path);
    }
  });
}
