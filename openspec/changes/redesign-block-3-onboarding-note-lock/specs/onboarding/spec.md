## Purpose

Guía a quien instala la app por primera vez a fijar la hora del recordatorio, decidir el permiso de notificaciones y guardar su primer mood, para que llegue al Log con el hábito ya empezado y con el permiso pedido en contexto.

## ADDED Requirements

### Requirement: El onboarding solo se muestra en la primera ejecución
La app SHALL mostrar el onboarding en lugar de la pantalla principal únicamente cuando no se ha completado ni omitido antes y el dispositivo no tiene ninguna Mood Entry. Al terminarlo u omitirlo, la app SHALL recordarlo y NO SHALL volver a mostrarlo. Quien ya tiene entradas (por ejemplo, tras actualizar desde una versión anterior) NO SHALL verlo nunca. El onboarding SHALL aparecer sin esperar ningún diálogo del sistema ni tarea lenta.

#### Scenario: Instalación nueva
- **WHEN** el usuario abre la app por primera vez, sin entradas
- **THEN** se muestra el paso 1 del onboarding y no la pantalla principal

#### Scenario: Actualización con historial
- **WHEN** un usuario con entradas abre la versión que incluye el onboarding
- **THEN** va directo al Log y el onboarding no aparece

#### Scenario: Onboarding ya terminado
- **WHEN** el usuario completó el onboarding y reabre la app
- **THEN** va directo al Log

#### Scenario: Onboarding omitido
- **WHEN** el usuario omitió el onboarding y reabre la app
- **THEN** va directo al Log y el onboarding no vuelve a aparecer

#### Scenario: Arranque sin bloqueo
- **WHEN** la app arranca en una instalación nueva
- **THEN** el primer paso se muestra sin que aparezca antes ningún diálogo de permisos

### Requirement: Cuatro pasos con progreso y "Skip"
El onboarding SHALL tener cuatro pasos en este orden: bienvenida, hora del recordatorio, permiso de notificaciones y primer registro. Cada paso SHALL mostrar un indicador de progreso con su posición ("Step n of 4") accesible para lectores de pantalla. Los pasos 1 a 3 SHALL ofrecer "Skip": en el paso 1 sale del onboarding hacia el Log, y en los pasos 2 y 3 salta al paso 4. El paso 4 NO SHALL ofrecer "Skip". En Android, el gesto de regreso del sistema SHALL volver al paso anterior y, en el paso 1, salir de la app.

#### Scenario: Avanzar
- **WHEN** el usuario toca el botón principal de un paso
- **THEN** pasa al siguiente y el indicador avanza una posición

#### Scenario: Omitir desde la bienvenida
- **WHEN** el usuario toca "Skip" en el paso 1
- **THEN** el onboarding termina, se muestra el Log y la app no vuelve a mostrar el onboarding

#### Scenario: Omitir la hora o el permiso
- **WHEN** el usuario toca "Skip" en el paso 2 o en el 3
- **THEN** pasa directo al paso 4

#### Scenario: Sin salida en el primer registro
- **WHEN** el usuario está en el paso 4
- **THEN** no hay "Skip"

### Requirement: Paso 1, bienvenida
El paso 1 SHALL mostrar el título "Track how you feel in 5 seconds a day", una frase de apoyo, una vista previa ilustrativa de un calendario con moods (fija, nunca datos del usuario) y el botón "Get started".

#### Scenario: Ver la bienvenida
- **WHEN** el usuario abre el onboarding
- **THEN** ve el título, la frase de apoyo, la vista previa del calendario y "Get started"

### Requirement: Paso 2, hora del recordatorio
El paso 2 SHALL preguntar "When do you want to check in?" y ofrecer tres horas sugeridas, Morning 9:00, Afternoon 14:00 y Night 20:00, con Night seleccionada al entrar, además de un selector de hora de rueda en el formato de 12 o 24 horas del dispositivo. Elegir una sugerencia SHALL mover el selector a esa hora y mover el selector SHALL dejar las sugerencias sin selección. "Continue" SHALL guardar la hora elegida como hora del recordatorio diario.

#### Scenario: Valor inicial
- **WHEN** el usuario llega al paso 2
- **THEN** Night está seleccionada y el selector muestra las 20:00

#### Scenario: Elegir una sugerencia
- **WHEN** el usuario toca Morning
- **THEN** Morning queda seleccionada y el selector muestra las 9:00

#### Scenario: Ajustar con el selector
- **WHEN** el usuario mueve el selector a las 21:30
- **THEN** ninguna sugerencia queda seleccionada y "Continue" guarda las 21:30

#### Scenario: Omitir la hora
- **WHEN** el usuario toca "Skip" en el paso 2
- **THEN** la hora del recordatorio no cambia

