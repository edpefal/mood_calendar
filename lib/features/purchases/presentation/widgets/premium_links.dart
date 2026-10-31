import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PremiumUrlOpener = Future<bool> Function(Uri url);

Future<bool> openInExternalBrowser(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// URL de la página legal del sitio en el idioma del dispositivo: el sitio
/// solo existe en inglés y en español, así que los demás idiomas usan inglés.
Uri legalPageUrl(BuildContext context, String page) {
  final isSpanish = Localizations.localeOf(context).languageCode == 'es';
  return Uri.parse(
    isSpanish
        ? 'https://moodcalendar.app/es/$page/'
        : 'https://moodcalendar.app/$page/',
  );
}
