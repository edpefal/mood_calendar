## Why

Hoy los 14 moods premium se venden uno a uno ($0.99) o en 4 Packs ($1.99): 18 productos por plataforma, una Tienda con tres listas, hojas de compra, avisos de solape y nombres de Packs en 5 idiomas. Es mucho catálogo para un ingreso que, hasta ahora, es cero: RevenueCat no registra ninguna compra real desde que se creó el proyecto (2026-09-25). Una suscripción semanal, mensual o anual que desbloquea todos los moods simplifica la oferta (una decisión en vez de dieciocho), crea ingreso recurrente y deja de exigir que cada mood nuevo tenga producto, precio y traducciones propias.

## What Changes

- **BREAKING** (de producto): las compras sueltas de moods y los Packs dejan de venderse. Se reemplazan por una suscripción con tres planes (semanal, mensual y anual) que desbloquea los 14 moods premium mientras esté activa. Precios base en USD $0.99 / $2.99 / $14.99, definidos en App Store Connect y Play (nunca en el código). Prueba gratis de 3 días en los tres planes, solo si la tienda confirma que el usuario es elegible.
- Un único entitlement `premium` en RevenueCat. El repositorio sigue reconociendo los entitlements `mood_*` heredados, de modo que quien compró un mood o Pack en las versiones 1.8.x–1.9.0 lo conserva y puede restaurarlo. Los 18 productos viejos se retiran de la venta en las tiendas solo cuando la 1.10.0 esté publicada.
- Productos nuevos: en iOS un grupo "Mood Calendar Premium" con `premium_weekly`, `premium_monthly` y `premium_annual`; en Android una suscripción `premium` con planes base `weekly`, `monthly` y `annual`. En RevenueCat se añaden los paquetes estándar `$rc_weekly`, `$rc_monthly` y `$rc_annual` a la oferta `default` existente, para no dejar vacía la tienda de las versiones 1.8.x y 1.9.0 (filtran por el prefijo `$rc_custom_mood_`/`$rc_custom_pack_` y ignoran lo demás).
- La tercera pestaña del bottom bar pasa de "Tienda" a **"Premium"** (icono de estrella o diamante) y es la pantalla de suscripción: escaparate de las caritas premium, tres tarjetas de plan con el anual preseleccionado y la etiqueta "Mejor valor" calculada con los precios de la tienda, botón principal ("Probar 3 días gratis" solo con elegibilidad confirmada; si no, "Suscribirme"), texto legal con precio, renovación automática y fin de la prueba, enlaces a Términos y Privacidad y "Restaurar compras". Quien ya está suscrito ve su plan, la fecha de renovación o de fin de prueba y "Gestionar suscripción".
- Tocar un mood bloqueado (carrusel, hoja de cuadrícula o Guardar) abre esa misma pantalla como hoja, en vez de la compra de ese mood. La pantalla solo aparece cuando el usuario la pide: nunca al abrir la app, tras guardar ni en un onboarding.
- Quien deja de pagar puede seguir guardando la nota de una entrada que ya tiene ese mood premium; necesita suscripción para elegir otro mood premium o crear una entrada nueva con uno. El historial nunca se oculta ni se modifica.
- Apple Watch (en la 1.10.0): si el iPhone descarta una elección de un mood que ya no está desbloqueado, publica el estado actualizado y el reloj quita la marca "pendiente" al recibir un estado sin esa elección.
- Analíticas: la lista cerrada añade el parámetro `plan` (`weekly`, `monthly` o `annual`) en `purchase_started` y `purchase_completed`, y `source` (`tab` o `locked_mood`) en `store_opened`. Sin ids de moods ni datos de entradas; las declaraciones de privacidad no cambian.
- Sitio y legal: se reescribe en inglés y español la sección 3 de `site/terms` (suscripción, renovación automática, prueba, cancelación, reembolsos por Apple y Google) y la línea de RevenueCat de `site/privacy`. La landing no cambia ("gratis para descargar y usar", sin precios). Se actualizan `PRODUCT.md`, `CONTEXT.md` (glosario), `docs/risks.md` y el ADR 0002, que pasa a "Reemplazado".
- Código: se eliminan `MoodPack`, `MoodOffer`, las hojas de compra de mood y de Pack, los avisos de solape y los nombres de Packs en los 5 idiomas. Del lado heredado solo queda la lectura de los entitlements `mood_*`.
- Tiendas: las suscripciones se crean por API (iOS con la clave de App Store Connect y las herramientas de RevenueCat; Android con la API de Play), mostrando cada paso al usuario antes de ejecutarlo y sin buscar credenciales por cuenta propia. La ficha de App Store y Play lleva un párrafo de suscripción y las notas para el revisor.
- Fuera de esta primera versión (van al backlog): plan vitalicio o compra única, ofertas promocionales o de reconquista, Compartir en Familia, paywalls y experimentos de RevenueCat, y avisos dentro de la app por vencimiento o reintento de cobro.
- Orden de lanzamiento: la implementación empieza cuando `add-apple-watch-mood-picker` esté publicado y archivado (1.9.0); esta suscripción sale en la 1.10.0 para iOS y Android a la vez.

