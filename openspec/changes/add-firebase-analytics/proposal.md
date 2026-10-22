## Why

No hay forma fiable de saber cuántos usuarios usan Mood Calendar: App Store Connect solo cuenta a quien comparte analíticas con Apple, RevenueCat solo a quien abrió una versión con compras y Google Play aún no está publicado. Sin una medición propia y anónima no podemos saber usuarios activos, retención ni qué versión se usa, y las decisiones de producto (más moods, packs, precio) se toman a ciegas. Firebase ya está en el proyecto por Crashlytics, así que medir uso cuesta casi nada más, y conviene hacerlo junto con la corrección pendiente de las declaraciones de privacidad para no tocarlas dos veces.

## What Changes

- Añadir **Firebase Analytics** (`firebase_analytics`) en iOS y Android, activo solo en builds de release y bajo la misma regla de activación que Crashlytics (`kReleaseMode`, iOS/Android, sin web ni desktop).
- Medir **usuarios activos, sesiones, versión y país** de forma anónima (ID de instalación de Firebase, sin cuentas) y un conjunto **cerrado y mínimo de eventos** ya definidos en `AppTelemetryEvents` (`mood_saved`, `opened_from_reminder`, `reminder_scheduled`, `reminder_cancelled`, `rating_prompt_requested`, `rating_manual_opened`) más la apertura de la tienda y el resultado de las compras.
- **Nunca** enviar datos de las entradas (mood, nota, fecha, intensidad): se reutiliza la lista de claves bloqueadas de Crashlytics (`blockedContextKeys`) también para los parámetros de eventos.
- **Sin ID de publicidad ni seguimiento**: se desactiva la recolección del IDFA/AAID, no se enlaza Analytics con Google Ads y no se solicita App Tracking Transparency.
- Añadir en Settings un interruptor **"Compartir datos de uso anónimos"** (activo por defecto, opt-out) que apaga la recolección de Analytics al instante y se guarda localmente. No gobierna Crashlytics (queda como está, ver `backlog.md`).
- Actualizar las declaraciones de privacidad **en un solo paso**: App Privacy de App Store Connect (*Usage Data → Product Interaction*, *Identifiers → Device ID*, más *Purchases* que ya faltaba), Seguridad de los datos de Google Play y la política de privacidad (TermsFeed), que además debe mencionar Crashlytics y RevenueCat.
- El entrypoint `tool/screenshots/main.dart`, los tests y los builds debug no envían nada.

## Capabilities

### New Capabilities
- `usage-analytics`: medición anónima de uso con Firebase Analytics solo en release, con lista cerrada de eventos, sin datos de entradas ni identificadores publicitarios, y con interruptor de opt-out.

### Modified Capabilities
- `settings-screen`: nueva fila en Settings con el interruptor "Compartir datos de uso anónimos".

## Impact

- **Dependencias**: `firebase_analytics` en `pubspec.yaml` (compatible con `firebase_core` ^4.x ya presente); pods de Firebase en iOS (iOS 15.0 es compatible) y dependencia de Gradle en Android.
- **Código**: `lib/core/telemetry/` (nueva implementación de `AppTelemetry` que reenvía eventos, una interfaz inyectable para tests, extensión de la lista de claves bloqueadas), `lib/core/settings/` (preferencia nueva en Hive), `lib/features/settings/` (fila y `SettingsCubit`), `lib/main.dart` (composición), strings en los 5 idiomas.
- **Plataforma**: `ios/Runner/Info.plist` (desactivar recolección de IDFA) y `android/app/src/main/AndroidManifest.xml` (desactivar el ID de publicidad); no se añade el permiso de Android `AD_ID`.
- **Privacidad / tiendas**: App Privacy en ASC, Data safety en Play Console y política de privacidad; hay que publicarlas antes de enviar a revisión la versión que incluya Analytics. Cambia el mensaje "datos solo locales".
- **Documentación**: `CLAUDE.md` (stack y arranque), `docs/risks.md` si procede y `backlog.md` (el toggle de Crashlytics sigue pendiente).
- **CI**: `flutter analyze` y `flutter test` no deben requerir Firebase; todo se prueba con fakes.
- **Fuera de alcance**: backend propio, cuentas de usuario, Crashlytics opt-out, atribución de campañas y A/B testing.
