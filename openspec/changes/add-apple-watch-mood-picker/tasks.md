## 1. Spike: el target de watchOS dentro del proyecto

- [x] 1.1 Crear desde Xcode el target "Watch App" (SwiftUI, watchOS 9.0, bundle id `com.artlab.moodcalendar.watchkitapp`) embebido en `Runner`, con el mismo equipo de firma, y revisar el diff de `ios/Runner.xcodeproj/project.pbxproj`. Hecho con `tool/watch/add_watch_target.rb` (gema `xcodeproj` de CocoaPods, idempotente) en vez de la interfaz de Xcode: el diff son solo líneas añadidas.
- [x] 1.2 Comprobar que `flutter build ios --simulator` (debug) y `flutter run` en un simulador de iPhone siguen compilando y que `pod install` no cambia nada inesperado en `Podfile.lock`. Hecho con `flutter build ios --simulator -d <id>` (necesita el runtime de watchOS instalado); `Podfile.lock` no cambió. `flutter run` se prueba en la tarea 6.2.
- [x] 1.3 Generar un archive real con `REVENUECAT_IOS_API_KEY=<key> STORE_VERIFIED=1 scripts/build_ios_release.sh` y comprobar que pasa `verify_ios_archive_key.sh`, `verify_ios_archive_crash_reporting.sh` y `verify_ios_archive_no_ad_id.sh` con `Watch/` dentro de `Runner.app`; adaptar los scripts con cambios mínimos si alguno falla y anotarlo. Hecho: las tres pasan; `verify_ios_archive_no_ad_id.sh` ahora también revisa el binario y el `Info.plist` del reloj. El archive solo se hizo como prueba y no se subió.
- [x] 1.4 Decidir con evidencia el mínimo de watchOS y si el catálogo de assets del reloj acepta SVG; registrar ambos en `design.md` (Decisiones 1 y 9) y cerrar las dos primeras preguntas abiertas.
- [x] 1.5 Si el spike falla de forma que no se resuelve con cambios pequeños, detenerse y replantear con el usuario antes de seguir. No hizo falta: los dos problemas del spike (runtime de watchOS y `SUPPORTED_PLATFORMS`) se resolvieron sin replantear.

## 2. Contrato y canal nativo en el iPhone

- [x] 2.1 Definir el contrato en un solo documento corto (`docs/watch-sync-contract.md`): estado publicado (`version`, `locale`, `moods[{id,name}]`, `today`) y elección enviada (`id`, `date`, `mood`, `chosenAt`), con ejemplos.
- [x] 2.2 Implementar en Swift el almacén del buzón (arreglo JSON versionado en `UserDefaults`, deduplicación por `id`, lectura y confirmación por ids) como lógica pura y testeable.
- [x] 2.3 Implementar el puente de `WCSession` en el iPhone: activación en `AppDelegate.application(_:didFinishLaunchingWithOptions:)`, recepción de `didReceiveUserInfo` hacia el buzón y publicación de `updateApplicationContext`.
- [x] 2.4 Registrar el `MethodChannel` (`readInbox`, `ackInbox`, `publishState`) y el aviso de elección nueva en `didInitializeImplicitFlutterEngine`, sin bloquear el arranque.
- [x] 2.5 Pruebas XCTest del almacén del buzón en `RunnerTests` (deduplicar, confirmar solo lo aplicado, sobrevivir a un reinicio simulado), si resultan baratas.

## 3. Caso de uso y cableado en Dart

- [x] 3.1 Crear `lib/features/watch/` (domain: `WatchMoodChoice`, interfaz de canal; data: canal de plataforma y versión sin efecto para Android y tests).
- [x] 3.2 Implementar `ProcessWatchInboxUseCase`: ordenar por `chosenAt`, descartar ids desconocidos o bloqueados, conservar la nota existente, resolver `intensity` con `MoodDefinitionResolver`, guardar con `SaveMoodUseCase` y confirmar al canal solo después de aplicar.
- [x] 3.3 Implementar `PublishWatchStateUseCase`: nombres con `AppStrings.forLocale`, orden con `MoodPickerOrder`, `today` desde el repositorio, y publicación con debounce cuando cambian desbloqueos (`unlockedPremiumMoodIds()`), la entrada de hoy o el idioma.
- [x] 3.4 Cablear en `main.dart` tras abrir Hive y `Purchases.configure()`, procesando al arrancar y en `AppLifecycleState.resumed`, sin `await` de nada que dependa del usuario antes de `runApp()`.
- [x] 3.5 Recargar `MoodCubit` y `CalendarCubit` cuando se aplica una elección con la app en primer plano, sin reordenar el selector mientras está visible.
- [x] 3.6 Tests de Dart con un canal falso en `test/support/`: nota conservada, fecha local, id desconocido, id bloqueado, orden por `chosenAt`, `ack` solo tras aplicar, no dispara calificación ni analíticas, publicación al cambiar desbloqueos; correr `flutter analyze` y `flutter test`.

