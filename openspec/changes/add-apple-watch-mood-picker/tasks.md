## 1. Spike: el target de watchOS dentro del proyecto

- [ ] 1.1 Crear desde Xcode el target "Watch App" (SwiftUI, watchOS 9.0, bundle id `com.artlab.moodcalendar.watchkitapp`) embebido en `Runner`, con el mismo equipo de firma, y revisar el diff de `ios/Runner.xcodeproj/project.pbxproj`.
- [ ] 1.2 Comprobar que `flutter build ios --simulator` (debug) y `flutter run` en un simulador de iPhone siguen compilando y que `pod install` no cambia nada inesperado en `Podfile.lock`.
- [ ] 1.3 Generar un archive real con `REVENUECAT_IOS_API_KEY=<key> STORE_VERIFIED=1 scripts/build_ios_release.sh` y comprobar que pasa `verify_ios_archive_key.sh`, `verify_ios_archive_crash_reporting.sh` y `verify_ios_archive_no_ad_id.sh` con `Watch/` dentro de `Runner.app`; adaptar los scripts con cambios mínimos si alguno falla y anotarlo.
- [ ] 1.4 Decidir con evidencia el mínimo de watchOS y si el catálogo de assets del reloj acepta SVG; registrar ambos en `design.md` (Decisiones 1 y 9) y cerrar las dos primeras preguntas abiertas.
- [ ] 1.5 Si el spike falla de forma que no se resuelve con cambios pequeños, detenerse y replantear con el usuario antes de seguir.

## 2. Contrato y canal nativo en el iPhone

- [ ] 2.1 Definir el contrato en un solo documento corto (`docs/watch-sync-contract.md`): estado publicado (`version`, `locale`, `moods[{id,name}]`, `today`) y elección enviada (`id`, `date`, `mood`, `chosenAt`), con ejemplos.
- [ ] 2.2 Implementar en Swift el almacén del buzón (arreglo JSON versionado en `UserDefaults`, deduplicación por `id`, lectura y confirmación por ids) como lógica pura y testeable.
- [ ] 2.3 Implementar el puente de `WCSession` en el iPhone: activación en `AppDelegate.application(_:didFinishLaunchingWithOptions:)`, recepción de `didReceiveUserInfo` hacia el buzón y publicación de `updateApplicationContext`.
- [ ] 2.4 Registrar el `MethodChannel` (`readInbox`, `ackInbox`, `publishState`) y el aviso de elección nueva en `didInitializeImplicitFlutterEngine`, sin bloquear el arranque.
- [ ] 2.5 Pruebas XCTest del almacén del buzón en `RunnerTests` (deduplicar, confirmar solo lo aplicado, sobrevivir a un reinicio simulado), si resultan baratas.

## 3. Caso de uso y cableado en Dart

- [ ] 3.1 Crear `lib/features/watch/` (domain: `WatchMoodChoice`, interfaz de canal; data: canal de plataforma y versión sin efecto para Android y tests).
- [ ] 3.2 Implementar `ProcessWatchInboxUseCase`: ordenar por `chosenAt`, descartar ids desconocidos o bloqueados, conservar la nota existente, resolver `intensity` con `MoodDefinitionResolver`, guardar con `SaveMoodUseCase` y confirmar al canal solo después de aplicar.
- [ ] 3.3 Implementar `PublishWatchStateUseCase`: nombres con `AppStrings.forLocale`, orden con `MoodPickerOrder`, `today` desde el repositorio, y publicación con debounce cuando cambian desbloqueos (`unlockedPremiumMoodIds()`), la entrada de hoy o el idioma.
- [ ] 3.4 Cablear en `main.dart` tras abrir Hive y `Purchases.configure()`, procesando al arrancar y en `AppLifecycleState.resumed`, sin `await` de nada que dependa del usuario antes de `runApp()`.
- [ ] 3.5 Recargar `MoodCubit` y `CalendarCubit` cuando se aplica una elección con la app en primer plano, sin reordenar el selector mientras está visible.
- [ ] 3.6 Tests de Dart con un canal falso en `test/support/`: nota conservada, fecha local, id desconocido, id bloqueado, orden por `chosenAt`, `ack` solo tras aplicar, no dispara calificación ni analíticas, publicación al cambiar desbloqueos; correr `flutter analyze` y `flutter test`.

