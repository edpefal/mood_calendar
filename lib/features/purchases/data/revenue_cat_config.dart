import 'package:flutter/foundation.dart';

/// Variable de `--dart-define` con la llave pública de RevenueCat de [platform].
/// Cada tienda tiene su propia llave (`appl_...` en iOS, `goog_...` en Android).
String revenueCatKeyVariableFor(TargetPlatform platform) {
  return platform == TargetPlatform.android
      ? 'REVENUECAT_ANDROID_API_KEY'
      : 'REVENUECAT_IOS_API_KEY';
}

/// Elige la llave de RevenueCat que corresponde a [platform]. Devuelve una
/// cadena vacía si no hay llave para esa plataforma (p. ej. escritorio o web,
/// donde las compras no están soportadas).
String revenueCatApiKeyFor(
  TargetPlatform platform, {
  required String iosKey,
  required String androidKey,
}) {
  switch (platform) {
    case TargetPlatform.iOS:
      return iosKey;
    case TargetPlatform.android:
      return androidKey;
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
      return '';
  }
}
