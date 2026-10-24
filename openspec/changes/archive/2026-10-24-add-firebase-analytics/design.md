## Context

`AppTelemetry` (`lib/core/telemetry/`) ya es el punto único por el que pasan `trackEvent` y `recordError`. `main.dart` lo compone: `LoggerAppTelemetry` (log local) y, si Crashlytics se inicializó, `CrashlyticsAppTelemetry` lo envuelve y reenvía los errores quitando `blockedContextKeys` (`date`, `mood`, `intensity`, `note`). Firebase ya se inicializa antes de `runApp()` en `initializeCrashReporting` solo en release, iOS/Android y con `errorsEnabled`. Hoy los eventos solo van al log; algunos incluyen datos de entradas (`mood_saved` manda `date`, `intensity`, `mood`, `has_note`; `mood_history_exported` manda `file_name`). Las preferencias locales viven en `core/settings/` (Hive) y Settings usa autoguardado con revertir al fallar. Ver `proposal.md` para el motivo.

## Goals / Non-Goals

**Goals:**
- Que los eventos que ya existen lleguen a Firebase Analytics sin cambiar los call sites.
- Garantizar por construcción (no por disciplina) que ningún dato de entradas ni identificador publicitario sale del dispositivo.
- Que el opt-out sea inmediato, persistente y probado.

**Non-Goals:**
- No se añaden cuentas, user properties ni IDs propios: la identidad es solo el ID de instalación de Firebase.
- No se mide navegación por pantallas ni se activa el seguimiento automático de pantallas.
- No se cambia el comportamiento de Crashlytics ni su toggle.

## Decisions

**1. Un decorador `AnalyticsAppTelemetry` sobre `AppTelemetry`, con una interfaz `AnalyticsReporter`.**
Igual que `CrashlyticsAppTelemetry`: envuelve al delegado, siempre escribe en el log y reenvía `trackEvent` a un `AnalyticsReporter` (`logEvent(name, params)` y `setEnabled(bool)`), con `FirebaseAnalyticsReporter` como implementación real y un fake en tests. Los call sites no cambian y CI no necesita Firebase.
*Alternativa:* llamar a `FirebaseAnalytics` directo desde cubits y servicios. Descartada: acopla la UI a Firebase, no se puede probar sin plugin y deja la privacidad en manos de cada call site.

**2. Composición en cadena.** `Logger → Crashlytics (si hay) → Analytics (si hay)`. Si Firebase falla al inicializar, ninguno de los dos decoradores existe y la app sigue con log local, igual que hoy. Se reutiliza `initializeCrashReporting` para `Firebase.initializeApp` y se añade `initializeAnalytics` que depende de que Firebase ya esté listo (misma regla: nunca espera al usuario).

**3. Lista cerrada de eventos y parámetros (allowlist), no solo lista de bloqueo.** `AnalyticsAppTelemetry` solo reenvía eventos de `AppTelemetryEvents` más los nuevos de tienda y compras (`store_opened`, `purchase_started|completed|cancelled|failed`, `purchases_restored`). Cualquier otro nombre (p. ej. `mood_history_exported`) se queda en el log. De los parámetros solo pasan `has_note` (booleano) y `source`; se descarta todo lo demás, incluidas las claves de `blockedContextKeys`. La allowlist es la que garantiza el spec "Lista cerrada de eventos"; `blockedContextKeys` se mueve a una constante compartida para que Crashlytics y Analytics usen la misma.
*Alternativa:* solo filtrar claves bloqueadas. Descartada: un parámetro nuevo con datos de entradas pasaría sin que nadie lo note.

