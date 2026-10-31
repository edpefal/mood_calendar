## MODIFIED Requirements

### Requirement: Estado de desbloqueo por usuario
El sistema SHALL determinar el estado `unlocked` de cada Mood premium por usuario: `true` si el usuario tiene una suscripción activa, o si compró ese Mood individualmente o compró un Pack que lo incluye en una versión anterior; `false` en caso contrario. Todo Mood `base` SHALL ser `unlocked` para cualquier usuario.

#### Scenario: Mood premium desbloqueado por suscripción
- **WHEN** el usuario tiene una suscripción activa
- **THEN** todos los Moods premium se reportan como `unlocked` para ese usuario

#### Scenario: Mood premium desbloqueado por compra individual heredada
- **WHEN** el usuario compró un Mood premium de forma individual en una versión anterior y no tiene suscripción
- **THEN** ese Mood se reporta como `unlocked` y los demás Moods premium no

#### Scenario: Mood premium desbloqueado vía Pack heredado
- **WHEN** el usuario compró un Pack que incluye un Mood premium en una versión anterior y no tiene suscripción
- **THEN** ese Mood se reporta como `unlocked` para ese usuario

#### Scenario: Mood premium sin suscripción ni compra
- **WHEN** el usuario no tiene suscripción activa ni compró un Mood o Pack en una versión anterior
- **THEN** todos los Moods premium se reportan como no `unlocked`

### Requirement: Selección bloqueada en el carrusel diario
El carrusel de selección diaria SHALL mostrar todos los Moods del catálogo (base y premium), marcando visualmente los Moods premium no `unlocked`. Al intentar seleccionar un Mood no `unlocked` para registrar o editar la entrada del día, el sistema SHALL impedir guardar esa entrada y SHALL abrir la hoja de suscripción en su lugar. La única excepción es una fecha que ya tiene una Mood Entry con ese mismo Mood: en ese caso el sistema SHALL permitir guardar los cambios de la nota sin pedir suscripción, siempre que el Mood de la entrada no cambie.

El carrusel SHALL ordenar sus Moods en dos grupos consecutivos: primero los Moods `unlocked`, ordenados por cantidad de Mood Entry guardadas con ese Mood (todo el historial) de mayor a menor; después los Moods no `unlocked`, en el orden del catálogo. Entre Moods `unlocked` con la misma cantidad de Mood Entry, el sistema SHALL conservar el orden del catálogo. El orden SHALL NOT depender de `intensity`.

El sistema SHALL calcular este orden al abrir el selector y cada vez que el usuario regresa a la pestaña del selector desde otra pestaña, de modo que refleje las suscripciones, las restauraciones y las entradas guardadas desde la última vez. Al recalcularlo, el sistema SHALL conservar la fecha del selector, el Mood seleccionado (aunque cambie de posición) y la nota sin guardar. El sistema SHALL NOT modificar el orden mientras el selector permanece visible.

#### Scenario: Usuario toca un Mood bloqueado
- **WHEN** el usuario toca el Mood premium no `unlocked` que está seleccionado en el carrusel
- **THEN** el sistema no permite seleccionarlo para guardar la entrada del día y abre la hoja de suscripción

#### Scenario: Usuario selecciona un Mood desbloqueado
- **WHEN** el usuario toca un Mood `base` o un Mood premium ya `unlocked`
- **THEN** el sistema permite seleccionarlo normalmente para registrar o editar la entrada del día

#### Scenario: Guardar con un Mood bloqueado distinto
- **WHEN** el usuario tiene seleccionado un Mood premium no `unlocked` que es distinto del Mood de la entrada de esa fecha (o la fecha no tiene entrada) y toca Guardar
- **THEN** no se guarda nada y se abre la hoja de suscripción

#### Scenario: Editar la nota con el mismo Mood caducado
- **WHEN** la fecha ya tiene una Mood Entry con un Mood premium que ya no está `unlocked`, el usuario cambia solo la nota y toca Guardar
- **THEN** la nota se guarda, el Mood de la entrada no cambia y no se abre la hoja de suscripción

#### Scenario: Cambiar a otro Mood premium bloqueado
- **WHEN** la fecha tiene una entrada con un Mood premium caducado y el usuario selecciona otro Mood premium bloqueado y toca Guardar
- **THEN** no se guarda nada y se abre la hoja de suscripción

