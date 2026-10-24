## 1. Dependencias y configuración nativa

- [x] 1.1 Añadir `firebase_analytics` a `pubspec.yaml` (compatible con `firebase_core` ^4.x), correr `flutter pub get` y `pod install`; confirmar que compila con iOS 15.0
- [x] 1.2 iOS: en `Info.plist` poner `FIREBASE_ANALYTICS_COLLECTION_ENABLED=false`, `GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS=false` y `GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_STORAGE=false`; confirmar que no se enlaza `IdentitySupport`/AdSupport ni se añade `NSUserTrackingUsageDescription`
- [x] 1.3 Android: en `AndroidManifest.xml` poner `firebase_analytics_collection_enabled=false` y `google_analytics_adid_collection_enabled=false`, y quitar el permiso `com.google.android.gms.permission.AD_ID` con `tools:node="remove"`
- [x] 1.4 Verificar que `GoogleService-Info.plist` y `google-services.json` ya tienen Analytics habilitado (si no, regenerarlos con `firebase apps:sdkconfig`) — Los archivos siguen con `IS_ANALYTICS_ENABLED=false` aunque la propiedad de GA está vinculada, pero Analytics funciona igual (eventos vistos en Realtime); no hizo falta regenerarlos.

## 2. Capa de analíticas

- [x] 2.1 Definir la interfaz `AnalyticsReporter` (`logEvent`, `setCollectionEnabled`) en `lib/core/telemetry/`
- [x] 2.2 Implementar `FirebaseAnalyticsReporter` sobre `FirebaseAnalytics`, con el seguimiento automático de pantallas desactivado
- [x] 2.3 Mover `blockedContextKeys` a una constante compartida entre Crashlytics y Analytics
- [x] 2.4 Añadir a `AppTelemetryEvents` los eventos de tienda y compras (`store_opened`, `purchase_started`, `purchase_completed`, `purchase_cancelled`, `purchase_failed`, `purchases_restored`) y emitirlos desde `PurchasesCubit`/tienda sin incluir ids de moods ni de Packs
- [x] 2.5 Implementar `AnalyticsAppTelemetry`: delega todo al log, reenvía solo los eventos de la allowlist y solo los parámetros permitidos (`has_note`, `source`), descartando las claves bloqueadas; `recordError` solo al delegado
- [x] 2.6 Un fallo del reporter no debe propagarse al llamador (capturar y escribir en el log)

## 3. Preferencia y Settings

- [x] 3.1 Añadir `usageAnalyticsEnabled` (por defecto `true`) a `AppSettings`, a su repositorio y a `AppSettingsLocalDataSource` (Hive)
- [x] 3.2 `SettingsCubit`: acción para cambiar la preferencia con el autoguardado en cola y reversión con mensaje si falla, y aplicar `setCollectionEnabled` al reporter
- [x] 3.3 `SettingsScreen`: fila con interruptor "Compartir datos de uso anónimos", explicación breve y `Semantics`
- [x] 3.4 Añadir los textos en `AppStrings` y en `app_strings_en/es/de/fr/it.dart`

## 4. Arranque

- [x] 4.1 En `main()`, tras abrir Hive, leer la preferencia y aplicar `setCollectionEnabled` antes de componer la telemetría; inicializar Analytics solo si Firebase se inicializó (release, iOS/Android)
- [x] 4.2 Componer la cadena `Logger → Crashlytics → Analytics` y confirmar que un fallo de inicialización deja la app con log local
- [x] 4.3 Confirmar que `tool/screenshots/main.dart` no inicializa Analytics ni envía nada y que ningún `await` espera al usuario antes de `runApp()`

## 5. Tests

- [x] 5.1 `FakeAnalyticsReporter` en `test/support/`
- [x] 5.2 Test de `AnalyticsAppTelemetry`: allowlist de eventos, descarte de claves bloqueadas (`mood_saved` con `date`, `mood`, `intensity`, `note` no las envía), `mood_history_exported` no se envía, siempre escribe al log, errores del reporter no propagan
- [x] 5.3 Test del gate: sin release/iOS-Android o con la preferencia en `false` no se envía nada
- [x] 5.4 Tests de `SettingsCubit` y `SettingsScreen` para el interruptor (estado inicial, apagar, reversión al fallar, textos en los 5 idiomas)
- [x] 5.5 Test de que la preferencia persiste entre arranques y se aplica antes del primer evento
- [x] 5.6 Correr `flutter analyze` y `flutter test` sin Firebase configurado

## 6. Release y verificación

- [x] 6.1 Script o comprobación que revisa el manifiesto fusionado del bundle de Android y falla si aparece `AD_ID`; engancharla a `scripts/build_android_release.sh`
- [x] 6.2 Comprobar en el archive de iOS que no se enlaza AdSupport/IdentitySupport (extender `scripts/verify_ios_archive_crash_reporting.sh` o un script nuevo)
- [ ] 6.3 Medir el tamaño del release antes y después y el arranque en frío; confirmar que la UI aparece antes del diálogo de notificaciones — No medido al archivar.
- [x] 6.4 Con un build de profile, verificar en `DebugView` de Firebase que llegan los eventos de la lista y que `mood_saved` no lleva mood, nota, fecha ni intensidad; apagar el interruptor y comprobar que deja de llegar todo — Verificado con Analytics → Realtime en builds de TestFlight y de la pista interna (DebugView no aplica a esos builds).
- [x] 6.5 Subir iOS (build 33 o superior) y Android (`versionCode` mayor que 32) con los scripts de release y confirmar usuarios activos en el panel de Analytics — iOS 1.8.5 (36) y Android 1.8.5 (36).

## 7. Privacidad y documentación

- [x] 7.1 App Store Connect → App Privacy: añadir *Usage Data → Product Interaction* y *Identifiers → Device ID* (no vinculados, sin tracking) y *Purchases* (RevenueCat); publicar
- [x] 7.2 Google Play → Seguridad de los datos: declarar actividad en la app, ID de dispositivo, historial de compras y registros de fallos/diagnóstico
- [x] 7.3 Actualizar la política de privacidad (TermsFeed) para cubrir Firebase Analytics, Crashlytics y RevenueCat, y cambiar "datos solo locales" por "datos locales, salvo analíticas y reportes de fallos anónimos" — Se publicó una política propia en https://moodcalendar.app/privacy/ (y `/es/privacy/`) en lugar de editar TermsFeed.
- [x] 7.4 Actualizar `CLAUDE.md` (stack, arranque, Settings y verificación de release), `docs/risks.md` si procede y `backlog.md` (el toggle de Crashlytics sigue pendiente)
