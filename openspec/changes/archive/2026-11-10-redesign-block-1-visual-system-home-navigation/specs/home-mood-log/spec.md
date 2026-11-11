## Purpose

Define la pantalla Log, donde el usuario registra su mood del día en una cuadrícula agrupada por categorías, y el estado "Saved" que sigue al guardado, con el atajo para registrar el día anterior.

## ADDED Requirements

### Requirement: Cuadrícula de moods por categorías
El Log SHALL mostrar todos los Moods del catálogo en una cuadrícula de 4 columnas (2 con texto grande del sistema) agrupada por las cuatro categorías, cada una con su nombre como título de sección, en el orden fijo de `mood-categories`. Cada celda SHALL mostrar el ícono y el nombre del Mood sobre el tinte de su categoría. El Mood seleccionado SHALL distinguirse con un anillo y un ícono ligeramente más grande, y los Moods premium no `unlocked` SHALL mostrarse atenuados con una insignia de candado. Un `Semantics` por celda SHALL indicar nombre, si está seleccionada y si está bloqueada.

#### Scenario: Orden y secciones
- **WHEN** el usuario abre el Log
- **THEN** ve las secciones Positive, Peaceful, Neutral y Hard con sus Moods en el orden fijo

#### Scenario: Mood seleccionado
- **WHEN** el usuario toca `calm`
- **THEN** su celda muestra el anillo de selección y su ícono crece, y las demás no

#### Scenario: Moods bloqueados
- **WHEN** el usuario no tiene suscripción
- **THEN** los 8 Moods premium aparecen atenuados con candado y los 11 base aparecen normales

#### Scenario: Texto grande
- **WHEN** el texto del sistema está al 200 %
- **THEN** la cuadrícula pasa a 2 columnas, no desborda y se puede desplazar hasta el botón Guardar

### Requirement: Selección inicial y botón Guardar
Al abrir una fecha sin Mood Entry, el Log SHALL no tener ningún Mood seleccionado y el botón Guardar SHALL estar deshabilitado hasta que el usuario elija uno. Al abrir una fecha con Mood Entry, el Log SHALL mostrar su Mood seleccionado. El botón Guardar SHALL ser una píldora de tinta y SHALL ocupar como máximo el ancho máximo de la barra de pestañas.

#### Scenario: Fecha sin entrada
- **WHEN** el usuario abre el Log en un día sin entrada
- **THEN** ningún Mood está seleccionado y Guardar está deshabilitado

#### Scenario: Elegir un mood
- **WHEN** el usuario toca un Mood desbloqueado
- **THEN** queda seleccionado y Guardar se habilita

#### Scenario: Fecha con entrada
- **WHEN** el usuario abre una fecha que ya tiene una Mood Entry con `sad`
- **THEN** `sad` aparece seleccionado

### Requirement: Mood bloqueado en el Log
Al tocar un Mood premium no `unlocked`, el Log SHALL abrir la hoja de suscripción sin cambiar el Mood seleccionado ni perder la fecha ni la nota sin guardar. Guardar con un Mood bloqueado SHALL NOT ocurrir: la única excepción es una fecha que ya tiene una Mood Entry con ese mismo Mood, en la que se pueden guardar cambios de la nota sin pedir suscripción mientras el Mood no cambie.

#### Scenario: Tocar un Mood bloqueado
- **WHEN** el usuario toca `brave` sin suscripción
- **THEN** se abre la hoja de suscripción y la selección anterior no cambia

#### Scenario: Editar la nota con el mismo Mood caducado
- **WHEN** la fecha tiene una entrada con `brave`, la suscripción venció y el usuario solo cambia la nota y guarda
- **THEN** la nota se guarda, el Mood no cambia y no se abre la hoja

#### Scenario: Cambiar a otro Mood bloqueado
- **WHEN** esa misma fecha tiene `brave` caducado y el usuario toca `confident` (bloqueado)
- **THEN** se abre la hoja de suscripción y no se guarda nada

### Requirement: Píldora de nota
El Log SHALL mostrar encima del botón Guardar una píldora de nota de ancho completo que abre el editor de nota. Su texto SHALL depender de la categoría del Mood seleccionado: "What made your day good?" para Positive y Peaceful, "Something to remember" para Neutral y "What is worrying you?" para Hard (traducidos a los 5 idiomas), y "Add a note (optional)" sin Mood seleccionado. Si ya hay nota, la píldora SHALL mostrarla recortada con un indicador de que existe.

#### Scenario: Pregunta según la categoría
- **WHEN** el usuario selecciona `anxious`
- **THEN** la píldora dice "What is worrying you?" en el idioma del dispositivo

