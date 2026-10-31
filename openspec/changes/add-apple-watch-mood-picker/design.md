## Context

La app es Flutter con Hive como única persistencia local, sin backend (ver `CLAUDE.md` → Arquitectura, y ADR 0001 sobre `intensity`). El iPhone ya conoce los moods desbloqueados (`MoodEntitlementsRepository.unlockedPremiumMoodIds()`, un `Stream`), el orden de uso del selector (`MoodPickerOrder`) y los nombres localizados (`AppStrings`). En iOS el único código nativo es `AppDelegate.swift` (`FlutterImplicitEngineDelegate`). Flutter no corre en watchOS, así que la app del reloj es SwiftUI nativo. Ver `proposal.md` para el motivo y el alcance, y `specs/watch-mood-picker/spec.md` para los requisitos.

Restricciones que condicionan el diseño:

- Hive no es accesible desde Swift ni desde un segundo isolate de forma segura, y WatchConnectivity puede despertar al iPhone con la app cerrada. Las elecciones del reloj no pueden escribirse directamente en Hive desde el lado nativo.
- Los App Groups no se comparten entre iPhone y Watch; el único canal entre ambos es WatchConnectivity.
- Deployment target del iPhone: iOS 15.0. Un reloj con watchOS 9+ exige un iPhone con iOS 16+, pero la app debe seguir instalándose y funcionando en iOS 15 sin reloj.
- `runApp()` no puede esperar nada que dependa del usuario; Hive y `Purchases.configure()` sí se esperan antes (ver "Arranque de la app" en `CLAUDE.md`).
- Los releases solo se generan con `scripts/build_ios_release.sh`, con tres verificaciones del archive (llave de RevenueCat, Crashlytics y sin ID de publicidad).
- La privacidad declarada (App Privacy, Data safety, política) no debe cambiar.

## Goals / Non-Goals

**Goals:**
- Elegir el mood de hoy desde el reloj con un toque, aunque el iPhone no esté cerca en ese momento.
- Mantener el iPhone como única fuente de verdad, sin duplicar lógica de dominio en Swift.
- No perder elecciones si la app del iPhone está cerrada o el reloj está sin conexión.
- Dejar el contrato de sincronización lo bastante estable como para añadir luego una complicación o notas sin cambiarlo.

**Non-Goals:**
- Complicación en la esfera, app de reloj independiente, notas, días pasados, compras o analíticas en el reloj.
- Resolver conflictos entre copias de datos: solo existe una copia (el iPhone).
- Wear OS.

## Decisions

1. **App de reloj companion de un solo target (watchOS 9.0 como mínimo).**
   Un target "Watch App" embebido en `Runner`, con bundle id `com.artlab.moodcalendar.watchkitapp`. watchOS 9 cubre relojes recientes sin forzar iOS 17 (watchOS 10 exigiría iPhone con iOS 17). Por eso la interfaz usa una cuadrícula de dos columnas con desplazamiento por la corona digital, disponible desde watchOS 6, y no `TabView` vertical (watchOS 10). **Spike (2026-10-26): confirmado.** El target compila para simulador y dispositivo con watchOS 9.0, el archive se firma y exporta, y `Runner.app/Watch/WatchApp.app` entra en el IPA con la misma versión y número de build que el iPhone. *Alternativas:* watchOS 10+ (más cómodo, excluye iPhones con iOS 15 y 16); app independiente con almacenamiento propio (descartada: obliga a sincronizar dos copias).

2. **Transporte: `applicationContext` hacia el reloj y `transferUserInfo` hacia el iPhone.**
   - iPhone → reloj: `updateApplicationContext` con el último estado (`version`, `locale`, `moods: [{id, name}]` ordenados, `today: id | null`). Es "último valor gana" y se entrega aunque la app del reloj esté cerrada.
   - Reloj → iPhone: `transferUserInfo` con `{id (uuid), date: "YYYY-MM-DD", mood, chosenAt (epoch ms)}`. Es una cola persistente que sobrevive a que el iPhone esté lejos o la app esté cerrada, y no pierde elecciones.
   *Alternativas:* `sendMessage` (solo con ambos activos, se pierde si no hay alcance); `transferCurrentComplicationUserInfo` (pensada para complicaciones).

