## Context

Hoy conviven dos identificadores: iOS `com.artlab.moodcalendar` (el de la app publicada) y Android `com.artlab.mood_calendar`. Android solo está configurado (Gradle, Firebase y el workflow `deploy_android.yml`, que se dispara con cualquier tag `v*.*.*`); no hay ningún build en Google Play. El `google-services.json` actual y el `appId` de Android en `firebase_options.dart` pertenecen a la app Firebase del paquete viejo. La API key de Android sigue sin restringir (pendiente hasta publicar).

## Goals / Non-Goals

**Goals:**
- Que Android use exactamente `com.artlab.moodcalendar`, igual que iOS.
- Que Crashlytics de Android quede apuntando a una app Firebase con el paquete nuevo.

**Non-Goals:**
- Publicar en Google Play o restringir la API key de Android (siguen diferidos).
- Tocar iOS, RevenueCat o cualquier comportamiento de la app.

## Decisions

- **App Firebase nueva, no renombrada.** Firebase no permite cambiar el `package_name` de una app Android registrada, así que se crea una nueva con `firebase apps:create ANDROID` y se descarga su configuración con `firebase apps:sdkconfig ANDROID <appId>`; la vieja se borra después en la consola (la CLI no borra apps). Alternativa descartada: dejar la app vieja y solo cambiar el `applicationId`, porque el plugin de Google Services falla si no coinciden.
- **Cambios en un solo PR.** `applicationId`, `google-services.json`, `firebase_options.dart`, `firebase.json` y el workflow cambian juntos; separados dejarían el build roto entre un PR y otro.
- **Actualizar `firebase_options.dart` a mano (o con `flutterfire configure` limitado a Android) y revisar el diff.** Solo deben cambiar los valores de Android (`appId`, `apiKey`, `androidClientId` si cambia); los de iOS no deben variar. Si se usa `flutterfire configure`, se pasa `--platforms=android` y se descartan cambios inesperados en iOS.
- **Mover `MainActivity.kt` con `git mv`** para conservar el historial, y cambiar solo su línea `package`.
- **Verificación sin firma de release**: `flutter build apk --debug` basta para comprobar que el plugin de Google Services acepta el `google-services.json` nuevo; `flutter build appbundle --release` se intenta solo si hay keystore local. Se corre también `flutter analyze` y `flutter test`.
- **Orden irreversible en Play**: el primer build subido fija el `applicationId` para siempre, por eso el cambio va antes de crear la ficha en Play Console.

## Risks / Trade-offs

- **Build roto si no coincide el paquete** → mitigación: un solo PR y `flutter build apk --debug` en la verificación. CI solo corre `analyze` y `test`, así que no detectaría el fallo de Gradle; la verificación local es obligatoria.
- **Versiones de AGP/Gradle del proyecto** (ya hubo un bump a AGP 8.9.1) → si el build local falla por entorno y no por el cambio, se separa el diagnóstico (probar en `main` antes).
- **App Firebase vieja huérfana** → no cuesta nada ni tiene datos; se borra al final desde la consola, sin urgencia.
- **Alguien ya subió algo a Play con el paquete viejo** → confirmado que no; si cambiara, el `applicationId` viejo ya no se podría abandonar.

## Open Questions

- Ninguna bloqueante. La creación de la ficha en Google Play Console con el paquete nuevo y la restricción de la API key de Android por paquete y SHA-1 siguen siendo pasos manuales posteriores.
