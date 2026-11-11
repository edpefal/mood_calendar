## Purpose

Da a los usuarios una vista resumida de su mes: cómo se han sentido en general y qué tan consistentes han sido registrando su ánimo.
## Requirements
### Requirement: Resumen mensual de estado de ánimo
El resumen bajo el calendario SHALL mostrar únicamente:
- Card del mood más frecuente del mes (moda), con su ícono y el texto descriptivo
- Barra de distribución por categoría del mes, con el porcentaje y el nombre de cada categoría
- Card de racha actual y card de mejor racha, con el número de días consecutivos registrados

El resumen NO SHALL mostrar la gráfica de líneas, ningún tooltip interactivo, ni ningún promedio numérico.

Para el cálculo de la racha, dos entradas SHALL considerarse días consecutivos si y solo si la diferencia entre sus fechas es de exactamente un día calendario, sin importar si ese día cae en un mes o año distinto. La racha actual SHALL contar hacia atrás desde hoy, o desde ayer si hoy aún no tiene entrada, y SHALL ser independiente del mes que se esté viendo.

#### Scenario: Pantalla con datos del mes
- **WHEN** el usuario navega a un mes con entradas registradas
- **THEN** la pantalla muestra la card del mood más frecuente, la barra de distribución por categoría y las cards de racha actual y mejor racha, sin gráfica ni promedio numérico

#### Scenario: Pantalla sin datos del mes
- **WHEN** el usuario navega a un mes sin entradas
- **THEN** el widget muestra el estado vacío sin gráfica ni barra de distribución

#### Scenario: Empate entre moods más frecuentes
- **WHEN** dos o más Moods tienen la misma cantidad de días registrados en el mes, siendo esa cantidad la más alta
- **THEN** la card muestra el Mood entre los empatados cuyo registro más reciente en el mes sea más tardío

#### Scenario: Racha que cruza un límite de mes o año
- **WHEN** existen entradas en días calendario consecutivos que caen en meses o años distintos (por ejemplo, 31 de enero y 1 de febrero, o 31 de diciembre y 1 de enero)
- **THEN** el cálculo de racha los cuenta como consecutivos, igual que si estuvieran dentro del mismo mes

#### Scenario: Racha actual al ver un mes pasado
- **WHEN** el usuario mira un mes pasado teniendo una racha vigente
- **THEN** la card de racha actual sigue mostrando la racha vigente de hoy y no la del mes visible

#### Scenario: Distribución por categoría
- **WHEN** el mes tiene 2 entradas Peaceful y 1 Positive
- **THEN** la barra muestra "Peaceful 67%" y "Positive 33%" con sus nombres visibles