3. **Buzón nativo en el iPhone y Dart como único escritor de Hive.**
   `WCSession` se activa en `AppDelegate` al arrancar, porque solo así el sistema entrega envíos con la app cerrada. Su delegado añade cada elección recibida al buzón: un arreglo JSON en `UserDefaults` (clave versionada), con deduplicación por `id`. Dart expone dos operaciones por un `MethodChannel` (`readInbox` y `ackInbox(ids)`) y recibe un aviso de "llegó algo" cuando la app está en primer plano. Procesar el buzón = leer, aplicar, y solo después confirmar (quitar por id), para no perder datos si la app muere en medio. *Alternativas:* escribir en Hive desde Swift (descartada: Hive es Dart-only); levantar el motor Flutter en segundo plano para procesar (frágil y lento); plugin de terceros `watch_connectivity` (descartado: la lógica del buzón es nativa de todos modos y evita otra dependencia en una app que declara SDKs).

4. **Nueva feature `lib/features/watch/` con la misma separación de capas.**
   - `domain/`: `WatchMoodChoice`, la interfaz de canal, y dos casos de uso: `ProcessWatchInboxUseCase` y `PublishWatchStateUseCase`.
   - `data/`: la implementación del canal de plataforma, con una versión sin efecto para Android y para tests.
   - Aplicar una elección: ordenar por `chosenAt`; descartar ids desconocidos o bloqueados (`MoodEntitlementsRepository.isUnlocked`); leer la entrada de esa fecha; guardar con `SaveMoodUseCase` el mood nuevo con la **nota existente** y el `intensity` del `MoodDefinitionResolver`. El reloj nunca envía `intensity` (ADR 0001).
   - Cableado en `main.dart` después de abrir Hive y `Purchases.configure()`, sin `await` de nada que dependa del usuario. En Android y en tests es un canal vacío.

5. **Cuándo se procesa y cuándo se publica.**
   Procesar: al arrancar, al volver a primer plano (`AppLifecycleState.resumed`) y cuando el canal avisa de una elección nueva. Publicar (con un pequeño debounce): al arrancar, y cuando cambian los moods desbloqueados, la entrada de hoy o el idioma. Tras aplicar una elección, `MoodCubit` y `CalendarCubit` se recargan para que la UI en primer plano la muestre; el orden del selector sigue sin cambiar mientras el selector está visible, como ya exige `premium-moods`.

6. **Los nombres y el orden los decide el iPhone.**
   `AppStrings.forLocale(...)` (con respaldo a inglés) produce los nombres, y `MoodPickerOrder` produce el orden, de modo que el reloj no duplica cadenas de moods en cinco idiomas ni la regla de orden. El reloj solo localiza sus propios textos fijos (mensaje de "abre Mood Calendar en el iPhone" y la indicación de pendiente) y guarda el último estado en `UserDefaults` del reloj.

7. **Conflictos: última elección del reloj gana, sin lógica de fusión.**
   Hay una sola copia de datos. Entre elecciones del reloj para la misma fecha, gana la de mayor `chosenAt`. *Limitación conocida:* las Mood Entries del iPhone no guardan hora, así que una elección muy vieja del reloj, entregada tarde, sobrescribiría un cambio posterior hecho en el iPhone. Se acepta porque `transferUserInfo` entrega en cuanto hay alcance y el caso es raro; guardar una marca de tiempo en `MoodModel` exigiría una migración de Hive que no justifica esta versión.

8. **Interfaz del reloj.**
   SwiftUI: cuadrícula de dos columnas con la carita y su nombre, el mood de hoy resaltado con un aro, retroalimentación háptica y una confirmación breve al tocar, e indicación de "pendiente" hasta que el iPhone publique el mood de hoy. Estado vacío cuando aún no hay estado. Respeta Dynamic Type y VoiceOver (cada mood es un botón con etiqueta). **En la primera versión no hay colores pastel por mood:** las baldosas son oscuras y neutras (el reloj es OLED) y el mood de hoy se marca con un aro del color de marca. Llevar los pasteles al reloj exigiría enviarlos o replicarlos y no cambia el contrato; queda como mejora posterior.

9. **Íconos.**
   Los SVG de `assets/icon/` se rasterizan a PNG @2x/@3x en el catálogo de assets del reloj con `tool/watch/export_mood_icons.sh` (requiere `rsvg-convert`). Se eligió PNG sobre SVG porque garantiza el render en todo watchOS soportado y porque `brave.svg` (1 MB) pasa a pesar 14 KB sin tratarlo aparte. 
10. **Release y verificación.**
    El spike debe demostrar que el archive con el reloj embebido pasa `scripts/build_ios_release.sh` y sus tres verificaciones. `verify_ios_archive_no_ad_id.sh` ya recorre binarios y `Info.plist`, y es probable que se aplique también al del reloj (sin `AdSupport` ni `NSUserTrackingUsageDescription`). `verify_ios_archive_key.sh` y `verify_ios_archive_crash_reporting.sh` miran `Runner.app` y sus dSYM y deben tolerar la carpeta `Watch/`. Si alguna falla, se adapta con un cambio mínimo y se documenta en `CLAUDE.md`.

