## Context

`MonthlyMoodSummaryCard` actualmente renderiza tres secciones: una gráfica de líneas (`_buildChartCard`), una card de promedio mensual (`_StatCard` con `monthlyAverage`), y una card de mejor racha (`_StatCard` con `bestStreak`). La gráfica usa `fl_chart` y tiene lógica de tooltip interactivo. Se confirmó que `fl_chart` solo se usa en este archivo.

## Goals / Non-Goals

**Goals:**
- Eliminar la gráfica de líneas y todo el código asociado (tooltip, estado, clase auxiliar, import)
- Mantener intactas las cards de promedio mensual y mejor racha
- Dejar el widget más simple y sin dependencias de `fl_chart`

**Non-Goals:**
- Modificar la lógica de carga del BLoC/Cubit (sigue cargando `summary` para las stats)
- Cambiar el diseño visual de las cards restantes
- Remover `fl_chart` de `pubspec.yaml` (fuera de scope; requeriría análisis más amplio, aunque se sabe que ya no tiene otros usos)

## Decisions

**Eliminar en `monthly_mood_summary_card.dart`:**
- Estado: `_tooltipLocalOffset` y `_tooltipMoodPath` en `_MonthlyMoodSummaryCardState`
- Llamada: `_buildChartCard(context, summaryData)` y `SizedBox(height: 16)` que le sigue en el `Column` del `build`
- Método: `_buildChartCard()`
- Clase: `_MoodTooltipOverlay`
- Import: `package:fl_chart/fl_chart.dart`

El widget `MonthlyMoodSummaryCard` se vuelve stateless-compatible (ya no necesita `setState`), pero se deja como `StatefulWidget` solo si hay otras razones; si no, puede simplificarse. Decisión: convertir a `StatelessWidget` para reducir overhead.

## Risks / Trade-offs

- [La racha y el promedio quedan sin contexto visual temporal] → Aceptable; el calendario ya provee contexto por día
- [fl_chart sigue en pubspec.yaml sin usarse] → Deuda técnica menor; se puede limpiar en un cambio separado si se confirma que ningún otro feature futuro lo usará
