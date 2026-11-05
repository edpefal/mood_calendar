import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/presentation/widgets/logged_time_text.dart';

void main() {
  Future<String> format(
    WidgetTester tester, {
    required bool use24Hour,
    Locale locale = const Locale('en'),
  }) async {
    late String text;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('de')],
        builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24Hour),
          child: child!,
        ),
        home: Builder(builder: (context) {
          text = formatLoggedTime(context, DateTime(2026, 11, 2, 21, 2));
          return const SizedBox();
        }),
      ),
    );
    return text;
  }

  testWidgets('uses the 12 hour format when the device does', (tester) async {
    expect(await format(tester, use24Hour: false), '9:02 PM');
  });

  testWidgets('uses the 24 hour format when the device does', (tester) async {
    expect(await format(tester, use24Hour: true), '21:02');
  });

  testWidgets('follows the device language', (tester) async {
    expect(
      await format(tester, use24Hour: true, locale: const Locale('de')),
      '21:02',
    );
  });
}
