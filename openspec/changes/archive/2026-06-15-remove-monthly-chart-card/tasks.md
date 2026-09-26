## 1. Limpiar monthly_mood_summary_card.dart

- [x] 1.1 Eliminar el import `package:fl_chart/fl_chart.dart` de la línea 1
- [x] 1.2 Convertir `MonthlyMoodSummaryCard` a `StatelessWidget` (eliminar `_MonthlyMoodSummaryCardState` y sus campos `_tooltipLocalOffset`, `_tooltipMoodPath`)
- [x] 1.3 Eliminar la llamada a `_buildChartCard(context, summaryData)` y el `SizedBox(height: 16)` que le sigue en el `Column` del método `build`
- [x] 1.4 Eliminar el método `_buildChartCard()`
- [x] 1.5 Eliminar la clase `_MoodTooltipOverlay`

## 2. Verificación

- [x] 2.1 Confirmar que la app compila sin errores (`flutter build` o hot reload)
- [ ] 2.2 Verificar visualmente que la pantalla muestra solo "Promedio mensual" y "Mejor racha" debajo del calendario
