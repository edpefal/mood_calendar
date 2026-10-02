## Purpose

Define cómo el usuario captura la nota diaria asociada a su mood a través de un preview inline de solo lectura que abre un bottom sheet de edición expandida, con un límite de caracteres explícito.

## ADDED Requirements

### Requirement: Preview inline de solo lectura
El campo de nota mostrado en la pantalla principal de registro de mood SHALL ser de solo lectura. El usuario NO SHALL poder escribir directamente sobre ese campo; tocarlo SHALL abrir la superficie de edición expandida (bottom sheet).

#### Scenario: Tocar el preview con nota vacía
- **WHEN** el usuario toca el preview de nota y no hay texto guardado
- **THEN** se abre el bottom sheet de edición con el campo de texto vacío

#### Scenario: Tocar el preview con nota existente
- **WHEN** el usuario toca el preview de nota y ya existe texto
- **THEN** se abre el bottom sheet de edición mostrando el texto existente, con el cursor listo para continuar editando

#### Scenario: Preview trunca texto largo
- **WHEN** el texto de la nota excede las 3 líneas visibles en el preview
- **THEN** el preview muestra como máximo 3 líneas y recorta el resto con elipsis, sin desbordar el layout de la pantalla

### Requirement: Edición expandida en bottom sheet
El sistema SHALL ofrecer una superficie de edición expandida (bottom sheet) para la nota diaria, distinta del preview inline. El campo de texto dentro del sheet SHALL recibir el foco automáticamente al abrirse.

#### Scenario: Apertura del sheet
- **WHEN** el usuario toca el preview de nota
- **THEN** se presenta un bottom sheet que ocupa la mayor parte de la pantalla, con el teclado visible de inmediato y el cursor en el campo de texto

#### Scenario: Edición en vivo
- **WHEN** el usuario escribe dentro del sheet
- **THEN** el texto se refleja inmediatamente en el mismo dato que se guardará al confirmar el registro de mood desde la pantalla principal

### Requirement: Cierre del bottom sheet sin confirmación de descarte
El bottom sheet SHALL poder cerrarse mediante un control explícito de cierre, o mediante gestos estándar (deslizar hacia abajo, tocar fuera del sheet). Cualquiera de estos mecanismos SHALL conservar el texto escrito hasta ese momento; el sistema NO SHALL solicitar confirmación de descarte.

#### Scenario: Cierre con control explícito
- **WHEN** el usuario activa el control de cierre del sheet
- **THEN** el sheet se cierra y el texto escrito permanece asociado a la nota, visible en el preview inline

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
El bottom sheet de edición de nota SHALL usar el color del mood actualmente seleccionado como acento visual (por ejemplo, en el borde del campo con foco y en el control de cierre), consistente con el resto de superficies de la app ligadas a un mood.

#### Scenario: Mood seleccionado distinto en cada apertura
- **WHEN** el usuario tiene seleccionado un mood distinto al abrir el bottom sheet
- **THEN** el acento visual del sheet corresponde al color de ese mood
