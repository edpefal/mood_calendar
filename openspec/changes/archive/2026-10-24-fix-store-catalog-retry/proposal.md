## Why

Al probar el build de release con la key real de RevenueCat, la Tienda del iPad mostró "We could not load the store right now" y se quedó así hasta reiniciar la app; en el iPhone y en un segundo intento en el iPad cargó bien. Esa es la misma pantalla de error que provocó un rechazo de Apple (Guideline 2.1(b)). La causa del fallo puntual no se pudo determinar porque nada la registra, pero el diseño agrava cualquier fallo transitorio: el catálogo se pide una sola vez, al crear `PurchasesCubit` al arrancar, y la pantalla de error no ofrece ninguna forma de reintentar (ni botón, ni pull-to-refresh, ni recarga al volver a la pestaña).

## What Changes

- La Tienda, cuando el catálogo no carga, muestra un botón de "Reintentar" que vuelve a pedirlo, con estado de carga mientras tanto.
- Al volver a la pestaña de la Tienda con el catálogo en error, se reintenta solo una vez por visita.
- El fallo de carga del catálogo se registra como error no fatal (`recordError`) con su causa, para que aparezca en el log local y en Crashlytics en release.
- Nuevo string localizado para el botón en los 5 idiomas.
- Sin cambios en compras, restauración ni en el catálogo cuando sí carga.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `mood-store`: añade el requisito de recuperación cuando el catálogo no carga (reintento manual y al volver a la pestaña).

## Impact

- **Código**: `lib/features/purchases/presentation/bloc/purchases_cubit.dart` (telemetría opcional), `lib/features/purchases/presentation/screens/mood_store_screen.dart` (botón de reintento), `lib/core/navigation/main_shell.dart` (recarga al entrar a la pestaña), `lib/main.dart` (inyectar telemetría), `lib/core/localization/` (`AppStrings` y las 5 subclases).
- **Tests**: cubit (reintento y registro del error), `MoodStoreScreen` (botón y estados), shell (reintento al volver a la pestaña).
- **Release**: si entra antes de enviar la 1.8.4 a revisión, el build 1.8.4+29 ya subido a App Store Connect se reemplaza por un +30.
- **Dependencias**: ninguna nueva.
