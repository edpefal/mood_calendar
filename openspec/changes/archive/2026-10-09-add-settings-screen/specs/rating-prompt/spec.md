## MODIFIED Requirements

### Requirement: Entrada manual para calificar la app
La pantalla de Settings SHALL incluir una fila "Calificar Mood Calendar" que abre la página de reseñas de la app en el App Store. Esta acción SHALL estar disponible siempre, sin depender de los intentos automáticos, y NO SHALL contar como un intento automático ni modificar su estado.

#### Scenario: Usuario toca la fila de calificar
- **WHEN** el usuario toca "Calificar Mood Calendar" en Settings
- **THEN** se abre la página de reseñas de la app en el App Store

#### Scenario: El uso manual no consume intentos
- **WHEN** el usuario usa la fila manual de calificar, con 0, 1 o 2 intentos automáticos previos
- **THEN** la cantidad de intentos automáticos registrada no cambia

### Requirement: Textos localizados y accesibles
El texto de la fila manual SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano (con inglés como respaldo), y el control SHALL exponer una etiqueta de `Semantics`.

#### Scenario: Dispositivo en alemán
- **WHEN** el idioma del dispositivo es alemán y el usuario abre Settings
- **THEN** la fila de calificar se muestra con su texto en alemán

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla recorre Settings
- **THEN** la fila de calificar se anuncia con una etiqueta que describe su acción

### Requirement: Telemetría del pedido de calificación
La app SHALL registrar un evento de telemetría cuando solicita automáticamente el diálogo de calificación y otro cuando el usuario usa la entrada manual en Settings.

#### Scenario: Intento automático
- **WHEN** la app solicita automáticamente el diálogo de calificación
- **THEN** se registra el evento de intento automático

#### Scenario: Uso de la entrada manual
- **WHEN** el usuario toca la fila manual de calificar en Settings
- **THEN** se registra el evento de entrada manual
