# daily-note-capture Specification

## Purpose

Define cómo el usuario captura la nota diaria asociada a su mood a través de un botón de nota en el encabezado de la pantalla principal que abre un bottom sheet de edición expandida, con un límite de caracteres explícito.
## Requirements
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

### Requirement: Cierre del bottom sheet sin confirmación de descarte
El bottom sheet SHALL poder cerrarse mediante un control explícito de cierre, o mediante gestos estándar (deslizar hacia abajo, tocar fuera del sheet). Cualquiera de estos mecanismos SHALL conservar el texto escrito hasta ese momento; el sistema NO SHALL solicitar confirmación de descarte.

#### Scenario: Cierre con control explícito
- **WHEN** el usuario activa el control de cierre del sheet
- **THEN** el sheet se cierra y el texto escrito permanece asociado a la nota, reflejado en el indicador del botón de nota

#### Scenario: Cierre por gesto
- **WHEN** el usuario desliza el sheet hacia abajo o toca fuera de él
- **THEN** el sheet se cierra igual que con el control explícito, sin pedir confirmación, conservando el texto escrito

### Requirement: Límite de caracteres de la nota
La nota diaria SHALL tener un límite máximo de 500 caracteres. El sistema SHALL mostrar un contador de caracteres visible mientras el usuario escribe dentro del bottom sheet, y SHALL impedir escribir más allá del límite.

#### Scenario: Escritura dentro del límite
- **WHEN** el usuario escribe texto por debajo de 500 caracteres
- **THEN** el contador refleja la cantidad actual sobre el máximo (ej. "320/500") sin alterar su color

#### Scenario: Alcanzar el límite
- **WHEN** el usuario alcanza los 500 caracteres
- **THEN** el campo no acepta caracteres adicionales y el contador muestra "500/500"

### Requirement: Acento visual ligado al mood seleccionado
El bottom sheet de edición de nota SHALL usar el tinte de la categoría del mood actualmente seleccionado como acento visual (por ejemplo, en el fondo del encabezado del sheet y en el borde del campo con foco), consistente con el resto de superficies de la app ligadas a un mood.

#### Scenario: Mood seleccionado de otra categoría en cada apertura
- **WHEN** el usuario tiene seleccionado un mood de otra categoría al abrir el bottom sheet
- **THEN** el acento visual del sheet corresponde al tinte de esa categoría

### Requirement: El editor de nota cubre el bottom bar
Mientras el bottom sheet de edición de la nota esté abierto, el bottom bar SHALL quedar cubierto por el sheet y no recibir toques, y SHALL volver a estar disponible al cerrarse el sheet.

#### Scenario: Abrir el editor
- **WHEN** el usuario toca el botón de nota
- **THEN** el bottom sheet se abre y el bottom bar queda cubierto por el sheet

#### Scenario: Cerrar el editor
- **WHEN** el usuario cierra el bottom sheet
- **THEN** el bottom bar vuelve a estar disponible

