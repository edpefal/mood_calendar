import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/localization/app_strings.dart';
import 'package:mood_calendar/features/insights/presentation/screens/insights_screen.dart';
import 'package:mood_calendar/features/insights/presentation/widgets/insight_previews.dart';
import 'package:mood_calendar/features/insights/presentation/widgets/locked_insight_card.dart';
import 'package:mood_calendar/features/insights/presentation/widgets/weekday_card.dart';
import 'package:mood_calendar/features/insights/presentation/widgets/year_pixels_card.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';
import 'package:mood_calendar/features/mood/presentation/widgets/day_detail_sheet.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_plan.dart';
import 'package:mood_calendar/features/purchases/domain/entities/subscription_status.dart';

import '../../../../support/app_harness.dart';
import '../../../../support/fake_mood_entitlements_repository.dart';
import '../../../../support/in_memory_mood_repository.dart';

void main() {
  final strings = AppStrings.forLocale(const Locale('en'));
  final today = DateTime(2026, 11, 15);
  const subscribed = SubscriptionStatus(
    isActive: true,
    plan: SubscriptionPlanType.annual,
  );

  /// 20 consecutive days ending yesterday, cycling through the categories.
  List<MoodEntry> twentyDays() {
    const moods = ['happy', 'calm', 'neutral', 'sad'];
    return [
      for (var i = 1; i <= 20; i++)
        MoodEntry(
          date: DateTime(2026, 11, 15 - i),
          mood: 'assets/icon/${moods[i % 4]}.svg',
          intensity: 1,
        ),
    ];
  }

  late RecordingTelemetry telemetry;
  late FakeMoodEntitlementsRepository entitlements;

  setUp(() {
    telemetry = RecordingTelemetry();
    entitlements = FakeMoodEntitlementsRepository();
  });

  Future<void> pump(
    WidgetTester tester,
    List<MoodEntry> entries, {
    SubscriptionStatus subscription = SubscriptionStatus.inactive,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    entitlements = FakeMoodEntitlementsRepository(subscription: subscription);
    await tester.pumpWidget(
      buildTestApp(
        moods: InMemoryMoodRepository(entries),
        entitlements: entitlements,
        telemetry: telemetry,
        calendarMonth: today,
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(390, 844),
            textScaler: TextScaler.linear(textScale),
          ),
          child: InsightsScreen(clock: () => today),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(finder, 300,
          scrollable: find.byType(Scrollable).first);

  testWidgets('without entries it shows the empty state and no cards',
      (tester) async {
    await pump(tester, const []);

    expect(find.text(strings.insightsEmptyTitle), findsOneWidget);
    expect(find.text(strings.trendTitle), findsNothing);
    expect(find.text(strings.seeWithPremium), findsNothing);
  });

  group('without a subscription', () {
    testWidgets('shows the free cards and blurs the Premium ones',
        (tester) async {
      await pump(tester, twentyDays());

      expect(find.text(strings.insightsMonthTitle('November')), findsOneWidget);
      expect(find.text(strings.trendTitle), findsOneWidget);
      // The trend names every category, so color is never the only cue.
      for (final name in [
        strings.categoryPositive,
        strings.categoryPeaceful,
        strings.categoryNeutral,
        strings.categoryHard,
      ]) {
        expect(find.text(name), findsWidgets);
      }
      await scrollTo(tester, find.text(strings.weekdayTitle));
      expect(find.text(strings.seeWithPremium), findsWidgets);
      expect(find.byType(WeekdayCard), findsNothing);
      expect(find.byType(YearPixelsCard), findsNothing);
      await scrollTo(tester, find.text(strings.yearInPixelsTitle(2026)));
      expect(find.byType(LockedInsightCard), findsNWidgets(2));
    });

    testWidgets('the blurred pixel preview paints real cells', (tester) async {
      await pump(tester, twentyDays());
      await scrollTo(tester, find.byType(SamplePixelsPreview));

      final cells = find.descendant(
        of: find.byType(SamplePixelsPreview),
        matching: find.byType(DecoratedBox),
      );
      expect(cells, findsWidgets);
      expect(tester.getSize(cells.first).height, greaterThan(0));
    });

    testWidgets('the blurred previews are fixed illustrations, not the data',
        (tester) async {
      await pump(tester, twentyDays());
      await scrollTo(tester, find.text(strings.yearInPixelsTitle(2026)));

      final previews = tester
          .widgetList<LockedInsightCard>(find.byType(LockedInsightCard))
          .map((card) => card.preview.runtimeType);
      expect(previews, [SampleBarsPreview, SamplePixelsPreview]);
    });

    testWidgets('7 and 30 days switch the trend freely', (tester) async {
      await pump(tester, twentyDays());
      final handle = tester.ensureSemantics();

      expect(
        find.bySemanticsLabel(
            strings.trendChartSemantics(7, 6, strings.categoryPeaceful)),
        findsOneWidget,
      );
      await tester.tap(find.text(strings.trendRangeChip(30)));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(
            strings.trendChartSemantics(30, 20, strings.categoryPositive)),
        findsOneWidget,
      );
      expect(find.text(strings.paywallTitle), findsNothing);
      handle.dispose();
    });

    testWidgets('90 days opens the subscription and keeps the range',
        (tester) async {
      await pump(tester, twentyDays());
      final handle = tester.ensureSemantics();

      await tester.tap(find.text(strings.trendRangeChip(90)));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      expect(telemetry.events.single.name, 'store_opened');
      expect(telemetry.events.single.properties['source'], 'insights');
      expect(
        find.bySemanticsLabel(
            strings.trendChartSemantics(7, 6, strings.categoryPeaceful)),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('See with Premium opens the sheet with source insights',
        (tester) async {
      await pump(tester, twentyDays());
      await scrollTo(tester, find.text(strings.weekdayTitle));

      await tester.tap(find.text(strings.seeWithPremium).first);
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsOneWidget);
      expect(telemetry.events.single.properties, {'source': 'insights'});
    });

    testWidgets('opening Insights or switching 7/30 sends no event',
        (tester) async {
      await pump(tester, twentyDays());

      await tester.tap(find.text(strings.trendRangeChip(30)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.trendRangeChip(7)));
      await tester.pumpAndSettle();

      expect(telemetry.events, isEmpty);
      expect(find.text(strings.paywallTitle), findsNothing);
    });

    testWidgets('a single entry shows not enough data in the trend',
        (tester) async {
      await pump(tester, [
        MoodEntry(
          date: DateTime(2026, 11, 14),
          mood: 'assets/icon/calm.svg',
          intensity: 1,
        ),
      ]);

      expect(find.text(strings.insightsNotEnoughTitle), findsOneWidget);
    });
  });

  group('with a subscription', () {
    testWidgets('shows every card with data and no lock', (tester) async {
      await pump(tester, twentyDays(), subscription: subscribed);

      await scrollTo(tester, find.byType(WeekdayCard));
      expect(find.byType(WeekdayCard), findsOneWidget);
      await scrollTo(tester, find.byType(YearPixelsCard));
      expect(find.byType(YearPixelsCard), findsOneWidget);
      expect(find.text(strings.seeWithPremium), findsNothing);
      expect(find.byType(LockedInsightCard), findsNothing);
    });

    testWidgets('90 and 365 days switch the trend without the sheet',
        (tester) async {
      await pump(tester, twentyDays(), subscription: subscribed);
      final handle = tester.ensureSemantics();

      await tester.tap(find.text(strings.trendRangeChip(90)));
      await tester.pumpAndSettle();

      expect(find.text(strings.paywallTitle), findsNothing);
      expect(
        find.bySemanticsLabel(
            strings.trendChartSemantics(90, 20, strings.categoryPositive)),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a logged pixel opens that day and Edit reports its date',
        (tester) async {
      final edited = <DateTime>[];
      await pump(tester, twentyDays(), subscription: subscribed);
      // Rebuild with an edit callback.
      await tester.pumpWidget(
        buildTestApp(
          moods: InMemoryMoodRepository(twentyDays()),
          entitlements:
              FakeMoodEntitlementsRepository(subscription: subscribed),
          calendarMonth: today,
          home: InsightsScreen(clock: () => today, onEditEntry: edited.add),
        ),
      );
      await tester.pumpAndSettle();
      final handle = tester.ensureSemantics();
      await scrollTo(tester, find.byType(YearPixelsCard));

      await tester.tap(find.bySemanticsLabel(
        RegExp(strings.formatFullDate(DateTime(2026, 11, 14))),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(DayDetailSheet), findsOneWidget);

      await tester.tap(find.text(strings.editEntryButton));
      await tester.pumpAndSettle();
      expect(edited, [DateTime(2026, 11, 14)]);
      handle.dispose();
    });

    testWidgets('the year grid paints real pixels, not zero-height boxes',
        (tester) async {
      await pump(tester, twentyDays(), subscription: subscribed);
      await scrollTo(tester, find.byType(YearPixelsCard));

      final pixels = find.descendant(
        of: find.byType(YearPixelsCard),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).borderRadius ==
                  BorderRadius.circular(2),
        ),
      );
      expect(pixels, findsWidgets);
      expect(tester.getSize(pixels.first).height, greaterThan(0));
      expect(tester.getSize(pixels.first).width, greaterThan(0));
    });

    testWidgets('with a single year the year arrows are disabled',
        (tester) async {
      await pump(tester, twentyDays(), subscription: subscribed);
      await scrollTo(tester, find.byType(YearPixelsCard));

      final previous = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_left_rounded).last,
      );
      expect(previous.onPressed, isNull);
    });

    testWidgets('the locks come back when the subscription ends',
        (tester) async {
      await pump(tester, twentyDays(), subscription: subscribed);
      await scrollTo(tester, find.byType(WeekdayCard));
      expect(find.byType(LockedInsightCard), findsNothing);

      entitlements.expireSubscription();
      await tester.pumpAndSettle();

      expect(find.byType(LockedInsightCard), findsNWidgets(2));
      expect(find.text(strings.seeWithPremium), findsWidgets);
    });
  });

  testWidgets('keeps working with text at 200%', (tester) async {
    await pump(tester, twentyDays(), subscription: subscribed, textScale: 2);
    await scrollTo(tester, find.byType(YearPixelsCard));

    expect(tester.takeException(), isNull);
  });
}
