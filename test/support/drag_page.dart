import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Arrastra el carrusel del selector exactamente una página. Su ancho depende
/// de la pantalla (la mitad del ancho, con tope en pantallas anchas), así que
/// un arrastre fijo puede saltar más de un mood.
Future<void> dragPage(WidgetTester tester, {bool forward = true}) async {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  final pageWidth = tester.getSize(find.byType(PageView)).width *
      pageView.controller!.viewportFraction;
  await tester.drag(
    find.byType(PageView),
    Offset(forward ? -pageWidth : pageWidth, 0),
  );
}
