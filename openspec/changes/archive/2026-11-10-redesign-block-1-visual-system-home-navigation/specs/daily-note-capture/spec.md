## MODIFIED Requirements

### Requirement: Edición expandida en bottom sheet
El sistema SHALL ofrecer una superficie de edición expandida (bottom sheet) para la nota diaria, abierta desde la píldora de nota del Log. El campo de texto dentro del sheet SHALL recibir el foco automáticamente al abrirse. El sheet SHALL mostrar arriba el Mood seleccionado (ícono y nombre) y un botón "Done" que lo cierra, y debajo el campo de texto con el contador de caracteres.

#### Scenario: Apertura del sheet
- **WHEN** el usuario toca la píldora de nota
- **THEN** se presenta un bottom sheet que ocupa la mayor parte de la pantalla, con el teclado visible de inmediato y el cursor en el campo de texto

#### Scenario: Mood visible en el sheet
- **WHEN** el usuario abre el sheet con `calm` seleccionado
- **THEN** el sheet muestra el ícono y el nombre de `calm` junto al botón "Done"

#### Scenario: Edición en vivo
- **WHEN** el usuario escribe dentro del sheet
- **THEN** el texto se refleja inmediatamente en el mismo dato que se guardará al guardar el registro desde el Log

#### Scenario: Cerrar con Done
- **WHEN** el usuario toca "Done"
- **THEN** el sheet se cierra y el texto escrito se conserva en el Log sin guardar el mood

### Requirement: Acento visual ligado al mood seleccionado
El bottom sheet de edición de nota SHALL usar el tinte de la categoría del mood actualmente seleccionado como acento visual (por ejemplo, en el fondo del encabezado del sheet y en el borde del campo con foco), consistente con el resto de superficies de la app ligadas a un mood.

#### Scenario: Mood seleccionado de otra categoría en cada apertura
- **WHEN** el usuario tiene seleccionado un mood de otra categoría al abrir el bottom sheet
- **THEN** el acento visual del sheet corresponde al tinte de esa categoría

## REMOVED Requirements

### Requirement: Botón de nota en el encabezado
**Reason**: La nota se abre desde una píldora de ancho completo encima del botón Guardar, y el encabezado del Log ya no lleva el botón de nota.
**Migration**: El comportamiento pasa a "Píldora de nota" en `home-mood-log`.

### Requirement: Indicador de nota existente
**Reason**: El indicador de existencia de nota vive ahora en la píldora de nota, que muestra el comienzo del texto.
**Migration**: Ver "Píldora de nota" en `home-mood-log`.
