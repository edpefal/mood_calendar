## Context

Ver `proposal.md` para el motivo. Puntos técnicos relevantes que acotan el diseño:

- El proyecto sigue Clean Architecture con **una sola feature** (`mood`) hoy; no hay service locator ni framework de DI — todo el wiring se hace a mano en `main.dart` (constructor injection directo hacia los `BlocProvider`).
- No hay backend; toda la persistencia es Hive local con el patrón simple de `Box<dynamic>` visto en `AppSettingsLocalDataSource`.
- `MoodModel` (Hive) persiste `intensity` como `int` por entrada; no cambia de tipo ni requiere migración (ver ADR 0001 — `intensity` pasa a ser un identificador puro, pero el dato ya guardado sigue siendo válido tal cual).
- Ya se documentó el vocabulario del dominio (`Mood`, `Tier`, `Unlocked`, `Purchase`, `Pack`, `Most Common Mood`) en `CONTEXT.md`, y las decisiones irreversibles en `docs/adr/0001-intensity-is-not-valence.md` y `docs/adr/0002-pack-composition-is-frozen.md`.

## Goals / Non-Goals

**Goals:**
- Modelar `Unlocked` y `Purchase`/`Pack` como conceptos independientes de `Mood`, para no acoplar el catálogo de moods a los detalles de RevenueCat.
- Que agregar/reconfigurar un Pack (composición, precio) no requiera cambios de código, solo configuración en RevenueCat — según lo acordado en la sesión de grilling.
- Reusar el patrón de capas (domain/data/presentation) ya establecido por la feature `mood`.

**Non-Goals:**
- Soporte de Android (se deja para una fase posterior; el diseño no debe bloquearlo, pero no se implementa aquí).
- Suscripciones, trials o regalos promocionales.
- Rediseño visual de `MonthlyMoodSummaryCard` o de `backgroundGradientForMood` más allá de lo estrictamente necesario para reflejar el nuevo dato de "mood más frecuente".
- Asignar gradientes/colores específicos a los nuevos moods premium (usan el `default` de `backgroundGradientForMood` tal como ya ocurre hoy).

## Decisions

### 1. Nueva feature `purchases`, separada de `mood`
Se introduce `lib/features/purchases/` como segunda feature del proyecto, en vez de meter el catálogo de compras dentro de `mood/`. Motivo: `purchases` encapsula un límite externo real (RevenueCat) con su propio ciclo de vida (compras, restore, listeners de `CustomerInfo`), mientras que `mood` es puramente local/Hive. Mezclar ambos en una sola feature acoplaría el modelo de entradas diarias a un SDK externo.

Dirección de dependencia (una sola vía, sin ciclos):
- `purchases/domain` lee ids de moods premium desde `mood/domain` (catálogo), nunca al revés.
- `mood/presentation` depende de `purchases/domain` (la interfaz `MoodEntitlementsRepository`) para saber si un mood está `unlocked` y para lanzar el flujo de compra — nunca importa nada de `purchases/data` (RevenueCat) directamente.

**Alternativa considerada**: meter todo en `mood/`. Se descartó porque el proyecto ya tiene precedente de una sola feature por una razón (app pequeña); pero mezclar un SDK de pagos externo con el modelo de datos local rompe esa cohesión — es el primer límite natural para separar.

### 2. `MoodDefinition` gana `tier`; se elimina la relación intensity↔valencia
```
enum MoodTier { base, premium }

class MoodDefinition {
  final String id;
  final String label;
  final String assetPath;
  final Color color;
  final int intensity; // identificador interno, ver ADR 0001 — no ordenar/comparar por este valor
  final MoodTier tier;
}
```
`freeMoodDefinitions` se renombra a `baseMoodDefinitions` (tier `base`); se agrega `premiumMoodDefinitions` (tier `premium`, arranca con los 5 assets ya existentes: anxious, brave, confident, romantic, shy). `allMoodDefinitions = [...baseMoodDefinitions, ...premiumMoodDefinitions]` deja de ser un alias y pasa a ser la unión real.

`MoodDefinitionResolver.moodPathForScore` se elimina: dependía de `averageScore`, que ya no existe (ver decisión 4). No tiene otros llamadores fuera de `monthly_mood_summary_card.dart`.

### 3. `Unlocked` vive en `purchases/domain`, no en `MoodDefinition`
`MoodDefinition` describe el catálogo (igual para todos los usuarios); `unlocked` es estado por usuario, así que no es un campo de `MoodDefinition` sino una consulta expuesta por `purchases/domain`:

```
abstract class MoodEntitlementsRepository {
  bool isUnlocked(String moodId);
  Stream<Set<String>> unlockedPremiumMoodIds(); // para reaccionar a compras/restore en vivo
  Future<List<MoodOffer>> availableMoodOffers();   // compras individuales
  Future<List<MoodPack>> availablePacks();         // packs, con su composición ya resuelta
  Future<void> purchaseMood(String moodId);
  Future<void> purchasePack(String packId);
  Future<void> restorePurchases();
}
```
`isUnlocked` SHALL devolver `true` de inmediato para cualquier mood `base`, sin consultar RevenueCat.

