## Purpose

Define cuándo se guarda la hora en que se registró una Mood Entry, cuándo se conserva y cuándo se muestra, para que el detalle del día pueda decir "registrado a las 9:02 PM" sin inventar nada ni exponer datos de las entradas.

## ADDED Requirements

### Requirement: Captura de la hora de registro
Al guardar una Mood Entry desde el Log, la app SHALL guardar junto a la entrada el instante en que se registró (hora local del dispositivo). Si se edita una entrada existente y el Mood no cambia, la hora SHALL conservarse; si el Mood cambia, SHALL reemplazarse por el instante del guardado. Una elección hecha desde el Apple Watch SHALL usar la hora en que se eligió en el reloj. Las entradas que ya existían antes de este change NO SHALL recibir ninguna hora.

#### Scenario: Entrada nueva
- **WHEN** el usuario guarda un Mood en el Log a las 21:02
- **THEN** la entrada queda con la hora de registro 21:02

#### Scenario: Editar solo la nota
- **WHEN** el usuario edita la nota de una entrada ya guardada sin cambiar el Mood
- **THEN** la hora de registro de la entrada no cambia

#### Scenario: Cambiar el Mood
- **WHEN** el usuario cambia el Mood de una entrada ya guardada y guarda
- **THEN** la hora de registro pasa a ser el instante de ese guardado

#### Scenario: Elección desde el reloj
- **WHEN** el iPhone aplica una elección hecha en el Apple Watch a las 08:15
- **THEN** la entrada queda con la hora de registro 08:15, no con la hora en que el iPhone la procesó

#### Scenario: Entrada anterior al cambio
- **WHEN** existe una entrada guardada antes de esta versión
- **THEN** sigue abriéndose y editándose igual y no tiene hora de registro

### Requirement: Cuándo se muestra la hora de registro
La app SHALL mostrar la hora de registro únicamente en el detalle del día, en el formato de hora (12 o 24 horas) y el idioma del dispositivo, y solo si la entrada tiene hora y esa hora cae en el mismo día calendario que la fecha de la entrada. En cualquier otro caso (sin hora, o registrada otro día) NO SHALL mostrar hora, ni un marcador de posición, ni un texto que la sustituya.

#### Scenario: Entrada registrada el mismo día
- **WHEN** el usuario abre el detalle de un día cuya entrada se registró ese mismo día a las 21:02
- **THEN** el detalle muestra la categoría y la hora de registro

#### Scenario: Entrada registrada con retraso
- **WHEN** el usuario registró hoy la entrada de ayer y abre el detalle de ayer
- **THEN** el detalle muestra la categoría sin hora

#### Scenario: Entrada sin hora
- **WHEN** el usuario abre el detalle de una entrada anterior a este change
- **THEN** el detalle muestra la categoría sin hora y sin texto de relleno

#### Scenario: Formato del dispositivo
- **WHEN** el dispositivo usa formato de 24 horas y la hora es 21:02
- **THEN** el detalle muestra la hora en formato de 24 horas

### Requirement: La hora de registro no sale del dispositivo
La hora de registro SHALL permanecer solo en el almacenamiento local. NO SHALL incluirse en el historial exportado ni en ningún evento de analíticas o de fallos.

#### Scenario: Exportar el historial
- **WHEN** el usuario exporta su historial
- **THEN** el archivo no contiene la hora de registro de ninguna entrada

#### Scenario: Evento de guardar
- **WHEN** se guarda un Mood y se envía el evento de mood guardado
- **THEN** el evento no lleva la hora de registro
