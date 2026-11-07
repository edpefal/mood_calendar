## Context

Tercer y último bloque del rediseño (motivación y alcance en `proposal.md`; requisitos en los specs de este change). Diseño de referencia: artefacto `b968c1cf-8592-4534-8a8c-db17961bb6fc` (Onboarding 1 a 4, Note y Settings). Partimos de los Bloques 1 y 2 ya en `main`:

- `MyApp` usa `home: MainShell(key: mainShellKey)`. No existe ningún estado de "primera ejecución"; la caja de ajustes (`app_settings`, Hive) ya guarda el recordatorio, el tema y las analíticas con claves sueltas.
- `LocalNotificationService.initialize()` pide el permiso de notificaciones en **cada** arranque (`_requestPermissions`), después de `runApp()`, y `main()` programa el recordatorio con los valores por defecto (activo, 18:00). `SettingsCubit` ya programa y cancela con autoguardado.
- El texto de una nota se lee en tres sitios de la UI (`LogScreen` en Saved y el editor `NoteEditorSheet`, y `DayDetailSheet`) y se escribe en el JSON de `JsonMoodHistoryExporter`. El reloj y `ProcessWatchInboxUseCase` solo **conservan** la nota del día sin mostrarla.
- `PremiumSource` (`locked_mood`, `settings`, `insights`) y `showPremiumSheet(source)` ya existen; `PurchasesCubit` expone el estado de suscripción.
- `WatchSyncHost` ya observa el ciclo de vida de la app (`WidgetsBindingObserver`), un patrón que se reutiliza.
- El CI usa Flutter 3.32.1: toda dependencia nueva tiene que resolver y compilar ahí (ver `CLAUDE.md`).

## Goals / Non-Goals

**Goals:**
- Un onboarding que pida el permiso de notificaciones en contexto y deje la primera entrada guardada, reutilizando `MoodCubit`, el editor de notas y el planificador de recordatorios en vez de duplicarlos.
- Un bloqueo de notas con un único punto de verdad (`NoteLockCubit`), de modo que ninguna pantalla decida por su cuenta si muestra el texto.
- Que el bloqueo nunca deje al usuario fuera de sus propias notas (suscripción vencida, código eliminado).

**Non-Goals:**
- Cifrar las notas en reposo, bloquear la app completa o ocultar el mood, la fecha y las rachas.
- Palabras frecuentes de las notas, "tu mes en una imagen", respaldo en iCloud, exportar CSV/PDF, selector de idioma y de ícono.
- Proteger la captura de pantalla o la vista previa del selector de apps (`FLAG_SECURE`, "privacy screen"). Es un cambio aparte.
- Cambiar la sincronización del reloj: no muestra notas.

## Decisions

### 1. El onboarding vive en `features/onboarding` y se decide en la raíz, no dentro de `MainShell`
`MyApp.home` pasa a un `AppRoot` que lee un `OnboardingGate`: si la caja de ajustes no tiene `onboarding_completed` **y** la caja `moods` está vacía, muestra `OnboardingFlow`; si no, `MainShell`. La decisión se toma una vez, de forma síncrona con las cajas Hive que `main()` ya abrió antes de `runApp()`, así que no hay parpadeo ni tarea lenta. Al terminar u omitir, el flujo escribe `onboarding_completed` y `AppRoot` cambia a `MainShell`.
- **Por qué la condición "sin entradas"**: quien actualiza desde 1.10.x tiene la caja de ajustes sin la clave nueva; sin mirar las entradas vería un onboarding sobre un calendario lleno. No se usa "es la primera vez que se abre" como señal porque no existe.
- **Alternativa descartada**: poner el onboarding como una ruta que `MainShell` empuja al arrancar; mezcla el onboarding con el estado de las pestañas y con el toque del recordatorio, y obliga a cancelar la ruta si llega una notificación.
- **Consecuencia aceptada**: reinstalar la app borra Hive y vuelve a mostrar el onboarding. Es lo esperado.

