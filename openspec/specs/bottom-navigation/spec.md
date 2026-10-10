# bottom-navigation Specification

## Purpose
Define el bottom bar flotante que da acceso permanente al selector de moods, al calendario, a la tienda y a los ajustes, y cómo se comporta (apariencia, estado de las pestañas y cambios automáticos de pestaña).

## Requirements

### Requirement: Cuatro pestañas en un bottom bar
La app SHALL mostrar un bottom bar con cuatro pestañas, de izquierda a derecha: selector de moods, calendario, tienda y ajustes. Los iconos SHALL ser de estilo outlined en el púrpura de marca; el de moods SHALL ser una carita sonriente de contorno, no un emoji SVG. Las pestañas de calendario, tienda y ajustes SHALL usar los mismos iconos que tenían como botones del header. Los botones de tienda, calendario y ajustes SHALL dejar de mostrarse en el header del selector.

#### Scenario: Orden y contenido
- **WHEN** la app muestra su pantalla principal
- **THEN** el bottom bar muestra, de izquierda a derecha, moods, calendario, tienda y ajustes

#### Scenario: El header del selector ya no tiene esos botones
- **WHEN** el usuario está en la pestaña del selector de moods
- **THEN** el header no muestra botones de tienda, calendario ni ajustes

#### Scenario: Cambiar de pestaña
- **WHEN** el usuario toca una pestaña distinta de la activa
- **THEN** la app muestra el contenido de esa pestaña y la marca como activa

### Requirement: Apariencia del bar como cápsula translúcida flotante
El bar SHALL mostrarse como una cápsula flotante con bordes totalmente redondeados, separada de los bordes laterales e inferior de la pantalla, con fondo translúcido que desenfoca el contenido que pasa por debajo. La pestaña activa SHALL distinguirse con una píldora translúcida detrás de su icono. En pantallas anchas el bar SHALL tener un ancho máximo de entre 400 y 440 pt y quedar centrado horizontalmente.

#### Scenario: Pestaña activa marcada
- **WHEN** una pestaña está activa
- **THEN** su icono aparece sobre una píldora translúcida y las otras pestañas no la tienen

#### Scenario: iPad
- **WHEN** la app corre en una pantalla más ancha que el ancho máximo del bar
- **THEN** el bar mantiene su ancho máximo y se centra en la parte baja de la pantalla

#### Scenario: El contenido no queda tapado
- **WHEN** una pantalla de pestaña tiene contenido en su parte baja (botón de guardar del selector, lista de Tienda o de Ajustes)
- **THEN** ese contenido puede desplazarse o colocarse de modo que ningún control quede cubierto por el bar

### Requirement: Las pestañas conservan su estado
Cambiar de pestaña NO SHALL reiniciar el contenido de las demás. En particular, la fecha del selector de moods SHALL conservarse al ir a otra pestaña y volver, y solo SHALL cambiar cuando el usuario toca un día del calendario. Al iniciar la app el selector SHALL mostrar hoy.

#### Scenario: Volver a la pestaña del selector
- **WHEN** el usuario está en el selector de la fecha F, va a Ajustes y toca la pestaña del selector
- **THEN** el selector sigue mostrando la fecha F

#### Scenario: Tocar un día del calendario
- **WHEN** el usuario toca un día D en la pestaña del calendario
- **THEN** la app cambia a la pestaña del selector con la fecha D

#### Scenario: Arranque
- **WHEN** la app se inicia
- **THEN** la pestaña activa es el selector de moods con la fecha de hoy

### Requirement: Los modales cubren el bar
El bar SHALL estar visible en las cuatro pestañas. Mientras haya un modal abierto sobre ellas (el editor de nota o una hoja de compra), el bar SHALL quedar cubierto por el modal y su barrera, sin poder recibir toques, y SHALL volver a estar disponible al cerrar el modal.

#### Scenario: Visible en el selector
- **WHEN** el usuario está en el selector de moods sin ningún modal abierto
- **THEN** el bar está visible y sus pestañas reciben toques

#### Scenario: Cubierto por una hoja de compra
- **WHEN** el usuario abre la hoja de compra de un mood o de un Pack
- **THEN** el bar no recibe toques ni aparece como control disponible, y vuelve a estarlo al cerrar la hoja

### Requirement: Guardar cambia a la pestaña del calendario
Tras guardar con éxito una Mood Entry, la app SHALL cambiar a la pestaña del calendario y resaltar el día guardado. Si el guardado falla, la app SHALL permanecer en la pestaña del selector.

#### Scenario: Guardado exitoso
- **WHEN** el usuario guarda una Mood Entry con éxito desde el selector
- **THEN** la pestaña activa pasa a ser el calendario, con el día guardado resaltado

#### Scenario: Guardado fallido
- **WHEN** el guardado de la Mood Entry falla
- **THEN** la app sigue en la pestaña del selector

### Requirement: El recordatorio abre el selector de la fecha del recordatorio
Al tocar la notificación del recordatorio diario, la app SHALL cerrar cualquier modal abierto, activar la pestaña del selector de moods y mostrar la fecha del recordatorio, estuviera la app cerrada o abierta en otra pestaña.

#### Scenario: App abierta en otra pestaña
- **WHEN** el usuario está en la pestaña de Ajustes y toca la notificación del recordatorio
- **THEN** la app activa la pestaña del selector con la fecha del recordatorio

#### Scenario: App abierta con un modal
- **WHEN** hay una hoja de compra abierta y el usuario toca la notificación del recordatorio
- **THEN** la hoja se cierra y la app muestra el selector con la fecha del recordatorio

### Requirement: Pantallas de pestaña con título y sin flecha de regresar
Calendario, Tienda y Ajustes SHALL mostrar su título en bold y color de marca, y NO SHALL mostrar un botón de regresar en su header. El título del calendario SHALL ser "Calendario" (o su traducción) en todos los idiomas soportados.

#### Scenario: Header de Ajustes
- **WHEN** el usuario está en la pestaña de Ajustes
- **THEN** el header muestra el título de Ajustes y ninguna flecha de regresar

#### Scenario: Header del calendario
- **WHEN** el usuario está en la pestaña del calendario
- **THEN** el header muestra el título "Calendario" en el idioma del dispositivo y ninguna flecha de regresar

### Requirement: Pestañas localizadas y accesibles
Cada pestaña SHALL tener una etiqueta de `Semantics` y un tooltip localizados en todos los idiomas soportados (inglés, español, alemán, francés e italiano), y SHALL indicar a las tecnologías de asistencia si está seleccionada.

#### Scenario: Etiqueta en alemán
- **WHEN** el idioma del dispositivo es alemán
- **THEN** las cuatro pestañas exponen su etiqueta en alemán

#### Scenario: Estado seleccionado
- **WHEN** una pestaña está activa
- **THEN** su `Semantics` la marca como seleccionada
