import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/widgets/floating_tab_bar.dart';

void main() {
  const items = [
    FloatingTabItem(icon: Icons.sentiment_satisfied_outlined, label: 'Moods'),
    FloatingTabItem(icon: Icons.calendar_today, label: 'Calendar'),
    FloatingTabItem(icon: Icons.storefront_outlined, label: 'Store'),
    FloatingTabItem(icon: Icons.settings_outlined, label: 'Settings'),
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

    await tester.tap(find.byTooltip('Store'));
    await tester.tap(find.byTooltip('Moods'));

    expect(taps, [2, 0]);
  });

  testWidgets('only the active tab has the highlight pill', (tester) async {
    await tester.pumpWidget(buildBar(currentIndex: 1));
    await tester.pumpAndSettle();

    Color? pillColor(String label) {
      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byTooltip(label),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return (container.decoration! as BoxDecoration).color;
    }

    expect(pillColor('Calendar'), isNot(Colors.transparent));
    expect(pillColor('Moods'), Colors.transparent);
    expect(pillColor('Store'), Colors.transparent);
    expect(pillColor('Settings'), Colors.transparent);
  });

  testWidgets('exposes labelled, selectable semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(buildBar(currentIndex: 2));

    expect(
      tester.getSemantics(find.byTooltip('Store')),
      matchesSemantics(
        label: 'Store',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
        isEnabled: false,
        hasEnabledState: false,
      ),
    );
    expect(
      tester.getSemantics(find.byTooltip('Moods')),
      matchesSemantics(
        label: 'Moods',
        isButton: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('keeps a maximum width on wide screens', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildBar(size: const Size(1024, 768)));

    final bar = tester.getRect(
      find.descendant(
        of: find.byType(FloatingTabBar),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(bar.width, lessThanOrEqualTo(FloatingTabBar.maxWidth));
    expect(bar.center.dx, closeTo(512, 0.5));
  });
}
