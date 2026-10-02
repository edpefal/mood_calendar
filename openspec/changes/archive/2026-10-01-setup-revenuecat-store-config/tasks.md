## 1. App Store Connect

- [x] 1.1 Completar acuerdos/impuestos/banca necesarios para vender productos in-app (si no está hecho ya) — confirmado: la cuenta ya vende otras apps/productos, agreements ya vigentes
- [x] 1.2 Crear un producto no consumible por cada Mood premium inicial vía App Store Connect API: `mood_anxious_unlock` (6815908320), `mood_brave_unlock` (6815908840), `mood_confident_unlock` (6815908811), `mood_romantic_unlock` (6815909155); `mood_shy_unlock` (6761625058) ya existía de una prueba anterior y se reutiliza como el producto real de "shy"
- [x] 1.3 Crear el producto no consumible del primer Pack de prueba: `pack_confianza_unlock` (6815908784) — agrupa brave + confident + romantic
- [x] 1.4 Completar precio y localización (en-US + es-MX) de cada producto: los 5 moods individuales a $0.99 USD, el pack a $1.99 USD (descuento frente a $2.97 comprando los 3 sueltos)

> Pendiente antes de enviar a review real (no bloquea sandbox/RevenueCat): los 4 productos nuevos y el pack quedaron en estado `MISSING_METADATA` porque les falta el screenshot de App Store Review — `mood_shy_unlock` sí lo tiene y por eso está en `READY_TO_SUBMIT`. Subir un screenshot de la Tienda una vez que exista esa pantalla en la app.

## 2. RevenueCat — proyecto y conexión

- [x] 2.1 Crear el proyecto de la app en RevenueCat — proyecto "Mood Calendar" (`projec4184a1`) con app iOS "Mood Calendar iOS" (`app9709d48ff4`, bundle `com.artlab.moodcalendar`) ya creados
- [x] 2.2 Conectar el proyecto con App Store Connect (API key / In-App Purchase Key de App Store Connect) — credenciales configuradas y validadas (`app_store_connect_key` y `app_store_subscriptions_key` ambas `valid`)
- [x] 2.3 Importar/sincronizar en RevenueCat los productos creados en el paso 1 — los 6 productos (`mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`) registrados como `non_consumable` en el app `app9709d48ff4`

## 3. RevenueCat — entitlements y packs

- [x] 3.1 Crear un entitlement por cada Mood premium, con identificador igual al `moodId` (ej. entitlement `mood_confident` para el mood `confident`) — creados `mood_anxious`, `mood_brave`, `mood_confident`, `mood_romantic`, `mood_shy`
- [x] 3.2 Adjuntar cada producto individual a su entitlement correspondiente
- [x] 3.3 Adjuntar el producto del Pack de prueba (`pack_confianza_unlock`) a los entitlements de sus moods miembro (`mood_brave`, `mood_confident`, `mood_romantic`) — verificado con `get-products-from-entitlement`
- [x] 3.4 Revisar si se puede adjuntar metadata al Offering/Package con la lista de `moodIds` del pack — **hallazgo**: la API de RevenueCat solo soporta `metadata` a nivel de Offering, no de Package (`create-packages`/`attach-products-to-package` no tienen ese campo). Se agregó `metadata: { pack_confianza_moodIds: ["brave","confident","romantic"] }` en el Offering "default" como workaround; la tarea 1.4 de `add-mood-in-app-purchases` debe leer los moodIds del pack desde ahí (o resolverlos por convención de producto) en vez de esperarlos en el Package
- [x] 3.5 Crear un Offering con el producto individual y el Pack de prueba, y marcarlo como "current" — Offering "default" (`ofrngbb6b5aded8`, `is_current: true`) con 6 packages: uno por cada mood individual y uno para `pack_confianza_unlock`

## 4. Entrega a desarrollo

- [x] 4.1 Obtener la API key **pública** de RevenueCat para iOS (no la secreta) y compartirla de forma segura para configurarla en la app (tarea 1.5 de `add-mood-in-app-purchases`) — key pública (entorno `production`): `appl_PqUaOfVljJyegpVDjMkhHroCQHf` (es una SDK key pensada para ir embebida en el cliente, no es secreta; aun así configurarla vía `--dart-define`/env var, no hardcodeada, por consistencia con el resto del proyecto)
- [x] 4.2 Confirmar que existe al menos un tester sandbox de App Store Connect para poder probar compras sin cobro real — confirmado por el usuario: ya existe un tester sandbox configurado
