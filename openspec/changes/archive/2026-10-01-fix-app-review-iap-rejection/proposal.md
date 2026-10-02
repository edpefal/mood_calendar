## Why

Apple rechazó el build (Guideline 2.1(b) — App Completeness) porque, al revisar las compras in-app en sandbox en un iPad Air 11" (iPadOS 27.0), el reviewer vio "un error en la store page" al interactuar con los productos IAP.

**Actualización (2026-10-01, revisión posterior)**: la investigación inicial de este change citó una causa raíz que, al verificarse en vivo contra RevenueCat (que mantiene la App Store Connect API key conectada para este proyecto), resultó estar desactualizada. Se corrige aquí antes de implementar nada sobre la base equivocada:

1. ~~**Productos IAP incompletos en App Store Connect**~~ — **descartada**. La investigación original citaba una nota de `openspec/changes/setup-revenuecat-store-config/tasks.md` (tarea 1.4) que documentaba 5 de 6 productos en `MISSING_METADATA`. Consultado el estado real vía `mcp__revenuecat__get-product-store-state` el 2026-10-01, **los 6 productos** (`mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`) están en `raw_store_status: READY_TO_SUBMIT`, con screenshot de review, pricing y localizaciones completos. El `status: needs_action` que muestra RevenueCat es el estado normal pre-lanzamiento (no indica un problema) mientras ningún build de la app con esos IAP adjuntos haya pasado revisión todavía. Esta causa no explica el rechazo — los productos ya estaban listos.
2. **Build de review potencialmente sin RevenueCat configurado** — **sigue siendo la causa más probable, ahora la única identificada**: `lib/main.dart` solo llama `RevenueCatDatasource.configure(apiKey)` si `REVENUECAT_IOS_API_KEY` llega vía `--dart-define`; si no, la app usa `NoopMoodEntitlementsRepository`, cuyos métodos de compra lanzan `PurchaseException(productUnavailable)` de inmediato (`lib/features/purchases/data/repositories/noop_mood_entitlements_repository.dart`). No existe en el repo ningún Fastfile, script de build ni workflow de CI que inyecte ese dart-define al generar el archive/IPA de distribución (`.github/workflows/` solo tiene `ci.yml` con `flutter analyze`/`flutter test`, y `deploy_android.yml` — ningún workflow de iOS) — nada garantiza hoy que el build subido a Apple lo haya tenido.

Hay que confirmar el estado real del build que se envió a revisión (tarea 2.1) antes de reenviar, y cerrar el hueco de proceso que permite que esto pase sin que nadie lo detecte antes del envío. La sección de App Store Connect (1) pasa de "completar productos" a "confirmar que siguen listos" — trabajo mucho menor al originalmente estimado.

## What Changes

- Confirmar en App Store Connect (vía RevenueCat) que los 6 productos del catálogo (5 moods + 1 pack) siguen en `READY_TO_SUBMIT` — ya verificado una vez el 2026-10-01, pero se re-confirma inmediatamente antes de reenviar por si algo cambió. Ya no requiere completar metadata faltante (ver corrección en "Why").
- Re-confirmar que el Paid Apps Agreement sigue vigente en la sección Business de App Store Connect (ya se había confirmado en `setup-revenuecat-store-config` tarea 1.1, pero el rechazo de Apple lo menciona explícitamente como requisito a confirmar, así que se re-verifica en el contexto de este incidente).
- Documentar explícitamente, en el proceso de build/distribución de iOS (p. ej. en `CLAUDE.md` o en un script versionado), que todo build de archive/release **debe** incluir `--dart-define=REVENUECAT_IOS_API_KEY=<key>`, y dejar constancia de cómo se verifica antes de subir un build a revisión. Hoy ese paso no está escrito en ningún lugar versionado del repo.
- Verificar en sandbox, sobre un build de **release real** (no `flutter run` en debug), el flujo completo de compras: los 5 moods premium individuales, el pack, y restore — antes de volver a enviar a revisión.
- No hay cambios de comportamiento observable del sistema de la app: el modelo de desbloqueo de moods premium (`premium-moods`) ya está correctamente implementado y no cambia. Esto es una corrección operativa (configuración externa en App Store Connect + verificación/documentación del proceso de build), análoga en naturaleza a `setup-revenuecat-store-config`. Por eso el change declara `skip_specs: true` en `.openspec.yaml` y no incluye specs delta.

## Capabilities

### New Capabilities
(ninguna)

### Modified Capabilities
(ninguna — no hay cambios de requisitos de comportamiento; ver justificación de `skip_specs: true` arriba)

## Impact

- App Store Connect: los 6 productos no consumibles existentes (`mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`) y el estado del Paid Apps Agreement.
- Proceso de build/distribución de iOS: documentación (y opcionalmente un script) que asegure que `REVENUECAT_IOS_API_KEY` se pasa en todo build de archive/release.
- `CLAUDE.md` u otro doc de proceso, si se decide documentar ahí el paso de build.
- Ningún archivo de código Dart bajo `lib/` cambia como parte de este change.
