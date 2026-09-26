## Purpose

Da a los usuarios un lugar dedicado para descubrir el catálogo de moods premium, comprarlos individualmente o en Pack con descuento, y restaurar compras previas.

## ADDED Requirements

### Requirement: Catálogo comprable en la Tienda
La pantalla de Tienda SHALL mostrar el catálogo completo de Moods premium disponibles para compra individual y todos los Packs disponibles, incluyendo su precio y qué Moods incluye cada Pack. SHALL indicar claramente cuáles Moods ya están `unlocked` para el usuario.

#### Scenario: Usuario abre la Tienda
- **WHEN** el usuario abre la pantalla de Tienda
- **THEN** ve todos los Moods premium con su precio y estado de desbloqueo, y todos los Packs disponibles con su precio y los Moods que incluyen

### Requirement: Compra individual de un Mood
El usuario SHALL poder comprar un Mood premium individual desde la Tienda, o desde el flujo de compra iniciado al tocar un Mood bloqueado en el carrusel diario. Al completarse la compra, ese Mood SHALL pasar a `unlocked` para el usuario.

#### Scenario: Compra individual exitosa
- **WHEN** el usuario completa la compra de un Mood premium individual
- **THEN** ese Mood pasa a estar `unlocked` inmediatamente y queda disponible para seleccionar en el carrusel

#### Scenario: Compra individual cancelada o fallida
- **WHEN** el usuario cancela la compra o esta falla
- **THEN** el Mood permanece sin `unlocked` y no se le cobra nada al usuario

### Requirement: Compra de un Pack
El usuario SHALL poder comprar un Pack desde la Tienda a su precio fijo. Al completarse la compra, todos los Moods incluidos en ese Pack SHALL pasar a `unlocked` para el usuario, sin importar si alguno ya estaba `unlocked` previamente.

#### Scenario: Compra de Pack exitosa
- **WHEN** el usuario completa la compra de un Pack
- **THEN** todos los Moods de ese Pack quedan `unlocked` para el usuario

### Requirement: Aviso de solape antes de comprar un Pack
Antes de confirmar la compra de un Pack que incluye uno o más Moods que el usuario ya tiene `unlocked`, el sistema SHALL advertir al usuario de ese solape. El aviso SHALL NOT bloquear la compra ni modificar su precio.

#### Scenario: Pack con solape parcial
- **WHEN** el usuario intenta comprar un Pack donde ya tiene `unlocked` al menos uno, pero no todos, de sus Moods
- **THEN** el sistema muestra una advertencia indicando cuáles Moods ya tiene, pero permite continuar con la compra al precio fijo del Pack

#### Scenario: Pack sin solape
- **WHEN** el usuario intenta comprar un Pack donde no tiene `unlocked` ninguno de sus Moods
- **THEN** el sistema no muestra ninguna advertencia de solape

### Requirement: Restaurar compras
La Tienda SHALL ofrecer una acción de restaurar compras que recupere el estado `unlocked` de todos los Moods y Packs previamente comprados por el usuario con su cuenta de la tienda de la plataforma.

#### Scenario: Restaurar en un dispositivo nuevo
- **WHEN** el usuario, en un dispositivo nuevo o tras reinstalar la app, ejecuta "Restaurar compras" con la misma cuenta de App Store usada para comprar
- **THEN** todos los Moods y Packs comprados previamente vuelven a estar `unlocked`
