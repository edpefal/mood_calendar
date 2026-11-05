import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/widgets/gradient_pill_button.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/presentation/screens/log_screen.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/fake_mood_entitlements_repository.dart';
import '../../../../support/in_memory_mood_repository.dart';

const _calm = 'assets/icon/calm.svg';
const _brave = 'assets/icon/brave.svg';

final _today = DateTime(2026, 11, 4);
DateTime _clock() => DateTime(2026, 11, 4, 15);

MoodEntry _entry(DateTime date, String mood,
        {String? note, int intensity = 1}) =>
    MoodEntry(date: date, mood: mood, note: note, intensity: intensity);

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));

  late InMemoryMoodRepository repository;
  late FakeRatingPromptService rating;
  var customSize = false;

  setUp(() {
    customSize = false;
    repository = InMemoryMoodRepository();
    rating = FakeRatingPromptService();
  });

  Future<void> pumpLog(
    WidgetTester tester, {
    DateTime? date,
    FakeMoodEntitlementsRepository? entitlements,
    bool isActive = true,
    VoidCallback? onOpenSettings,
    ValueChanged<DateTime>? onRequestDate,
    DateTime Function()? clock,
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    // A phone, unless the test asked for another size.
    if (!customSize) {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(
      buildTestApp(
        moods: repository,
        entitlements: entitlements,
        ratingPromptService: rating,
        locale: locale,
        themeMode: themeMode,
        home: LogScreen(
          selectedDate: date ?? _today,
          isActive: isActive,
          clock: clock ?? _clock,
          onOpenSettings: onOpenSettings,
          onRequestDate: onRequestDate,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void tallScreen(WidgetTester tester) {
    customSize = true;
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  bool saveEnabled(WidgetTester tester) => tester
      .widget<GradientPillButton>(find.byType(GradientPillButton))
      .enabled;

  group('grid', () {
    testWidgets('lists the four categories in order with every mood',
        (tester) async {
      tallScreen(tester);
      await pumpLog(tester);

      // 'Neutral' is both a category and a mood; the title comes first.
      double top(String text) => tester.getTopLeft(find.text(text).first).dy;
      expect(top('Positive'), lessThan(top('Peaceful')));
      expect(top('Peaceful'), lessThan(top('Neutral')));
      expect(top('Neutral'), lessThan(top('Hard')));
      for (final id in ['happy', 'laughing', 'calm', 'shy', 'sad', 'sick']) {
        expect(find.text(strings.moodName(id)), findsOneWidget, reason: id);
      }
    });

    testWidgets('keeps the fixed order inside a category', (tester) async {
      tallScreen(tester);
      await pumpLog(tester);

      const order = [
        'Sad', 'Angry', 'Anxious', 'Stressed', 'Scared', 'Crying', 'Sick',
        'Hurt', //
      ];
      final positions = [
        for (final name in order) tester.getTopLeft(find.text(name)),
      ];
      for (var i = 1; i < positions.length; i++) {
        final previous = positions[i - 1];
        final current = positions[i];
        expect(
          current.dy > previous.dy ||
              (current.dy == previous.dy && current.dx > previous.dx),
          isTrue,
          reason: '${order[i - 1]} before ${order[i]}',
        );
      }
    });

    testWidgets('locks the 8 premium moods for a free user', (tester) async {
      tallScreen(tester);
      await pumpLog(tester);

      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(8));
    });

    testWidgets('a subscriber sees no locks', (tester) async {
      tallScreen(tester);
      await pumpLog(
        tester,
        entitlements: FakeMoodEntitlementsRepository(
          unlockedMoodIds: {
            'laughing', 'confident', 'brave', 'affectionate', //
            'hugging', 'romantic', 'shy', 'hurt',
          },
        ),
      );

      expect(find.byIcon(Icons.lock_rounded), findsNothing);
    });

    testWidgets('uses 4 columns, and 2 with large text', (tester) async {
      await pumpLog(tester);
      expect(
        tester.getTopLeft(find.text('Happy')).dy,
        tester.getTopLeft(find.text('Brave')).dy,
      );

      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text('Happy')).dy,
        isNot(tester.getTopLeft(find.text('Brave')).dy),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('at 200% in German nothing overflows and Save is reachable',
        (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpLog(tester, locale: const Locale('de'));

      final save = find.text(AppStrings.forLocale(const Locale('de')).save);
      await tester.scrollUntilVisible(
        save,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(save, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in the dark theme', (tester) async {
      await pumpLog(tester, themeMode: ThemeMode.dark);

      expect(find.text('Happy'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('choosing and saving', () {
    testWidgets('starts with no mood selected and Save disabled',
        (tester) async {
      await pumpLog(tester);

      expect(saveEnabled(tester), isFalse);
      expect(find.text(strings.notePromptEmpty), findsOneWidget);
    });

    testWidgets('choosing a mood enables Save', (tester) async {
      await pumpLog(tester);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();

      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('saving shows the Saved state on the same tab', (tester) async {
      await pumpLog(tester);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(repository.entries, hasLength(1));
      expect(repository.entries.single.mood, _calm);
      expect(repository.entries.single.date, _today);
      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsOneWidget);
      expect(find.textContaining('1 day in a row'), findsOneWidget);
      expect(find.text(strings.todayYouFeel), findsOneWidget);
      expect(find.text(strings.noNoteYet), findsOneWidget);
      expect(find.text(strings.editEntryButton), findsOneWidget);
    });

    testWidgets('the Saved state shows the current streak', (tester) async {
      repository.entries.add(_entry(DateTime(2026, 11, 3), _calm));
      await pumpLog(tester);

      await tester.tap(find.text('Happy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(find.textContaining('2 days in a row'), findsOneWidget);
    });

    testWidgets('requests the rating once after a successful save',
        (tester) async {
      await pumpLog(tester);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(rating.maybeRequestCalls, 1);
    });

    testWidgets('does not request the rating when the tab is not active',
        (tester) async {
      await pumpLog(tester, isActive: false);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(repository.entries, hasLength(1));
      expect(rating.maybeRequestCalls, 0);
    });

    testWidgets('a failed save stays on the grid with the pick and the note',
        (tester) async {
      repository.failNextSaves = 1;
      await pumpLog(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(find.text(strings.saveMoodError), findsOneWidget);
      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsNothing);
      expect(repository.entries, isEmpty);
      expect(saveEnabled(tester), isTrue);
      expect(rating.maybeRequestCalls, 0);

      // Let the error message go away before trying again.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();
      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsOneWidget);
    });

    testWidgets('Edit returns to the grid with the mood and the note',
        (tester) async {
      repository.entries.add(_entry(_today, _calm, note: 'quiet day'));
      await pumpLog(tester);
      expect(find.text('quiet day'), findsOneWidget);

      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();

      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsNothing);
      expect(saveEnabled(tester), isTrue);
      expect(find.text('quiet day'), findsOneWidget);

      await tester.tap(find.text('Happy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(repository.entries, hasLength(1));
      expect(repository.entries.single.mood, 'assets/icon/happy.svg');
      expect(repository.entries.single.note, 'quiet day');
    });

    testWidgets('opening a date with an entry shows the Saved state',
        (tester) async {
      repository.entries.add(_entry(_today, _calm, note: 'hello'));
      await pumpLog(tester);

      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.text(strings.save), findsNothing);
    });

    testWidgets('a past date uses the past wording', (tester) async {
      final past = DateTime(2026, 10, 20);
      repository.entries.add(_entry(past, _calm));
      await pumpLog(tester, date: past);

      expect(find.text(strings.pastYouFelt), findsOneWidget);
      expect(find.text(strings.todayYouFeel), findsNothing);
    });
  });

  group('locked moods', () {
    testWidgets('tapping one opens the sheet and keeps the selection',
        (tester) async {
      tallScreen(tester);
      await pumpLog(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Brave'));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      // The sheet shows the tapped mood as context (grid cell + capsule).
      expect(find.text('Brave'), findsNWidgets(2));
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isTrue);
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();
      expect(repository.entries.single.mood, _calm);
    });

    testWidgets('the sheet keeps the date and the note when closed',
        (tester) async {
      tallScreen(tester);
      await pumpLog(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.notePromptPositive));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'my draft');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confident'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();

      expect(find.text('my draft'), findsOneWidget);
      expect(find.text(strings.formatFullDate(_today)), findsOneWidget);
    });

    testWidgets('an expired mood on the same entry can still change the note',
        (tester) async {
      repository.entries.add(
        _entry(_today, _brave, note: 'old note', intensity: 7),
      );
      await pumpLog(tester);
      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('old note'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'new note');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsNothing);
      expect(repository.entries.single.mood, _brave);
      expect(repository.entries.single.note, 'new note');
    });

    testWidgets('another locked mood still opens the sheet', (tester) async {
      tallScreen(tester);
      repository.entries.add(_entry(_today, _brave, intensity: 7));
      await pumpLog(tester);
      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confident'));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();
      expect(repository.entries.single.mood, _brave);
    });

    testWidgets('a date without an entry cannot be saved with a locked mood',
        (tester) async {
      tallScreen(tester);
      await pumpLog(tester);

      await tester.tap(find.text('Brave'));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();
      expect(saveEnabled(tester), isFalse);
      expect(repository.entries, isEmpty);
    });
  });

  group('note pill', () {
    testWidgets('asks a question that depends on the category', (tester) async {
      await pumpLog(tester);

      Future<void> expectPromptFor(String mood, String prompt) async {
        await tester.tap(find.text(mood));
        await tester.pumpAndSettle();
        expect(find.text(prompt), findsOneWidget, reason: mood);
      }

      await expectPromptFor('Happy', strings.notePromptPositive);
      await expectPromptFor('Calm', strings.notePromptPositive);
      await tester.tap(find.text('Neutral').last);
      await tester.pumpAndSettle();
      expect(find.text(strings.notePromptNeutral), findsOneWidget);
      await expectPromptFor('Anxious', strings.notePromptHard);
    });

    testWidgets('shows the note and an indicator once written', (tester) async {
      await pumpLog(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.notePromptPositive));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'long walk');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();

      expect(find.text('long walk'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // Writing the note does not save the mood.
      expect(repository.entries, isEmpty);
    });

    testWidgets('clearing the note brings the question back', (tester) async {
      repository.entries.add(_entry(_today, _calm, note: 'something'));
      await pumpLog(tester);
      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('something'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();

      expect(find.text(strings.notePromptPositive), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('the editor shows the mood and enforces 500 characters',
        (tester) async {
      await pumpLog(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.notePromptPositive));
      await tester.pumpAndSettle();

      expect(find.text(strings.noteSheetDoneButton), findsOneWidget);
      expect(find.text('Calm'), findsNWidgets(2));
      await tester.enterText(find.byType(TextField), 'x' * 600);
      await tester.pumpAndSettle();
      expect(find.text('500/500'), findsOneWidget);
    });

    testWidgets('is announced as a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLog(tester);

      expect(
        tester.getSemantics(find.text(strings.notePromptEmpty)),
        matchesSemantics(
          label: strings.notePromptEmpty,
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('follows the device language', (tester) async {
      final es = AppStrings.forLocale(const Locale('es'));
      await pumpLog(tester, locale: const Locale('es'));

      expect(find.text(es.notePromptEmpty), findsOneWidget);
      await tester.tap(find.text('Ansioso'));
      await tester.pumpAndSettle();
      expect(find.text(es.notePromptHard), findsOneWidget);
    });
  });

  group('header', () {
    testWidgets('shows the date and the greeting for the time of day',
        (tester) async {
      Future<void> expectGreeting(int hour, String greeting) async {
        await pumpLog(tester, clock: () => DateTime(2026, 11, 4, hour));
        expect(find.text(strings.formatFullDate(_today)), findsOneWidget);
        expect(find.text(greeting), findsOneWidget, reason: '$hour:00');
      }

      await expectGreeting(5, strings.greetingMorning);
      await expectGreeting(11, strings.greetingMorning);
      await expectGreeting(12, strings.greetingAfternoon);
      await expectGreeting(18, strings.greetingAfternoon);
      await expectGreeting(19, strings.greetingEvening);
      await expectGreeting(4, strings.greetingEvening);
    });

    testWidgets('asks how you feel today, or about the day for a past date',
        (tester) async {
      await pumpLog(tester);
      expect(find.text(strings.moodQuestion), findsOneWidget);

      await pumpLog(tester, date: DateTime(2026, 11, 1));
      expect(find.text(strings.moodQuestion), findsNothing);
      expect(find.text(strings.moodQuestionPast), findsOneWidget);
    });

    testWidgets('the bell opens Settings', (tester) async {
      var opened = 0;
      await pumpLog(tester, onOpenSettings: () => opened++);

      await tester.tap(find.byTooltip(strings.remindersBellLabel));

      expect(opened, 1);
    });
  });

  group('forgot yesterday', () {
    testWidgets('is offered when yesterday has no entry', (tester) async {
      repository.entries.add(_entry(_today, _calm));
      DateTime? requested;
      await pumpLog(tester, onRequestDate: (d) => requested = d);

      expect(
          find.textContaining(strings.forgotYesterdayAction), findsOneWidget);
      await tester.tap(find.textContaining(strings.forgotYesterdayAction));

      expect(requested, DateTime(2026, 11, 3));
    });

    testWidgets('is hidden when yesterday already has an entry',
        (tester) async {
      repository.entries
        ..add(_entry(_today, _calm))
        ..add(_entry(DateTime(2026, 11, 3), _calm));
      await pumpLog(tester);

      expect(find.textContaining(strings.forgotYesterdayAction), findsNothing);
    });

    testWidgets('is not offered on a past date', (tester) async {
      final past = DateTime(2026, 10, 20);
      repository.entries.add(_entry(past, _calm));
      await pumpLog(tester, date: past);

      expect(find.textContaining(strings.forgotYesterdayAction), findsNothing);
    });
  });
}
