import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/presentation/screens/log_screen.dart';
import 'package:mood_calendar/features/mood/presentation/widgets/day_detail_sheet.dart';
import 'package:mood_calendar/features/note_lock/presentation/bloc/note_lock_cubit.dart';

import '../../support/app_harness.dart';
import '../../support/fake_note_lock_authenticator.dart';
import '../../support/in_memory_mood_repository.dart';

const _calm = 'assets/icon/calm.svg';
final _today = DateTime(2026, 11, 4);

MoodEntry _entry({String? note}) =>
    MoodEntry(date: _today, mood: _calm, note: note, intensity: 2);

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));

  late InMemoryMoodRepository repository;
  late FakeNoteLockAuthenticator authenticator;
  late NoteLockCubit lock;

  setUp(() {
    repository = InMemoryMoodRepository();
    authenticator = FakeNoteLockAuthenticator();
  });

  Future<void> pump(
    WidgetTester tester, {
    required Widget home,
    bool lockEnabled = true,
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The provider in buildTestApp closes it with the widget tree.
    lock = NoteLockCubit(
      authenticator: authenticator,
      telemetry: RecordingTelemetry(),
      isSubscribed: () => true,
      enabled: lockEnabled,
    );
    await tester.pumpWidget(
      buildTestApp(
        moods: repository,
        noteLockCubit: lock,
        locale: locale,
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget log() => LogScreen(
        selectedDate: _today,
        clock: () => DateTime(2026, 11, 4, 15),
      );

  group('Log, Saved state', () {
    testWidgets('hides the note behind "Note locked" while locked',
        (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());

      expect(find.text('my secret'), findsNothing);
      expect(find.text(strings.noteLockedLabel), findsOneWidget);
      // The rest of the entry stays visible.
      expect(find.text('Calm'), findsOneWidget);
    });

    testWidgets('tapping it authenticates and shows the note', (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());

      await tester.tap(find.text(strings.noteLockedUnlockAction));
      await tester.pumpAndSettle();

      expect(authenticator.reasons, [strings.noteLockReasonUnlock]);
      expect(find.text('my secret'), findsOneWidget);
    });

    testWidgets('a failed authentication keeps it hidden', (tester) async {
      authenticator.succeeds = false;
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());

      await tester.tap(find.text(strings.noteLockedUnlockAction));
      await tester.pumpAndSettle();

      expect(find.text('my secret'), findsNothing);
      expect(find.text(strings.noteLockedLabel), findsOneWidget);
    });

    testWidgets('goes back to hidden when the app is backgrounded',
        (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());
      await tester.tap(find.text(strings.noteLockedUnlockAction));
      await tester.pumpAndSettle();
      expect(find.text('my secret'), findsOneWidget);

      lock.lock();
      await tester.pumpAndSettle();

      expect(find.text('my secret'), findsNothing);
    });

    testWidgets('shows the note when the lock is off and never asks',
        (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log(), lockEnabled: false);

      expect(find.text('my secret'), findsOneWidget);
      expect(authenticator.reasons, isEmpty);
    });

    testWidgets('an entry without a note shows no marker', (tester) async {
      repository.entries.add(_entry());
      await pump(tester, home: log());

      expect(find.text(strings.noteLockedLabel), findsNothing);
      expect(find.text(strings.noNoteYet), findsOneWidget);
    });

    testWidgets('speaks the device language', (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log(), locale: const Locale('es'));

      expect(find.text('Nota bloqueada'), findsOneWidget);
      expect(find.text('Desbloquear'), findsOneWidget);
    });
  });

  group('Log, editing', () {
    Future<void> startEditing(WidgetTester tester) async {
      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();
    }

    testWidgets('the note pill does not leak the saved note', (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());

      await startEditing(tester);

      expect(find.text('my secret'), findsNothing);
      expect(find.text(strings.noteLockedLabel), findsOneWidget);
    });

    testWidgets('saving without opening the note keeps it', (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());
      await startEditing(tester);

      await tester.tap(find.text('Happy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(repository.entries.single.mood, 'assets/icon/happy.svg');
      expect(repository.entries.single.note, 'my secret');
    });

    testWidgets('opening the note asks first and shows it on success',
        (tester) async {
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());
      await startEditing(tester);

      await tester.tap(find.text(strings.noteLockedLabel));
      await tester.pumpAndSettle();

      expect(authenticator.reasons, [strings.noteLockReasonUnlock]);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(TextField),
          matching: find.text('my secret'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a cancelled authentication does not open the editor',
        (tester) async {
      authenticator.succeeds = false;
      repository.entries.add(_entry(note: 'my secret'));
      await pump(tester, home: log());
      await startEditing(tester);

      await tester.tap(find.text(strings.noteLockedLabel));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('my secret'), findsNothing);
    });

    testWidgets('writing a new note asks nothing', (tester) async {
      repository.entries.add(_entry());
      await pump(tester, home: log());
      await startEditing(tester);

      await tester.tap(find.text(strings.notePromptPositive));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(authenticator.reasons, isEmpty);
    });
  });

  group('day detail', () {
    Widget detail(MoodEntry entry) => Scaffold(
          body: DayDetailSheet(entry: entry, onEdit: () {}),
        );

    testWidgets('keeps mood, category and time but hides the note',
        (tester) async {
      await pump(tester, home: detail(_entry(note: 'my secret')));

      expect(find.text('Calm'), findsOneWidget);
      expect(find.text('my secret'), findsNothing);
      expect(find.text(strings.noteLockedLabel), findsOneWidget);
    });

    testWidgets('shows the note after unlocking', (tester) async {
      await pump(tester, home: detail(_entry(note: 'my secret')));

      await tester.tap(find.text(strings.noteLockedUnlockAction));
      await tester.pumpAndSettle();

      expect(find.text('my secret'), findsOneWidget);
    });

    testWidgets('an unlocked session shows it straight away', (tester) async {
      await pump(tester, home: detail(_entry(note: 'my secret')));
      await lock.unlock('r');
      await tester.pumpAndSettle();

      expect(find.text('my secret'), findsOneWidget);
    });

    testWidgets('lock off: plain note', (tester) async {
      await pump(
        tester,
        home: detail(_entry(note: 'my secret')),
        lockEnabled: false,
      );

      expect(find.text('my secret'), findsOneWidget);
    });
  });
}
