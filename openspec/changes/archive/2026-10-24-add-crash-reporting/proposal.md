## Why

Hoy no hay visibilidad de los crashes en producción: `AppTelemetry.recordError` solo escribe en el log local (`LoggerAppTelemetry`) y no hay hooks globales de errores, así que un fallo en el dispositivo de un usuario nunca llega al desarrollador. Los crashes son la causa principal de reseñas de 1 estrella y penalizan el ranking en App Store; necesitamos detectarlos y poder leerlos con stack traces simbolicados, sin costo (free tier) y sin backend propio.

## What Changes

- Integrar **Firebase Crashlytics** (`firebase_core` + `firebase_crashlytics`) como proveedor de reporte de crashes, activo solo en builds de release, en iOS y Android.
- Registrar los hooks globales (`FlutterError.onError`, `PlatformDispatcher.instance.onError`) para capturar errores fatales de Flutter y errores asíncronos no manejados.
- Añadir `CrashlyticsAppTelemetry`, una implementación de `AppTelemetry` que reenvía `recordError` a Crashlytics como error no fatal, sin tocar los call sites actuales.
- Inicializar Firebase antes de `runApp()` sin esperar nada que dependa del usuario (respeta la regla de arranque del proyecto).
- Subir dSYMs en el flujo de release de iOS, y los símbolos nativos en Android, para que los traces lleguen simbolicados.
- Política de **opt-out**: el reporte está activo por defecto, sin toggle en Settings (el toggle queda anotado en `backlog.md` como seguimiento).
- Actualizar la política de privacidad y la declaración "App Privacy" de App Store Connect y la sección "Data safety" de Google Play para declarar *Crash Data* (no vinculado a la identidad, sin tracking).

## Capabilities

### New Capabilities
- `crash-reporting`: captura y envío de crashes y errores no fatales a Crashlytics solo en release, con hooks globales, sin datos personales y con el entrypoint de screenshots y los builds de debug excluidos.

### Modified Capabilities
<!-- Ninguna: no cambian requisitos de specs existentes (no hay toggle en Settings). -->

## Impact

- **Dependencias**: `firebase_core`, `firebase_crashlytics` en `pubspec.yaml`; pods de Firebase en iOS (deployment target iOS 15.0 es compatible).
- **Código**: `lib/main.dart` (init y hooks), `lib/core/telemetry/` (nueva implementación y config), archivos de plataforma (`ios/Runner/GoogleService-Info.plist`, build phase de Crashlytics, `android/app/google-services.json`, plugins de Gradle de Google Services y Crashlytics).
- **Release**: `scripts/build_ios_release.sh` / verificación de archive deben cubrir la subida de dSYMs; `tool/screenshots/main.dart` no debe reportar.
- **Privacidad / tienda**: política de privacidad (página de TermsFeed enlazada desde Settings) y App Privacy en App Store Connect; el mensaje "datos solo locales" cambia a "datos locales, salvo reportes de fallos anónimos".
- **CI**: `flutter analyze` y `flutter test` no deben requerir Firebase (la implementación se inyecta y se prueba con fakes).
