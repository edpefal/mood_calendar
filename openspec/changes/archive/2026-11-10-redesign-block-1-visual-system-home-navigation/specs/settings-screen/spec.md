## ADDED Requirements

### Requirement: Secciones y filas de Settings
Settings SHALL organizarse en cinco secciones, en este orden: Premium (la fila Premium y "Restaurar compras"), Reminders (recordatorio diario y hora), Privacy and data (exportar historial y el interruptor de datos de uso anónimos), Appearance (tema) y Help (calificar, enviar comentarios, política de privacidad, términos y versión). Settings NO SHALL mostrar filas de mensaje del recordatorio, idioma, ícono de la app ni respaldo en la nube. Cada fila SHALL tener un ícono en un recuadro de color, su título, un detalle opcional y su control (interruptor, valor o flecha), con un área táctil de al menos 44 pt.

#### Scenario: Orden de las secciones
- **WHEN** el usuario abre Settings
- **THEN** ve las secciones Premium, Reminders, Privacy and data, Appearance y Help en ese orden

#### Scenario: Filas descartadas
- **WHEN** el usuario recorre Settings
- **THEN** no hay filas de mensaje del recordatorio, idioma, ícono de la app ni respaldo

#### Scenario: Idioma de las filas
- **WHEN** el dispositivo está en alemán, francés, italiano, español o inglés
- **THEN** todos los títulos de sección y de fila se muestran en ese idioma

### Requirement: Fila Premium
La sección Premium SHALL mostrar, sin suscripción activa, la fila "Get Premium" con un detalle breve de los beneficios que abre la hoja de suscripción. Con suscripción activa, SHALL mostrar "Premium · Active" con el plan y la fecha de renovación, y abrir los ajustes de suscripciones del sistema. La sección SHALL incluir siempre la fila "Restaurar compras".

#### Scenario: Sin suscripción
- **WHEN** el usuario sin suscripción toca "Get Premium"
- **THEN** se abre la hoja de suscripción

#### Scenario: Suscrito
- **WHEN** el usuario con suscripción activa abre Settings
- **THEN** la fila dice "Premium · Active" y al tocarla se abren los ajustes de suscripciones del sistema

#### Scenario: Restaurar compras
- **WHEN** el usuario toca "Restaurar compras"
- **THEN** se ejecuta la restauración y se informa el resultado

### Requirement: Tema de la app en Settings
La sección Appearance SHALL incluir una fila "Tema" cuyo valor actual (Sistema, Claro u Oscuro) se muestra a la derecha y que permite elegir entre las tres opciones. El cambio SHALL aplicarse y guardarse al instante, sin botón de guardar, y si el guardado falla SHALL revertirse con un mensaje.

#### Scenario: Elegir Oscuro
- **WHEN** el usuario toca la fila Tema y elige Oscuro
- **THEN** la app cambia a oscuro al instante y la fila muestra "Oscuro"

#### Scenario: Valor inicial
- **WHEN** el usuario abre Settings por primera vez
- **THEN** la fila Tema muestra "Sistema"

### Requirement: Enviar comentarios y términos
La sección Help SHALL incluir una fila "Enviar comentarios" que abre el correo del dispositivo dirigido a `support@moodcalendar.app`, y una fila "Términos" que abre en el navegador externo los Términos del sitio en el idioma del dispositivo (con la versión en español si el dispositivo está en español). Si el enlace no puede abrirse, la app SHALL informar con un mensaje y NO SHALL fallar.

#### Scenario: Enviar comentarios
- **WHEN** el usuario toca "Enviar comentarios"
- **THEN** se abre un correo nuevo para `support@moodcalendar.app`

#### Scenario: Abrir los términos
- **WHEN** el usuario toca "Términos" con el dispositivo en español
- **THEN** los Términos en español se abren en el navegador externo

#### Scenario: No se puede abrir
- **WHEN** el sistema no puede abrir el correo o el enlace
- **THEN** la app muestra un mensaje indicando que no se pudo abrir y permanece en Settings

## MODIFIED Requirements

### Requirement: Acceso a Settings desde la pantalla principal
Settings SHALL ser la cuarta pestaña del bottom bar, con un ícono de ajustes, y abrirse al tocarla. El encabezado del Log SHALL ofrecer además un botón de campana que lleva a Settings. Settings NO SHALL mostrar un botón de regresar. El calendario NO SHALL ofrecer acceso a la configuración de recordatorios.

#### Scenario: Abrir Settings
- **WHEN** el usuario toca la pestaña de ajustes del bottom bar
- **THEN** se muestra la pantalla de Settings

#### Scenario: Desde la campana del Log
- **WHEN** el usuario toca la campana del encabezado del Log
- **THEN** se activa la pestaña de Settings

#### Scenario: Orden de las pestañas
- **WHEN** se muestra el bottom bar
- **THEN** la pestaña de ajustes es la última, a la derecha de Calendar, Insights y Log

#### Scenario: El calendario no tiene acceso a recordatorios
- **WHEN** el usuario está en la vista del calendario
- **THEN** el encabezado no muestra ningún control que abra la configuración de recordatorios

#### Scenario: Salir de Settings
- **WHEN** el usuario toca otra pestaña del bottom bar
- **THEN** Settings deja de mostrarse y al volver conserva su estado

### Requirement: Textos localizados y accesibles de Settings
Todos los textos de Settings (título, secciones, filas, mensajes y detalles) SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo. Todo control interactivo SHALL exponer una etiqueta de `Semantics`.

#### Scenario: Dispositivo en alemán
- **WHEN** el idioma del dispositivo es alemán y el usuario abre Settings
- **THEN** el título, las secciones y las filas se muestran en alemán

#### Scenario: Idioma no soportado
- **WHEN** el idioma del dispositivo no está soportado (por ejemplo, portugués)
- **THEN** Settings se muestra en inglés

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla recorre Settings
- **THEN** la campana del Log, el interruptor del recordatorio, la fila de hora, la fila de tema y las filas de calificar, comentarios, privacidad y términos se anuncian con una etiqueta que describe su acción
