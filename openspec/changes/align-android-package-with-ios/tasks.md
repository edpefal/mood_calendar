## 1. Firebase

- [x] 1.1 Registrar la app Android `com.artlab.moodcalendar` en `mood-calendar-fee5c` (`firebase apps:create ANDROID`) y anotar su `appId`
- [x] 1.2 Descargar su configuración (`firebase apps:sdkconfig ANDROID <appId>`) y reemplazar `android/app/google-services.json`
- [x] 1.3 Actualizar los valores de Android en `lib/firebase_options.dart` y el `appId` de Android en `firebase.json`; confirmar en el diff que los de iOS no cambian

## 2. Código Android

- [x] 2.1 Cambiar `namespace` y `applicationId` a `com.artlab.moodcalendar` en `android/app/build.gradle`
- [x] 2.2 Mover `MainActivity.kt` a `android/app/src/main/kotlin/com/artlab/moodcalendar/` con `git mv` y cambiar su `package`
- [x] 2.3 Confirmar que no quedan referencias a `com.artlab.mood_calendar` fuera de `openspec/changes/archive/` y de docs históricos

## 3. CI y documentación

- [x] 3.1 Actualizar `packageName` en `.github/workflows/deploy_android.yml`
- [x] 3.2 Documentar el identificador de Android (y que coincide con iOS) en `CLAUDE.md`

## 4. Verificación

- [x] 4.1 `flutter pub get`, `flutter analyze` y `flutter test` limpios
- [x] 4.2 `flutter build apk --debug` compila (el plugin de Google Services acepta el `google-services.json` nuevo)
- [x] 4.3 Si hay keystore local, `flutter build appbundle --release`; si no, anotarlo como no verificado

## 5. Cierre (manual, tras el merge)

- [ ] 5.1 Borrar la app Android vieja (`com.artlab.mood_calendar`) en la consola de Firebase
- [ ] 5.2 Al publicar en Google Play: crear la ficha con `com.artlab.moodcalendar`, restringir la API key de Android por paquete y SHA-1 y completar Data safety (ver backlog de Crashlytics)
- [ ] 5.3 Archivar con `/opsx:archive`
