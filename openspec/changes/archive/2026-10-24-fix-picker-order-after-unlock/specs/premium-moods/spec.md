## MODIFIED Requirements

### Requirement: Selección bloqueada en el carrusel diario
El carrusel de selección diaria SHALL mostrar todos los Moods del catálogo (base y premium), marcando visualmente los Moods premium no `unlocked`. Al intentar seleccionar un Mood no `unlocked` para registrar o editar la entrada del día, el sistema SHALL impedir guardar esa entrada y SHALL iniciar el flujo de compra de ese Mood en su lugar.

El carrusel SHALL ordenar sus Moods en dos grupos consecutivos: primero los Moods `unlocked`, ordenados por cantidad de Mood Entry guardadas con ese Mood (todo el historial) de mayor a menor; después los Moods no `unlocked`, en el orden del catálogo. Entre Moods `unlocked` con la misma cantidad de Mood Entry, el sistema SHALL conservar el orden del catálogo. El orden SHALL NOT depender de `intensity`.

El sistema SHALL calcular este orden al abrir el selector y cada vez que el usuario regresa a la pestaña del selector desde otra pestaña, de modo que refleje las compras, las restauraciones y las entradas guardadas desde la última vez. Al recalcularlo, el sistema SHALL conservar la fecha del selector, el Mood seleccionado (aunque cambie de posición) y la nota sin guardar. El sistema SHALL NOT modificar el orden mientras el selector permanece visible.

#### Scenario: Usuario toca un Mood bloqueado
- **WHEN** el usuario toca un Mood premium no `unlocked` en el carrusel
- **THEN** el sistema no permite seleccionarlo para guardar la entrada del día y muestra el flujo de compra de ese Mood

#### Scenario: Usuario selecciona un Mood desbloqueado
- **WHEN** el usuario toca un Mood `base` o un Mood premium ya `unlocked`
- **THEN** el sistema permite seleccionarlo normalmente para registrar o editar la entrada del día

#### Scenario: Primer uso sin historial
- **WHEN** el usuario abre la pantalla de selección sin ninguna Mood Entry guardada
- **THEN** el carrusel muestra los Moods en el orden del catálogo, con los premium no `unlocked` al final

#### Scenario: Moods desbloqueados ordenados por frecuencia
- **WHEN** el usuario tiene 3 Mood Entry con `calm`, 1 con `happy` y ninguna con los demás Moods `base`
- **THEN** el carrusel muestra primero `calm`, luego `happy`, luego los demás Moods `base` en el orden del catálogo

#### Scenario: Empate de frecuencia
- **WHEN** dos Moods `unlocked` tienen la misma cantidad de Mood Entry
- **THEN** el que aparece antes en el catálogo se muestra primero

#### Scenario: Mood premium comprado entra al grupo ordenado
- **WHEN** el usuario compró un Mood premium y tiene Mood Entry con él
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
- **WHEN** el selector está visible y cambia el historial o el estado `unlocked` de un Mood, por ejemplo al completar una compra iniciada desde un Mood bloqueado
- **THEN** el orden del carrusel no cambia hasta que el usuario sale de la pestaña del selector y regresa

#### Scenario: Compra en la Tienda reordena al volver
- **WHEN** el usuario compra un Mood o un Pack en la Tienda y regresa a la pestaña del selector
- **THEN** los Moods recién desbloqueados aparecen entre los Moods `unlocked`, antes de los bloqueados

#### Scenario: Restaurar compras reordena al volver
- **WHEN** el usuario restaura sus compras en la Tienda y regresa a la pestaña del selector
- **THEN** los Moods restaurados aparecen entre los Moods `unlocked`, antes de los bloqueados

#### Scenario: Reordenar conserva la selección sin guardar
- **WHEN** el usuario tiene un Mood seleccionado y una nota sin guardar, cambia de pestaña, compra un Mood y regresa al selector
- **THEN** el Mood seleccionado, la fecha y la nota siguen iguales, y el carrusel está posicionado en ese Mood en su nueva posición
