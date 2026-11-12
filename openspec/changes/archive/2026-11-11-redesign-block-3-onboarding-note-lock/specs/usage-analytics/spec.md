## MODIFIED Requirements

### Requirement: Lista cerrada de eventos sin datos de entradas
La app SHALL enviar únicamente los eventos de una lista cerrada: guardar un mood, abrir la app desde el recordatorio, programar o cancelar el recordatorio, pedir la calificación (automática o manual), abrir la hoja de suscripción y el resultado de una suscripción (iniciada, completada, cancelada o fallida, y restaurada), terminar u omitir el onboarding (`onboarding_completed` y `onboarding_skipped`) y activar o desactivar el bloqueo de notas (`note_lock_enabled` y `note_lock_disabled`). Los eventos de suscripción iniciada y completada SHALL poder llevar el parámetro `plan` con uno de los valores `weekly`, `monthly` o `annual`; el evento de abrir la hoja de suscripción SHALL poder llevar el parámetro `source` con el valor `locked_mood` (un Mood bloqueado), `settings` (la fila Premium o el interruptor del bloqueo de notas en Ajustes), `insights` (una tarjeta o rango bloqueado de Insights) u `onboarding` (el final del onboarding); y `onboarding_skipped` SHALL poder llevar el parámetro `step` con el número del paso (1 a 3) en el que se omitió. Ver, abrir o cambiar de rango en Insights, abrir el detalle de un día, desbloquear las notas y avanzar entre los pasos del onboarding NO SHALL generar eventos propios. Ningún evento NO SHALL incluir el mood elegido, la nota, la fecha de la entrada, la hora de registro, la intensidad ni el identificador de un Mood comprado.

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
- **WHEN** el usuario toca "Get Premium" o el interruptor del bloqueo de notas sin suscripción en Ajustes
- **THEN** se envía el evento de abrir la hoja con `source` igual a `settings`

#### Scenario: Abrir la hoja desde Insights
- **WHEN** el usuario sin suscripción toca "Ver con Premium" en una tarjeta de Insights
- **THEN** se envía el evento de abrir la hoja con `source` igual a `insights`, sin el rango ni ningún dato de las entradas

#### Scenario: Abrir la hoja al terminar el onboarding
- **WHEN** el onboarding termina y se abre la hoja de suscripción
- **THEN** se envía el evento de abrir la hoja con `source` igual a `onboarding`

#### Scenario: Terminar el onboarding
- **WHEN** el usuario toca "Continue" en la confirmación del primer registro
- **THEN** se envía `onboarding_completed` sin el mood ni la nota del primer registro

#### Scenario: Omitir el onboarding
- **WHEN** el usuario toca "Skip" en el paso 2
- **THEN** se envía `onboarding_skipped` con `step` igual a `2`

#### Scenario: Activar el bloqueo de notas
- **WHEN** el usuario activa o desactiva el bloqueo de notas
- **THEN** se envía `note_lock_enabled` o `note_lock_disabled` sin ningún dato de las notas ni de las entradas

#### Scenario: Usar Insights sin bloqueo
- **WHEN** el usuario abre Insights o cambia entre los rangos de 7 y 30 días
- **THEN** no se envía ningún evento

#### Scenario: Desbloquear las notas
- **WHEN** el usuario desbloquea las notas con la autenticación del dispositivo
- **THEN** no se envía ningún evento

#### Scenario: Evento con parámetros prohibidos
- **WHEN** un componente intenta enviar un evento con una clave de contexto que contiene datos de entradas (`date`, `mood`, `intensity` o `note`)
- **THEN** esas claves se descartan antes de enviarse y el resto del evento se envía

#### Scenario: Parámetro fuera de la lista
- **WHEN** un componente intenta enviar un evento con un parámetro que no es `has_note`, `source`, `plan` ni `step`
- **THEN** ese parámetro se descarta antes de enviarse y el resto del evento se envía

#### Scenario: Evento fuera de la lista
- **WHEN** un componente intenta enviar un evento que no está en la lista cerrada
- **THEN** el evento no se envía y solo se escribe en el log local
