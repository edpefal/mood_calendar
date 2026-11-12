## ADDED Requirements

### Requirement: Fila de bloqueo de notas en Privacy and data
La sección Privacy and data de Settings SHALL incluir, antes del interruptor de datos de uso anónimos, una fila con un interruptor para bloquear las notas, con ícono, título, un detalle que indica que se usa la biometría o el código del dispositivo, la marca "Pro" mientras el usuario no tenga suscripción activa y un área táctil de al menos 44 pt. El comportamiento del interruptor lo define la capacidad `note-lock`. Si el bloqueo está activo pero el dispositivo no tiene autenticación configurada, la fila SHALL explicarlo en su detalle.

#### Scenario: Ver la fila
- **WHEN** el usuario sin suscripción abre Settings
- **THEN** la sección Privacy and data muestra la fila del bloqueo de notas con la marca "Pro" y el interruptor apagado

#### Scenario: Suscriptor
- **WHEN** un suscriptor abre Settings
- **THEN** la fila del bloqueo de notas no muestra la marca "Pro"

#### Scenario: Bloqueo sin autenticación disponible
- **WHEN** el bloqueo está activo y el dispositivo ya no tiene biometría ni código
- **THEN** el detalle de la fila indica que hay que configurar un código en el dispositivo

### Requirement: Activar el recordatorio pide el permiso de notificaciones si hace falta
Al activar el recordatorio diario en Settings, si el sistema aún no ha decidido el permiso de notificaciones, la app SHALL pedirlo. Si el usuario lo niega, el interruptor SHALL volver a apagado con un mensaje. Si el permiso ya estaba concedido, NO SHALL pedirse de nuevo.

#### Scenario: Activar tras omitir el onboarding
- **WHEN** un usuario que omitió el permiso en el onboarding activa el recordatorio en Settings
- **THEN** el sistema muestra el diálogo del permiso

#### Scenario: Permiso negado
- **WHEN** el usuario niega el permiso tras activar el recordatorio
- **THEN** el interruptor vuelve a apagado y se muestra un mensaje

#### Scenario: Permiso ya concedido
- **WHEN** el usuario activa el recordatorio con el permiso ya concedido
- **THEN** el recordatorio se programa sin mostrar ningún diálogo