#### Scenario: Primer uso sin historial
- **WHEN** el usuario abre la pantalla de selección sin ninguna Mood Entry guardada
- **THEN** el carrusel muestra los Moods en el orden del catálogo, con los premium no `unlocked` al final

#### Scenario: Moods desbloqueados ordenados por frecuencia
- **WHEN** el usuario tiene 3 Mood Entry con `calm`, 1 con `happy` y ninguna con los demás Moods `base`
- **THEN** el carrusel muestra primero `calm`, luego `happy`, luego los demás Moods `base` en el orden del catálogo

#### Scenario: Empate de frecuencia
- **WHEN** dos Moods `unlocked` tienen la misma cantidad de Mood Entry
- **THEN** el que aparece antes en el catálogo se muestra primero

#### Scenario: Mood premium desbloqueado entra al grupo ordenado
- **WHEN** el usuario tiene una suscripción activa y Mood Entry con un Mood premium
- **THEN** ese Mood se ordena por su frecuencia junto con los demás Moods `unlocked`, y no al final con los bloqueados

#### Scenario: Moods bloqueados al final
- **WHEN** el usuario tiene Moods premium no `unlocked`
- **THEN** se muestran después de todos los Moods `unlocked`, en el orden del catálogo, sin importar si tienen Mood Entry históricas

#### Scenario: Mood preseleccionado en una fecha sin entrada
- **WHEN** el usuario abre una fecha sin Mood Entry
- **THEN** el Mood seleccionado inicialmente es el primero del carrusel ordenado

#### Scenario: Fecha con entrada existente
- **WHEN** el usuario abre una fecha que ya tiene una Mood Entry
- **THEN** el carrusel se posiciona en el Mood de esa entrada, esté en la posición que esté

#### Scenario: El orden no cambia con el selector visible
- **WHEN** el selector está visible y cambia el historial o el estado `unlocked` de un Mood, por ejemplo al completar una suscripción iniciada desde un Mood bloqueado
- **THEN** el orden del carrusel no cambia hasta que el usuario sale de la pestaña del selector y regresa

#### Scenario: Suscribirse en Premium reordena al volver
- **WHEN** el usuario se suscribe en la pestaña Premium y regresa a la pestaña del selector
- **THEN** los Moods premium aparecen entre los Moods `unlocked`, antes de los bloqueados, ordenados por frecuencia

#### Scenario: Restaurar compras reordena al volver
- **WHEN** el usuario restaura sus compras en la pestaña Premium y regresa a la pestaña del selector
- **THEN** los Moods restaurados aparecen entre los Moods `unlocked`, antes de los bloqueados

#### Scenario: Reordenar conserva la selección sin guardar
- **WHEN** el usuario tiene un Mood seleccionado y una nota sin guardar, cambia de pestaña, se suscribe y regresa al selector
- **THEN** el Mood seleccionado, la fecha y la nota siguen iguales, y el carrusel está posicionado en ese Mood en su nueva posición

### Requirement: El desbloqueo no reescribe el historial
Un cambio en el estado `unlocked` de un Mood (incluida su pérdida, por ejemplo tras vencer una suscripción, un fallo de pago o un reembolso) SHALL afectar únicamente la capacidad de crear o editar entradas nuevas con ese Mood. El sistema SHALL NOT ocultar, modificar ni invalidar entradas (Mood Entry) ya guardadas con ese Mood.

#### Scenario: Pérdida de desbloqueo no afecta entradas pasadas
- **WHEN** un Mood premium pierde su estado `unlocked` después de que el usuario ya registró días con ese Mood
- **THEN** esas entradas ya guardadas siguen mostrándose sin cambios en el calendario y el historial

#### Scenario: Vencimiento de la suscripción
- **WHEN** la suscripción vence y el usuario abre el calendario y el resumen mensual
- **THEN** las entradas con Moods premium se muestran igual, y el mood más frecuente y la mejor racha las siguen contando

