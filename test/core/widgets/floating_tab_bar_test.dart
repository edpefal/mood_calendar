import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/widgets/floating_tab_bar.dart';

void main() {
  const items = [
    FloatingTabItem(icon: Icons.calendar_today, label: 'Calendar'),
    FloatingTabItem(icon: Icons.bar_chart_rounded, label: 'Insights'),
    FloatingTabItem(icon: Icons.add_rounded, label: 'Log', highlighted: true),
    FloatingTabItem(icon: Icons.tune_rounded, label: 'Settings'),
  ];

  Widget buildBar({
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    Size size = const Size(390, 844),
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingTabBar(
                items: items,
                currentIndex: currentIndex,
                onTap: onTap ?? (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('lays out the tabs in order', (tester) async {
    await tester.pumpWidget(buildBar());

    final xs = [
      for (final item in items) tester.getCenter(find.byTooltip(item.label)).dx,
    ];
    expect(xs, [...xs]..sort());
    expect(xs.toSet(), hasLength(items.length));
  });

  testWidgets('reports the tapped index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(buildBar(onTap: taps.add));

    await tester.tap(find.byTooltip('Log'));
    await tester.tap(find.byTooltip('Calendar'));

    expect(taps, [2, 0]);
  });

  testWidgets('shows every tab name', (tester) async {
    await tester.pumpWidget(buildBar());

    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  });

  testWidgets('draws the active tab brighter and heavier than the others',
      (tester) async {
    await tester.pumpWidget(buildBar(currentIndex: 1));

    TextStyle styleOf(String label) =>
        tester.widget<Text>(find.text(label)).style!;

    expect(styleOf('Insights').color!.a, 1);
    expect(styleOf('Insights').fontWeight, FontWeight.w600);
    expect(styleOf('Calendar').color!.a, lessThan(1));
    expect(styleOf('Calendar').fontWeight, FontWeight.w500);
  });

  testWidgets('the central tab is a round gradient button', (tester) async {
    await tester.pumpWidget(buildBar(currentIndex: 2));

    final button = tester.widget<Container>(
      find.descendant(
        of: find.byTooltip('Log'),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      ),
    );
    expect((button.decoration! as BoxDecoration).gradient, isNotNull);
    expect(tester.getSize(find.byWidget(button)), const Size(38, 38));
  });

  testWidgets('exposes labelled, selectable semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildBar(currentIndex: 2));

    expect(
      tester.getSemantics(find.byTooltip('Log')),
      matchesSemantics(
        label: 'Log',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        isEnabled: false,
        hasEnabledState: false,
      ),
    );
    expect(
      tester.getSemantics(find.byTooltip('Calendar')),
      matchesSemantics(
        label: 'Calendar',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('long labels at 200% text do not overflow the fixed-height bar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingTabBar(
                items: const [
                  FloatingTabItem(
                      icon: Icons.calendar_today, label: 'Kalender'),
                  FloatingTabItem(
                      icon: Icons.bar_chart_rounded, label: 'Insights'),
                  FloatingTabItem(
                    icon: Icons.add_rounded,
                    label: 'Eintrag',
                    highlighted: true,
                  ),
                  FloatingTabItem(
                      icon: Icons.tune_rounded, label: 'Einstellungen'),
                ],
                currentIndex: 2,
                onTap: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps a maximum width on wide screens', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildBar(size: const Size(1024, 768)));

    final bar = tester.getRect(
      find
          .descendant(
            of: find.byType(FloatingTabBar),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(bar.width, lessThanOrEqualTo(FloatingTabBar.maxWidth));
    expect(bar.center.dx, closeTo(512, 0.5));
  });
}
