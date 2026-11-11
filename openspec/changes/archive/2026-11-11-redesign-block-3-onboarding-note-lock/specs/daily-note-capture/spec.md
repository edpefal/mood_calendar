## ADDED Requirements

### Requirement: Una nota existente se muestra solo con la sesión desbloqueada cuando el bloqueo está activo
Con el bloqueo de notas activo y la sesión bloqueada, el editor de nota SHALL pedir la autenticación antes de mostrar el texto de una nota existente, y el estado "Saved" del Log SHALL mostrar el marcador "Note locked" en lugar de la nota. Si el usuario cancela la autenticación al abrir el editor, el editor NO SHALL abrirse con el texto y la nota NO SHALL modificarse. Guardar o editar la nota con la sesión desbloqueada SHALL funcionar como siempre, y con el bloqueo apagado NO SHALL cambiar nada. El límite de 500 caracteres y el resto del comportamiento del editor no cambian.

#### Scenario: Abrir una nota existente bloqueada
- **WHEN** el bloqueo está activo, la sesión bloqueada y el usuario abre el editor de una entrada con nota
- **THEN** se pide la autenticación y el texto aparece en el editor solo si tiene éxito

#### Scenario: Cancelar la autenticación
- **WHEN** el usuario cancela la autenticación al abrir el editor de una nota existente
- **THEN** el editor no muestra el texto y la nota queda sin cambios

#### Scenario: Estado Saved con nota bloqueada
- **WHEN** el bloqueo está activo, la sesión bloqueada y el Log está en "Saved" con una nota
- **THEN** la tarjeta muestra "Note locked" y no el texto

#### Scenario: Entrada sin nota
- **WHEN** el bloqueo está activo y la entrada no tiene nota
- **THEN** el editor se abre vacío sin pedir autenticación
