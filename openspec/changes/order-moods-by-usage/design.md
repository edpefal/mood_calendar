## Context

`MoodScreen` usa `allMoodDefinitions` (base 1-5 + premium 6-10) directamente por índice en cinco sitios: página inicial, `_applyMoodEntry`, `_onPageChanged`, el Semantics del `PageView` y los indicadores de puntos. El historial completo ya está disponible en `MoodCubit` como `MoodState.loaded(entries)`, y el estado `unlocked` en `PurchasesCubit`. Hay una Mood Entry por día (clave por fecha en Hive). Ver proposal.md para la motivación y specs/premium-moods para el comportamiento.

## Goals / Non-Goals

**Goals:**
- Ordenamiento puro, testeable y sin dependencias de Flutter.
- Que `MoodScreen` use una sola lista ordenada para todos sus usos por índice.

**Non-Goals:**
- Persistir contadores o preferencias de orden.
- Cambiar el orden en el calendario, el resumen mensual o la tienda.
- Reordenar en vivo o animar el reordenamiento.

## Decisions

**1. Servicio de dominio puro `MoodPickerOrder`** en `lib/features/mood/domain/services/`, con una función `sort(entries, isUnlocked)` que devuelve `List<MoodDefinition>`.
- Cuenta entradas por `assetPath` (así se guarda `MoodEntry.mood`), parte de `allMoodDefinitions`, separa en desbloqueados y bloqueados, y ordena los desbloqueados por conteo descendente.
- El desempate sale gratis usando un sort estable o comparando por índice original; no se implementa lógica especial para "sin historial".
- Alternativa descartada: derivar el conteo en `MoodCubit`/estado. Mezcla presentación con una regla de dominio y obliga a regenerar freezed.
- Alternativa descartada: persistir contadores en Hive. Duplica datos que ya se derivan del historial y hay que mantenerlos sincronizados al editar o borrar.

**2. Orden fijado una vez en `MoodScreen`.** Se calcula en la primera hidratación del estado (`_hydrateFromState` con `loaded`) y se guarda en un campo `_orderedMoods`. No se recalcula en `didChangeDependencies` ni en listeners posteriores, para que ni guardar, ni `fetchAll()`, ni una compra muevan las páginas. La pantalla ya muestra un loader hasta esa primera hidratación, así que no hay parpadeo del orden original.
- Alternativa descartada: `BlocBuilder` reactivo. Reacomodaría el carrusel con el usuario mirándolo.

**3. Sustituir `allMoodDefinitions` por `_orderedMoods` en los cinco usos por índice**, incluidos `_applyMoodEntry` (buscar el índice del Mood guardado en la lista ordenada) y el valor inicial de `selectedMood`, que pasa a ser `_orderedMoods.first` tras hidratar. El `BlocBuilder<PurchasesCubit>` por página sigue decidiendo el candado en vivo: si se compra un Mood con la pantalla abierta, se desbloquea en su posición sin moverse.

**4. Predicado de desbloqueo**: se inyecta como función al servicio para mantener el dominio independiente de `purchases`. Se usa `PurchasesCubit.isMoodUnlockedNow(id)`, una lectura síncrona de `repository.isUnlocked`, y no `isMoodUnlocked` (basado en `state`): `PurchasesCubit` se crea de forma perezosa en la primera lectura y su `unlockedMoodIds` se llena un instante después por stream, así que al calcular el orden un Mood comprado aparecería como bloqueado.

**5. Posicionar el carrusel en una entrada existente.** `_applyMoodEntry` saltaba con `jumpToPage` solo si el `PageController` tenía clientes, pero en la primera hidratación el `PageView` aún no existe (se muestra el loader), así que el carrusel quedaba en la página 0 mientras `selectedMood` apuntaba a otro Mood. Bug previo, necesario de corregir para el escenario "Fecha con entrada existente": en ese caso se recrea el controlador con `initialPage`.

## Risks / Trade-offs

- [Índice incorrecto al editar una entrada] → buscar siempre en `_orderedMoods`; test de widget con una entrada de un Mood que no está en su posición de catálogo.
- [Estado de compras aún no cargado al calcular el orden, dejando un Mood comprado entre los bloqueados] → resuelto con la lectura síncrona del repositorio (decisión 4); cubierto por test de widget.
- [Un Mood comprado sin uso queda tras los ya usados, no en su lugar del catálogo] → comportamiento acordado: entra con 0 usos.
- [Semantics "N de 10" cambia entre sesiones] → es correcto: refleja la posición real.
