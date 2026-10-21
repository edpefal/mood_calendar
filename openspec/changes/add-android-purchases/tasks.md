## 1. RevenueCat (producción)

- [x] 1.1 Crear la app Android `play_store` con paquete `com.artlab.moodcalendar` y anotar su llave pública (`goog_...`)
- [x] 1.2 Crear los 18 productos `non_consumable` de la app Android con los mismos identificadores de tienda que en iOS
- [x] 1.3 Adjuntar cada producto a los mismos entitlements que su equivalente de iOS (los 4 Packs a los 3 de su composición)
- [x] 1.4 Adjuntar cada producto Android al paquete de la oferta `default` que ya tiene su producto de iOS
- [x] 1.5 Verificar: lista de entitlements y de la oferta con los productos de las dos tiendas, sin quitar nada de iOS

## 2. App

- [x] 2.1 Crear `revenueCatApiKeyFor` (llave según plataforma) en `lib/features/purchases/data/` y usarla en `main.dart` con `REVENUECAT_IOS_API_KEY` y `REVENUECAT_ANDROID_API_KEY`
- [x] 2.2 Ajustar el mensaje de error del arranque para que nombre la variable de la plataforma actual
- [x] 2.3 Tests de `revenueCatApiKeyFor` (iOS, Android, llave vacía, plataformas no móviles)

## 3. Build y CI

- [x] 3.1 `scripts/build_android_release.sh`: exige la llave `goog_...`, la pasa por `--dart-define`, verifica el bundle y falla si no hay `.aab`
- [x] 3.2 `scripts/verify_android_bundle_key.sh`: busca la llave dentro de `libapp.so` del `.aab`; probarlo con un build real y comprobar que falla sin llave
- [x] 3.3 Ampliar `.claude/hooks/require-release-script.sh` para bloquear `flutter build appbundle`/`apk` de release directos
- [x] 3.4 `deploy_android.yml`: comprobar el secreto `REVENUECAT_ANDROID_API_KEY` y pasarlo por `--dart-define`

## 4. Documentación y verificación

- [x] 4.1 `CLAUDE.md`: compras en iOS y Android, build de Android, cómo obtener la llave de Android
- [x] 4.2 `flutter analyze` y `flutter test` limpios
- [x] 4.3 Build real de `appbundle` con una llave de prueba y verificación del script (y fallo esperado sin llave)

## 5. Cierre (manual, usuario)

- [x] 5.1 Crear los 18 productos en Google Play Console con los mismos identificadores y precios (hecho el 2026-10-19 por la API de Android Publisher: 14 moods a $0.99 y 4 packs a $1.99, todos ACTIVE)
- [x] 5.2 Subir las credenciales de servicio de Play a RevenueCat (hecho el 2026-10-19; las 3 comprobaciones pasan)
- [ ] 5.3 Crear el secreto `REVENUECAT_ANDROID_API_KEY` en GitHub
- [x] 5.4 Subir el primer build a la pista interna, añadir testers de licencia y probar una compra (compra de prueba exitosa el 2026-10-20; falta probar Restaurar compras)
- [ ] 5.5 Archivar con `/opsx:archive`
