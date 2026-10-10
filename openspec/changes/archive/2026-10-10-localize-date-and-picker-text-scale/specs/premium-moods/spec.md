## ADDED Requirements

### Requirement: El selector soporta texto grande del sistema
La pantalla del selector de moods SHALL mostrarse sin desbordes visuales con cualquier tamaño de texto que permita el sistema, hasta el 200 %, en pantallas desde 390 pt de ancho. Cuando el contenido no quepa en la altura disponible, la pantalla SHALL poder desplazarse en vertical de modo que el encabezado, el botón de nota, el carrusel y el botón Guardar sean alcanzables. Con tamaños de texto normales la disposición SHALL ser la misma que antes: encabezado arriba, carrusel centrado y botón Guardar abajo, sin desplazamiento.

#### Scenario: Texto al 200 % en iPhone de 390 pt
- **WHEN** el texto del sistema está al 200 % en una pantalla de 390×844 pt y el usuario abre el selector
- **THEN** no hay desbordes y el usuario puede desplazarse hasta el botón Guardar

#### Scenario: Texto al 200 % con idioma de etiquetas largas
- **WHEN** el idioma es alemán, la fecha es larga y el texto está al 200 %
- **THEN** el encabezado, el botón de nota y el carrusel se muestran completos, sin recortes ni desbordes

#### Scenario: Tamaño de texto normal
- **WHEN** el texto del sistema está al 100 %
- **THEN** el selector no se desplaza y mantiene la disposición habitual

#### Scenario: Teclado del editor de nota abierto
- **WHEN** el editor de nota está abierto con el teclado visible
- **THEN** el selector detrás no desborda
