# Probar la app de Apple Watch

La app del reloj (`ios/WatchApp/`, SwiftUI) se sincroniza con el iPhone por WatchConnectivity. Contrato: `docs/watch-sync-contract.md`.

## Requisitos

- Runtime de watchOS instalado: `xcodebuild -downloadPlatform watchOS`. **Sin él, `xcodebuild` no compila el esquema `Runner` ni siquiera para el simulador de iPhone** ("watchOS … must be installed").
- `flutter build ios --simulator` y `flutter run` piden un simulador explícito: `-d <udid>`.
- Íconos: `brew install librsvg` y `tool/watch/export_mood_icons.sh` cuando cambie `assets/icon/`.
- Si añades archivos Swift o recursos a `ios/WatchApp/`, corre `ruby tool/watch/add_watch_target.rb` para que entren al proyecto (es idempotente).

## Simuladores emparejados

Siempre en simuladores propios, nunca en los del día a día:

```bash
RT_IOS=com.apple.CoreSimulator.SimRuntime.iOS-26-2
RT_WATCH=com.apple.CoreSimulator.SimRuntime.watchOS-26-2
PH=$(xcrun simctl create "MC Watch Phone" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro $RT_IOS)
WA=$(xcrun simctl create "MC Watch" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-11-46mm $RT_WATCH)
xcrun simctl pair $WA $PH
xcrun simctl boot $PH && xcrun simctl boot $WA
flutter build ios --simulator --debug -d $PH
xcrun simctl install $PH build/ios/iphonesimulator/Runner.app
xcrun simctl install $WA build/ios/iphonesimulator/Runner.app/Watch/WatchApp.app
xcrun simctl launch $PH com.artlab.moodcalendar
xcrun simctl launch $WA com.artlab.moodcalendar.watchkitapp
xcrun simctl io $WA screenshot watch.png
```

`xcrun simctl delete $PH $WA` al terminar.

## Limitaciones conocidas

- En simuladores WatchConnectivity no es fiable: instalar la app del reloj con `simctl install` deja `appInstalled: NO` en el iPhone (`WCSession counterpart app not installed`) y el iPhone no publica su estado. La sincronización de punta a punta se prueba en un **iPhone y un Apple Watch reales** (TestFlight).
- Para ver la interfaz del reloj sin sincronizar, inyecta un estado publicado con `defaults import` (el reloj debe estar cerrado):

  ```bash
  # state.plist: { "watch.state.v1": { version: 1, locale: "es", today: "calm", moods: [{id, name}, …] } }
  xcrun simctl terminate $WA com.artlab.moodcalendar.watchkitapp
  xcrun simctl spawn $WA defaults import com.artlab.moodcalendar.watchkitapp state.plist
  xcrun simctl launch $WA com.artlab.moodcalendar.watchkitapp
  ```
- No hay forma de tocar el reloj simulado desde la terminal (`idb` es solo iOS). La lógica de elegir un mood se cubre con XCTest (`ios/RunnerTests/WatchModelTests.swift`, que compila `WatchModel.swift` y `WatchModels.swift`) y la del iPhone con `WatchInboxStoreTests` y las pruebas de Dart de `test/features/watch/`.

## Pruebas automáticas

```bash
flutter test test/features/watch
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner \
  -destination "platform=iOS Simulator,id=<udid>" -only-testing:RunnerTests
```

## Suscripción vencida (1.10.0)

Los moods premium los desbloquea la suscripción (o una compra suelta de una versión anterior). Para ver cómo se comporta el reloj cuando deja de estar activa:

1. Con una suscripción de sandbox activa, comprueba que el reloj ofrece los moods premium.
2. Cierra la app del iPhone y deja vencer la suscripción (en sandbox, la renovación acelerada de la semanal tarda unos minutos).
3. En el reloj, que todavía muestra el estado viejo, elige un mood premium. Verás "Sincronizando con el iPhone".
4. Abre la app del iPhone: descarta la elección sin cambiar ninguna entrada, publica el estado nuevo y el reloj quita la marca "pendiente" y solo ofrece los moods base.

Las pruebas automáticas lo cubren en Dart (`watch_sync_coordinator_test.dart`) y en Swift (`WatchModelTests`: `testPendingIsDroppedWhenThePhoneReportsItProcessedThatChoice`).
