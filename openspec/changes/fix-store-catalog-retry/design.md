## Context

`PurchasesCubit` pide el catálogo en su constructor (`loadCatalog()`); `MoodStoreScreen` solo renderiza un `Center(Text(storeLoadError))` cuando `catalogError != null` y no hay ofertas, sin `RefreshIndicator` ni botón. `RefreshIndicator` solo existe en la rama con contenido. `catch (e)` guarda el error en el estado pero no lo registra en ningún lado. Las pestañas viven en un `IndexedStack` (`MainShell`), así que la pantalla no se reconstruye al volver a ella.

Lo observado: un fallo puntual en el iPad que no se repitió (el disco del Mac estaba casi lleno en ese momento, sin confirmar como causa). `availableMoodOffers()` y `availablePacks()` llaman cada uno a `Purchases.getOfferings()`, que puede lanzar `PlatformException` por red, configuración o StoreKit. Ver `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Que un fallo transitorio de carga se pueda recuperar sin reiniciar la app.
- Dejar rastro de la causa del fallo (log local y Crashlytics en release).

**Non-Goals:**
- Reintentos automáticos con backoff en segundo plano.
- Distinguir tipos de error con mensajes distintos (red vs. configuración).
- Cambiar cómo se cargan o se cachean las ofertas, o las compras y la restauración.
- Cargar el catálogo dos veces con una sola llamada a `getOfferings()` (optimización aparte).

## Decisions

**1. Botón "Reintentar" en el estado de error, con `GradientPillButton`.** Es el botón primario estándar del proyecto y tiene `Semantics`. Llama a `loadCatalog()`, que ya emite `isLoadingCatalog` y limpia `catalogError`, así que el estado de carga sale gratis. Alternativa descartada: solo pull-to-refresh, que no es descubrible en una pantalla vacía.

**2. Reintento al entrar a la pestaña de la Tienda si hay error, una vez por visita.** Sigue el patrón de `MoodScreen` y `CalendarScreen`: `MainShell` pasa `isActive` a `MoodStoreScreen`, y la pantalla, al mostrarse por primera vez o al pasar de inactiva a activa, si `catalogError != null` y no se está cargando, llama a `loadCatalog()`. La lógica vive en la pantalla y `MainShell` solo cablea `isActive`. Cubre el caso del usuario que sale y vuelve sin darse cuenta del botón. Alternativa descartada: temporizador con backoff, más código y estado para un caso raro.

**3. Telemetría opcional en el cubit.** `PurchasesCubit(repository, {AppTelemetry? telemetry})` y en el `catch`, `telemetry?.recordError('load_store_catalog_failed', reason: 'get_offerings', error: e, stackTrace: s)`. Parámetro nombrado y opcional para no tocar los ~12 call sites de tests. `main.dart` inyecta la telemetría real. El error de RevenueCat no lleva datos del usuario, así que no choca con el filtro de privacidad de Crashlytics.

**4. Un string nuevo, `storeRetry`,** en `AppStrings` y sus 5 subclases (en, es, de, fr, it), como exige la guía de localización.

## Risks / Trade-offs

- [Reintento al volver a la pestaña genera llamadas repetidas si el fallo es persistente] → solo una por visita y solo si hay error; el costo es una llamada a RevenueCat por entrada a la pestaña.
- [El reintento no arregla fallos persistentes de configuración (key o producto mal configurado)] → ahora al menos queda registrado con su causa, que es lo que faltaba para diagnosticarlo.
- [El estado de error sigue sin explicar la causa al usuario] → fuera de alcance; el mensaje actual se mantiene.
- [Un build nuevo reemplaza al 1.8.4+29 ya subido] → decisión del release, no del código.
