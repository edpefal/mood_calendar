## Why

El Bloque 1 dejó el paywall prometiendo "Notas protegidas con biometría" y el diseño de referencia (artefacto `b968c1cf-8592-4534-8a8c-db17961bb6fc`, pantallas Onboarding 1–4, Note y Settings) incluye un onboarding de 4 pasos que hoy no existe: quien instala la app cae directo en el Log, el permiso de notificaciones aparece sin contexto y nadie le explica el recordatorio. Este es el tercero y último bloque del rediseño; con él se cumple la promesa del paywall y la versión se puede publicar.

## What Changes

- **Onboarding de 4 pasos** para instalaciones nuevas: (1) bienvenida, (2) hora del recordatorio con tres sugerencias y un selector de rueda, (3) permiso de notificaciones con "Turn on reminder" / "Not now", (4) primer registro ("How are you feeling right now?") que guarda de verdad la entrada de hoy y termina en "Day 1 of your calendar". "Skip" está disponible en los pasos 1 a 3. Se muestra una sola vez; quien ya tiene entradas nunca lo ve.
- **El permiso de notificaciones deja de pedirse al arrancar** en una instalación nueva: se pide en el paso 3 del onboarding (o al activar el recordatorio en Ajustes). Las instalaciones existentes conservan su comportamiento.
- **Hoja de suscripción al final del onboarding** (con `source` = `onboarding`), una sola vez, descartable y nunca a un suscriptor. **BREAKING (regla del Bloque 1)**: hasta ahora la oferta no podía aparecer "en un onboarding"; el diseño de referencia la pone al terminar el paso 4.
- **Bloqueo de notas con biometría** (Premium): un interruptor "Lock with Face ID" en Ajustes > Privacy and data. Con el bloqueo activo, el texto de las notas solo se muestra tras autenticarse (Face ID, Touch ID, huella o el código del dispositivo) y vuelve a ocultarse al enviar la app a segundo plano. Protege el Log (tarjeta Saved y editor), el detalle del día y la exportación del historial. Los moods, las fechas y las rachas siguen visibles.
- **Quien deja de pagar no pierde acceso a sus notas**: activar el bloqueo exige Premium, pero un bloqueo ya activo se sigue aplicando (y se puede apagar) aunque la suscripción venza.
- **Analíticas**: eventos nuevos sin datos de entradas (`onboarding_completed`, `onboarding_skipped`, `note_lock_enabled`, `note_lock_disabled`), parámetro `step` y valor `onboarding` de `source`.
- **Fuera de este bloque**: palabras frecuentes de las notas (necesitan el texto de las notas, que ahora puede estar bloqueado; siguen en `backlog.md`), "tu mes en una imagen", respaldo en iCloud, exportar CSV/PDF, selector de idioma y de ícono (filas del diseño que Ajustes descartó), bloqueo de la app completa, ícono, sitio y arte de tienda. No se publica versión, no se recapturan capturas ni se tocan las tiendas.

## Capabilities

### New Capabilities
- `onboarding`: cuándo se muestra, los 4 pasos, cómo se omite, qué guarda (hora del recordatorio, permiso, primer registro) y cómo termina en la hoja de suscripción.
- `note-lock`: bloqueo biométrico de las notas: qué protege, cuándo exige autenticación y vuelve a bloquear, disponibilidad del dispositivo, acceso Premium y qué pasa si vence la suscripción.

### Modified Capabilities
- `premium-subscription`: la hoja también puede abrirse una vez al terminar el onboarding (`source` = `onboarding`) y desde la fila bloqueada "Lock with Face ID" de Ajustes.
- `settings-screen`: la sección Privacy and data añade la fila "Lock with Face ID" con la marca Pro, y activar el recordatorio pide el permiso de notificaciones si aún no se ha decidido.
- `usage-analytics`: eventos de onboarding y de bloqueo de notas, parámetro `step`, valor `onboarding` de `source`.
- `mood-history-export`: con el bloqueo de notas activo, exportar exige autenticarse porque el archivo lleva el texto de las notas.
- `daily-note-capture`: el texto de una nota existente solo se muestra (tarjeta Saved y editor) con la sesión desbloqueada cuando el bloqueo está activo.

## Impact

- **Código (`lib/`)**: nuevo `features/onboarding` (cubit, 4 pantallas, gate en la raíz de la app) y `features/note_lock` (servicio de autenticación inyectable, `NoteLockCubit`, widget que oculta el texto); `core/settings` (claves `onboardingCompleted` y `noteLockEnabled` en Hive, sin migración); `core/notifications/local_notification_service.dart` (pedir el permiso bajo demanda en vez de al arrancar en instalaciones nuevas); `main.dart` (gate de onboarding, `NoteLockCubit`, `AppLifecycle`); `features/mood/presentation` (tarjeta Saved, `NoteEditorSheet`, `DayDetailSheet`); `features/settings` (fila nueva y flujo de activación); `features/purchases` (`PremiumSource.onboarding`); `core/telemetry` (allowlist); `core/localization/*` en los 5 idiomas.
- **Dependencias**: `local_auth` **fijado en `^2.3.0`**: la 3.x exige Dart ^3.9 / Flutter 3.35 y el CI usa Flutter 3.32.1 (ver `CLAUDE.md`); `local_auth_android` 1.x y `local_auth_darwin` 1.x resuelven en esa versión. Hay que comprobarlo con Flutter 3.32.1 antes de dar por buena la dependencia.
- **Plataformas**: iOS `Info.plist` (`NSFaceIDUsageDescription`, localizada en los 5 idiomas con `InfoPlist.strings`); Android `AndroidManifest.xml` (`USE_BIOMETRIC`), `MainActivity` pasa a `FlutterFragmentActivity` y los temas deben ser de AppCompat (requisito de `local_auth_android`). El reloj no cambia: no muestra notas.
- **Datos**: dos claves nuevas en la caja de ajustes; sin migración. Las entradas no cambian. El texto de las notas sigue guardado sin cifrar en Hive: el bloqueo es una barrera de interfaz, no cifrado en reposo (se documenta en `docs/risks.md`).
- **Privacidad**: sin SDK nuevo que recoja datos; la autenticación ocurre en el sistema operativo y la app solo recibe sí/no. App Privacy, Data safety y la política no cambian; la política de privacidad sí puede mencionar el bloqueo de notas (a decidir en el paso de marketing). Los eventos nuevos no llevan datos de entradas.
- **Docs**: `CONTEXT.md` (Onboarding, Note lock), `CLAUDE.md`, `backlog.md` (palabras frecuentes dependen del bloqueo) y `docs/risks.md`.
- **Tests**: nuevos para el cubit y las pantallas del onboarding, el gate de primera ejecución, el cubit y el widget del bloqueo con un autenticador falso, y la fila de Ajustes; se adaptan los del Log, el detalle del día, la exportación y el arranque.
- **Dependencia de orden**: los deltas de `premium-subscription` y `settings-screen` parten de los de los Bloques 1 y 2; hay que archivar primero el Bloque 1 y luego el 2 (al 2026-11-05 les faltan las mediciones en iPhone real, 9.3, 7.2 y 7.3).
