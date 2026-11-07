## ADDED Requirements

### Requirement: Exportar con el bloqueo de notas activo exige autenticarse
Con el bloqueo de notas activo, "Exportar historial" SHALL pedir la autenticación del dispositivo antes de generar el archivo, porque el archivo incluye el texto de las notas. Si el usuario ya está desbloqueado en la sesión, NO SHALL pedirla de nuevo. Si cancela o falla, la app NO SHALL generar el archivo ni abrir la hoja de compartir y SHALL dejar la fila disponible sin mostrar un error.

#### Scenario: Exportar con el bloqueo activo
- **WHEN** el bloqueo está activo, la sesión está bloqueada y el usuario toca "Exportar historial"
- **THEN** la app pide la autenticación y, solo si tiene éxito, genera el archivo y abre la hoja de compartir

#### Scenario: Autenticación cancelada
- **WHEN** el usuario cancela la autenticación al exportar
- **THEN** no se genera el archivo, no se abre la hoja de compartir y la fila vuelve a estar disponible

#### Scenario: Sesión desbloqueada
- **WHEN** el bloqueo está activo y el usuario ya se autenticó en esta sesión
- **THEN** exportar no pide una nueva autenticación

#### Scenario: Bloqueo apagado
- **WHEN** el bloqueo está apagado
- **THEN** exportar funciona como antes, sin autenticación
