## REMOVED Requirements

### Requirement: Gráfica de líneas del mes
El widget MonthlyMoodSummaryCard mostraba una gráfica de líneas con la evolución del estado de ánimo a lo largo del mes, con tooltip interactivo al tocar un punto.

**Reason**: Se elimina para simplificar la pantalla principal y reducir la complejidad visual.
**Migration**: No aplica; feature puramente de presentación sin efecto en datos.

## MODIFIED Requirements

### Requirement: Resumen mensual de estado de ánimo
El widget MonthlyMoodSummaryCard SHALL mostrar únicamente:
- Card de promedio mensual con el emoji representativo del mes y el texto descriptivo
- Card de mejor racha con el número de días consecutivos registrados

El widget NO SHALL mostrar la gráfica de líneas ni ningún tooltip interactivo.

#### Scenario: Pantalla con datos del mes
- **WHEN** el usuario navega al mes con entradas registradas
- **THEN** la pantalla muestra la card de promedio mensual y la card de mejor racha, sin gráfica

#### Scenario: Pantalla sin datos del mes
- **WHEN** el usuario navega a un mes sin entradas
- **THEN** el widget muestra el estado vacío (`_EmptyState`) sin gráfica