### 2. Estado del onboarding en un cubit, pasos como widgets simples
`OnboardingCubit` guarda `step` (1 a 4), la hora elegida y, en el paso 4, el mood elegido y la nota; no toca Hive hasta confirmar. Los pasos 1 a 3 solo cambian el estado y lanzan efectos inyectados (guardar la hora y el recordatorio mediante `SettingsCubit`, pedir el permiso mediante `LocalNotificationService`). El paso 4 reutiliza `MoodCategoryGrid` filtrando los Moods base (sin candados) y el `NoteEditorSheet` existente, y guarda con `MoodCubit.save` para que la entrada, la hora de registro y el estado Saved del Log sean los de siempre. El progreso se dibuja con un widget propio (`OnboardingProgress`) que expone "Step n of 4" como `Semantics`.
- **Por qué `MoodCubit` y no un caso de uso suelto**: así la pestaña Log arranca ya en "Saved" de hoy cuando el flujo termina, y los tests de guardado cubren las dos entradas.
- **Qué no ocurre**: la calificación se pide desde el Log al entrar en Saved tras un guardado; como el Log no está montado durante el onboarding y la política exige el 3.er día con entradas, no se pide. Si el Log ya está montado cuando el flujo termina, la hoja de calificación sigue sin salir por la política de hitos.

### 3. El permiso de notificaciones se pide bajo demanda
`LocalNotificationService` separa tres cosas que hoy van juntas en `initialize()`: configurar plugin y zona horaria, **pedir el permiso** y programar. Se añade `requestPermission()` (devuelve si quedó concedido) y `initialize({required bool requestPermission})`. `main()` pasa `false` mientras el onboarding esté pendiente, y `true` en cualquier otro caso (las instalaciones existentes conservan exactamente su comportamiento). El recordatorio por defecto (activo, 18:00) **no se programa** mientras el onboarding esté pendiente: el paso 3 lo activa con la hora elegida si el permiso se concede, o deja `dailyReminderEnabled = false` si no. "Skip" en el paso 1 también lo deja desactivado.
- **Settings**: activar el interruptor llama a `requestPermission()` antes de programar; si se niega, se revierte con el mensaje (el autoguardado ya sabe revertir). Sin esto, quien dijo "Not now" no tendría ninguna forma de activar el recordatorio.
- **Por qué no preguntar siempre**: iOS solo muestra el diálogo una vez; llamar a `requestPermission()` con el permiso ya decidido es inofensivo, así que Settings puede llamarlo siempre sin consultar el estado.
- **Regla de arranque que se conserva**: ningún `await` que dependa del usuario antes de `runApp()` (ver `CLAUDE.md`). El onboarding aparece en el primer frame y el diálogo del sistema solo sale al tocar "Turn on reminder".

### 4. Bloqueo de notas: `NoteLockCubit` en la raíz, un único widget que decide si el texto se ve
Se crean:
- `NoteLockAuthenticator` (interfaz) con `isAvailable()` y `authenticate(reason)`; la implementación usa `local_auth` con `biometricOnly: false` (biometría **o** código del dispositivo) y `stickyAuth`; los tests inyectan un falso.
- `NoteLockCubit` con `enabled` (de la caja de ajustes), `unlocked` (en memoria, nunca persistido) y la disponibilidad de autenticación. Expone `unlock()`, `lock()`, `enable()` y `disable()`. Escucha el ciclo de vida: al pasar la app a `hidden`/`paused` pone `unlocked = false`. No reacciona a `inactive`, porque el propio diálogo de Face ID provoca `inactive` en iOS y el bloqueo se cancelaría solo.
- `LockedNoteText`, un widget que recibe el texto y muestra el texto o el marcador "Note locked" según `NoteLockCubit`. Las tres pantallas que muestran una nota lo usan; **ninguna lee `unlocked` directamente**, de modo que un cuarto consumidor futuro tiene un solo camino correcto.
- El editor pide `unlock()` antes de abrirse si la entrada tiene nota y la sesión está bloqueada; si falla, no se abre.
- La exportación llama a `unlock()` (si hace falta) antes de generar el archivo; si falla, no genera nada.
- **Por qué `unlocked` en memoria y sin temporizador**: el diálogo del sistema ya limita los intentos; un temporizador añadiría un estado que probar y sorprendería al usuario mientras escribe. Volver a bloquear al ir a segundo plano es la regla que el usuario espera de una app que "bloquea con Face ID".
- **Por qué `enabled` se guarda aparte del permiso Premium**: así un bloqueo activo sobrevive a un vencimiento (spec `note-lock`). El estado de suscripción solo se consulta al **encender**.
- **Alternativa descartada**: bloquear la pestaña Calendar/Log entera con una pantalla de candado. Es lo que hacen las apps de diario, pero el paywall promete "notas protegidas", no "app protegida", el Log es la pantalla de uso diario y el reloj escribe sin pasar por la UI.

