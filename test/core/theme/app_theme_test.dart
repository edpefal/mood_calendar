import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/app_theme.dart';

/// The AppBar is transparent over the mesh background, so Flutter would pick
/// white status bar icons for both themes unless the theme says otherwise.
void main() {
  testWidgets('light theme asks for dark status bar icons', (tester) async {
    final style =
        buildAppTheme(Brightness.light).appBarTheme.systemOverlayStyle;
    await tester.pumpAndSettle();

    expect(style, SystemUiOverlayStyle.dark);
  });

  testWidgets('dark theme asks for light status bar icons', (tester) async {
    final style = buildAppTheme(Brightness.dark).appBarTheme.systemOverlayStyle;
    await tester.pumpAndSettle();

    expect(style, SystemUiOverlayStyle.light);
  });
}
