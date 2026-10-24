## 1. Telemetría del fallo

- [x] 1.1 Añadir `AppTelemetry? telemetry` opcional y nombrado a `PurchasesCubit` y registrar `load_store_catalog_failed` en el `catch` de `loadCatalog()` con error y stack trace
- [x] 1.2 Inyectar la telemetría real en `PurchasesCubit` desde `lib/main.dart`

## 2. Reintento en la pantalla

- [x] 2.1 Añadir el getter `storeRetry` a `AppStrings` e implementarlo en `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart` y `app_strings_it.dart`
- [x] 2.2 En `MoodStoreScreen`, mostrar junto al mensaje de error un `GradientPillButton` con `Semantics` que llame a `loadCatalog()`
- [x] 2.3 `MainShell` pasa `isActive` a `MoodStoreScreen`, que al activarse (o al mostrarse por primera vez) con `catalogError` y sin carga en curso llama a `loadCatalog()` una vez

## 3. Tests

- [x] 3.1 Test del cubit: `loadCatalog()` fallido registra el error en la telemetría y deja `catalogError`; un segundo intento exitoso limpia el error y carga las ofertas
- [x] 3.2 Test de `MoodStoreScreen`: con error se ve el botón; al tocarlo muestra carga y luego el catálogo; si vuelve a fallar, reaparece el botón
- [x] 3.3 Test de `MainShell`: volver a la pestaña de la Tienda con error reintenta una vez; con el catálogo cargado no vuelve a pedirlo
- [x] 3.4 Test de que el texto del botón existe en los 5 idiomas
- [x] 3.5 Correr `flutter analyze` y `flutter test`

## 4. Verificación y release

- [x] 4.1 En el simulador de iPhone, forzar fallos de catálogo con un parche temporal (no commiteado) y confirmar que el botón recupera la Tienda; el reintento fallido vuelve a mostrar el botón. No se probó en iPad
- [x] 4.2 Decidir con el release si este cambio entra en la 1.8.4 y, de ser así, subir el build a +30 y repetir `scripts/build_ios_release.sh` — Entró en la 1.8.4 (builds +30 y +31).
