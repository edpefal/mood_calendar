# mood-store Specification

## Purpose
Da a los usuarios la pestaña Premium donde descubrir el catálogo de moods premium (con los desbloqueados marcados), y restaurar compras previas. Los planes de suscripción y su compra se especifican en `premium-subscription`.
## Requirements
### Requirement: Restaurar compras
La hoja de suscripción y Ajustes SHALL ofrecer una acción de restaurar compras que recupere el estado `unlocked` de la suscripción activa y de los Moods comprados individualmente o en Pack en versiones anteriores, con la cuenta de la tienda de la plataforma. La acción SHALL estar disponible con y sin suscripción activa.

#### Scenario: Restaurar en un dispositivo nuevo
- **WHEN** el usuario, en un dispositivo nuevo o tras reinstalar la app, ejecuta "Restaurar compras" con la misma cuenta de la tienda usada para suscribirse
- **THEN** la suscripción activa vuelve a desbloquear todos los Moods premium

#### Scenario: Restaurar compras heredadas
- **WHEN** el usuario ejecuta "Restaurar compras" y su cuenta tiene un Pack comprado en una versión anterior
- **THEN** los Moods de ese Pack vuelven a estar `unlocked`

#### Scenario: Sin nada que restaurar
- **WHEN** el usuario ejecuta "Restaurar compras" y su cuenta no tiene suscripción ni compras anteriores
- **THEN** la app termina la acción sin cambiar el estado de ningún Mood y sin mostrar un error

#### Scenario: Desde Ajustes
- **WHEN** el usuario toca "Restaurar compras" en la sección Premium de Ajustes
- **THEN** se ejecuta la misma restauración que en la hoja y el Log refleja los Moods recuperados al volver

### Requirement: Nombres de Mood localizados en la tienda
La hoja de suscripción SHALL mostrar el nombre del Mood bloqueado que la abrió en el idioma activo del dispositivo, con fallback a inglés. Los textos de los planes y la información legal SHALL seguir la misma regla de idioma.

#### Scenario: Hoja en alemán
- **WHEN** el dispositivo está en alemán y se abre la hoja desde `brave`
- **THEN** la cápsula muestra "Mutig" y los textos de los planes están en alemán

#### Scenario: Idioma no soportado
- **WHEN** el dispositivo está en un idioma que la app no soporta
- **THEN** los nombres y los textos aparecen en inglés

### Requirement: El control de reintento es accesible
El control para reintentar la carga de los planes SHALL tener una etiqueta de accesibilidad y SHALL mostrarse en el idioma del dispositivo.

#### Scenario: Control en otro idioma
- **WHEN** el dispositivo está en alemán, francés, italiano o español y los planes no cargaron
- **THEN** el control de reintentar aparece con su texto en ese idioma y con etiqueta de accesibilidad

### Requirement: Recuperación cuando los planes no cargan
Si los planes de suscripción de la hoja no se pueden cargar, la hoja SHALL mostrar un mensaje de error junto con un control para reintentar, y NO SHALL quedarse en ese estado sin una forma de recuperarse. Al activar el control, la hoja SHALL mostrar un estado de carga y volver a pedir los planes. Al abrir la hoja con los planes en error, la app SHALL reintentar la carga una vez por apertura. Un reintento fallido SHALL volver a mostrar el error con el control disponible.

#### Scenario: Reintento manual exitoso
- **WHEN** los planes no cargaron y el usuario toca el control de reintentar y la carga ahora tiene éxito
- **THEN** la hoja muestra los planes en lugar del error

#### Scenario: Reintento manual fallido
- **WHEN** los planes no cargaron y el usuario toca el control de reintentar y la carga vuelve a fallar
- **THEN** la hoja muestra otra vez el mensaje de error con el control para reintentar

#### Scenario: Estado de carga durante el reintento
- **WHEN** el usuario toca el control de reintentar
- **THEN** la hoja muestra un estado de carga hasta que el reintento termina

#### Scenario: Reintento automático al abrir la hoja
- **WHEN** los planes están en error y el usuario cierra la hoja y la vuelve a abrir
- **THEN** la app reintenta cargar los planes sin que el usuario toque nada

#### Scenario: Sin recarga si los planes ya cargaron
- **WHEN** los planes ya se cargaron y el usuario cierra la hoja y la vuelve a abrir
- **THEN** la hoja conserva los planes y no los vuelve a pedir

