## Context

Motivación y alcance en `proposal.md`; requisitos en `specs/`. Estado actual relevante:

- `MoodEntitlementsRepositoryImpl` (`lib/features/purchases/data/repositories/`) traduce los entitlements activos de RevenueCat con prefijo `mood_` a un `Set<String>` de ids y lo expone con `unlockedPremiumMoodIds()` (replay del estado actual + stream) e `isUnlocked(id)`. **Todo lo demás consume solo eso**: el selector (`MoodScreen`, `MoodPickerOrder`), el reloj (`PublishWatchStateUseCase`, `ProcessWatchInboxUseCase`) y `PurchasesCubit`. La API de compra (`purchaseMood`, `purchasePack`, `availableMoodOffers`, `availablePacks`) solo la usan `PurchasesCubit` y las dos hojas de compra.
- RevenueCat (proyecto `projec4184a1`): oferta `default` (la actual) con 18 paquetes `$rc_custom_mood_*`/`$rc_custom_pack_*` y la composición de los Packs en su `metadata`; 14 entitlements `mood_<id>`. Las apps iOS (`app9709d48ff4`, con clave de suscripciones ya configurada) y Android (`appbf76851644`) comparten ids. No hay grupos de suscripción ni compras reales.
- Las versiones 1.8.x y 1.9.0 seguirán instaladas tras publicar la 1.10.0: leen `offerings.current` y filtran por prefijo, así que cualquier paquete nuevo en `default` les es invisible, pero una oferta nueva como actual les dejaría la tienda vacía.
- `purchases_flutter` ^10.13.2 (soporta opciones de suscripción en Android y `checkTrialOrIntroductoryPriceEligibility` en iOS).
- Hoy `MoodScreen` abre `showMoodPurchaseSheet` en tres sitios (mood bloqueado seleccionado, hoja de cuadrícula y Guardar con mood bloqueado, `mood_screen.dart:~249/296/312`).

## Goals / Non-Goals

**Goals:**
- Cambiar el modelo de monetización tocando lo mínimo fuera de `features/purchases`: el contrato `unlockedPremiumMoodIds()`/`isUnlocked()` se conserva.
- Que ningún usuario con una compra heredada pierda lo pagado, y que las apps 1.8.x/1.9.0 sigan funcionando mientras existan.
- Que los precios, la prueba gratis y la elegibilidad vengan siempre de la tienda, nunca del código.

**Non-Goals:**
- Plan vitalicio, ofertas promocionales o de reconquista, Compartir en Familia, paywalls o experimentos de RevenueCat, avisos in-app de vencimiento o reintento de cobro.
- Validación de recibos en un backend propio (sigue valiendo `docs/risks.md`: RevenueCat actúa de fuente de verdad).
- Renombrar los eventos de analíticas existentes.

## Decisions

### D1. Un entitlement `premium` + lectura de los `mood_*` heredados
`_applyCustomerInfo` calcula: si `premium` está activo, el conjunto desbloqueado es **todos** los ids premium del catálogo (`allMoodDefinitions` con `tier == premium`); si no, los ids de los entitlements `mood_*` activos como hoy. El repositorio deja de ser un simple mapeo de prefijo, pero `unlockedPremiumMoodIds()` sigue siendo `Stream<Set<String>>`, así que el selector, el orden y el reloj no cambian.
- *Alternativa*: un entitlement por mood adjuntado a los productos nuevos. Descartada: cada mood nuevo exigiría tocar RevenueCat, y desaparece el motivo de la suscripción.
- Un mood premium que se añada al catálogo queda desbloqueado para suscriptores sin tocar RevenueCat.

### D2. API del dominio
`MoodEntitlementsRepository` pierde `purchaseMood`, `purchasePack`, `availableMoodOffers` y `availablePacks`, y gana:
- `Future<List<SubscriptionPlan>> availablePlans()` — para cada `PackageType` (`weekly`, `monthly`, `annual`) de la oferta `default`: plan, id de producto, precio mostrado, precio numérico (para calcular el ahorro), moneda y `isTrialEligible`.
- `Future<void> purchasePlan(SubscriptionPlanType plan)`.
- `Stream<SubscriptionStatus> subscriptionStatus()` con `isActive`, plan actual, `expiresAt`/`renewsAt`, `isInTrial`, `willRenew` y la URL de gestión (`managementURL` de `CustomerInfo`, con fallback a la URL de suscripciones de cada tienda).
- `restorePurchases()` sin cambios.
Los paquetes se buscan por `PackageType`, no por `lookup_key` personalizado: las claves `$rc_weekly`, `$rc_monthly` y `$rc_annual` son las estándar. `PurchaseException`/`PurchaseFailureReason` se conservan.
- *Ahorro*: `1 − precioAnual / (12 × precioMensual)`, redondeado al entero, calculado con los precios numéricos de la tienda (con $2.99 y $14.99 da 58 %). Si falta algún precio, la etiqueta "Mejor valor" se muestra sin porcentaje.

