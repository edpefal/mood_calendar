# settings-screen Specification

## Purpose

Define la pantalla de Settings de Mood Calendar: cómo se llega a ella desde el bottom bar y qué opciones ofrece (recordatorio diario, calificar la app, política de privacidad y versión), para que los ajustes tengan un lugar estable y descubrible.

## Requirements
### Requirement: Acceso a Settings desde la pantalla principal
Settings SHALL ser la cuarta pestaña del bottom bar, con un icono de engrane, y abrirse al tocarla. La pantalla principal NO SHALL mostrar un engrane en su header. Settings NO SHALL mostrar un botón de regresar. El calendario NO SHALL ofrecer acceso a la configuración de recordatorios.

#### Scenario: Abrir Settings
- **WHEN** el usuario toca la pestaña de ajustes del bottom bar
- **THEN** se muestra la pantalla de Settings

#### Scenario: Orden de las pestañas
- **WHEN** se muestra el bottom bar
- **THEN** la pestaña de ajustes es la última, a la derecha de moods, calendario y tienda

#### Scenario: El calendario no tiene acceso a recordatorios
- **WHEN** el usuario está en la vista del calendario
- **THEN** el header no muestra el icono de campana ni ningún control que abra la configuración de recordatorios

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
Todos los textos de Settings (título, secciones, filas, mensajes y tooltip del engrane) SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo. Todo control interactivo SHALL exponer una etiqueta de `Semantics`.

#### Scenario: Dispositivo en alemán
- **WHEN** el idioma del dispositivo es alemán y el usuario abre Settings
- **THEN** el título, las secciones y las filas se muestran en alemán

#### Scenario: Idioma no soportado
- **WHEN** el idioma del dispositivo no está soportado (por ejemplo, portugués)
- **THEN** Settings se muestra en inglés

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla recorre la pantalla principal y Settings
- **THEN** el engrane, el switch, la fila de hora y las filas de calificar y privacidad se anuncian con una etiqueta que describe su acción

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
