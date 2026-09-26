## Why

La gráfica de líneas "Resumen del mes" agrega complejidad visual sin aportar valor suficiente para el flujo principal. El usuario prefiere una pantalla más limpia que enfoque la atención en el calendario y las estadísticas clave (promedio mensual y mejor racha).

## What Changes

- Eliminar la card de gráfica de líneas (`_buildChartCard`) del widget `MonthlyMoodSummaryCard`
- Eliminar el estado de tooltip (`_tooltipLocalOffset`, `_tooltipMoodPath`) y la clase `_MoodTooltipOverlay`
- Eliminar el import de `fl_chart` del archivo si queda sin uso
- Mantener las cards de "Promedio mensual" y "Mejor racha" sin cambios

## Capabilities

### New Capabilities
<!-- ninguna -->

### Modified Capabilities
- `monthly-mood-summary`: La card de resumen mensual ya no muestra la gráfica de líneas; solo muestra promedio mensual y mejor racha.

## Impact

- `lib/features/mood/presentation/widgets/monthly_mood_summary_card.dart` — eliminación de ~150 líneas (método `_buildChartCard`, clase `_MoodTooltipOverlay`, estado del tooltip, import de `fl_chart`)
- Dependencia `fl_chart` puede quedar huérfana si no se usa en otro widget (verificar antes de remover de `pubspec.yaml`)