### Requirement: Paso 3, permiso de notificaciones
El paso 3 SHALL explicar el recordatorio ("One reminder a day, that's it") y ofrecer "Turn on reminder" y "Not now". "Turn on reminder" SHALL pedir el permiso de notificaciones al sistema; si se concede, SHALL activar y programar el recordatorio a la hora del paso 2, y si se niega, SHALL dejar el recordatorio desactivado sin mostrar un error. "Not now" y "Skip" SHALL dejar el recordatorio desactivado sin pedir el permiso. En una instalación nueva la app NO SHALL pedir el permiso de notificaciones en ningún otro momento antes de este paso. En los tres casos el onboarding SHALL continuar al paso 4.

#### Scenario: Permiso concedido
- **WHEN** el usuario toca "Turn on reminder" y concede el permiso
- **THEN** el recordatorio queda activo a la hora elegida y se muestra el paso 4

#### Scenario: Permiso negado
- **WHEN** el usuario toca "Turn on reminder" y niega el permiso
- **THEN** el recordatorio queda desactivado, no se muestra ningún error y se muestra el paso 4

#### Scenario: Ahora no
- **WHEN** el usuario toca "Not now"
- **THEN** no aparece el diálogo del sistema, el recordatorio queda desactivado y se muestra el paso 4

#### Scenario: Sin diálogo antes del paso 3
- **WHEN** el usuario recorre los pasos 1 y 2 en una instalación nueva
- **THEN** el sistema no ha mostrado ningún diálogo de permiso de notificaciones

### Requirement: Paso 4, primer registro
El paso 4 SHALL preguntar "How are you feeling right now?" y mostrar únicamente los Moods base, agrupados por categoría en el orden fijo del catálogo, sin candados ni Moods premium y sin ningún mood preseleccionado. "Save my first day" SHALL estar deshabilitado hasta elegir un mood. SHALL ofrecer añadir una nota opcional con el mismo editor del Log. Guardar SHALL crear la Mood Entry de hoy con las mismas reglas que guardar desde el Log (hora de registro incluida) y mostrar una confirmación "Day 1 of your calendar" con el mood elegido y el botón "Continue". El primer guardado NO SHALL pedir la calificación.

#### Scenario: Sin selección
- **WHEN** el usuario llega al paso 4
- **THEN** ningún mood está seleccionado y "Save my first day" está deshabilitado

#### Scenario: Solo moods base
- **WHEN** el usuario ve la cuadrícula del paso 4
- **THEN** todos los Moods base están y ningún Mood premium aparece, ni bloqueado

#### Scenario: Guardar el primer día
- **WHEN** el usuario elige un mood y toca "Save my first day"
- **THEN** se guarda la entrada de hoy y se muestra "Day 1 of your calendar" con el mood elegido

#### Scenario: Con nota
- **WHEN** el usuario escribe una nota antes de guardar
- **THEN** la entrada de hoy se guarda con esa nota

#### Scenario: Sin pedido de calificación
- **WHEN** el usuario guarda su primer día
- **THEN** la app no pide la calificación

### Requirement: El onboarding termina en el Log y ofrece la suscripción una vez
Al tocar "Continue" en la confirmación del paso 4, la app SHALL marcar el onboarding como completado y mostrar el Log en el estado "Saved" de hoy. Si el usuario no tiene suscripción, SHALL abrir la hoja de suscripción una sola vez con `source` igual a `onboarding`; cerrarla SHALL dejar al usuario en el Log sin más avisos. A un suscriptor NO SHALL abrírsele. Omitir el onboarding en el paso 1 NO SHALL abrir la hoja.

#### Scenario: Terminar sin suscripción
- **WHEN** un usuario sin suscripción toca "Continue" en la confirmación
- **THEN** ve el Log en "Saved" y se abre la hoja de suscripción

#### Scenario: Cerrar la hoja
- **WHEN** el usuario cierra la hoja de suscripción abierta por el onboarding
- **THEN** permanece en el Log y la hoja no vuelve a abrirse por sí sola

#### Scenario: Suscriptor
- **WHEN** un suscriptor (por ejemplo, tras restaurar compras) termina el onboarding
- **THEN** ve el Log y la hoja de suscripción no se abre

#### Scenario: Omitir el onboarding
- **WHEN** el usuario toca "Skip" en el paso 1
- **THEN** ve el Log y la hoja de suscripción no se abre

### Requirement: Textos localizados y accesibles del onboarding
Todos los textos del onboarding SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo. Todo control interactivo SHALL exponer una etiqueta de `Semantics`, las sugerencias de hora SHALL anunciar si están seleccionadas, y cada paso SHALL poder desplazarse cuando el texto del sistema es grande, sin recortar el botón principal.

#### Scenario: Dispositivo en español
- **WHEN** el idioma del dispositivo es español y el usuario abre el onboarding
- **THEN** los cuatro pasos se muestran en español

#### Scenario: Texto grande
- **WHEN** el tamaño de texto del sistema es grande
- **THEN** el botón principal de cada paso sigue siendo alcanzable
