## MODIFIED Requirements

### Requirement: Cuatro pestañas en un bottom bar
La app SHALL mostrar un bottom bar con cuatro pestañas, de izquierda a derecha: selector de moods, calendario, Premium y ajustes. Los iconos SHALL ser de estilo outlined en el púrpura de marca; el de moods SHALL ser una carita sonriente de contorno, no un emoji SVG; el de Premium SHALL ser una estrella o un diamante de contorno. Las pestañas de calendario y ajustes SHALL usar los mismos iconos que tenían como botones del header. Los botones de calendario y ajustes y cualquier acceso a la tienda SHALL dejar de mostrarse en el header del selector.

#### Scenario: Orden y contenido
- **WHEN** la app muestra su pantalla principal
- **THEN** el bottom bar muestra, de izquierda a derecha, moods, calendario, Premium y ajustes

#### Scenario: El header del selector ya no tiene esos botones
- **WHEN** el usuario está en la pestaña del selector de moods
- **THEN** el header no muestra botones de Premium, calendario ni ajustes

#### Scenario: Cambiar de pestaña
- **WHEN** el usuario toca una pestaña distinta de la activa
- **THEN** la app muestra el contenido de esa pestaña y la marca como activa

#### Scenario: Nombre de la pestaña en cada idioma
- **WHEN** el dispositivo está en inglés, español, alemán, francés o italiano
- **THEN** la pestaña Premium muestra su nombre en ese idioma y tiene etiqueta de accesibilidad
