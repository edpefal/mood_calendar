## RENAMED Requirements

- FROM: `### Requirement: Catálogo comprable en la Tienda`
- TO: `### Requirement: Escaparate de moods premium en la pantalla Premium`

- FROM: `### Requirement: La Tienda es una pestaña del bottom bar`
- TO: `### Requirement: Premium es una pestaña del bottom bar`

## MODIFIED Requirements

### Requirement: Escaparate de moods premium en la pantalla Premium
La pantalla Premium SHALL mostrar los Moods premium del catálogo como escaparate, con su nombre localizado, e indicar cuáles están `unlocked` para el usuario. Los planes de suscripción y su compra se especifican en `premium-subscription`. La pantalla NO SHALL mostrar precios por Mood ni Packs.

#### Scenario: Usuario abre la pestaña Premium
- **WHEN** el usuario abre la pestaña Premium sin suscripción activa
- **THEN** ve el escaparate de los Moods premium y los planes de suscripción con el precio de la tienda

#### Scenario: Mood desbloqueado por una compra heredada
- **WHEN** el usuario compró el Mood `brave` en una versión anterior y abre la pestaña Premium
- **THEN** `brave` aparece marcado como desbloqueado en el escaparate

### Requirement: Restaurar compras
La pantalla Premium SHALL ofrecer una acción de restaurar compras que recupere el estado `unlocked` de la suscripción activa y de los Moods comprados individualmente o en Pack en versiones anteriores, con la cuenta de la tienda de la plataforma. La acción SHALL estar disponible con y sin suscripción activa.

#### Scenario: Restaurar en un dispositivo nuevo
- **WHEN** el usuario, en un dispositivo nuevo o tras reinstalar la app, ejecuta "Restaurar compras" con la misma cuenta de la tienda usada para suscribirse
- **THEN** la suscripción activa vuelve a desbloquear todos los Moods premium

#### Scenario: Restaurar compras heredadas
- **WHEN** el usuario ejecuta "Restaurar compras" y su cuenta tiene un Pack comprado en una versión anterior
- **THEN** los Moods de ese Pack vuelven a estar `unlocked`

#### Scenario: Sin nada que restaurar
- **WHEN** el usuario ejecuta "Restaurar compras" y su cuenta no tiene suscripción ni compras anteriores
- **THEN** la app termina la acción sin cambiar el estado de ningún Mood y sin mostrar un error

### Requirement: Nombres de Mood localizados en la tienda
La pantalla Premium SHALL mostrar los nombres de los Moods premium en el idioma activo del dispositivo, con fallback a inglés. Los textos de los planes y la información legal SHALL seguir la misma regla de idioma.

#### Scenario: Pantalla Premium en alemán
- **WHEN** el dispositivo está en alemán y se abre la pestaña Premium
- **THEN** el escaparate muestra los nombres de los Moods en alemán (por ejemplo "Mutig" para `brave`) y los textos de los planes en alemán

#### Scenario: Idioma no soportado
- **WHEN** el dispositivo está en un idioma que la app no soporta
- **THEN** los nombres y los textos aparecen en inglés

### Requirement: Premium es una pestaña del bottom bar
La pantalla Premium SHALL abrirse desde la tercera pestaña del bottom bar, con el nombre "Premium" y su icono. La pantalla principal NO SHALL mostrar un icono de tienda en su header, y la pantalla Premium NO SHALL mostrar un botón de regresar. La hoja de suscripción que se abre al tocar un Mood bloqueado SHALL cubrir el bottom bar mientras esté abierta.

#### Scenario: Abrir Premium
- **WHEN** el usuario toca la pestaña Premium
- **THEN** se muestra la pantalla Premium

#### Scenario: Hoja de suscripción
- **WHEN** el usuario toca un Mood bloqueado en el selector y se abre la hoja de suscripción
- **THEN** el bottom bar queda cubierto por la hoja hasta que se cierra

### Requirement: Recuperación cuando los planes no cargan
Si los planes de suscripción de la pantalla Premium no se pueden cargar, la pantalla SHALL mostrar un mensaje de error junto con un control para reintentar, y NO SHALL quedarse en ese estado sin una forma de recuperarse. Al activar el control, la pantalla SHALL mostrar un estado de carga y volver a pedir los planes. Al volver a la pestaña Premium con los planes en error, la app SHALL reintentar la carga una vez por visita. Un reintento fallido SHALL volver a mostrar el error con el control disponible.

#### Scenario: Reintento manual exitoso
- **WHEN** los planes no cargaron y el usuario toca el control de reintentar y la carga ahora tiene éxito
- **THEN** la pantalla muestra los planes en lugar del error

#### Scenario: Reintento manual fallido
- **WHEN** los planes no cargaron y el usuario toca el control de reintentar y la carga vuelve a fallar
- **THEN** la pantalla muestra otra vez el mensaje de error con el control para reintentar

#### Scenario: Estado de carga durante el reintento
- **WHEN** el usuario toca el control de reintentar
- **THEN** la pantalla muestra un estado de carga hasta que el reintento termina

#### Scenario: Reintento automático al volver a la pestaña
- **WHEN** los planes están en error y el usuario cambia a otra pestaña y regresa a Premium
- **THEN** la app reintenta cargar los planes sin que el usuario toque nada

#### Scenario: Sin recarga si los planes ya cargaron
- **WHEN** los planes ya se cargaron y el usuario cambia a otra pestaña y regresa a Premium
- **THEN** la pantalla conserva los planes y no los vuelve a pedir

## REMOVED Requirements

### Requirement: Compra individual de un Mood
**Reason**: Los Moods premium dejan de venderse uno a uno; se desbloquean todos con la suscripción.
**Migration**: La suscripción (`premium-subscription`) desbloquea todos los Moods premium. Las compras individuales hechas en versiones anteriores se siguen reconociendo.

### Requirement: Compra de un Pack
**Reason**: Los Packs dejan de venderse; la suscripción cubre todos los Moods premium.
**Migration**: La suscripción (`premium-subscription`) reemplaza a los Packs. Los Packs comprados en versiones anteriores se siguen reconociendo.

### Requirement: Aviso de solape antes de comprar un Pack
**Reason**: Sin Packs ni compras sueltas ya no hay solape que advertir.
**Migration**: Ninguna; el aviso se elimina.

### Requirement: Packs de la primera ola
**Reason**: Los Packs Afecto, Cuerpo e Intenso y las compras individuales de los 9 Moods nuevos no llegan a venderse: la suscripción los reemplaza. El catálogo de Moods y su orden no cambian (siguen definidos en `premium-moods`).
**Migration**: La suscripción (`premium-subscription`) desbloquea esos 9 Moods junto con los demás.
