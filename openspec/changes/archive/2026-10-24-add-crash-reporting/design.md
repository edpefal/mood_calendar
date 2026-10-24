## Context

`AppTelemetry` (`lib/core/telemetry/`) ya aísla el destino de los errores: `recordError(name, reason, context, error, stackTrace)` y `trackEvent`. Su única implementación, `LoggerAppTelemetry`, escribe en el log local. `AppTelemetryConfig.errorsEnabled` vale `true` por defecto, también en debug. `lib/main.dart` no registra `FlutterError.onError` ni `PlatformDispatcher.onError`, así que los errores no manejados nunca se reportan.

Restricciones del proyecto: `runApp()` no puede esperar nada que dependa del usuario (rechazo de Apple 2.1(a)); Hive y `Purchases.configure()` sí se esperan antes de `runApp()`; iOS es la plataforma principal (iOS 15.0) y las compras solo existen en iOS, pero `deploy_android.yml` publica en Google Play, así que Android también se cubre. El proyecto Firebase `mood-calendar-fee5c` ya tiene registradas las apps `com.artlab.moodcalendar` (iOS, `1:1027445865703:ios:8ba25f27493625c91ef642`) y `com.artlab.mood_calendar` (Android, `1:1027445865703:android:aecf736adeabf7051ef642`); las apps `com.wezen.*` previas quedan sin uso. Ver `proposal.md` para la motivación.

## Goals / Non-Goals

**Goals:**
- Recibir crashes fatales y errores no fatales de builds de release de iOS y Android, simbolicados.
- Mantener los call sites de `AppTelemetry` intactos y testeables sin Firebase.
- No agregar `await` que dependa del usuario antes de `runApp()`.

**Non-Goals:**
- Analítica de uso (`trackEvent` sigue siendo solo log).
- Toggle de opt-out en Settings (se anota en `backlog.md`).
- Performance monitoring, breadcrumbs o logs de sesión.

## Decisions

**1. Firebase Crashlytics sobre Sentry.** Free tier sin tope de eventos, soporte oficial en Flutter, integración natural con dSYMs y App Store Connect. Sentry (~5k eventos/mes gratis) queda como plan B. Alternativas descartadas: Bugsnag/Instabug/Datadog (de pago o muy limitados).

**2. Nueva implementación de `AppTelemetry`, no un cambio en los call sites.** `CrashlyticsAppTelemetry` envuelve a `LoggerAppTelemetry` (componer, no reemplazar): siempre escribe al log y, además, reenvía `recordError` a Crashlytics como no fatal. `trackEvent` delega solo al logger. Así el log local sigue sirviendo en debug y los tests no dependen de Firebase.

**3. El gate de release vive en la composición, no en el SDK.** `main.dart` elige la implementación: Crashlytics solo si `kReleaseMode`, la plataforma es iOS o Android y `errorsEnabled`; en cualquier otro caso usa `LoggerAppTelemetry`. Se inyecta la dependencia de Firebase detrás de una interfaz pequeña (`CrashReporter`: `recordFatal`, `recordNonFatal`) para poder usar un fake en tests. Alternativa descartada: llamar a `FirebaseCrashlytics.instance` directamente, que obliga a mockear el plugin.

**4. Orden de arranque.** Dentro de `main()`, antes de `runApp()`: `Firebase.initializeApp()` (no espera al usuario), luego registrar `FlutterError.onError = recordFlutterFatalError` y `PlatformDispatcher.instance.onError` que reporta y devuelve `true`. Se hace tras `WidgetsFlutterBinding.ensureInitialized()` y se envuelve en `try/catch`: si falla, se registra en el log y la app arranca sin reporte. El permiso de notificaciones sigue después de `runApp()`.

**5. iOS y Android.** Android necesita `google-services.json` y los plugins de Gradle de Google Services y Crashlytics; sin ellos `firebase_core` falla al inicializar. El gate por plataforma excluye web y escritorio, donde no hay configuración. El `google-services.json` se versiona por la misma razón que el plist (decisión 8).

**6. Privacidad por construcción.** El `context` que ya se pasa a `recordError` se revisa para que no incluya notas, moods ni fechas de entrada; se reenvían a Crashlytics solo claves técnicas. No se llama a `setUserIdentifier`. Crashlytics asigna un ID de instalación propio.

**7. dSYMs en el flujo de release.** Se agrega la build phase de Crashlytics (script de subida de símbolos) al target Runner y `scripts/build_ios_release.sh` verifica al final que el archive contiene dSYMs (y que `GoogleService-Info.plist` está embebido), igual que ya verifica la key de RevenueCat.

**8. `GoogleService-Info.plist` versionado en el repo.** El repo es público y se decide versionar el plist en `ios/Runner/`. No es secreto: va embebido en el binario y se extrae del IPA. La protección real es restringir la API key en Google Cloud Console al bundle ID `com.artlab.moodcalendar`. Alternativas descartadas: inyectarlo en el script de release (complica CI y builds locales sin aportar seguridad) y hacer el repo privado (perdería branch protection en el plan gratuito y no protege el plist).

## Risks / Trade-offs

- [Crash en arranque por Firebase] → `try/catch` alrededor de `initializeApp` y fallback a `LoggerAppTelemetry`; verificar en simulador y iPad que la UI aparece antes del diálogo de notificaciones.
- [Traces sin simbolicar] → build phase de dSYMs y verificación en el script; probar con un crash forzado en un build de TestFlight.
- [El claim "100 % local" deja de ser exacto] → declarar *Crash Data* en App Privacy y actualizar la política de privacidad antes de enviar el build.
- [Sin toggle de opt-out] → riesgo bajo para datos anónimos; seguimiento en `backlog.md`. Agregarlo después no obliga a rehacer nada: bastaría leer el valor guardado en `initializeCrashReporting` y devolver `null` si está desactivado.
- [Ruido de errores benignos] → los hooks reportan solo no manejados; revisar el dashboard tras la primera versión y filtrar si hace falta.
- [API key de Firebase visible en un repo público] → restringir las API keys al bundle ID iOS y al package + SHA-1 de Android en Google Cloud Console; no hay datos sensibles en el plist.
- [Tamaño y tiempo de arranque] → medir el arranque en frío antes y después; Firebase añade peso al binario.

## Migration Plan

1. Crear el proyecto en Firebase, registrar la app iOS (`com.artlab.moodcalendar`) y habilitar Crashlytics.
2. Implementar y probar en rama; CI no requiere Firebase.
3. Subir un build a TestFlight, forzar un crash de prueba y confirmar que llega simbolicado.
4. Actualizar App Privacy y la política de privacidad antes de enviar a revisión.
5. Rollback: volver a `LoggerAppTelemetry` en `main.dart` (una línea) o desactivar con `ENABLE_ERROR_TELEMETRY=false`.
