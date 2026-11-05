## MODIFIED Requirements

### Requirement: Fecha del selector tras tocar un día del calendario
Al tocar un día en la pestaña Calendar, la app SHALL cambiar a la pestaña Log mostrando la fecha de ese día, y esa fecha SHALL permanecer hasta que el usuario toque otro día o use el atajo del día anterior. Si la fecha ya tiene una Mood Entry, el Log SHALL mostrar la tarjeta de esa entrada con su botón "Edit" en lugar de la cuadrícula; si no la tiene, SHALL mostrar la cuadrícula con la fecha elegida. La app NO SHALL permitir elegir fechas futuras.

#### Scenario: Tocar un día distinto de hoy
- **WHEN** el usuario toca un día pasado sin entrada en el calendario
- **THEN** el Log se muestra con la cuadrícula y la fecha de ese día

#### Scenario: Varios días tocados
- **WHEN** el usuario toca el día A, guarda, toca el día B y vuelve a la pestaña Log
- **THEN** el Log muestra el día B

#### Scenario: El Log muestra la entrada de esa fecha
- **WHEN** el usuario toca un día que ya tiene una Mood Entry
- **THEN** el Log muestra la tarjeta con el Mood de esa entrada y su botón "Edit"

#### Scenario: Editar un día pasado
- **WHEN** el usuario toca "Edit" en la tarjeta de un día pasado
- **THEN** vuelve la cuadrícula con el Mood y la nota de esa entrada, y al guardar la entrada de esa fecha se actualiza

#### Scenario: Fechas futuras
- **WHEN** el usuario mira el calendario del mes actual
- **THEN** los días posteriores a hoy no se pueden tocar
