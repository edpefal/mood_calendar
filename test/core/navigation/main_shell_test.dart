import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/core/navigation/main_shell.dart';
import 'package:mood_calendar/core/widgets/floating_tab_bar.dart';
import 'package:mood_calendar/features/insights/presentation/screens/insights_screen.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/presentation/screens/calendar_screen.dart';
import 'package:mood_calendar/features/mood/presentation/screens/log_screen.dart';
import 'package:mood_calendar/features/settings/presentation/screens/settings_screen.dart';
import 'package:mood_calendar/main.dart';

import '../../support/app_harness.dart';
import '../../support/in_memory_mood_repository.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  late InMemoryMoodRepository repository;
  late GlobalKey<MainShellState> shellKey;

  setUp(() {
    repository = InMemoryMoodRepository();
    shellKey = GlobalKey<MainShellState>();
  });

  Future<void> pumpShell(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildTestApp(
        moods: repository,
        locale: locale,
        home: MainShell(key: shellKey),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip(label));
    await tester.pumpAndSettle();
  }

  group('tabs', () {
    testWidgets('shows Calendar, Insights, Log and Settings, starting on Log',
        (tester) async {
      await pumpShell(tester);

      final xs = [
        for (final label in [
          strings.tabCalendar,
          strings.tabInsights,
          strings.tabLog,
          strings.tabSettings,
        ])
          tester.getCenter(find.byTooltip(label)).dx,
      ];
      expect(xs, [...xs]..sort());
      expect(shellKey.currentState!.currentTab, MainTab.log);
      expect(shellKey.currentState!.logDate, today);
      expect(find.text(strings.formatFullDate(today)), findsOneWidget);
    });

    testWidgets('has no Premium or store tab', (tester) async {
      await pumpShell(tester);

      expect(find.byTooltip('Premium'), findsNothing);
      expect(find.byTooltip(strings.openPremiumTooltip), findsNothing);
      expect(find.byIcon(Icons.diamond_outlined), findsNothing);
    });

    testWidgets('names the tabs in each language', (tester) async {
      for (final locale in AppStrings.supportedLocales) {
        final localized = AppStrings.forLocale(locale);
        await pumpShell(tester, locale: locale);

        for (final label in [
          localized.tabCalendar,
          localized.tabInsights,
          localized.tabLog,
          localized.tabSettings,
        ]) {
          expect(find.byTooltip(label), findsOneWidget,
              reason: '${locale.languageCode}: $label');
        }
      }
    });

    testWidgets('Insights is a placeholder with an empty state',
        (tester) async {
      await pumpShell(tester);

      await openTab(tester, strings.tabInsights);

      expect(find.byType(InsightsScreen), findsOneWidget);
      expect(find.text(strings.tabInsights), findsWidgets);
      expect(find.text(strings.insightsEmptyTitle), findsOneWidget);
      expect(find.text(strings.paywallTitle), findsNothing);
    });

    testWidgets('Calendar and Settings have no back button', (tester) async {
      await pumpShell(tester);

      await openTab(tester, strings.tabCalendar);
      expect(find.byType(BackButton), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(strings.calendarTitle),
        ),
        findsOneWidget,
      );

      await openTab(tester, strings.tabSettings);
      expect(find.byType(BackButton), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(strings.settingsTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the Log bell shows Settings', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.byTooltip(strings.remindersBellLabel));
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.settings);
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('the Log keeps its state', () {
    testWidgets('date, pick and unsaved note survive a tab change',
        (tester) async {
      await pumpShell(tester);
      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.notePromptPositive));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'half written');
      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();

      await openTab(tester, strings.tabSettings);
      await openTab(tester, strings.tabLog);

      expect(find.text('half written'), findsOneWidget);
      expect(find.text(strings.formatFullDate(today)), findsOneWidget);
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();
      expect(repository.entries.single.mood, 'assets/icon/calm.svg');
    });

    testWidgets('saving stays on the Log', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.log);
      expect(find.textContaining(strings.savedLabel, findRichText: true),
          findsOneWidget);
    });

    testWidgets('a failed save stays on the Log with the grid', (tester) async {
      repository.failNextSaves = 1;
      await pumpShell(tester);

      await tester.tap(find.text('Calm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.log);
      expect(find.text(strings.saveMoodError), findsOneWidget);
    });
  });

  group('calendar', () {
    testWidgets('tapping a day opens the Log on that date', (tester) async {
      final firstOfMonth = DateTime(now.year, now.month, 1);
      await pumpShell(tester);
      await openTab(tester, strings.tabCalendar);
      final handle = tester.ensureSemantics();

      await tester.tap(find.bySemanticsLabel(
        RegExp(strings.formatFullDate(firstOfMonth)),
      ));
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.log);
      expect(shellKey.currentState!.logDate, firstOfMonth);
      expect(find.text(strings.formatFullDate(firstOfMonth)), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a day with an entry opens the Log on its card',
        (tester) async {
      final day = DateTime(now.year, now.month, 1);
      repository.entries.add(
        MoodEntry(
          date: day,
          mood: 'assets/icon/calm.svg',
          note: 'first of the month',
          intensity: 2,
        ),
      );
      await pumpShell(tester);
      await openTab(tester, strings.tabCalendar);
      final handle = tester.ensureSemantics();

      await tester.tap(find.bySemanticsLabel(
        RegExp(strings.formatFullDate(day)),
      ));
      await tester.pumpAndSettle();

      expect(find.text('first of the month'), findsOneWidget);
      expect(find.text(strings.editEntryButton), findsOneWidget);
      handle.dispose();
    });

    testWidgets('days after today cannot be tapped', (tester) async {
      final lastOfMonth = DateTime(now.year, now.month + 1, 0);
      if (!lastOfMonth.isAfter(today)) {
        return; // Today is the last day: there are no future days.
      }
      await pumpShell(tester);
      await openTab(tester, strings.tabCalendar);
      final handle = tester.ensureSemantics();

      await tester.tap(
        find.bySemanticsLabel(RegExp(strings.formatFullDate(lastOfMonth))),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.currentTab, MainTab.calendar);
      expect(find.byType(CalendarScreen), findsOneWidget);
      handle.dispose();
    });
  });

  group('forgot yesterday', () {
    testWidgets('opens the grid for yesterday and saves there', (tester) async {
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      repository.entries.add(
        MoodEntry(
          date: today,
          mood: 'assets/icon/calm.svg',
          intensity: 2,
        ),
      );
      await pumpShell(tester);

      await tester.tap(find.textContaining(strings.forgotYesterdayAction));
      await tester.pumpAndSettle();

      expect(shellKey.currentState!.logDate, yesterday);
      expect(find.text(strings.save), findsOneWidget);
      await tester.tap(find.text('Sad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.save));
      await tester.pumpAndSettle();
      expect(
        repository.entries.map((e) => e.date),
        containsAll([today, yesterday]),
      );
    });
  });

  group('modals', () {
    testWidgets('the bar is covered by the note editor and comes back',
        (tester) async {
      await pumpShell(tester);
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsOneWidget);

      await tester.tap(find.text(strings.notePromptEmpty));
      await tester.pumpAndSettle();
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsNothing);

      await tester.tap(find.text(strings.noteSheetDoneButton));
      await tester.pumpAndSettle();
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsOneWidget);
    });

    testWidgets('the bar is covered by the subscription sheet', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Brave'));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsNothing);
      await tester.tap(find.byTooltip(strings.closeLabel));
      await tester.pumpAndSettle();
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsOneWidget);
    });

    testWidgets('the Log does not overflow with the keyboard open',
        (tester) async {
      await pumpShell(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('wide screens', () {
    testWidgets('the bar keeps its maximum width and stays centered',
        (tester) async {
      tester.view.physicalSize = const Size(1032, 1376);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        buildTestApp(
          moods: repository,
          home: MainShell(key: shellKey),
        ),
      );
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(FloatingTabBar));
      expect(bar.center.dx, closeTo(516, 1));
      final logCell = tester.getRect(find.byType(LogScreen));
      expect(logCell.width, 1032);
      final saveWidth =
          tester.getSize(find.text(strings.notePromptEmpty)).width;
      expect(saveWidth, lessThan(520));
    });
  });

  group('reminder tap', () {
    Widget buildMyApp() => buildTestProviders(
          moods: repository,
          child: const MyApp(),
        );

    testWidgets('from another tab it shows the Log on today', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      await openTab(tester, strings.tabSettings);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await handleReminderTap();
      await tester.pumpAndSettle();

      expect(mainShellKey.currentState!.currentTab, MainTab.log);
      expect(find.text(strings.formatFullDate(today)), findsOneWidget);
    });

    testWidgets('it closes an open modal and shows today, not the viewed date',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      final past = DateTime(now.year, now.month - 1, 10);
      mainShellKey.currentState!.showLog(past);
      await tester.pumpAndSettle();
      expect(find.text(strings.formatFullDate(past)), findsOneWidget);
      await tester.tap(find.text(strings.notePromptEmpty));
      await tester.pumpAndSettle();
      expect(find.text(strings.noteSheetDoneButton), findsOneWidget);

      await handleReminderTap();
      await tester.pumpAndSettle();

      expect(find.text(strings.noteSheetDoneButton), findsNothing);
      expect(find.text(strings.formatFullDate(today)), findsOneWidget);
      expect(find.byTooltip(strings.tabCalendar).hitTestable(), findsOneWidget);
    });

    testWidgets('a tap that arrives before the shell exists is not lost',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.localesTestValue = const [Locale('en')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      final pending = handleReminderTap();
      await tester.pumpWidget(buildMyApp());
      await tester.pumpAndSettle();
      await pending;

      expect(mainShellKey.currentState!.currentTab, MainTab.log);
      expect(find.text(strings.formatFullDate(today)), findsOneWidget);
    });
  });
}
