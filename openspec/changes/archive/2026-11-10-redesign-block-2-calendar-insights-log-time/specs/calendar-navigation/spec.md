## MODIFIED Requirements

### Requirement: Fecha del selector tras tocar un día del calendario
Al tocar un día pasado o de hoy **sin entrada** en la pestaña Calendar, la app SHALL cambiar a la pestaña Log mostrando la cuadrícula con la fecha de ese día, y esa fecha SHALL permanecer hasta que el usuario toque otro día o use el atajo del día anterior. Al tocar un día **con entrada**, la app SHALL abrir una hoja de detalle del día con el Mood, su categoría, la hora de registro cuando corresponda, la nota y el botón "Edit"; "Edit" SHALL cerrar la hoja y llevar al Log con esa fecha, con la cuadrícula en edición y el Mood y la nota de la entrada. La app NO SHALL permitir elegir fechas futuras.

#### Scenario: Tocar un día pasado sin entrada
- **WHEN** el usuario toca un día pasado sin entrada en el calendario
- **THEN** el Log se muestra con la cuadrícula y la fecha de ese día

#### Scenario: Tocar un día con entrada
- **WHEN** el usuario toca un día que ya tiene una Mood Entry
- **THEN** se abre la hoja de detalle con el Mood, su categoría y la nota, sin cambiar de pestaña

#### Scenario: Editar desde el detalle
- **WHEN** el usuario toca "Edit" en la hoja de detalle de un día pasado
- **THEN** la hoja se cierra, se muestra el Log con la cuadrícula en edición y con el Mood y la nota de esa entrada, y al guardar la entrada de esa fecha se actualiza

#### Scenario: Cerrar el detalle
- **WHEN** el usuario cierra la hoja de detalle sin editar
- **THEN** vuelve al calendario en el mismo mes y la fecha del Log no cambia

#### Scenario: Varios días tocados
- **WHEN** el usuario edita el día A desde el detalle, guarda, toca el día B sin entrada y vuelve a la pestaña Log
- **THEN** el Log muestra el día B

#### Scenario: Fechas futuras
- **WHEN** el usuario mira el calendario del mes actual
- **THEN** los días posteriores a hoy no se pueden tocar

## ADDED Requirements

### Requirement: Navegación entre meses y años
El calendario SHALL permitir cambiar de mes con las flechas y elegir cualquier mes y año con un selector abierto al tocar el título del mes. La flecha al mes siguiente y los meses futuros del selector SHALL estar deshabilitados cuando el mes visible sea el actual. El botón "ver año" del encabezado SHALL llevar a la tarjeta Year in Pixels de la pestaña Insights; sin suscripción SHALL mostrar esa tarjeta bloqueada.

#### Scenario: Elegir un mes del pasado
- **WHEN** el usuario abre el selector y elige marzo de 2026
- **THEN** el calendario muestra marzo de 2026 con sus entradas y su resumen

#### Scenario: Mes actual
- **WHEN** el calendario muestra el mes actual
- **THEN** la flecha al mes siguiente está deshabilitada y el selector no permite meses futuros

#### Scenario: Ver año sin suscripción
- **WHEN** un usuario sin suscripción toca "ver año"
- **THEN** se abre Insights en la tarjeta Year in Pixels bloqueada, sin abrir la hoja de suscripción por sí sola

### Requirement: Celdas del calendario
Cada día del calendario SHALL mostrarse según su estado: con entrada, teñido con la categoría del Mood y con su carita; sin entrada y pasado, con borde punteado y un "+"; hoy, con un aro de tinta; futuro, sin relleno ni interacción. Cada celda SHALL tener una etiqueta de accesibilidad con la fecha y el nombre del Mood o "sin entrada".

#### Scenario: Día sin entrada
- **WHEN** un día pasado no tiene entrada
- **THEN** su celda muestra el borde punteado y el "+", y su etiqueta dice que no hay entrada

#### Scenario: Hoy con entrada
- **WHEN** hoy tiene entrada
- **THEN** su celda muestra la carita, el tinte de la categoría y el aro de tinta
