## Why

Hoy la app solo ofrece 5 moods gratuitos y no tiene ningún mecanismo de monetización. Ya existen 5 íconos de moods adicionales sin usar en `assets/icon/` (anxious, brave, confident, romantic, shy). Se decidió venderlos como moods premium — individuales y en packs con descuento — usando RevenueCat, sentando las bases de un catálogo que seguirá creciendo con el tiempo.

## What Changes

- Agregar el concepto de `tier` (`base` | `premium`) a la definición de un Mood en el catálogo.
- Introducir el estado `unlocked` por usuario: todo Mood `base` está unlocked para cualquiera; un Mood `premium` solo si fue comprado (individual o vía Pack). `unlocked` nunca reescribe entradas históricas ya guardadas (ver ADR 0001/0002 y `CONTEXT.md`).
- Integrar RevenueCat (`purchases_flutter`) para compras no consumibles de pago único — sin suscripciones, sin trials/regalos en v1. Solo iOS en esta entrega; la arquitectura no debe bloquear agregar Android después.
- El carrusel de selección diaria (`mood_screen.dart`) muestra todos los moods (base + premium), con candado visual en los bloqueados; tocar uno bloqueado abre el flujo de compra de ese mood específico.
- Nueva pantalla de Tienda: catálogo completo de moods premium y packs, compra individual o por pack, aviso (no bloqueo) si el usuario ya tiene desbloqueado algún mood del pack que está por comprar, y botón de restaurar compras.
- Los packs son bundles con descuento, de composición fija al crearse (no se les agregan/quitan moods después); qué moods componen cada pack y su precio se configuran en RevenueCat, no en el código.
- **BREAKING (dominio, no de datos)**: `intensity` deja de representar valencia emocional y pasa a ser un identificador interno sin orden de "mejor/peor". El resumen mensual reemplaza el promedio (`averageScore`/`representativeAverageEntry`) por el mood más frecuente del mes (moda, desempate por fecha más reciente). No requiere migración de datos: los `MoodEntry` existentes conservan su `intensity` tal cual.

## Capabilities

### New Capabilities
- `premium-moods`: catálogo de moods con tier base/premium, estado de desbloqueo por usuario, y su reflejo en el carrusel de selección diaria (candado en bloqueados, bloqueo de selección para crear/editar una entrada con un mood no desbloqueado).
- `mood-store`: pantalla de Tienda — listar catálogo premium y packs, comprar individual o por pack vía RevenueCat, aviso de solape antes de comprar un pack, restaurar compras.

### Modified Capabilities
- `monthly-mood-summary`: el resumen mensual ya no muestra un promedio numérico ni un "mood representativo" calculado por cercanía al promedio; muestra el mood más frecuente del mes (moda), con desempate por fecha de registro más reciente.

## Impact

- `lib/features/mood/domain/entities/mood_definition.dart` — agregar `tier`; redefinir `freeMoodDefinitions`/`allMoodDefinitions` para incluir el catálogo premium.
- `lib/features/mood/domain/services/mood_definition_resolver.dart` — ajustar resolutores que asumían una escala 1–5 (`moodPathForScore`, `backgroundGradientForMood`).
- Nuevas entidades/repositorio de dominio para `Unlocked` (por Mood) y `Purchase`/`Pack` (catálogo comprable).
- `lib/features/mood/domain/entities/monthly_mood_summary.dart` y `get_monthly_mood_summary_usecase.dart` — reemplazar `averageScore`/`representativeAverageEntry` por `mostCommonMoodEntry` (o similar).
- `lib/features/mood/presentation/widgets/monthly_mood_summary_card.dart` — actualizar al nuevo dato (mismo layout).
- `lib/features/mood/presentation/screens/mood_screen.dart` — candado visual y bloqueo de selección para moods no desbloqueados.
- Nueva pantalla de Tienda (presentation) y su Cubit.
- `pubspec.yaml` — agregar `purchases_flutter`.
- `lib/core/localization/*` — nuevos strings de Tienda/paywall en los 5 idiomas (en, es, de, fr, it).
- `openspec/specs/monthly-mood-summary/spec.md` — actualizar requisitos.
- Sin migración de datos en Hive: `MoodModel.intensity` conserva su tipo y valores actuales.
