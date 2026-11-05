import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/app_theme.dart';
import 'package:mood_calendar/core/widgets/glass_card.dart';

Widget _host(
    {bool highContrast = false, Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: buildAppTheme(brightness),
    home: MediaQuery(
      data: MediaQueryData(highContrast: highContrast),
      child: const Scaffold(
        body: Center(child: GlassCard(child: Text('hello'))),
      ),
    ),
  );
}

void main() {
  testWidgets('blurs what is behind it by default', (tester) async {
    await tester.pumpWidget(_host());

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('falls back to an opaque fill with high contrast',
      (tester) async {
    await tester.pumpWidget(_host(highContrast: true));

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('keeps the same content in the dark theme', (tester) async {
    await tester.pumpWidget(_host(brightness: Brightness.dark));

    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });
}