**4. Sin identificadores publicitarios por configuración de plataforma, no por código.** iOS: `Info.plist` con `GOOGLE_ANALYTICS_IDFV_COLLECTION_ENABLED` activo (IDFV, no IDFA), `GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS=false` y `GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_STORAGE=false`; no se enlaza `FirebaseAnalytics/IdentitySupport` ni AdSupport, y no se añade `NSUserTrackingUsageDescription`. Android: `AndroidManifest.xml` con `google_analytics_adid_collection_enabled=false` y `tools:node="remove"` del permiso `com.google.android.gms.permission.AD_ID`. Un script de verificación (patrón de `verify_*_key.sh`) comprueba el manifiesto fusionado del bundle.
*Alternativa:* confiar en los valores por defecto del SDK. Descartada: el SDK de Android declara `AD_ID` por defecto y Play lo exige declarar.

**5. Opt-out guardado en Hive y aplicado antes del primer evento.** Se añade `usageAnalyticsEnabled` (por defecto `true`) a `AppSettings`. `main.dart` lee la preferencia tras abrir Hive y llama `setAnalyticsCollectionEnabled(value)` antes de componer la telemetría; `SettingsCubit` la cambia con el mismo patrón de autoguardado en cola y reversión. Como Firebase Analytics persiste el estado de recolección, el SDK puede arrancar con la recolección desactivada en `Info.plist`/manifiesto (`FIREBASE_ANALYTICS_COLLECTION_ENABLED=false`) y activarse solo cuando la preferencia lo permite, evitando que se envíe nada antes de leer Hive.
*Alternativa:* dejar la recolección activa y filtrar en el decorador. Descartada: el SDK envía `first_open` y `session_start` por su cuenta, fuera de nuestro control.

**6. Eventos automáticos del SDK.** Se aceptan `first_open`, `session_start`, `app_update` y `os_update` (son los que dan usuarios activos y versiones). Se desactiva el seguimiento automático de pantallas porque los nombres de pantalla no aportan y reduce superficie.

**7. Un solo paso para las declaraciones de privacidad.** Se publican juntas App Privacy (*Usage Data → Product Interaction*, *Identifiers → Device ID* y la etiqueta *Purchases* que ya faltaba; no vinculados a la identidad, sin tracking), Seguridad de los datos de Play y la política actualizada, antes de enviar a revisión el build con Analytics.

## Risks / Trade-offs

- [Un evento futuro filtra datos de entradas] → la allowlist de eventos y parámetros más un test que recorre todos los eventos de `AppTelemetryEvents` con propiedades sensibles y verifica que no salen.
- [El SDK envía eventos automáticos antes del opt-out] → recolección apagada por configuración nativa y encendida en código solo si la preferencia es `true`; test de orden de arranque.
- [Opt-out por defecto es más laxo que opt-in] → la app no tiene cuentas, no se recoge nada personal y el interruptor está visible en Settings; si Apple o Google piden consentimiento previo, el valor por defecto se cambia a `false` sin tocar el resto del diseño.
- [Analytics y Crashlytics comparten el ID de instalación de Firebase] → se declara así en las tiendas; no se enlazan con ningún dato de entradas.
- [La cifra de usuarios sigue siendo aproximada] → quien desactive el interruptor o use una versión anterior no cuenta; se documenta como "instalaciones activas medidas", no como total de usuarios.
- [El tamaño del binario crece] → `firebase_analytics` añade unos pocos MB; se mide en el build de release y se acepta si es menor a 3 MB.

## Migration Plan

1. Implementar y probar en una rama; verificar en `DebugView` de Firebase con un build de profile (único caso donde se activa la depuración, no se envía a producción).
2. Subir los builds nuevos (iOS build 33 o superior, Android con `versionCode` mayor que 32) con los scripts de release de siempre.
3. Publicar las declaraciones de privacidad y la política **antes** de enviar el build a revisión.
4. Rollback: apagar `FIREBASE_ANALYTICS_COLLECTION_ENABLED` en una actualización o retirar el decorador de `main.dart`; el resto de la app no depende de Analytics.

## Open Questions

- ¿Se quiere mostrar una vez, en la primera apertura, un aviso de que existe el interruptor? Puede resolverse después sin cambiar specs ni tareas.
