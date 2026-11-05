## ADDED Requirements

### Requirement: Insights provisional hasta el siguiente bloque
La pestaña Insights SHALL mostrar, mientras no exista su contenido, una pantalla con el título "Insights" y un estado vacío que invita a registrar días, sin gráficas ni datos inventados y sin acceso a la hoja de suscripción.

#### Scenario: Abrir Insights
- **WHEN** el usuario toca la pestaña Insights
- **THEN** ve el título "Insights" y un estado vacío localizado, sin gráficas

### Requirement: Apariencia del bar como cápsula oscura flotante
El bar SHALL mostrarse como una cápsula flotante de tinta oscura con bordes totalmente redondeados y una sombra suave, separada de los bordes laterales e inferior de la pantalla. La pestaña activa SHALL distinguirse con su ícono y nombre en blanco y en peso mayor; las inactivas, en blanco atenuado con contraste de al menos 4.5:1. En pantallas anchas el bar SHALL tener un ancho máximo de entre 400 y 440 pt y quedar centrado horizontalmente. Con el tema oscuro el bar SHALL conservar su contraste sobre el fondo oscuro.

#### Scenario: Pestaña activa marcada
- **WHEN** una pestaña está activa
- **THEN** su ícono y nombre aparecen en blanco y en peso mayor, y los de las otras pestañas atenuados

#### Scenario: iPad
- **WHEN** la app corre en una pantalla más ancha que el ancho máximo del bar
- **THEN** el bar mantiene su ancho máximo y se centra en la parte baja de la pantalla

#### Scenario: El contenido no queda tapado
- **WHEN** una pantalla de pestaña tiene contenido en su parte baja (botón de guardar del Log, lista de Ajustes)
- **THEN** ese contenido puede desplazarse o colocarse de modo que ningún control quede cubierto por el bar

#### Scenario: Tema oscuro
- **WHEN** el tema es Oscuro
- **THEN** el bar se distingue del fondo y sus íconos siguen con contraste de al menos 4.5:1

## MODIFIED Requirements

### Requirement: Cuatro pestañas en un bottom bar
La app SHALL mostrar un bottom bar con cuatro pestañas, de izquierda a derecha: Calendar, Insights, Log y Settings. Los iconos de Calendar, Insights y Settings SHALL ser de contorno; el de Log SHALL ser un botón circular central con un signo "+" sobre el degradado de marca, más destacado que los demás. Todas las pestañas SHALL tener un nombre visible debajo de su icono. Los accesos a Premium, calendario y ajustes SHALL dejar de mostrarse como botones del header del Log, salvo la campana que lleva a Ajustes.

#### Scenario: Orden y contenido
- **WHEN** la app muestra su pantalla principal
- **THEN** el bottom bar muestra, de izquierda a derecha, Calendar, Insights, Log y Settings

#### Scenario: Log destacado
- **WHEN** el bottom bar se muestra en cualquier pestaña
- **THEN** la pestaña Log aparece como un botón circular con "+" más grande que los demás iconos

#### Scenario: No hay pestaña Premium
- **WHEN** el usuario mira el bottom bar
- **THEN** no hay ninguna pestaña de Premium ni de tienda

#### Scenario: Cambiar de pestaña
- **WHEN** el usuario toca una pestaña distinta de la activa
- **THEN** la app muestra el contenido de esa pestaña y la marca como activa

#### Scenario: Nombre de la pestaña en cada idioma
- **WHEN** el dispositivo está en inglés, español, alemán, francés o italiano
- **THEN** las cuatro pestañas muestran su nombre en ese idioma y tienen etiqueta de accesibilidad

### Requirement: Las pestañas conservan su estado
Cambiar de pestaña NO SHALL reiniciar el contenido de las demás. En particular, la fecha del Log SHALL conservarse al ir a otra pestaña y volver, y solo SHALL cambiar cuando el usuario toca un día del calendario o el atajo del día anterior. Al iniciar la app la pestaña activa SHALL ser Log con la fecha de hoy.

#### Scenario: Volver a la pestaña Log
- **WHEN** el usuario está en el Log de la fecha F, va a Ajustes y toca la pestaña Log
- **THEN** el Log sigue mostrando la fecha F

#### Scenario: Tocar un día del calendario
- **WHEN** el usuario toca un día D en la pestaña Calendar
- **THEN** la app cambia a la pestaña Log con la fecha D

#### Scenario: Arranque
- **WHEN** la app se inicia
- **THEN** la pestaña activa es Log con la fecha de hoy

### Requirement: Los modales cubren el bar
El bar SHALL estar visible en las cuatro pestañas. Mientras haya un modal abierto sobre ellas (el editor de nota o la hoja de suscripción), el bar SHALL quedar cubierto por el modal y su barrera, sin poder recibir toques, y SHALL volver a estar disponible al cerrar el modal.

#### Scenario: Visible en el Log
- **WHEN** el usuario está en el Log sin ningún modal abierto
- **THEN** el bar está visible y sus pestañas reciben toques

#### Scenario: Cubierto por la hoja de suscripción
- **WHEN** el usuario abre la hoja de suscripción
- **THEN** el bar no recibe toques ni aparece como control disponible, y vuelve a estarlo al cerrar la hoja

### Requirement: El recordatorio abre el selector de la fecha del recordatorio
Al tocar la notificación del recordatorio diario, la app SHALL cerrar cualquier modal abierto, activar la pestaña Log y mostrar la fecha del recordatorio, estuviera la app cerrada o abierta en otra pestaña.

#### Scenario: App abierta en otra pestaña
- **WHEN** el usuario está en la pestaña de Ajustes y toca la notificación del recordatorio
- **THEN** la app activa la pestaña Log con la fecha del recordatorio

#### Scenario: App abierta con un modal
- **WHEN** hay la hoja de suscripción abierta y el usuario toca la notificación del recordatorio
- **THEN** la hoja se cierra y la app muestra el Log con la fecha del recordatorio

### Requirement: Pantallas de pestaña con título y sin flecha de regresar
Calendar, Insights y Settings SHALL mostrar su título en peso medio y color de tinta, y NO SHALL mostrar un botón de regresar en su encabezado. El título del calendario SHALL ser "Calendario" (o su traducción) en todos los idiomas soportados.

#### Scenario: Encabezado de Ajustes
- **WHEN** el usuario está en la pestaña de Ajustes
- **THEN** el encabezado muestra el título de Ajustes y ninguna flecha de regresar

#### Scenario: Encabezado del calendario
- **WHEN** el usuario está en la pestaña del calendario
- **THEN** el encabezado muestra el título "Calendario" en el idioma del dispositivo y ninguna flecha de regresar

## REMOVED Requirements

### Requirement: Apariencia del bar como cápsula translúcida flotante
**Reason**: La barra pasa de cápsula translúcida a cápsula oscura de tinta.
**Migration**: Sustituida por "Apariencia del bar como cápsula oscura flotante".

### Requirement: Guardar cambia a la pestaña del calendario
**Reason**: Guardar ahora deja al usuario en el Log con el estado "Saved".
**Migration**: El comportamiento tras guardar se define en `home-mood-log` ("Estado Saved").