### Requirement: El carrusel indica que se puede deslizar
El carrusel SHALL mostrar parte de los Moods vecinos al seleccionado (anterior y siguiente), más pequeños y atenuados, para que sea evidente que hay más opciones a los lados. Junto al contador SHALL haber un botón "anterior" y otro "siguiente", con etiqueta de accesibilidad, que mueven el carrusel un Mood; el de "anterior" SHALL estar deshabilitado en el primer Mood y el de "siguiente" en el último. En pantallas anchas (iPad) el ancho de cada página SHALL limitarse para que los vecinos queden cerca del seleccionado y no pegados a los bordes de la pantalla. Solo el Mood seleccionado SHALL mostrar su nombre.

Tocar un Mood vecino SHALL centrarlo sin abrir la suscripción, aunque esté bloqueado. Tocar el Mood seleccionado, si está bloqueado, SHALL abrir la hoja de suscripción.

#### Scenario: Se ven los vecinos
- **WHEN** el selector está en el segundo Mood
- **THEN** se ven, más pequeños y atenuados, el primero a la izquierda y el tercero a la derecha, sin sus nombres

#### Scenario: Pantalla ancha
- **WHEN** el selector se muestra en una pantalla de 1032 pt de ancho
- **THEN** cada página mide 240 pt como máximo y los Moods vecinos se ven cerca del seleccionado

#### Scenario: Girar la pantalla
- **WHEN** el usuario gira el dispositivo con el tercer Mood seleccionado
- **THEN** el ancho de página se ajusta al nuevo ancho y el tercer Mood sigue seleccionado

#### Scenario: Flechas
- **WHEN** el usuario toca el botón "siguiente"
- **THEN** el carrusel avanza un Mood y el contador aumenta en uno

#### Scenario: Flechas en los extremos
- **WHEN** el carrusel está en el primer Mood
- **THEN** el botón "anterior" está deshabilitado

#### Scenario: Tocar un vecino bloqueado
- **WHEN** el usuario toca un Mood premium bloqueado que es vecino del seleccionado
- **THEN** el carrusel lo centra y no se abre la hoja de suscripción

#### Scenario: Tocar el seleccionado bloqueado
- **WHEN** el Mood premium bloqueado ya está seleccionado y el usuario lo toca
- **THEN** se abre la hoja de suscripción

### Requirement: Selección rápida desde la hoja de todos los moods
El selector SHALL ofrecer un botón, con etiqueta de accesibilidad, que abre una hoja inferior con todos los Moods del carrusel en una cuadrícula. La hoja SHALL usar exactamente el orden vigente del carrusel (Moods `unlocked` primero, bloqueados al final) y SHALL NOT recalcularlo. Debe marcar el Mood actualmente seleccionado y mostrar los bloqueados atenuados con candado.

Al tocar un Mood `unlocked`, la hoja SHALL cerrarse y el carrusel SHALL posicionarse en ese Mood, quedando seleccionado; la fecha, la nota sin guardar y el resto del estado del selector SHALL conservarse. Al tocar un Mood no `unlocked`, el sistema SHALL abrir la hoja de suscripción sin cambiar el Mood seleccionado.

#### Scenario: Abrir la hoja
- **WHEN** el usuario toca el botón de la cuadrícula
- **THEN** se muestra una hoja con todos los Moods en el mismo orden que el carrusel y el Mood actual marcado

#### Scenario: Saltar a un mood lejano
- **WHEN** el usuario toca en la hoja un Mood `unlocked` que está en la posición 12 del carrusel
- **THEN** la hoja se cierra, el carrusel muestra ese Mood, el contador indica "12 / M" y el Mood queda seleccionado para guardar

#### Scenario: El estado del selector se conserva
- **WHEN** el usuario tiene una nota sin guardar y salta a otro Mood desde la hoja
- **THEN** la nota sin guardar y la fecha siguen igual

#### Scenario: Mood bloqueado en la hoja
- **WHEN** el usuario toca en la hoja un Mood premium no `unlocked`
- **THEN** se abre la hoja de suscripción y el Mood seleccionado no cambia

#### Scenario: La hoja respeta el orden congelado
- **WHEN** el historial o el estado `unlocked` cambian mientras el selector está visible
- **THEN** la hoja muestra el mismo orden que el carrusel, sin reordenarse

#### Scenario: Texto grande del sistema
- **WHEN** el texto del sistema está al 200 % y el usuario abre la hoja
- **THEN** los nombres de los Moods se muestran sin desbordes y la hoja puede desplazarse para alcanzar todos
