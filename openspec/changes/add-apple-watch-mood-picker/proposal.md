## Why

Registrar el ánimo es un gesto de segundos, y hoy exige sacar el iPhone, abrir la app y deslizar el selector. Un Apple Watch es el dispositivo más a mano para ese gesto: elegir "cómo me siento" con un toque en la muñeca, en cualquier momento del día, hace más probable que el registro diario se mantenga. La app ya es iOS-primero (deployment target 15.0) y ya tiene todo lo necesario en el iPhone (Hive como única fuente de verdad, desbloqueos de RevenueCat y orden de uso del selector); falta una superficie en el reloj que hable con él.

## What Changes

- Nueva app de Apple Watch (SwiftUI, target watchOS companion embebido en la app de iOS) que muestra los moods disponibles y registra el de **hoy** con un toque.
- El reloj muestra **solo los moods desbloqueados** (los 5 base más los premium comprados), en el mismo orden de uso que el selector del iPhone. No hay compras ni pantallas de tienda en el reloj.
- Registrar desde el reloj **reemplaza el mood de hoy y conserva la nota** que ya existiera ese día. Solo se puede registrar el día actual.
- Sincronización con WatchConnectivity: el iPhone publica el estado (moods desbloqueados ordenados, nombres ya localizados y mood de hoy) y el reloj envía solo `{fecha local, id estable del mood}` por una cola persistente, de modo que una elección hecha lejos del iPhone llega después. El iPhone sigue siendo la única fuente de verdad (Hive); el reloj no guarda un historial propio.
- Lado nativo del iPhone: un canal con un **buzón** (inbox) donde Swift apunta las elecciones recibidas y que Dart procesa al abrir o reanudar la app, porque Hive no es accesible desde Swift y la app puede estar cerrada cuando llega la elección.
- Nueva carpeta `lib/features/watch/` con el caso de uso que procesa el buzón y publica el estado al reloj, y refresco de la UI del iPhone (calendario y selector) cuando una elección llega con la app en primer plano.
- Íconos de los moods convertidos desde `assets/icon/` al catálogo de assets del reloj. `brave.svg` (1 MB, pendiente de regenerar en el backlog) no se copia: se rasteriza a un PNG pequeño solo para el reloj, para que un `brave` comprado también se vea ahí.
- Capturas de Apple Watch en `tool/screenshots/` y en App Store Connect; versión nueva (≈1.9.0).
- Fuera de alcance de esta primera versión: complicación en la esfera, app de reloj independiente (sin iPhone), notas desde el reloj, registrar días pasados, acciones sobre la notificación del recordatorio, Wear OS y cualquier analítica o reporte de fallos en el reloj.

## Capabilities

### New Capabilities
- `watch-mood-picker`: elegir desde Apple Watch el mood de hoy: moods ofrecidos, contrato de sincronización, conservación de la nota, entrega en cola y reglas de privacidad.

### Modified Capabilities
(ninguna: `premium-moods` y `mood-store` no cambian; el reloj solo lee qué moods están desbloqueados. Los eventos de analíticas no cambian porque el reloj no emite ninguno, así que `usage-analytics` queda igual.)

## Impact

- `ios/Runner.xcodeproj`: nuevo target de watchOS embebido; `ios/Runner/AppDelegate.swift` registra el canal y el buzón; archivos Swift nuevos para WatchConnectivity en el iPhone y para la app del reloj (`ios/WatchApp/` o similar).
- `lib/features/watch/` (nuevo): canal de plataforma, caso de uso que drena el buzón, publicación del estado; `lib/main.dart` lo cablea tras abrir Hive y `Purchases.configure()`, sin esperar nada del usuario antes de `runApp()`.
- `lib/features/mood/` y presentación: refresco de `MoodCubit`/`CalendarCubit` al aplicar elecciones del reloj. Reusa `SaveMoodUseCase`, `MoodPickerOrder`, `MoodDefinitionResolver` y `MoodEntitlementsRepository.unlockedPremiumMoodIds()`.
- `scripts/build_ios_release.sh` y sus verificaciones (llave de RevenueCat, Crashlytics, sin ID de publicidad): hay que confirmar que siguen pasando con el binario del reloj en el archive y, si hace falta, adaptarlas.
- `tool/screenshots/`: capturas de Apple Watch; App Store Connect: capturas y metadatos de la versión nueva.
- Pruebas: tests de Dart del caso de uso y del contrato; la app SwiftUI se verifica a mano con simuladores de iPhone y Watch emparejados (CI solo corre `flutter analyze` y `flutter test`).
- Privacidad: sin cambios. WatchConnectivity es local entre los dos dispositivos, el reloj no recolecta datos ni usa la red, y no lleva Firebase. App Privacy, Data safety y la política siguen valiendo.
- Android no cambia.
