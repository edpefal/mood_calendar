## 1. Firebase y dependencias

- [x] 1.1 Registrar en el proyecto Firebase `mood-calendar-fee5c` las apps iOS `com.artlab.moodcalendar` y Android `com.artlab.mood_calendar` (hecho con `firebase apps:create`); falta habilitar Crashlytics en la consola (paso manual)
- [x] 1.2 Colocar `GoogleService-Info.plist` en `ios/Runner/`, versionarlo en el repo (añadirlo al target Runner) y `android/app/google-services.json` (descargados con `firebase apps:sdkconfig`); restringir las API keys al bundle ID iOS y al package + SHA-1 de Android en Google Cloud Console — Los archivos están versionados en el repo.
- [x] 1.3 Añadir `firebase_core` y `firebase_crashlytics` a `pubspec.yaml`, correr `flutter pub get` y `pod install`; confirmar que compila con iOS 15.0
- [x] 1.4 Añadir la build phase de subida de símbolos de Crashlytics al target Runner
- [x] 1.5 Android: añadir los plugins de Gradle `com.google.gms.google-services` y `com.google.firebase.crashlytics` y confirmar que `flutter build appbundle` compila

## 2. Capa de telemetría

- [x] 2.1 Definir la interfaz `CrashReporter` (`recordFatal`, `recordNonFatal`) en `lib/core/telemetry/`
- [x] 2.2 Implementar `FirebaseCrashReporter` sobre `FirebaseCrashlytics`
- [x] 2.3 Implementar `CrashlyticsAppTelemetry`: delega todo en `LoggerAppTelemetry` y reenvía `recordError` a `CrashReporter` como no fatal; `trackEvent` solo al logger
- [x] 2.4 Revisar los call sites de `recordError` y asegurar que el `context` no incluye notas, moods ni fechas de entrada

## 3. Arranque

- [x] 3.1 En `main()`, tras `ensureInitialized()` y antes de `runApp()`, inicializar Firebase solo si `kReleaseMode`, iOS o Android y `errorsEnabled`, dentro de `try/catch` con fallback a `LoggerAppTelemetry`
- [x] 3.2 Registrar `FlutterError.onError` y `PlatformDispatcher.instance.onError` hacia `CrashReporter`
- [x] 3.3 Componer la implementación de `AppTelemetry` en `main.dart` según el gate de release
- [x] 3.4 Confirmar que `tool/screenshots/main.dart` no inicializa Firebase ni reporta

## 4. Tests

- [x] 4.1 Crear `FakeCrashReporter` en `test/support/`
- [x] 4.2 Test de `CrashlyticsAppTelemetry`: reenvía `recordError` como no fatal, siempre escribe al log, `trackEvent` no llega al reporter
- [x] 4.3 Test del gate: con config de errores desactivada no se reenvía nada
- [x] 4.4 Test de que un fallo de `CrashReporter` no propaga la excepción al llamador
- [x] 4.5 Correr `flutter analyze` y `flutter test` sin Firebase configurado

## 5. Release y símbolos

- [x] 5.1 Extender `scripts/build_ios_release.sh` para verificar que el archive contiene dSYMs y `GoogleService-Info.plist` (el plist está versionado, no se inyecta)
- [ ] 5.2 Subir un build a TestFlight (y uno a la pista interna de Play), forzar un crash de prueba y confirmar que llega simbolicado a la consola de Crashlytics — No se verificó un crash simbolicado en iOS al archivar (en Android el crash sí llegó a la consola). — No verificado al archivar.
- [ ] 5.3 Medir el arranque en frío antes y después en iPhone y iPad; confirmar que la UI aparece antes del diálogo de notificaciones — No medido al archivar.

## 6. Privacidad y documentación

- [x] 6.1 Declarar *Crash Data* (no vinculado a la identidad, sin tracking) en App Privacy de App Store Connect — Publicado en App Privacy (Crash Data, no vinculado, sin tracking).
- [x] 6.2 Actualizar la política de privacidad (TermsFeed, la que enlaza `privacyPolicyUrl` en Settings; no vive en el repo `support`) con un párrafo sobre reportes de fallos anónimos de Crashlytics — Cubierto por la política propia en https://moodcalendar.app/privacy/ (y `/es/privacy/`).
- [x] 6.3 Anotar en `backlog.md` el toggle de opt-out en Settings 
- [x] 6.4 Completar la sección "Data safety" de Google Play declarando datos de diagnóstico (crash logs) — Declarado en Data safety de Play (registros de fallas y diagnóstico).
- [x] 6.5 Actualizar `CLAUDE.md` (stack, arranque y comandos de release) con Crashlytics