## 4. App SwiftUI del reloj

- [x] 4.1 Implementar el cliente de `WCSession` del reloj: recibir `applicationContext`, guardar el último estado en `UserDefaults` del reloj y enviar elecciones con `transferUserInfo`.
- [x] 4.2 Construir la pantalla principal: cuadrícula de dos columnas con carita y nombre, mood de hoy resaltado, háptica y confirmación breve al tocar.
- [x] 4.3 Implementar el estado "pendiente de sincronizar" (se quita cuando el iPhone publica el mood de hoy) y el estado vacío "abre Mood Calendar en el iPhone".
- [x] 4.4 Textos fijos del reloj localizados en inglés, español, alemán, francés e italiano; etiquetas de VoiceOver por mood y soporte de Dynamic Type.
- [x] 4.5 Confirmar que el reloj no usa la red ni incluye Firebase ni `AdSupport`, y que no ofrece compras ni enlaces a la tienda.

## 5. Íconos y assets

- [x] 5.1 Script reproducible `tool/watch/export_mood_icons.sh` que rasteriza los SVG de `assets/icon/` a PNG @2x/@3x en el catálogo del reloj (PNG por fiabilidad de render; incluye `brave`).
- [x] 5.2 Revisar a ojo el PNG de `brave` rasterizado (14 KB a 132 px): se ve bien y se ofrece como el resto.
- [x] 5.3 Ícono de la app de reloj (todos los tamaños que exige Xcode y App Store Connect) (los colores pastel por mood quedan fuera de la primera versión, ver `design.md` decisión 8).

## 6. Pruebas manuales

- [x] 6.1 Documentar en `docs/` cómo emparejar un simulador de iPhone con uno de Watch (`xcrun simctl`) y correr ambas apps. Hecho en `docs/watch-testing.md`.
- [x] 6.2 Probar en simuladores emparejados. La interfaz del reloj y el estado vacío se verificaron en el simulador, en los cinco idiomas, y la lógica con XCTest y pruebas de Dart; la sincronización de punta a punta no se puede ver en simuladores (el iPhone reporta `appInstalled: NO`, ver `docs/watch-testing.md`) y se cubrió en dispositivos reales (6.3).
- [x] 6.3 Probar en un iPhone y un Apple Watch reales (TestFlight 1.9.0 build 37): entrega en cola, app del iPhone cerrada, varias elecciones del mismo día, nota conservada, idioma del iPhone en el reloj, compra de un mood premium y reinstalación de la app del reloj. Todas pasaron (2026-10-30).
- [x] 6.4 Verificar a mano que registrar desde el reloj no dispara el pedido de calificación y que la elección aparece en el calendario, el resumen, la racha y la exportación. Pasó (2026-10-30).

## 7. App Store Connect y release

- [x] 7.1 Confirmar en App Store Connect los tamaños y la cantidad de capturas de Apple Watch que pide hoy la versión. Confirmado subiéndolas por API: el conjunto `APP_WATCH_SERIES_10` acepta 416×496 (PNG sin transparencia); se subió una captura por idioma.
- [x] 7.2 Añadir a `tool/screenshots/` las capturas de Apple Watch (simulador de Watch) y generarlas en los cinco idiomas. Hecho con `tool/screenshots/capture_watch.py`: una captura de la cuadrícula por idioma (416×496, Series 11 de 46 mm); el simulador de Watch no permite fijar la hora, así que la barra muestra la hora real.
- [x] 7.3 Preparar la versión (≈1.9.0): notas de la versión, texto promocional, descripción con la sección "Apple Watch", capturas de Watch y notas para el revisor, en los 5 idiomas. App Privacy no cambia. Hubo que responder además el cuestionario de clasificación por edad (sigue en 4+).
- [x] 7.4 Subir la versión, construir con `scripts/build_ios_release.sh` y enviar a revisión. El bump a 1.9.0+37 fue un commit del PR #113 (no un PR aparte); el build 37 es el de TestFlight y se envió a revisión el 2026-10-31.

## 8. Documentación y cierre

- [x] 8.1 Actualizar `CLAUDE.md`: arquitectura (carpeta `lib/features/watch/`, target del reloj, buzón), sección de release (verificaciones con el reloj) y comandos de prueba con simuladores emparejados.
- [x] 8.2 Actualizar `backlog.md` (publicación en revisión; complicación, notas y app independiente como mejoras futuras) y el estado de la versión en `CLAUDE.md`. La marca de función completada queda para cuando Apple apruebe la 1.9.0.
- [x] 8.3 Abrir el PR con los commits `feat(watch)`/`chore(ios)`, esperar "Analyze and Test", mergear y borrar la rama. Se hizo en un único PR (#113) con los 7 commits, por decisión del usuario.
- [ ] 8.4 Archivar el change con `/opsx:archive` sincronizando el spec `watch-mood-picker` a `openspec/specs/`.
