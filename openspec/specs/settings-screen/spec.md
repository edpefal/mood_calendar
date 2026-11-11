# settings-screen Specification

## Purpose

Define la pantalla de Settings de Mood Calendar: cómo se llega a ella desde el bottom bar y qué opciones ofrece (recordatorio diario, calificar la app, política de privacidad y versión), para que los ajustes tengan un lugar estable y descubrible.
## Requirements
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

### Requirement: Configuración del recordatorio diario con autoguardado
Settings SHALL incluir una sección "Recordatorios" con un switch para activar o desactivar el recordatorio diario y una fila para elegir su hora. Cada cambio SHALL guardarse y aplicarse al instante, sin botón de guardar. Al activar el recordatorio o cambiar su hora se SHALL reprogramar la notificación; al desactivarlo se SHALL cancelar. La fila de hora SHALL estar deshabilitada mientras el recordatorio esté desactivado.

#### Scenario: Estado inicial
- **WHEN** el usuario abre Settings
- **THEN** el switch y la hora muestran los valores guardados actualmente

#### Scenario: Activar el recordatorio
- **WHEN** el usuario activa el switch
- **THEN** el valor se guarda y la notificación diaria se programa a la hora guardada

#### Scenario: Desactivar el recordatorio
- **WHEN** el usuario desactiva el switch
- **THEN** el valor se guarda, la notificación diaria se cancela y la fila de hora queda deshabilitada

#### Scenario: Cambiar la hora
- **WHEN** el recordatorio está activado y el usuario elige una nueva hora en el selector
- **THEN** la nueva hora se guarda y la notificación se reprograma a esa hora

#### Scenario: Cancelar el selector de hora
- **WHEN** el usuario cierra el selector de hora sin elegir una hora
- **THEN** la hora guardada y la notificación programada no cambian

#### Scenario: Los cambios persisten
- **WHEN** el usuario cambia un ajuste, sale de Settings y vuelve a abrirla
- **THEN** la pantalla muestra el ajuste cambiado

### Requirement: Entrada manual para calificar en Settings
Settings SHALL incluir una fila "Calificar Mood Calendar" con el comportamiento definido en la capability `rating-prompt`.

#### Scenario: Fila de calificar visible
- **WHEN** el usuario abre Settings
- **THEN** la fila "Calificar Mood Calendar" está visible en la sección de ayuda y acerca de

### Requirement: Enlace a la política de privacidad
Settings SHALL incluir una fila "Política de privacidad" que abre en el navegador externo del dispositivo la política de privacidad publicada de Mood Calendar. Si el enlace no puede abrirse, la app SHALL informar al usuario con un mensaje y NO SHALL fallar.

#### Scenario: Abrir la política
- **WHEN** el usuario toca "Política de privacidad"
- **THEN** la política de privacidad de Mood Calendar se abre en el navegador externo

#### Scenario: No se puede abrir el enlace
- **WHEN** el usuario toca "Política de privacidad" y el sistema no puede abrir el enlace
- **THEN** la app muestra un mensaje indicando que no se pudo abrir y permanece en Settings

### Requirement: Versión de la app visible
Settings SHALL mostrar la versión de la app (nombre de versión y número de build) en una fila informativa no interactiva.

#### Scenario: Versión mostrada
- **WHEN** el usuario abre Settings en un build con versión 1.8.3 y build 28
- **THEN** se muestra la versión 1.8.3 (28)

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

### Requirement: Interruptor de datos de uso anónimos
Settings SHALL incluir un interruptor "Compartir datos de uso anónimos", activado por defecto, con una breve explicación de que solo se mide el uso general de la app y nunca las entradas. Al cambiarlo SHALL guardarse y aplicarse al instante, sin botón de guardar, y si el guardado falla SHALL revertirse con un mensaje, igual que el recordatorio diario. El interruptor SHALL tener label de `Semantics` y su texto SHALL estar localizado en todos los idiomas soportados.

#### Scenario: Estado inicial
- **WHEN** el usuario abre Settings por primera vez
- **THEN** el interruptor aparece activado

#### Scenario: Desactivar los datos de uso
- **WHEN** el usuario desactiva el interruptor
- **THEN** la preferencia se guarda y deja de enviarse la medición de uso

#### Scenario: Fallo al guardar
- **WHEN** el guardado de la preferencia falla
- **THEN** el interruptor vuelve a su valor anterior y se muestra un mensaje de error

#### Scenario: Texto en el idioma del dispositivo
- **WHEN** el dispositivo está en alemán, francés, italiano, español o inglés
- **THEN** la fila del interruptor y su explicación se muestran en ese idioma

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

### Requirement: Fila de bloqueo de notas en Privacy and data
La sección Privacy and data de Settings SHALL incluir, antes del interruptor de datos de uso anónimos, una fila con un interruptor para bloquear las notas, con ícono, título, un detalle que indica que se usa la biometría o el código del dispositivo, la marca "Pro" mientras el usuario no tenga suscripción activa y un área táctil de al menos 44 pt. El comportamiento del interruptor lo define la capacidad `note-lock`. Si el bloqueo está activo pero el dispositivo no tiene autenticación configurada, la fila SHALL explicarlo en su detalle.

#### Scenario: Ver la fila
- **WHEN** el usuario sin suscripción abre Settings
- **THEN** la sección Privacy and data muestra la fila del bloqueo de notas con la marca "Pro" y el interruptor apagado

#### Scenario: Suscriptor
- **WHEN** un suscriptor abre Settings
- **THEN** la fila del bloqueo de notas no muestra la marca "Pro"

#### Scenario: Bloqueo sin autenticación disponible
- **WHEN** el bloqueo está activo y el dispositivo ya no tiene biometría ni código
- **THEN** el detalle de la fila indica que hay que configurar un código en el dispositivo

### Requirement: Activar el recordatorio pide el permiso de notificaciones si hace falta
Al activar el recordatorio diario en Settings, si el sistema aún no ha decidido el permiso de notificaciones, la app SHALL pedirlo. Si el usuario lo niega, el interruptor SHALL volver a apagado con un mensaje. Si el permiso ya estaba concedido, NO SHALL pedirse de nuevo.

#### Scenario: Activar tras omitir el onboarding
- **WHEN** un usuario que omitió el permiso en el onboarding activa el recordatorio en Settings
- **THEN** el sistema muestra el diálogo del permiso

#### Scenario: Permiso negado
- **WHEN** el usuario niega el permiso tras activar el recordatorio
- **THEN** el interruptor vuelve a apagado y se muestra un mensaje

#### Scenario: Permiso ya concedido
- **WHEN** el usuario activa el recordatorio con el permiso ya concedido
- **THEN** el recordatorio se programa sin mostrar ningún diálogo

