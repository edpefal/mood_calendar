import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/presentation/screens/calendar_screen.dart';
import 'package:mood_calendar/features/mood/presentation/widgets/monthly_mood_summary_card.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/in_memory_mood_repository.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));
  final today = DateTime(2026, 11, 15);

  MoodEntry entry(int day, String mood, {int month = 11}) => MoodEntry(
        date: DateTime(2026, month, day),
        mood: 'assets/icon/$mood.svg',
        intensity: 1,
      );

  Future<List<DateTime>> pump(
    WidgetTester tester,
    List<MoodEntry> entries,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final tapped = <DateTime>[];
    await tester.pumpWidget(
      buildTestApp(
        moods: InMemoryMoodRepository(entries),
        calendarMonth: today,
        home: CalendarScreen(
          clock: () => today,
          onDaySelected: tapped.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tapped;
  }

  testWidgets('a past day without an entry is tappable and offers to log it',
      (tester) async {
    final tapped = await pump(tester, [entry(14, 'calm')]);
    final handle = tester.ensureSemantics();

    final label = strings.calendarDayLabel(
      formattedDate: strings.formatFullDate(DateTime(2026, 11, 3)),
      isFutureDate: false,
    );
    await tester.tap(find.bySemanticsLabel(label));

    expect(tapped, [DateTime(2026, 11, 3)]);
    expect(find.byIcon(Icons.add_rounded), findsWidgets);
    handle.dispose();
  });

  testWidgets('days after today are inert and show no plus', (tester) async {
    final tapped = await pump(tester, const []);
    final handle = tester.ensureSemantics();

    final label = strings.calendarDayLabel(
      formattedDate: strings.formatFullDate(DateTime(2026, 11, 20)),
      isFutureDate: true,
    );
    await tester.tap(find.bySemanticsLabel(label), warnIfMissed: false);

    expect(tapped, isEmpty);
    // 14 past days (Nov 1 to 14) and today without entries: 15 plus signs.
    expect(find.byIcon(Icons.add_rounded), findsNWidgets(15));
    handle.dispose();
  });

  testWidgets('shows the month by category with the names visible',
      (tester) async {
    await pump(tester, [
      entry(12, 'calm'),
      entry(13, 'calm'),
      entry(14, 'happy'),
    ]);
    await tester.scrollUntilVisible(
      find.text(strings.monthSoFarTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(strings.categoryShareLabel(strings.categoryPeaceful, 67)),
        findsOneWidget);
    expect(find.text(strings.categoryShareLabel(strings.categoryPositive, 33)),
        findsOneWidget);
  });

  testWidgets('the category bar is drawn with a height, not collapsed',
      (tester) async {
    await pump(tester, [entry(12, 'calm'), entry(14, 'happy')]);
    await tester.scrollUntilVisible(
      find.text(strings.monthSoFarTitle),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    final segments = find.descendant(
      of: find.byType(CategoryDistributionCard),
      matching: find.byWidgetPredicate(
        (w) =>
            w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(999),
      ),
    );
    expect(segments, findsNWidgets(2));
    expect(tester.getSize(segments.first).height, 12);
  });

  testWidgets('the title stays centered with the year button', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        calendarMonth: today,
        // Tests run as Android, where titles start-align; the app ships on iOS.
        home: Builder(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(platform: TargetPlatform.iOS),
            child: CalendarScreen(
              clock: () => today,
              onDaySelected: (_) {},
              onViewYear: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final center = tester.getCenter(find.text(strings.calendarTitle)).dx;
    expect(center, closeTo(195, 2));
  });

  testWidgets('the current streak does not depend on the month in view',
      (tester) async {
    await pump(tester, [
      entry(20, 'calm', month: 10),
      entry(14, 'calm'),
      entry(15, 'calm'),
    ]);
    final handle = tester.ensureSemantics();
    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text(strings.currentStreakTitle),
      200,
      scrollable: scrollable,
    );
    expect(find.bySemanticsLabel(strings.currentStreakSemantics(2)),
        findsOneWidget);
    expect(
        find.bySemanticsLabel(strings.bestStreakSemantics(2)), findsOneWidget);

    await tester.drag(scrollable, const Offset(0, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(strings.previousMonthTooltip));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(strings.currentStreakTitle),
      200,
      scrollable: scrollable,
    );

    // October's best streak is 1 day, but the streak alive today is still 2.
    expect(
        find.bySemanticsLabel(strings.bestStreakSemantics(1)), findsOneWidget);
    expect(find.bySemanticsLabel(strings.currentStreakSemantics(2)),
        findsOneWidget);
    handle.dispose();
  });

  testWidgets('a month without entries shows the empty state, no bar',
      (tester) async {
    await pump(tester, const []);

    expect(find.text(strings.emptySummary), findsOneWidget);
    expect(find.text(strings.monthSoFarTitle), findsNothing);
  });
}
