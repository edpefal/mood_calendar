## Context

Ver `proposal.md` — "Why" para la causa raíz completa y su corrección. **Actualización 2026-10-01**: se verificó en vivo vía RevenueCat (`get-product-store-state` sobre los 6 productos) que los 6 productos del catálogo están en `READY_TO_SUBMIT` con screenshot, pricing y localizaciones completos — la causa de "productos incompletos" citada originalmente ya no aplica, probablemente porque se resolvió entre que se escribió la nota en `setup-revenuecat-store-config/tasks.md` y hoy, sin que quedara registrado. La única causa que queda en pie:

- Proceso de build: `lib/main.dart` lee `REVENUECAT_IOS_API_KEY` vía `String.fromEnvironment`, que solo tiene valor si se pasó `--dart-define` en el comando de build. No hay ningún Fastfile/script/CI versionado que lo garantice para builds de archive (`flutter build ipa` / Xcode Archive) — confirmado que `.github/workflows/` no tiene ningún workflow de build/deploy de iOS. Si falta, la app usa `NoopMoodEntitlementsRepository` y toda compra falla con `productUnavailable`.

Este change no toca código de `lib/` — es trabajo de confirmación de configuración externa (App Store Connect, ya resuelta) más un cambio de proceso/documentación para el build de iOS (la parte que queda pendiente).

**Mecanismo concreto que conecta la causa con el síntoma reportado por Apple**: en `lib/features/purchases/presentation/screens/mood_store_screen.dart`, si `PurchasesCubit.loadCatalog()` captura una excepción, `state.catalogError` queda no-nulo y la pantalla de tienda muestra únicamente `strings.storeLoadError` en vez del catálogo — literalmente "un error en la store page". Si el build revisado no tenía el dart-define, `NoopMoodEntitlementsRepository.availableMoodOffers()`/`availablePacks()` devuelven listas vacías (no lanzan excepción), por lo que la UI mostraría los textos de catálogo vacío (`storeEmptyMoods`/`storeEmptyPacks`), no `storeLoadError` — una distinción visual que la tarea 3.5 debe usar para diagnosticar cuál mecanismo se está reproduciendo si el problema persiste.

## Goals / Non-Goals

**Goals:**
- Re-confirmar que los 6 productos IAP del catálogo siguen en estado válido para sandbox y revisión (`Ready to Submit` o equivalente) — ya verificado el 2026-10-01.
- Cerrar la brecha de proceso que permite subir un build de archive sin `REVENUECAT_IOS_API_KEY`, mediante documentación explícita y verificación manual repetible.
- Confirmar que no hay un problema adicional de acuerdo legal (Paid Apps Agreement) antes de reenviar.
- Verificar en sandbox, sobre un build de release real, que el flujo de compra ya no produce ningún error antes de reenviar a Apple.

**Non-Goals:**
- No se modifica el modelo de desbloqueo de moods premium ni ningún código bajo `lib/features/purchases` o `lib/features/mood` — ya está correctamente implementado (ver `premium-moods` spec y el change archivado `add-mood-in-app-purchases`).
- No se automatiza el build de iOS con CI/Fastlane en este change (sería un cambio de infraestructura más grande); aquí solo se documenta y verifica manualmente el paso que falta.
- No se crean productos IAP nuevos ni se cambia el modelo de precios/packs existente.

## Decisions

### 1. Re-confirmar el estado de productos antes de asumir que el dart-define es la única causa restante
La investigación original trató "productos incompletos" y "dart-define faltante" como dos causas independientes a resolver en paralelo. La verificación en vivo (2026-10-01) mostró que los productos ya están listos, así que esa causa queda descartada — pero el change igual incluye una tarea de re-confirmación inmediatamente antes de reenviar (en vez de asumir que el estado verificado hoy seguirá igual sin cambios), ya que es una verificación barata y el estado de App Store Connect puede cambiar.

**Alternativa considerada**: confiar en la verificación de hoy y no volver a chequear antes de reenviar. Se descarta porque el costo de re-verificar es mínimo comparado con el de otro rechazo por la misma causa.

### 2. Documentar el paso de `--dart-define` en vez de automatizarlo con Fastlane/CI en este change
Automatizar con Fastlane o un workflow de GitHub Actions que firme y suba el archive sería la solución robusta a largo plazo, pero es un cambio de infraestructura considerablemente más grande (gestión de secretos del API key de RevenueCat, certificados de firma, etc.) y no es necesario para resolver el rechazo actual. Para este change basta con que el paso quede documentado de forma explícita y verificable (p. ej. un checklist en `CLAUDE.md` o un comentario fijado en el flujo de release) para que no se repita el olvido.

**Alternativa considerada**: crear ya un script `scripts/build_release.sh` que siempre incluya el dart-define. Se deja como posible follow-up, no bloqueante para resolver el rechazo — documentarlo ahora, evaluar el script en un change futuro si el proceso manual sigue fallando.

### 3. Verificar en un build de release real, no en `flutter run` debug
El bug de la API key faltante solo se manifiesta en el tipo de build que realmente se sube a Apple (`flutter build ipa` o Archive desde Xcode), porque `flutter run` normalmente se ejecuta con el dart-define pasado a mano por el desarrollador día a día. La verificación de sandbox de este change debe hacerse explícitamente sobre un IPA/archive generado de la misma forma que se generaría para reenviar a revisión.

## Risks / Trade-offs

- [Riesgo] Subir los screenshots de App Store Review a los 5 productos pendientes y volver a validar toma tiempo de revisión por parte de Apple (los metadatos de producto no se validan instantáneamente) → Mitigación: completar esta tarea cuanto antes, en paralelo con la verificación del proceso de build, para no bloquear secuencialmente el reenvío.
- [Riesgo] Documentar el paso de `--dart-define` sin automatizarlo deja la puerta abierta a que alguien vuelva a olvidarlo en un futuro build manual → Mitigación: dejar explícitamente anotado en tasks.md un follow-up sugerido (script de build o CI) si se repite el problema; no se bloquea este change por eso.
- [Riesgo] Confirmar el Paid Apps Agreement requiere acceso a la sección Business de App Store Connect, que no está disponible vía ninguna herramienta conectada en este entorno → Mitigación: se marca explícitamente en tasks.md como acción manual del dueño de la cuenta. (El estado de productos sí es verificable por el agente vía el MCP de RevenueCat, que ya tiene la App Store Connect API key conectada — usado para la re-confirmación de la tarea 1.1; no requiere credenciales nuevas del usuario.)

## Migration Plan

No aplica migración de datos ni despliegue de código. El "rollout" de este change es: completar configuración externa → verificar en sandbox con build de release → reenviar a revisión de Apple. No hay rollback de código porque no se modifica código de la app.