### 5. Qué pasa cuando no hay autenticación disponible
`isAvailable()` se consulta al abrir Settings, al volver a primer plano y antes de desbloquear. Si el bloqueo está activo y no hay biometría ni código, `NoteLockCubit` expone `enforceable = false`: `LockedNoteText` muestra el texto y Settings explica por qué. Es una concesión deliberada: la alternativa (notas ilegibles hasta que haya un código) pierde datos del usuario por una configuración del teléfono, y quien quita el código del dispositivo ya se lo entrega al siguiente que lo tenga.

### 6. `local_auth` 2.3.x, no 3.x
El CI usa Flutter 3.32.1 (Dart 3.8). `local_auth` 3.0.x pide Dart `^3.9` y Flutter `>=3.35`; la 2.3.0 pide Dart `^3.2.3` y arrastra `local_auth_android` 1.x y `local_auth_darwin` 1.x. Se fija `local_auth: ^2.3.0` (que no sube a 3.x) y la primera tarea del bloque comprueba que resuelve y compila con 3.32.1 antes de escribir código que dependa de ella.
- **Android**: `local_auth_android` 1.x exige que `MainActivity` extienda `FlutterFragmentActivity`, que los temas hereden de AppCompat/`Theme.AppCompat` (hoy heredan de `@android:style/Theme.Light.NoTitleBar`) y el permiso `USE_BIOMETRIC`. Cambiar `LaunchTheme`/`NormalTheme` toca el arranque, que el rediseño ya cuidó (ver `branded-launch-screen`): se verifica en un dispositivo o emulador.
- **iOS**: `NSFaceIDUsageDescription` es obligatoria; si falta, Face ID falla en silencio. Se localiza con `InfoPlist.strings` por idioma (hoy no hay `*.lproj` de la app salvo el storyboard) y `CFBundleLocalizations` en `Info.plist`.
- **Alternativa descartada**: un canal de plataforma propio con `LAContext`/`BiometricPrompt`; más código nativo que mantener para algo que `local_auth` resuelve.

### 7. Settings: una fila, y el copy no promete cifrado
La fila nueva vive en Privacy and data, con la marca "Pro" mientras no haya suscripción. Sin suscripción, tocarla abre la hoja con `source = settings` (no se añade un valor nuevo). El título se redacta de forma genérica ("Lock notes") con el detalle "Face ID, Touch ID, fingerprint or your device passcode" según la plataforma, porque el título del diseño ("Lock with Face ID") no vale en Android ni en iPhones con Touch ID. Ningún texto dice "cifrado" (spec `note-lock`).
- **Alternativa descartada**: ocultar la fila en dispositivos sin autenticación; es preferible mostrarla desactivada con la explicación para que quien lo busque sepa qué falta.

### 8. Analíticas
Se añaden a la lista cerrada `onboarding_completed`, `onboarding_skipped`, `note_lock_enabled` y `note_lock_disabled`, el parámetro `step` (1 a 3, solo en `onboarding_skipped`) y el valor `onboarding` de `PremiumSource`. No hay evento por paso ni por desbloqueo: con el cierre y la omisión por paso se mide el embudo sin enviar más. Ningún evento lleva el mood, la nota ni la fecha del primer registro. El guardado del primer día sigue emitiendo `mood_saved` como cualquier guardado.