11. **Pruebas.**
    - Dart (CI): casos de uso con un canal falso en `test/support/` (conservar nota, fecha local, ids desconocidos y bloqueados, orden por `chosenAt`, `ack` solo tras aplicar, publicación al cambiar desbloqueos).
    - Swift: el buzón es lógica pura; se prueba con XCTest en `RunnerTests` si resulta barato.
    - Manual: simuladores de iPhone y Watch emparejados (`xcrun simctl` con la pareja), con casos de iPhone cerrado, reloj sin alcance y compra de un mood. WatchConnectivity en simuladores es poco fiable, así que la prueba final es en dispositivos reales con TestFlight.

12. **Sin analíticas ni calificación desde el reloj.**
    La elección del reloj entra por `SaveMoodUseCase`, no por `MoodCubit.save`, así que no emite `mood_saved` ni dispara el pedido de calificación. Esto deja `usage-analytics` y `rating-prompt` sin cambios y evita tocar la allowlist de eventos.

## Risks / Trade-offs

- [Un target de watchOS puede no convivir con CocoaPods o `flutter build ipa`] → El spike es la primera tarea y bloquea el resto; si falla, se replantea (por ejemplo, crear el target con un script de la gema `xcodeproj`, o abandonar).
- [Editar `project.pbxproj` a mano o por script es frágil] → Crear el target desde Xcode, revisar el diff del proyecto y guardarlo en un PR aparte y pequeño.
- [Las verificaciones de release pueden fallar con el binario del reloj] → Probarlas en el spike con un archive real y adaptarlas con cambios mínimos.
- [WatchConnectivity en simuladores es inconsistente] → Cerrar con pruebas en dispositivos reales y TestFlight antes de enviar a revisión.
- [Una elección vieja entregada tarde sobrescribe un cambio posterior del iPhone] → Aceptado y documentado (decisión 7).
- [App Store Connect exige capturas de Watch, ícono propio y revisión más larga] → Previsto en las tareas; confirmar en ASC los tamaños vigentes antes de generar capturas.
- [El PNG de `brave` puede verse mal al rasterizarlo] → Revisado: a 132 px se ve bien (14 KB).
- [Un reloj con watchOS 9 exige un iPhone con iOS 16, así que la función no llega a quien tenga iOS 15] → Esperable; la app del iPhone sigue funcionando igual en iOS 15.

- [El runtime de watchOS es obligatorio para compilar el esquema `Runner` en simulador] → Hallazgo del spike: `xcodebuild` se niega ("watchOS 26.2 must be installed") y `flutter build ios --simulator` exige `-d <id de simulador>`. Cada desarrollador necesita `xcodebuild -downloadPlatform watchOS` (varios GB); documentarlo en `CLAUDE.md` (tarea 8.1).
- [Un IPA de cualquier release incluye el reloj apenas el target llegue a `main`] → Hallazgo del spike: el target vacío de prueba viajaría en un release. No mergear el target a `main` hasta que la app del reloj sea funcional; acumular el trabajo en una rama de funcionalidad y mergear de una vez (o detrás de la primera versión que lo publique).
- [El archive compilaba el reloj con el SDK de iPhone] → Corregido en `tool/watch/add_watch_target.rb` con `SUPPORTED_PLATFORMS = "watchos watchsimulator"`; sin eso, `actool` fallaba con "AppIcon did not have any applicable content".

## Migration Plan

1. Rama `feat/watch-spike` con solo el target vacío y la verificación del archive; si pasa, seguir.
2. Contrato y buzón nativo + caso de uso de Dart + tests, sin interfaz de reloj todavía, probando con un emisor de pruebas.
3. Interfaz SwiftUI del reloj y assets; pruebas con simuladores emparejados.
4. Dispositivos reales y TestFlight; capturas de Watch; ficha de App Store Connect.
5. Subir la versión (≈1.9.0) en un PR aparte, construir con `scripts/build_ios_release.sh` y enviar a revisión.
6. Rollback: la función es aditiva; si algo falla antes del envío basta no mergear el target. Si ya salió, una versión posterior puede retirar el target del reloj sin migrar datos, porque el reloj no guarda nada propio.

## Open Questions

- ~~Mínimo de watchOS y SVG en el catálogo~~ Resuelto: watchOS 9.0; los íconos van como PNG.
- Tamaños y cantidad de capturas de Apple Watch que pide hoy App Store Connect para la versión.
- Si el aro del mood de hoy y los colores pastel por mood se envían desde el iPhone o se fijan en el catálogo del reloj; no cambia el contrato de elecciones ni el desglose de tareas.
