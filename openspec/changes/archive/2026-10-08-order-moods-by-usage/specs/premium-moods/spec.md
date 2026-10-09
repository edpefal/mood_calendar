## MODIFIED Requirements

### Requirement: Selección bloqueada en el carrusel diario
El carrusel de selección diaria SHALL mostrar todos los Moods del catálogo (base y premium), marcando visualmente los Moods premium no `unlocked`. Al intentar seleccionar un Mood no `unlocked` para registrar o editar la entrada del día, el sistema SHALL impedir guardar esa entrada y SHALL iniciar el flujo de compra de ese Mood en su lugar.

El carrusel SHALL ordenar sus Moods en dos grupos consecutivos: primero los Moods `unlocked`, ordenados por cantidad de Mood Entry guardadas con ese Mood (todo el historial) de mayor a menor; después los Moods no `unlocked`, en el orden del catálogo. Entre Moods `unlocked` con la misma cantidad de Mood Entry, el sistema SHALL conservar el orden del catálogo. El orden SHALL NOT depender de `intensity`.

El sistema SHALL calcular este orden al abrir la pantalla y SHALL NOT modificarlo mientras la pantalla permanece abierta.

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

#### Scenario: El orden no cambia con la pantalla abierta
- **WHEN** la pantalla de selección está abierta y cambia el historial o el estado `unlocked` de un Mood
- **THEN** el orden del carrusel no cambia hasta que la pantalla se vuelve a abrir
