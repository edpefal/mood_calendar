## ADDED Requirements

### Requirement: Recuperación cuando el catálogo no carga
Si el catálogo de la Tienda no se puede cargar, la pantalla SHALL mostrar un mensaje de error junto con un control para reintentar, y NO SHALL quedarse en ese estado sin una forma de recuperarse. Al activar el control, la Tienda SHALL mostrar un estado de carga y volver a pedir el catálogo. Al volver a la pestaña de la Tienda con el catálogo en error, la app SHALL reintentar la carga una vez por visita. Un reintento fallido SHALL volver a mostrar el error con el control disponible.

#### Scenario: Reintento manual exitoso
- **WHEN** el catálogo no cargó y el usuario toca el control de reintentar y la carga ahora tiene éxito
- **THEN** la Tienda muestra el catálogo completo en lugar del error

#### Scenario: Reintento manual fallido
- **WHEN** el catálogo no cargó y el usuario toca el control de reintentar y la carga vuelve a fallar
- **THEN** la Tienda muestra otra vez el mensaje de error con el control para reintentar

#### Scenario: Estado de carga durante el reintento
- **WHEN** el usuario toca el control de reintentar
- **THEN** la Tienda muestra un estado de carga hasta que el reintento termina

#### Scenario: Reintento automático al volver a la pestaña
- **WHEN** el catálogo está en error y el usuario cambia a otra pestaña y regresa a la Tienda
- **THEN** la app reintenta cargar el catálogo sin que el usuario toque nada

#### Scenario: Sin recarga si el catálogo ya cargó
- **WHEN** el catálogo ya se cargó y el usuario cambia a otra pestaña y regresa a la Tienda
- **THEN** la Tienda conserva el catálogo y no lo vuelve a pedir

### Requirement: El control de reintento es accesible
El control para reintentar la carga del catálogo SHALL tener una etiqueta de accesibilidad y SHALL mostrarse en el idioma del dispositivo.

#### Scenario: Control en otro idioma
- **WHEN** el dispositivo está en alemán, francés, italiano o español y el catálogo falló
- **THEN** el control de reintentar aparece con su texto en ese idioma y con etiqueta de accesibilidad