### 4. Mapeo con RevenueCat: un entitlement por Mood premium
Cada Mood premium se mapea 1:1 a un **entitlement** de RevenueCat identificado por su `moodId` (ej. entitlement `mood_confident`). Un producto de compra individual otorga un solo entitlement; un producto de Pack se configura en RevenueCat para otorgar varios entitlements a la vez (los de sus moods miembro) — esta relación producto→entitlements vive enteramente en el dashboard de RevenueCat, nunca en código Dart. Esto es lo que permite cumplir la decisión de grilling: reconfigurar qué moods forman un pack, o lanzar un pack nuevo con moods ya existentes, sin release de la app.

`isUnlocked(moodId)` para un mood premium se resuelve como `customerInfo.entitlements.active.containsKey('mood_' + moodId)` — el identificador del entitlement en RevenueCat lleva el prefijo `mood_` (ver `setup-revenuecat-store-config` 3.1), no es igual al `moodId` crudo. El prefijo se despoja dentro de `MoodEntitlementsRepositoryImpl` y nunca sale de la capa de datos: el resto de la app (domain/presentation) solo maneja `moodId`s planos.

La composición visible de un Pack (qué moods incluye, para mostrarlo en la Tienda y calcular el aviso de solape) se obtiene de los metadatos del `Offering`/`Package` de RevenueCat (campo de metadata configurable por dashboard), no de una lista hardcodeada en Dart — de lo contrario el código quedaría desincronizado en cuanto alguien reconfigure un pack. **Se deja como pregunta abierta la verificación exacta de la API de `purchases_flutter` para leer esos metadatos** (ver Open Questions).

### 5. Sin caché propia en Hive para entitlements
El SDK de RevenueCat ya persiste `CustomerInfo` localmente y funciona offline tras el primer fetch exitoso; no se agrega una copia redundante en un Hive Box propio (evita tener dos fuentes de verdad para lo mismo). `MoodEntitlementsRepositoryImpl` expone un `Stream` respaldado por `Purchases.addCustomerInfoUpdateListener`, y el estado en memoria del `PurchasesCubit` es lo que consume la UI.

**Alternativa considerada**: mirror local en Hive del set de moods desbloqueados, igual al patrón de `AppSettingsLocalDataSource`. Se descartó por redundancia — RevenueCat ya resuelve el caso offline, y mantener dos copias sincronizadas agrega complejidad sin beneficio claro para esta app.

### 6. `MonthlyMoodSummary` reemplaza promedio por moda
```
class MonthlyMoodSummary {
  final DateTime month;
  final List<MoodEntry> entries;
  final MoodEntry? mostCommonMoodEntry; // reemplaza averageScore + representativeAverageEntry
  final int bestStreak;
  final MoodEntry? lastEntry;
}
```
`GetMonthlyMoodSummaryUseCase` agrupa `entries` por `mood` (assetPath/id), cuenta ocurrencias, y entre los moods con el conteo máximo elige la entrada cuyo `date` sea más reciente (mismo criterio de desempate que ya usaba `_resolveRepresentativeAverageEntry`, por consistencia con el comportamiento actual). `bestStreak` no cambia.

## Risks / Trade-offs

- [Verificación tardía de la API de metadata de RevenueCat para composición de Packs] → Se resuelve como primera tarea técnica del change, antes de construir la pantalla de Tienda; si `purchases_flutter` no expone metadata de forma conveniente, el fallback es una lista de packs mínima en código (rompiendo parcialmente la decisión de "sin release para reconfigurar packs", pero solo para su composición visible — el otorgamiento de entitlements seguiría siendo remoto).
- [Doble mantenimiento de ids] → El `moodId` debe coincidir exactamente entre `MoodDefinition.id` (Dart) y el entitlement identifier (RevenueCat dashboard); un typo rompe el desbloqueo silenciosamente. Mitigación: un test que verifique que todo `premiumMoodDefinitions.map((m) => m.id)` tiene un entitlement esperado, más un chequeo defensivo (loggear si `isUnlocked` no encuentra el entitlement esperado en `customerInfo.entitlements.all`).
- [Solo iOS en esta entrega] → La interfaz `MoodEntitlementsRepository` y el modelo de dominio son agnósticos de plataforma; agregar Android después implica configuración en Play Console/RevenueCat, no cambios de arquitectura.

## Open Questions

- ~~¿`purchases_flutter` expone metadata custom de `Offering`/`Package` en la versión estable actual...?~~ **Resuelto** (tarea 1.4): `purchases_flutter` 10.13.2 expone `Offering.metadata` como `Map<String, Object>` (verificado en el source de `RevenueCat/purchases-flutter`, `lib/models/offering_wrapper.dart`). `Package` **no** tiene metadata propio — coincide con lo verificado del lado del dashboard de RevenueCat (la API REST solo soporta `metadata` a nivel de `Offering`, ver `setup-revenuecat-store-config` tarea 3.4). Convención adoptada: cada Pack tiene una clave `"{packageLookupKey}_moodIds"` en el metadata del Offering "default" (ej. `pack_confianza_moodIds: ["brave","confident","romantic"]`, ya configurado en RevenueCat). El fallback de lista mínima en código no fue necesario.