### D3. Elegibilidad de la prueba
En iOS, `checkTrialOrIntroductoryPriceEligibility` sobre los productos del grupo; la elegibilidad es por Apple ID y grupo, así que es la misma para los tres planes. En Android, Play solo devuelve las ofertas para las que el usuario es elegible: hay oferta con prueba en la opción de suscripción ⇒ elegible. Cualquier error, estado desconocido o falta de la oferta ⇒ no elegible (el botón dice "Suscribirme"). La compra usa la opción por defecto del paquete, de modo que la tienda aplica la prueba por sí misma; la UI solo decide qué texto muestra.
- *Riesgo*: la API de elegibilidad de Android no equivale a la de iOS; **se verifica en la pista interna** antes de enviar.

### D4. Una sola pantalla, dos presentaciones
`MoodStoreScreen` se reescribe como `PremiumScreen` (pestaña) sobre un widget interno `PremiumPlansView` que también usa `showPremiumSheet(context, source: ...)` (hoja modal que cubre el bottom bar). Estados: cargando, error con reintentar (se conserva la recuperación vigente), planes, suscrito. El `PurchasesCubit` se reescribe en torno a `SubscriptionPlan`/`SubscriptionStatus` y conserva `unlockedMoodIds`, `actionStatus` y `restorePurchases`. Los textos legales y las cadenas viven en `AppStrings` (5 idiomas); el ancho de contenido se limita como en el resto de pantallas para iPad.

### D5. Guardar con un mood bloqueado
Un caso de uso/función pura `canSaveWithMood(existingEntry, selectedMood, isUnlocked)` decide: guardar si el mood está desbloqueado **o** si la entrada existente de esa fecha tiene ese mismo mood. `MoodScreen` la llama antes de guardar y, si no se puede, abre `showPremiumSheet(source: lockedMood)`. Los otros dos sitios (mood seleccionado y hoja de cuadrícula) pasan a abrir la misma hoja. Se prueba con tests unitarios y de widget; el spec `premium-moods` define los casos.

### D6. Analíticas
Se conservan los nombres de evento (`store_opened`, `purchase_started`, `purchase_completed`…) para no romper la serie histórica en Firebase; en el spec se llaman "abrir Premium" y "suscripción iniciada/completada". `analyticsParameterAllowlist` pasa a `{'has_note', 'source', 'plan'}`. `PurchasesCubit` envía `source` (`tab` o `locked_mood`) y `plan` (`weekly`, `monthly`, `annual`). Ningún parámetro lleva ids de moods; `blockedContextKeys` no cambia.

### D7. Reloj
Para que el reloj sepa que su elección ya fue procesada (aplicada o descartada) el estado que publica el iPhone gana un campo aditivo `handledChoiceIds` (ids de las elecciones procesadas desde la última publicación, acotado a las últimas 20). `ProcessWatchInboxUseCase` ya descarta y confirma las elecciones con mood bloqueado; ahora, si procesó alguna, fuerza una publicación. El reloj (`WatchModel`) elimina su marca pendiente cuando el id de su elección aparece en `handledChoiceIds` (además de las reglas actuales: el mood coincide con hoy o cambia el día). El campo es opcional, así que no sube `version` y un estado viejo sigue siendo válido. `docs/watch-sync-contract.md` y el spec `watch-mood-picker` se actualizan.
- *Alternativa*: quitar la marca al recibir cualquier estado. Descartada: un cambio de idioma o una compra mientras la elección sigue en cola la borraría antes de tiempo.

### D8. Productos, ofertas y entitlement en las tiendas
- **iOS (App Store Connect)**: grupo "Mood Calendar Premium"; suscripciones `premium_weekly` (1 semana), `premium_monthly` (1 mes) y `premium_annual` (1 año), con orden de niveles anual > mensual > semanal; precio base USD $0.99 / $2.99 / $14.99 con equivalencias automáticas por territorio; oferta de introducción gratis de 3 días en las tres para clientes nuevos; nombre y descripción visibles en los 5 idiomas; captura de revisión de la pantalla Premium. Compartir en Familia desactivado.
- **Android (Play Console)**: suscripción `premium` con planes base `weekly`, `monthly` y `annual` (renovación automática, mismo precio base) y una oferta de prueba gratis de 3 días para clientes nuevos en cada uno. En RevenueCat los productos de Android se registran como `premium:weekly`, `premium:monthly` y `premium:annual` (`<suscripción>:<plan base>`).
- **RevenueCat**: productos importados en las dos apps, entitlement `premium` con los 6 productos adjuntos y los paquetes `$rc_weekly`, `$rc_monthly`, `$rc_annual` añadidos a `default` (los 18 paquetes viejos se quedan hasta retirarlos de la venta).
- Se hace por API y paso a paso con confirmación del usuario. En Play, la ubicación de las credenciales la indica el usuario; la app nunca las busca. La versión de producción de Play se confirma a mano.

