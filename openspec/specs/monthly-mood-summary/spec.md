## Purpose

Da a los usuarios una vista resumida de su mes: cómo se han sentido en general y qué tan consistentes han sido registrando su ánimo.
## Requirements
### Requirement: Resumen mensual de estado de ánimo
El widget MonthlyMoodSummaryCard SHALL mostrar únicamente:
- Card del mood más frecuente del mes (moda), con su ícono y el texto descriptivo
- Card de mejor racha con el número de días consecutivos registrados

El widget NO SHALL mostrar la gráfica de líneas, ningún tooltip interactivo, ni ningún promedio numérico.

#### Scenario: Pantalla con datos del mes
- **WHEN** el usuario navega a un mes con entradas registradas
- **THEN** la pantalla muestra la card del mood más frecuente del mes y la card de mejor racha, sin gráfica ni promedio numérico

#### Scenario: Pantalla sin datos del mes
- **WHEN** el usuario navega a un mes sin entradas
- **THEN** el widget muestra el estado vacío (`_EmptyState`) sin gráfica

#### Scenario: Empate entre moods más frecuentes
- **WHEN** dos o más Moods tienen la misma cantidad de días registrados en el mes, siendo esa cantidad la más alta
- **THEN** la card muestra el Mood entre los empatados cuyo registro más reciente en el mes sea más tardío

