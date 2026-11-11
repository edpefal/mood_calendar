## MODIFIED Requirements

### Requirement: Lista cerrada de eventos sin datos de entradas
La app SHALL enviar únicamente los eventos de una lista cerrada: guardar un mood, abrir la app desde el recordatorio, programar o cancelar el recordatorio, pedir la calificación (automática o manual), abrir la hoja de suscripción y el resultado de una suscripción (iniciada, completada, cancelada o fallida, y restaurada). Los eventos de suscripción iniciada y completada SHALL poder llevar el parámetro `plan` con uno de los valores `weekly`, `monthly` o `annual`, y el evento de abrir la hoja de suscripción SHALL poder llevar el parámetro `source` con el valor `locked_mood` (un Mood bloqueado), `settings` (la fila Premium de Ajustes) o `insights` (una tarjeta o rango bloqueado de Insights). Ver, abrir o cambiar de rango en Insights y abrir el detalle de un día NO SHALL generar eventos propios. Ningún evento NO SHALL incluir el mood elegido, la nota, la fecha de la entrada, la hora de registro, la intensidad ni el identificador de un Mood comprado.

#### Scenario: Guardar un mood
- **WHEN** el usuario guarda un mood con una nota
- **THEN** se envía el evento de mood guardado sin el mood, la nota, la fecha, la hora de registro ni la intensidad

#### Scenario: Elegir un plan
- **WHEN** el usuario inicia la suscripción al plan anual
- **THEN** se envía el evento de suscripción iniciada con `plan` igual a `annual` y sin ningún dato de las entradas

#### Scenario: Abrir la hoja desde un Mood bloqueado
- **WHEN** el usuario toca un Mood bloqueado y se abre la hoja de suscripción
- **THEN** se envía el evento de abrir la hoja con `source` igual a `locked_mood`, sin el id del Mood

#### Scenario: Abrir la hoja desde Ajustes
- **WHEN** el usuario toca "Get Premium" en Ajustes
- **THEN** se envía el evento de abrir la hoja con `source` igual a `settings`

#### Scenario: Abrir la hoja desde Insights
- **WHEN** el usuario sin suscripción toca "Ver con Premium" en una tarjeta de Insights
- **THEN** se envía el evento de abrir la hoja con `source` igual a `insights`, sin el rango ni ningún dato de las entradas

#### Scenario: Usar Insights sin bloqueo
- **WHEN** el usuario abre Insights o cambia entre los rangos de 7 y 30 días
- **THEN** no se envía ningún evento

#### Scenario: Evento con parámetros prohibidos
- **WHEN** un componente intenta enviar un evento con una clave de contexto que contiene datos de entradas (`date`, `mood`, `intensity` o `note`)
- **THEN** esas claves se descartan antes de enviarse y el resto del evento se envía

#### Scenario: Parámetro fuera de la lista
- **WHEN** un componente intenta enviar un evento con un parámetro que no es `has_note`, `source` ni `plan`
- **THEN** ese parámetro se descarta antes de enviarse y el resto del evento se envía

#### Scenario: Evento fuera de la lista
- **WHEN** un componente intenta enviar un evento que no está en la lista cerrada
- **THEN** el evento no se envía y solo se escribe en el log local