## Capabilities

### New Capabilities
- `premium-subscription`: los planes de suscripción, su precio y prueba gratis desde la tienda, la compra y la restauración, el estado de quien está suscrito, la convivencia con los entitlements heredados y la regla de que la oferta solo aparece a petición del usuario.

### Modified Capabilities
- `mood-store`: la Tienda deja de ser un catálogo de compras sueltas y Packs y pasa a ser la pantalla Premium: se retiran la compra individual, la compra de Pack, el aviso de solape y los Packs de la primera ola; se conservan, adaptados, el escaparate de los moods premium, la restauración, los nombres localizados, la recuperación cuando el catálogo no carga y el acceso desde el bottom bar.
- `premium-moods`: el estado `unlocked` sale de una suscripción activa o de un entitlement heredado (ya no de una compra individual o de un Pack); tocar un mood bloqueado inicia la suscripción; se permite guardar la nota de una entrada con el mismo mood premium aunque no esté desbloqueado.
- `bottom-navigation`: la tercera pestaña se llama Premium y cambia su icono.
- `usage-analytics`: nuevos parámetros `plan` y `source` en eventos de la lista cerrada.
- `watch-mood-picker`: el reloj quita la marca "pendiente" al recibir un estado que no incluye su elección (requisito añadido; este spec existe en `openspec/specs/` solo cuando `add-apple-watch-mood-picker` se archive, y ese archivado va antes que el de este change).

## Impact

- `lib/features/purchases/`: `MoodEntitlementsRepository` pasa de `purchaseMood`/`purchasePack`/ofertas por mood a planes de suscripción, elegibilidad de la prueba y estado de la suscripción; `MoodEntitlementsRepositoryImpl` lee `premium` y los `mood_*` heredados; `PurchasesCubit` y `PurchasesState` se reescriben; `MoodStoreScreen` se convierte en la pantalla Premium y se reutiliza como hoja; se borran `MoodPack`, `MoodOffer`, `mood_purchase_sheet.dart` y `pack_purchase_sheet.dart`. `NoopMoodEntitlementsRepository` se adapta.
- `lib/features/mood/presentation/screens/mood_screen.dart`: abre la hoja Premium al tocar un mood bloqueado y permite guardar la nota cuando el mood no cambia.
- `lib/core/navigation/` y el bottom bar: nombre e icono de la pestaña.
- `lib/core/localization/`: cadenas nuevas de la pantalla y de los planes en los 5 idiomas; se eliminan las de Packs y compras sueltas.
- `lib/core/telemetry/`: allowlist de parámetros y eventos con `plan` y `source`.
- `lib/features/watch/` y `ios/WatchApp/`: descarte y republicación del estado, y retiro de la marca "pendiente"; `docs/watch-sync-contract.md`.
- `site/terms`, `site/es/terms`, `site/privacy`, `site/es/privacy`; `PRODUCT.md`, `CONTEXT.md`, `docs/risks.md`, `docs/adr/0002-*`, `CLAUDE.md`, `backlog.md`.
- RevenueCat (proyecto `projec4184a1`; apps `app9709d48ff4` iOS y `appbf76851644` Android): entitlement, productos y paquetes nuevos. App Store Connect y Play Console: suscripciones, localizaciones, capturas de revisión y ficha.
- Privacidad: sin cambios en App Privacy ni en Data safety (RevenueCat ya recibe el historial de compras); se actualiza solo el texto de la política.
- Pruebas: tests de Dart del repositorio, el cubit y la pantalla; pruebas en dispositivo con sandbox y TestFlight (iOS) y la pista interna (Android), y revisión en iPad y con texto al 200 % en los 5 idiomas antes de `STORE_VERIFIED=1`.
