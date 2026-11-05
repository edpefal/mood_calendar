## Purpose

Define la identidad visual de Mood Calendar (tinta de marca, fondo de malla pastel, tarjetas de vidrio) y el tema claro, oscuro o del sistema, para que toda la app se vea y se comporte igual con cualquier preferencia del usuario.

## ADDED Requirements

### Requirement: Identidad visual de la app
La app SHALL usar una tinta casi negra como color de las acciones principales (botones primarios, barra de pestañas, controles activos) sobre un fondo de malla de degradados pastel, con las superficies de contenido como tarjetas de vidrio translúcido de esquinas redondeadas. La tipografía SHALL ser Poppins. Los botones primarios SHALL ser píldoras de tinta con texto blanco. El texto sobre las superficies SHALL cumplir un contraste de al menos 4.5:1 en el tema claro y en el oscuro.

#### Scenario: Botón primario
- **WHEN** una pantalla muestra su acción principal (por ejemplo Guardar)
- **THEN** es una píldora de tinta con texto blanco, con contraste de al menos 4.5:1

#### Scenario: Tarjetas de vidrio
- **WHEN** una pantalla muestra una tarjeta de contenido sobre el fondo
- **THEN** la tarjeta es translúcida, con borde claro y esquinas redondeadas, y el fondo se distingue tras ella

#### Scenario: Sin color de marca anterior
- **WHEN** el usuario recorre cualquier pantalla de la app
- **THEN** ningún control ni título usa el cian ni el morado de las marcas anteriores como color de marca

### Requirement: Alternativa opaca para accesibilidad
Cuando el sistema pide reducir la transparencia o el contraste alto, las tarjetas y la barra de pestañas SHALL mostrarse con un relleno opaco del mismo tono, sin desenfoque, conservando el mismo contenido y la misma disposición.

#### Scenario: Reducir transparencia
- **WHEN** el usuario tiene activada la opción de reducir la transparencia del sistema
- **THEN** las tarjetas se muestran opacas y legibles, sin desenfoque

### Requirement: Tema claro, oscuro o del sistema
La app SHALL ofrecer tres temas: Sistema (por defecto), Claro y Oscuro. Con Sistema, la app SHALL seguir el modo del dispositivo y cambiar si este cambia mientras la app está abierta. La elección SHALL guardarse localmente, aplicarse al instante en toda la app sin reiniciarla y conservarse entre sesiones. El tema oscuro SHALL cubrir todas las pantallas, hojas y modales, con su propia malla de fondo y sus tintes por categoría.

#### Scenario: Primer arranque
- **WHEN** el usuario abre la app por primera vez
- **THEN** el tema es Sistema y la app se ve en el modo que tiene el dispositivo

#### Scenario: Forzar oscuro
- **WHEN** el usuario elige Oscuro en Ajustes con el dispositivo en modo claro
- **THEN** toda la app cambia a oscuro al instante y sigue así al reabrirla

#### Scenario: Seguir al sistema
- **WHEN** el tema es Sistema y el dispositivo cambia de claro a oscuro con la app abierta
- **THEN** la app cambia a oscuro sin reiniciarse

#### Scenario: Fallo al guardar
- **WHEN** el guardado de la preferencia falla
- **THEN** el tema vuelve a su valor anterior y se muestra un mensaje de error

#### Scenario: Hojas y modales
- **WHEN** el tema es Oscuro y el usuario abre el editor de nota o la hoja de suscripción
- **THEN** ambos se muestran con los colores del tema oscuro

### Requirement: Texto grande y áreas táctiles
Las pantallas y componentes del sistema visual SHALL mostrarse sin desbordes con el texto del sistema hasta el 200 % en pantallas desde 390 pt de ancho, desplazándose en vertical cuando el contenido no quepa, y todo control interactivo SHALL tener un área táctil de al menos 44 × 44 pt y una etiqueta de `Semantics`.

#### Scenario: Texto al 200 %
- **WHEN** el texto del sistema está al 200 % en una pantalla de 390 × 844 pt
- **THEN** ninguna pantalla desborda y los controles principales son alcanzables desplazando

#### Scenario: Control pequeño
- **WHEN** un control es visualmente menor de 44 pt
- **THEN** su área táctil sigue siendo de al menos 44 × 44 pt

### Requirement: Diseño de teléfono centrado en pantallas anchas
En pantallas más anchas que el teléfono (iPad), la app SHALL conservar el diseño de teléfono centrado con un ancho máximo del contenido y de la barra de pestañas, sin una disposición propia para tablet.

#### Scenario: iPad
- **WHEN** la app corre en una pantalla de 1032 pt de ancho
- **THEN** el contenido y la barra de pestañas quedan centrados con su ancho máximo y el fondo ocupa toda la pantalla
