## ADDED Requirements

### Requirement: Indicador de posición del carrusel
El selector SHALL indicar la posición del Mood visible con un contador "N / M" (N = posición 1-based, M = total de Moods del carrusel) en lugar de un punto por Mood. El indicador SHALL ocupar el mismo espacio sin importar el total y SHALL NOT desbordar con cualquier cantidad de Moods en pantallas desde 390 pt de ancho. El contador SHALL excluirse del árbol de accesibilidad como elemento aparte, porque la posición ya se anuncia en la etiqueta del carrusel.

#### Scenario: Contador con muchos moods
- **WHEN** el catálogo tiene 15 Moods y el carrusel muestra el tercero
- **THEN** el indicador muestra "3 / 15" y no hay desbordes

#### Scenario: El contador sigue al carrusel
- **WHEN** el usuario desliza al siguiente Mood
- **THEN** el contador avanza una posición

### Requirement: El carrusel indica que se puede deslizar
El carrusel SHALL mostrar parte de los Moods vecinos al seleccionado (anterior y siguiente), más pequeños y atenuados, para que sea evidente que hay más opciones a los lados. Junto al contador SHALL haber un botón "anterior" y otro "siguiente", con etiqueta de accesibilidad, que mueven el carrusel un Mood; el de "anterior" SHALL estar deshabilitado en el primer Mood y el de "siguiente" en el último. En pantallas anchas (iPad) el ancho de cada página SHALL limitarse para que los vecinos queden cerca del seleccionado y no pegados a los bordes de la pantalla. Solo el Mood seleccionado SHALL mostrar su nombre.

Tocar un Mood vecino SHALL centrarlo sin abrir ninguna compra, aunque esté bloqueado. Tocar el Mood seleccionado, si está bloqueado, SHALL iniciar el flujo de compra como antes.

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
- **THEN** el carrusel lo centra y no se abre la compra

#### Scenario: Tocar el seleccionado bloqueado
- **WHEN** el Mood premium bloqueado ya está seleccionado y el usuario lo toca
- **THEN** se muestra el flujo de compra de ese Mood

### Requirement: Selección rápida desde la hoja de todos los moods
El selector SHALL ofrecer un botón, con etiqueta de accesibilidad, que abre una hoja inferior con todos los Moods del carrusel en una cuadrícula. La hoja SHALL usar exactamente el orden vigente del carrusel (Moods `unlocked` primero, bloqueados al final) y SHALL NOT recalcularlo. Debe marcar el Mood actualmente seleccionado y mostrar los bloqueados atenuados con candado.

Al tocar un Mood `unlocked`, la hoja SHALL cerrarse y el carrusel SHALL posicionarse en ese Mood, quedando seleccionado; la fecha, la nota sin guardar y el resto del estado del selector SHALL conservarse. Al tocar un Mood no `unlocked`, el sistema SHALL iniciar el flujo de compra de ese Mood sin cambiar el Mood seleccionado.

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
- **THEN** se muestra el flujo de compra de ese Mood y el Mood seleccionado no cambia

#### Scenario: La hoja respeta el orden congelado
- **WHEN** el historial o el estado `unlocked` cambian mientras el selector está visible
- **THEN** la hoja muestra el mismo orden que el carrusel, sin reordenarse

#### Scenario: Texto grande del sistema
- **WHEN** el texto del sistema está al 200 % y el usuario abre la hoja
- **THEN** los nombres de los Moods se muestran sin desbordes y la hoja puede desplazarse para alcanzar todos