## 4. App SwiftUI del reloj

- [ ] 4.1 Implementar el cliente de `WCSession` del reloj: recibir `applicationContext`, guardar el último estado en `UserDefaults` del reloj y enviar elecciones con `transferUserInfo`.
- [ ] 4.2 Construir la pantalla principal: cuadrícula de dos columnas con carita y nombre, mood de hoy resaltado, háptica y confirmación breve al tocar.
- [ ] 4.3 Implementar el estado "pendiente de sincronizar" (se quita cuando el iPhone publica el mood de hoy) y el estado vacío "abre Mood Calendar en el iPhone".
- [ ] 4.4 Textos fijos del reloj localizados en inglés, español, alemán, francés e italiano; etiquetas de VoiceOver por mood y soporte de Dynamic Type.
- [ ] 4.5 Confirmar que el reloj no usa la red ni incluye Firebase ni `AdSupport`, y que no ofrece compras ni enlaces a la tienda.

## 5. Íconos y assets

- [ ] 5.1 Script reproducible en `tool/watch/` que lleva los SVG de `assets/icon/` al catálogo del reloj (SVG o PNG según 1.4), excluyendo `brave.svg`.
- [ ] 5.2 Rasterizar `brave` a un PNG pequeño solo para el reloj, revisarlo a ojo y decidir si se ofrece o se espera a regenerar el SVG.
- [ ] 5.3 Ícono de la app de reloj (todos los tamaños que exige Xcode y App Store Connect) y colores pastel por mood alineados con `MoodDefinitionResolver.backgroundGradientForMood`.

## 6. Pruebas manuales

- [ ] 6.1 Documentar en `docs/` cómo emparejar un simulador de iPhone con uno de Watch (`xcrun simctl`) y correr ambas apps.
- [ ] 6.2 Probar en simuladores emparejados: elegir un mood, nota conservada, iPhone con la app cerrada, reloj sin alcance y compra de un mood premium que aparece en el reloj.
- [ ] 6.3 Probar en un iPhone y un Apple Watch reales (TestFlight): entrega en cola, idioma del iPhone en el reloj, varias elecciones del mismo día y reinstalación de la app del reloj.
- [ ] 6.4 Verificar a mano que registrar desde el reloj no dispara el pedido de calificación y que la elección aparece en el calendario, el resumen, la racha y la exportación.

## 7. App Store Connect y release

- [ ] 7.1 Confirmar en App Store Connect los tamaños y la cantidad de capturas de Apple Watch que pide hoy la versión.
- [ ] 7.2 Añadir a `tool/screenshots/` las capturas de Apple Watch (simulador de Watch con la barra de estado limpia) y generarlas en los cinco idiomas.
- [ ] 7.3 Preparar la versión (≈1.9.0): notas de la versión, texto promocional, capturas de Watch y revisión de App Privacy (debe seguir igual).
- [ ] 7.4 Subir la versión en un PR aparte, construir con `scripts/build_ios_release.sh` y enviar a revisión.

## 8. Documentación y cierre

- [ ] 8.1 Actualizar `CLAUDE.md`: arquitectura (carpeta `lib/features/watch/`, target del reloj, buzón), sección de release (verificaciones con el reloj) y comandos de prueba con simuladores emparejados.
- [ ] 8.2 Actualizar `backlog.md` (función completada; complicación, notas y app independiente como mejoras futuras) y el estado de la versión.
- [ ] 8.3 Abrir los PR en ramas aparte (spike, Dart y nativo, reloj, release) con commits `feat(watch)`/`chore(ios)`, esperar "Analyze and Test", mergear y borrar las ramas.
- [ ] 8.4 Archivar el change con `/opsx:archive` sincronizando el spec `watch-mood-picker` a `openspec/specs/`.
