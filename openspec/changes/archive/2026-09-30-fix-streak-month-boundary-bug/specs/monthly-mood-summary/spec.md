## MODIFIED Requirements

### Requirement: Resumen mensual de estado de ánimo
El widget MonthlyMoodSummaryCard SHALL mostrar únicamente:
- Card del mood más frecuente del mes (moda), con su ícono y el texto descriptivo
- Card de mejor racha con el número de días consecutivos registrados

El widget NO SHALL mostrar la gráfica de líneas, ningún tooltip interactivo, ni ningún promedio numérico.

Para el cálculo de la racha, dos entradas SHALL considerarse días consecutivos si y solo si la diferencia entre sus fechas es de exactamente un día calendario, sin importar si ese día cae en un mes o año distinto.

#### Scenario: Pantalla con datos del mes
- **WHEN** el usuario navega a un mes con entradas registradas
- **THEN** la pantalla muestra la card del mood más frecuente del mes y la card de mejor racha, sin gráfica ni promedio numérico

#### Scenario: Pantalla sin datos del mes
- **WHEN** el usuario navega a un mes sin entradas
- **THEN** el widget muestra el estado vacío (`_EmptyState`) sin gráfica

#### Scenario: Empate entre moods más frecuentes
- **WHEN** dos o más Moods tienen la misma cantidad de días registrados en el mes, siendo esa cantidad la más alta
- **THEN** la card muestra el Mood entre los empatados cuyo registro más reciente en el mes sea más tardío

#### Scenario: Racha que cruza un límite de mes o año
- **WHEN** existen entradas en días calendario consecutivos que caen en meses o años distintos (por ejemplo, 31 de enero y 1 de febrero, o 31 de diciembre y 1 de enero)
- **THEN** el cálculo de racha los cuenta como consecutivos, igual que si estuvieran dentro del mismo mes