### D9. Retirada de los productos heredados
Solo después de publicada la 1.10.0: retirar de la venta los 18 productos (iOS: quitar de la venta; Play: desactivar) y quitar los 18 paquetes de `default`. Los entitlements `mood_*` y los productos se conservan en RevenueCat para restaurar. Este paso es una tarea del change, no del código.

### D10. Sitio y textos legales
`site/terms` y `site/es/terms` reescriben la sección 3 (suscripción, renovación automática, prueba, cancelación en los ajustes de la tienda, reembolsos por Apple/Google, compras anteriores). `site/privacy` y `site/es/privacy` cambian "compras de moods premium" por "compras y suscripción". Las páginas llevan fecha de última actualización. La pantalla enlaza a esas URLs según el idioma del dispositivo.

### D11. Limpieza
Se borran `MoodPack`, `MoodOffer`, `mood_purchase_sheet.dart`, `pack_purchase_sheet.dart`, `packNames`/`packName`, `packIncludesMoods`, `buyPackButtonLabel`, `packOverlap*` y las cadenas de Tienda sin uso en los 5 idiomas, y los tests asociados. El ADR 0002 se marca "Reemplazado" con una nota; `CONTEXT.md` retira/anota Pack y Purchase; `docs/risks.md` añade el riesgo de caducidad offline.

## Risks / Trade-offs

- [App Review cuestiona el valor continuo de una suscripción para moods visuales (3.1.2)] → Notas para el revisor con la ruta a la pantalla, descripción clara de lo que se desbloquea y del catálogo que crece; sin promesas de funciones que no existen.
- [Rechazo por información de suscripción incompleta o enlaces rotos] → Texto legal con nombre, duración, precio y renovación; enlaces a Términos y Privacidad ya publicados; verificación en el simulador y en TestFlight antes de enviar.
- [La primera suscripción debe enviarse junto con un binario] → Se crea en App Store Connect antes de enviar la 1.10.0 y se adjunta a esa versión.
- [Quien se suscribe en un dispositivo con 1.8.x/1.9.0 no ve desbloqueos] → Esas versiones solo leen `mood_*`; el usuario debe actualizar. Aceptado: la tienda de esas versiones sigue vendiendo lo antiguo y no promociona la suscripción.
- [Elegibilidad de la prueba distinta en Android] → Se verifica en la pista interna; ante duda el botón no menciona la prueba.
- [El mensual ($2.99) supera el costo de comprar todo ($0.99 × 14 ≈ $13.86 o 4 Packs ≈ $8) en pocos meses] → Se acepta: con 0 compras reales no hay clientes que comparar. El anual ($14.99) es el plan principal; los precios se pueden cambiar en las tiendas sin tocar código.
- [Caducidad offline] → RevenueCat cachea `CustomerInfo` y evalúa la caducidad con fechas firmadas; sin red, el estado puede ser el último conocido. Riesgo aceptado, anotado en `docs/risks.md`.
- [Reembolsos y fallos de pago] → El entitlement se desactiva por la notificación de la tienda a RevenueCat; en Play, las notificaciones en tiempo real (RTDN) siguen pendientes en el backlog y sin ellas la actualización puede tardar.
- [La prueba de 3 días en un plan semanal casi iguala el ciclo] → Apple concede una sola oferta de introducción por grupo y Apple ID; en Play se limita a clientes nuevos.

## Migration Plan

1. Terminar y publicar la 1.9.0 (reloj); archivar `add-apple-watch-mood-picker`. Este change se implementa **después**, sobre `main`.
2. Crear los productos, el entitlement y los paquetes (D8). Añadirlos a `default` no afecta a las apps instaladas.
3. Implementar la app (repositorio, cubit, pantalla, MoodScreen, reloj, analíticas, cadenas, sitio y documentos), con tests de Dart y de Swift.
4. Probar según el spec/tasks: sandbox + TestFlight (iOS), pista interna (Android), iPad y texto al 200 % en los 5 idiomas.
5. Construir con `scripts/build_ios_release.sh` y `scripts/build_android_release.sh` (`STORE_VERIFIED=1` solo tras las pruebas), subir la versión 1.10.0 con el párrafo de suscripción y las notas para el revisor, y enviar a revisión.
6. Con la 1.10.0 publicada: retirar de la venta los 18 productos viejos y sus paquetes de `default` (D9); actualizar `CLAUDE.md`, `backlog.md` y archivar el change.
- *Rollback*: si Apple rechaza, la 1.9.0 sigue publicada con el modelo anterior y nada en las tiendas la afecta (los productos nuevos son aditivos). Un fallo en producción se mitiga retirando los paquetes nuevos de `default`: las apps nuevas mostrarían el error con reintentar y las viejas no cambian.

## Open Questions

- Versión y build exactos (`1.10.0+N`): dependen de cuántos builds se hayan subido para la 1.9.0.
- Si la landing debe mencionar la suscripción más adelante (hoy se decidió que no).