#### Scenario: Sin mood
- **WHEN** no hay Mood seleccionado
- **THEN** la píldora dice "Add a note (optional)"

#### Scenario: Con nota
- **WHEN** la fecha tiene una nota
- **THEN** la píldora muestra el comienzo de la nota y un indicador de nota existente

#### Scenario: Escribir y cerrar el editor
- **WHEN** el usuario escribe texto en el editor y lo cierra con "Done"
- **THEN** la píldora pasa al estado con nota sin necesidad de guardar el mood

#### Scenario: Borrar toda la nota
- **WHEN** el usuario borra todo el texto y cierra el editor
- **THEN** la píldora vuelve a mostrar la pregunta de la categoría

#### Scenario: Etiqueta accesible
- **WHEN** un lector de pantalla enfoca la píldora
- **THEN** la anuncia como botón con su texto localizado, con o sin nota

### Requirement: Estado "Saved"
Tras guardar con éxito, el Log SHALL permanecer en la misma pestaña y SHALL mostrar el estado "Saved": una confirmación con la racha actual ("Saved · N days in a row"), una tarjeta con el Mood de la fecha, su categoría y la nota (o "No note yet."), y un botón "Edit" que vuelve a la cuadrícula conservando el Mood y la nota. Si el guardado falla, el Log SHALL conservar la selección y la nota y mostrar un mensaje de error, sin pasar a "Saved". La racha actual SHALL contar los días consecutivos con entrada que terminan en la fecha guardada.

#### Scenario: Guardado exitoso
- **WHEN** el usuario guarda `calm` hoy y ayer también tenía entrada
- **THEN** el Log muestra "Saved · 2 days in a row" y la tarjeta con `calm`

#### Scenario: Sin nota
- **WHEN** la entrada guardada no tiene nota
- **THEN** la tarjeta dice "No note yet."

#### Scenario: Editar
- **WHEN** el usuario toca "Edit"
- **THEN** vuelve la cuadrícula con el Mood y la nota de la entrada

#### Scenario: Guardado fallido
- **WHEN** el guardado falla
- **THEN** el Log sigue en la cuadrícula con la selección y la nota, y muestra un mensaje de error

#### Scenario: Abrir un día ya registrado
- **WHEN** el usuario abre el Log en hoy y hoy ya tiene entrada
- **THEN** ve el estado "Saved" con su tarjeta

### Requirement: Atajo para registrar el día anterior
El estado "Saved" de hoy SHALL ofrecer "Forgot yesterday? Log it" únicamente si ayer no tiene Mood Entry. Al tocarlo, el Log SHALL mostrar la cuadrícula con la fecha de ayer.

#### Scenario: Ayer sin entrada
- **WHEN** hoy está guardado y ayer no tiene entrada
- **THEN** el atajo aparece

#### Scenario: Ayer con entrada
- **WHEN** hoy y ayer tienen entrada
- **THEN** el atajo no aparece

#### Scenario: Registrar ayer
- **WHEN** el usuario toca el atajo
- **THEN** el Log muestra la cuadrícula con la fecha de ayer y, al guardar, la entrada queda en esa fecha

### Requirement: Encabezado con fecha y saludo sin nombre
El encabezado del Log SHALL mostrar la fecha completa del día en el formato del idioma y debajo un saludo según la hora local ("Good morning" de 5:00 a 11:59, "Good afternoon" de 12:00 a 18:59 y "Good evening" el resto, traducidos a los 5 idiomas), sin nombre del usuario. SHALL incluir un botón con ícono de campana, con etiqueta de accesibilidad, que lleva a Ajustes. La pregunta "How are you feeling today?" SHALL mostrarse al elegir mood en la fecha de hoy.

#### Scenario: Saludo de la tarde
- **WHEN** son las 15:00 locales
- **THEN** el encabezado muestra la fecha y "Good afternoon" en el idioma del dispositivo, sin nombre

#### Scenario: Campana
- **WHEN** el usuario toca la campana
- **THEN** la app activa la pestaña de Ajustes

### Requirement: El Log conserva la fecha entre pestañas
El Log SHALL conservar su fecha, el Mood seleccionado y la nota sin guardar al cambiar de pestaña y volver. La fecha SHALL cambiar solo cuando el usuario toca un día del calendario o usa el atajo de ayer, y SHALL ser hoy al iniciar la app.

#### Scenario: Volver al Log
- **WHEN** el usuario selecciona `calm`, va a Ajustes y vuelve al Log
- **THEN** `calm` sigue seleccionado, con la misma fecha y nota

#### Scenario: Arranque
- **WHEN** la app se inicia
- **THEN** el Log muestra hoy
