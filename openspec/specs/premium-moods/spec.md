# premium-moods Specification

## Purpose
Define el catálogo de moods con niveles (`base` / `premium`) y el estado de desbloqueo por usuario, controlando qué moods puede usar cada usuario para registrar o editar entradas del día.
## Requirements
### Requirement: Catálogo de moods con tier
Todo Mood definido en el catálogo SHALL tener un tier fijo, `base` o `premium`. Los Moods `base` SHALL estar disponibles para cualquier usuario sin necesidad de compra.

#### Scenario: El catálogo incluye ambos tiers
- **WHEN** se consulta el catálogo completo de moods
- **THEN** incluye tanto los moods `base` como los `premium`, cada uno con su tier correspondiente

### Requirement: Estado de desbloqueo por usuario
El sistema SHALL determinar el estado `unlocked` de cada Mood premium por usuario: `true` si el usuario compró ese Mood individualmente o compró un Pack que lo incluye; `false` en caso contrario. Todo Mood `base` SHALL ser `unlocked` para cualquier usuario.

#### Scenario: Mood premium desbloqueado por compra individual
- **WHEN** el usuario compró un Mood premium de forma individual
- **THEN** ese Mood se reporta como `unlocked` para ese usuario

#### Scenario: Mood premium desbloqueado vía Pack
- **WHEN** el usuario compró un Pack que incluye un Mood premium
- **THEN** ese Mood se reporta como `unlocked` para ese usuario, aunque no lo haya comprado individualmente

#### Scenario: Mood premium no comprado
- **WHEN** el usuario no ha comprado un Mood premium ni ningún Pack que lo incluya
- **THEN** ese Mood se reporta como no `unlocked`

### Requirement: Selección bloqueada en el carrusel diario
El carrusel de selección diaria SHALL mostrar todos los Moods del catálogo (base y premium), marcando visualmente los Moods premium no `unlocked`. Al intentar seleccionar un Mood no `unlocked` para registrar o editar la entrada del día, el sistema SHALL impedir guardar esa entrada y SHALL iniciar el flujo de compra de ese Mood en su lugar.

#### Scenario: Usuario toca un Mood bloqueado
- **WHEN** el usuario toca un Mood premium no `unlocked` en el carrusel
- **THEN** el sistema no permite seleccionarlo para guardar la entrada del día y muestra el flujo de compra de ese Mood

#### Scenario: Usuario selecciona un Mood desbloqueado
- **WHEN** el usuario toca un Mood `base` o un Mood premium ya `unlocked`
- **THEN** el sistema permite seleccionarlo normalmente para registrar o editar la entrada del día

### Requirement: El desbloqueo no reescribe el historial
Un cambio en el estado `unlocked` de un Mood (incluida su pérdida, por ejemplo tras un reembolso) SHALL afectar únicamente la capacidad de crear o editar entradas nuevas con ese Mood. El sistema SHALL NOT ocultar, modificar ni invalidar entradas (Mood Entry) ya guardadas con ese Mood.

#### Scenario: Pérdida de desbloqueo no afecta entradas pasadas
- **WHEN** un Mood premium pierde su estado `unlocked` después de que el usuario ya registró días con ese Mood
- **THEN** esas entradas ya guardadas siguen mostrándose sin cambios en el calendario y el historial

