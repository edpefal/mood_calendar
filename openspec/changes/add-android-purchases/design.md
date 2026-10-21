## Context

`main.dart` configura RevenueCat con `String.fromEnvironment('REVENUECAT_IOS_API_KEY')`; sin llave usa `NoopMoodEntitlementsRepository` para no tocar `purchases_flutter` sin `configure()` (crash nativo no capturable). `RevenueCatDatasource.configure(apiKey)` ya es agnóstico de plataforma (`Purchases.configure(PurchasesConfiguration(apiKey))`), así que no hay código de compra específico de iOS. En RevenueCat, el proyecto "Mood Calendar" tiene la app `app_store` (`app9709d48ff4`) y la Test Store. La oferta `default` tiene 18 paquetes y cada producto de iOS está adjunto a su entitlement (los moods a `mood_<id>`; cada Pack a los 3 entitlements de su composición).

## Goals / Non-Goals

**Goals:** que una build de Android con su llave cargue el mismo catálogo y desbloquee los mismos entitlements; que sea imposible publicar un bundle sin llave sin darse cuenta.

**Non-Goals:** crear productos o precios en Google Play Console (manual), cambiar el catálogo o los Packs, validar recibos en servidor (ver `docs/risks.md`), soporte de otras tiendas.

## Decisions

- **Llave por plataforma con una función pura** (`revenueCatApiKeyFor(platform, iosKey, androidKey)`) en `lib/features/purchases/data/`: devuelve la llave de la plataforma o cadena vacía. Así se prueba sin plugins y `main.dart` solo pasa `defaultTargetPlatform` y los `fromEnvironment`. Alternativa descartada: una sola `REVENUECAT_API_KEY`, porque cada tienda tiene su propia llave pública y un `--dart-define` único obligaría a builds distintos con el mismo nombre de variable (más fácil confundirse).
- **Mismos identificadores de producto en Play que en iOS** (`mood_<id>_unlock`, `pack_<nombre>_unlock`): son válidos en Play (minúsculas, números y guion bajo) y permiten reutilizar entitlements y paquetes sin cambiar la lógica de la app.
- **Productos de RevenueCat para Android**: tipo `non_consumable`, un producto por cada uno de iOS, adjuntos a los mismos entitlements (el Pack a los 3 de su composición) y a los mismos paquetes con `eligibility_criteria: all`. Se crean vía MCP; nada de esto crea el producto en Play.
- **Script de build de Android espejo del de iOS** (`scripts/build_android_release.sh`): exige `REVENUECAT_ANDROID_API_KEY` con prefijo `goog_`, ejecuta `flutter build appbundle --release --dart-define=...` y llama a `scripts/verify_android_bundle_key.sh`, que busca la llave dentro de `libapp.so` del bundle (como hace el de iOS con `App.framework/App`). Lleva el mismo `STORE_VERIFIED=1` para afirmar la comprobación manual. Falla si no se generó el `.aab`.
- **Hook**: se amplía `require-release-script.sh` para bloquear `flutter build appbundle` y `flutter build apk` de release directos (no debug ni profile), con el mensaje apuntando al script.
- **CI**: un paso previo comprueba que el secreto exista y pasa `--dart-define=REVENUECAT_ANDROID_API_KEY=...` al build; el despliegue sigue yendo a la pista `internal`.
- **Fallback**: se mantiene `NoopMoodEntitlementsRepository` cuando falta la llave, con el mensaje de error indicando qué variable falta para la plataforma actual.

## Risks / Trade-offs

- **La tienda de Android no mostrará catálogo hasta que existan los productos en Play y RevenueCat tenga las credenciales de servicio** → es el estado esperado de la primera subida a la pista interna; la pantalla ya tiene mensaje de error y reintento.
- **Play exige un build subido para que los productos de prueba funcionen** → la primera subida debe ser a `internal`, y la prueba de compra real se hace con un tester de licencia.
- **Configurar RevenueCat en producción** puede afectar a iOS si se adjunta mal un producto → los productos nuevos son de la app Android y solo se añaden (no se quita ninguna asociación), y se verifica después listando los entitlements y la oferta.
- **Verificar la llave dentro del bundle** podría no encontrar la cadena si el compilador de Dart la guarda de otra forma → se comprueba empíricamente con un build real antes de dar por buena la verificación.

## Open Questions

- Ninguna bloqueante. Precios de los productos en Play: los define el usuario al crearlos (en iOS los moods cuestan $0.99).