### 9. Orden de la hoja de suscripción al final del onboarding
`OnboardingFlow` marca `onboarding_completed`, deja que `AppRoot` monte `MainShell` y, **después del primer frame**, llama a `showPremiumSheet(source: onboarding)` solo si `PurchasesCubit` no reporta suscripción. No se abre desde dentro del flujo: así el Log queda debajo y, al cerrarla, el usuario ya está donde terminó. Una guarda en memoria evita abrirla dos veces si `AppRoot` se reconstruye.
- **Por qué esto contradice la regla anterior**: el Bloque 1 prohibía la oferta "en un onboarding" mientras no existía ninguno; el diseño de referencia la coloca explícitamente tras el primer registro (pantalla Paywall después de Onboarding 4). El spec `premium-subscription` se modifica en este change y la oferta sigue siendo descartable, única y nunca para un suscriptor.

### 10. Datos y claves
`AppSettings` gana `noteLockEnabled` (por defecto `false`). `onboarding_completed` no entra en `AppSettings` (no es una preferencia que Settings edite): se lee y escribe con un `OnboardingStateDataSource` sobre la misma caja, igual que `RatingPromptLocalDataSource`. Sin migración: las claves ausentes valen `false`.

## Risks / Trade-offs

- [El bloqueo es una barrera de interfaz: el texto sigue sin cifrar en Hive y entra a los respaldos del dispositivo] → La copia nunca dice "cifrado"; `docs/risks.md` lo recoge como riesgo aceptado; cifrar la caja de notas queda como mejora futura.
- [Cambiar `MainActivity` y los temas de Android rompe el arranque o el modo oscuro] → Se prueba el arranque en frío y el diálogo biométrico en un emulador/dispositivo antes de dar la tarea por hecha, y se revisa que el launch screen no cambie de color.
- [`local_auth` 2.3.x queda sin parches de seguridad al pasar el CI a Flutter 3.35+] → Subir a la 3.x cuando el CI suba de Flutter; la dependencia queda anotada en `CLAUDE.md` junto a `fl_chart`.
- [Face ID sin `NSFaceIDUsageDescription` falla sin avisar, y en simulador no se prueba un sensor real] → La clave y su localización se verifican en `Info.plist`; la autenticación real se prueba en un iPhone y en un Android reales (queda como tarea abierta, igual que 9.3 y 7.3 de los bloques anteriores).
- [El paso 4 no tiene "Skip": quien no quiere registrar nada en ese momento queda atrapado en el flujo] → Se respeta el diseño de referencia; cerrar la app no marca el onboarding como terminado, así que reaparece, y la elección es un solo toque. Se revisa tras probarlo en TestFlight.
- [Usuarios que ya tienen la app instalada y vacía (sin entradas) verán el onboarding tras actualizar] → Es un grupo sin historial que perder; aceptado.
- [Pedir el permiso en Settings cambia el flujo de un usuario existente que había negado el permiso] → `requestPermission()` con el permiso ya negado no muestra nada en iOS y el interruptor se revierte con el mensaje existente; en Android 13+ la segunda negativa tampoco muestra diálogo.

## Migration Plan

Sin migración de datos: dos claves nuevas con valor por defecto `false`. Orden de despliegue: archivar los Bloques 1 y 2, mergear este change a `main`, probar en TestFlight y en la pista interna de Play (con autenticación real) y solo entonces preparar la versión (quitar la prueba gratis del mensual y el semanal, rehacer capturas y fichas: ver `backlog.md`). Revertir es seguro: al volver a una versión sin el bloqueo, las notas se leen normal porque nunca se cambiaron.

## Open Questions

- Si la política de privacidad y la ficha de las tiendas mencionan el bloqueo de notas (y con qué palabras): se decide en el paso de marketing, sin cambiar la app.
- Si en una versión posterior el bloqueo debe cubrir también las palabras frecuentes de las notas: se decide al proponer ese change.
