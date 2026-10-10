## ADDED Requirements

### Requirement: Botón de nota en el encabezado
La pantalla principal de registro de mood SHALL ofrecer un botón de nota en la esquina superior derecha, alineado con el encabezado de fecha y pregunta, compuesto por un icono y una etiqueta de texto corta. Tocarlo SHALL abrir la superficie de edición expandida (bottom sheet). La pantalla NO SHALL mostrar un campo de nota inline ni el texto de la nota fuera del sheet.

#### Scenario: Tocar el botón con nota vacía
- **WHEN** el usuario toca el botón de nota y no hay texto guardado
- **THEN** se abre el bottom sheet de edición con el campo de texto vacío

#### Scenario: Tocar el botón con nota existente
- **WHEN** el usuario toca el botón de nota y ya existe texto
- **THEN** se abre el bottom sheet de edición mostrando el texto existente, con el cursor listo para continuar editando

#### Scenario: Sin campo inline
- **WHEN** el usuario ve la pantalla principal de registro de mood
- **THEN** no hay un campo de nota sobre el botón Guardar y el texto de la nota no se muestra fuera del sheet

#### Scenario: Encabezado angosto
- **WHEN** la fecha y la pregunta no caben junto al botón en un ancho reducido o con texto grande
- **THEN** la fecha y la pregunta se recortan con elipsis antes de ocultar o desbordar el botón

### Requirement: Indicador de nota existente
El botón de nota SHALL indicar si hay una nota escrita para la fecha seleccionada. Sin nota, SHALL mostrar el icono en su variante de contorno. Con nota, SHALL mostrar el icono en su variante rellena y un indicador de punto de color fijo, independiente del mood seleccionado, de modo que no cambie al deslizar el carrusel. La etiqueta de texto SHALL ser la misma en ambos estados.

#### Scenario: Sin nota
- **WHEN** la nota de la fecha seleccionada está vacía
- **THEN** el botón muestra el icono de contorno y ningún punto indicador

#### Scenario: Con nota
- **WHEN** la fecha seleccionada tiene una nota con texto
- **THEN** el botón muestra el icono relleno y un punto indicador, del mismo color con cualquier mood seleccionado

#### Scenario: Escribir y cerrar el sheet
- **WHEN** el usuario escribe texto en el sheet y lo cierra
- **THEN** el botón pasa al estado con nota sin necesidad de guardar el mood

#### Scenario: Borrar toda la nota
- **WHEN** el usuario borra todo el texto de la nota y cierra el sheet
- **THEN** el botón vuelve al estado sin nota

#### Scenario: Cambio de fecha con entrada existente
- **WHEN** el usuario selecciona una fecha cuya entrada ya tiene nota
- **THEN** el botón muestra el estado con nota desde que carga la pantalla

#### Scenario: Etiqueta accesible
- **WHEN** un lector de pantalla enfoca el botón de nota
- **THEN** lo anuncia como botón con la etiqueta de texto localizada, tanto con nota como sin ella

## MODIFIED Requirements

### Requirement: Edición expandida en bottom sheet
El sistema SHALL ofrecer una superficie de edición expandida (bottom sheet) para la nota diaria, abierta desde el botón de nota del encabezado. El campo de texto dentro del sheet SHALL recibir el foco automáticamente al abrirse.

#### Scenario: Apertura del sheet
- **WHEN** el usuario toca el botón de nota
- **THEN** se presenta un bottom sheet que ocupa la mayor parte de la pantalla, con el teclado visible de inmediato y el cursor en el campo de texto

#### Scenario: Edición en vivo
- **WHEN** el usuario escribe dentro del sheet
- **THEN** el texto se refleja inmediatamente en el mismo dato que se guardará al confirmar el registro de mood desde la pantalla principal

### Requirement: Cierre del bottom sheet sin confirmación de descarte
El bottom sheet SHALL poder cerrarse mediante un control explícito de cierre, o mediante gestos estándar (deslizar hacia abajo, tocar fuera del sheet). Cualquiera de estos mecanismos SHALL conservar el texto escrito hasta ese momento; el sistema NO SHALL solicitar confirmación de descarte.

#### Scenario: Cierre con control explícito
- **WHEN** el usuario activa el control de cierre del sheet
- **THEN** el sheet se cierra y el texto escrito permanece asociado a la nota, reflejado en el indicador del botón de nota

#### Scenario: Cierre por gesto
- **WHEN** el usuario desliza el sheet hacia abajo o toca fuera de él
- **THEN** el sheet se cierra igual que con el control explícito, sin pedir confirmación, conservando el texto escrito

### Requirement: El editor de nota cubre el bottom bar
Mientras el bottom sheet de edición de la nota esté abierto, el bottom bar SHALL quedar cubierto por el sheet y no recibir toques, y SHALL volver a estar disponible al cerrarse el sheet.

#### Scenario: Abrir el editor
- **WHEN** el usuario toca el botón de nota
- **THEN** el bottom sheet se abre y el bottom bar queda cubierto por el sheet

#### Scenario: Cerrar el editor
- **WHEN** el usuario cierra el bottom sheet
- **THEN** el bottom bar vuelve a estar disponible

## REMOVED Requirements

### Requirement: Preview inline de solo lectura
**Reason**: El campo inline ocupaba un bloque completo de la pantalla para una función secundaria; el punto de entrada pasa al botón del encabezado y el estado se comunica con el indicador de nota existente.
**Migration**: Usar "Botón de nota en el encabezado" e "Indicador de nota existente". El texto de la nota solo se ve dentro del bottom sheet.
