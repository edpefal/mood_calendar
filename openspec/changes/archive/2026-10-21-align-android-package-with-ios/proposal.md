## Why

iOS usa `com.artlab.moodcalendar` y Android usa `com.artlab.mood_calendar` (con guion bajo). Son dos identificadores casi iguales que se confunden al configurar Firebase, Google Play y las llaves de API. Android todavía no está publicado en Google Play (confirmado: no hay ningún build subido), así que el `applicationId` aún se puede cambiar; después del primer build subido a Play queda fijo para siempre. Alinearlo ahora cuesta unos pocos archivos y evita arrastrar la inconsistencia.

## What Changes

- Cambiar `namespace` y `applicationId` de Android de `com.artlab.mood_calendar` a `com.artlab.moodcalendar` (`android/app/build.gradle`).
- Mover `MainActivity.kt` a `android/app/src/main/kotlin/com/artlab/moodcalendar/` y actualizar su `package`.
- Registrar en el proyecto Firebase `mood-calendar-fee5c` una app Android nueva con el paquete `com.artlab.moodcalendar` (Firebase no permite renombrar el paquete de una app registrada) y reemplazar `android/app/google-services.json`.
- Actualizar el `appId`, la API key y el client ID de Android en `lib/firebase_options.dart` y el `appId` de Android en `firebase.json`.
- Actualizar `packageName` en `.github/workflows/deploy_android.yml`.
- Documentar el identificador en `CLAUDE.md`.
- Sin cambios en iOS, en RevenueCat (solo tiene la app de iOS) ni en el comportamiento de la app.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
<!-- Ninguna: no cambia ningún comportamiento (`skip_specs: true`). -->

## Impact

- **Código y config**: `android/app/build.gradle`, `android/app/src/main/kotlin/.../MainActivity.kt`, `android/app/google-services.json`, `lib/firebase_options.dart`, `firebase.json`, `.github/workflows/deploy_android.yml`, `CLAUDE.md`.
- **Firebase**: nueva app Android en `mood-calendar-fee5c`; la app Android vieja (`com.artlab.mood_calendar`) queda sin uso y se borra en la consola. Crashlytics de Android no tiene datos que perder (Android no se ha publicado).
- **Google Play**: la ficha de la app se creará con el paquete nuevo; el workflow de despliegue ya apuntará a él.
- **Riesgo principal**: si el `applicationId` cambia sin cambiar `google-services.json` en el mismo PR, el build de Android falla (el plugin de Google Services exige que coincidan), por eso van juntos.
- **Dependencias**: ninguna nueva.
