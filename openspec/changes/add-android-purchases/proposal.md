## Why

La app compila para Android, pero las compras no funcionan allí: `main.dart` solo lee `REVENUECAT_IOS_API_KEY`, el proyecto de RevenueCat solo tiene la app de iOS y, sin llave, la app cae a `NoopMoodEntitlementsRepository` (toda compra falla con "producto no disponible"). En Android quedarían 14 de los 19 moods bloqueados para siempre, el mismo tipo de error que causó el rechazo de Apple (Guideline 2.1(b)). Hay que dar soporte de compras a Android antes de publicarlo.

## What Changes

- RevenueCat: crear la app Android (`play_store`, paquete `com.artlab.moodcalendar`), registrar sus 18 productos (14 moods y 4 packs, con los mismos identificadores de tienda que en iOS), adjuntarlos a los mismos entitlements y a los mismos paquetes de la oferta `default`.
- App: elegir la llave de RevenueCat según la plataforma (`REVENUECAT_IOS_API_KEY` en iOS, `REVENUECAT_ANDROID_API_KEY` en Android) con una función pequeña y probada, y ajustar el mensaje de error del arranque.
- Build: nuevo `scripts/build_android_release.sh`, equivalente al de iOS (se niega a correr sin la llave, la pasa por `--dart-define` y comprueba que quedó dentro del bundle). El hook de Claude Code también bloquea `flutter build appbundle`/`apk` de release directos.
- CI: `deploy_android.yml` falla si falta el secreto `REVENUECAT_ANDROID_API_KEY` y lo pasa por `--dart-define`.
- Documentación: `CLAUDE.md` (compras ya no son "solo iOS", build de Android, cómo obtener la llave).
- Sin cambios en iOS ni en el comportamiento de la tienda: es el mismo catálogo, los mismos entitlements y los mismos Packs.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
<!-- Ninguna: la tienda se comporta igual en las dos plataformas (`skip_specs: true`). -->

## Impact

- **Código**: `lib/main.dart`, un archivo nuevo de configuración en `lib/features/purchases/data/`, tests de esa función.
- **Scripts y CI**: `scripts/build_android_release.sh` (nuevo), `scripts/verify_android_bundle_key.sh` (nuevo), `.claude/hooks/require-release-script.sh`, `.github/workflows/deploy_android.yml`.
- **RevenueCat (producción)**: app Android nueva, 18 productos, asociaciones a entitlements y paquetes. No altera a los clientes de iOS (cada paquete elige el producto de su tienda).
- **Pasos manuales (usuario)**: crear los 18 productos en Google Play Console con los mismos identificadores y precios, configurar las credenciales de servicio de Play en RevenueCat, subir un build a una pista de pruebas (Play exige un build subido para probar compras), añadir testers de licencia y crear el secreto `REVENUECAT_ANDROID_API_KEY` en GitHub.
- **Riesgo**: los productos de RevenueCat para Android quedan "sin verificar" hasta que existan en Play Console; la tienda de Android no cargará catálogo real hasta entonces (la pantalla ya tiene reintento y mensaje de error).
