## Context

`MoodScreen` fija el orden una sola vez en `_hydrateFromState` (`_fixedOrderedMoods ??= MoodPickerOrder.sort(...)`). `MainShell` mantiene sus cuatro pestañas en un `IndexedStack` y solo recrea el selector, con una `Key` nueva, en `showMoodPicker` (tocar un día del calendario o el recordatorio). Cambiar de pestaña con la barra no reconstruye `MoodScreen`, así que su orden queda congelado hasta reiniciar la app. `CalendarScreen` ya recibe `isActive` desde el shell para refrescarse al activarse; el mismo patrón sirve aquí.

## Goals / Non-Goals

**Goals:**
- Que los moods desbloqueados por compra o restauración aparezcan primero al volver al selector.
- Conservar fecha, mood seleccionado y nota sin guardar al reordenar.
- No reacomodar el carrusel mientras el selector está visible.

**Non-Goals:**
- Cambiar la regla de ordenamiento, el flujo de compra o la Tienda.
- Reordenar en tiempo real mientras el selector está visible.

## Decisions

**1. Recalcular al activarse la pestaña, no al cambiar el estado.** `MainShell` pasa `isActive: _tab == MainTab.moodPicker` a `MoodScreen`. Cuando pasa de `false` a `true` (`didUpdateWidget`), se recalcula el orden con el historial y el estado `unlocked` actuales (`MoodPickerOrder.sort`). Alternativas descartadas:
- *Recrear el selector con una `Key` nueva al volver*: pierde la nota y la selección sin guardar, que hoy se conservan al cambiar de pestaña.
- *Reordenar de inmediato cuando cambia `unlocked`*: mueve el carrusel mientras el usuario lo mira, que es justo lo que la regla original evitaba. Además, una compra iniciada desde un mood bloqueado ocurre con el selector visible.

**2. Conservar la selección por identidad.** Antes de recalcular se guarda el id del mood seleccionado; después se busca su nueva posición y se hace `jumpToPage` a ella, con `setState` para `_currentPage` y `selectedMood`. La nota (`_noteController`) y la fecha no se tocan.

**3. Sin recálculo si nada cambió.** Si el orden recalculado es igual al actual, no se hace `setState` ni salto, para evitar parpadeos al alternar pestañas.

**4. Primera carga sin cambios.** El orden inicial se sigue fijando al hidratar el estado; la regla nueva solo aplica a las activaciones posteriores.

## Risks / Trade-offs

- **El carrusel puede reordenarse al volver aunque no compraste nada** (por ejemplo tras guardar una entrada, que cambia las frecuencias). Es coherente con "calcular al abrir" y la selección se conserva, pero puede sorprender. → Se acepta; el salto conserva el mood visible.
- **`isMoodUnlockedNow` debe estar al día al volver.** Se confía en el estado de `PurchasesCubit`, que se actualiza con la compra y con la restauración antes de que el usuario cambie de pestaña. → Un test cubre compra y restauración.
- **Primer cambio de `MoodScreen` sin shell** (`onSaved` es opcional y el widget se usa suelto en tests): `isActive` debe tener un valor por defecto `true` que no cambie ese uso.

## Migration Plan

Sin datos ni configuración externa. Se entrega como parte del siguiente build.

## Open Questions

Ninguna.
