# premium-moods Specification

## Purpose
Define el catálogo de moods con niveles (`base` / `premium`) y el estado de desbloqueo por usuario, controlando qué moods puede usar cada usuario para registrar o editar entradas del día.
## Requirements
### Requirement: Catálogo de moods con tier
Todo Mood definido en el catálogo SHALL tener un tier fijo, `base` o `premium`. Los Moods `base` SHALL estar disponibles para cualquier usuario sin necesidad de compra.

#### Scenario: El catálogo incluye ambos tiers
- **WHEN** se consulta el catálogo completo de moods
- **THEN** incluye tanto los moods `base` como los `premium`, cada uno con su tier correspondiente

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

### Requirement: El desbloqueo no reescribe el historial
Un cambio en el estado `unlocked` de un Mood (incluida su pérdida, por ejemplo tras vencer una suscripción, un fallo de pago o un reembolso) SHALL afectar únicamente la capacidad de crear o editar entradas nuevas con ese Mood. El sistema SHALL NOT ocultar, modificar ni invalidar entradas (Mood Entry) ya guardadas con ese Mood.

#### Scenario: Pérdida de desbloqueo no afecta entradas pasadas
- **WHEN** un Mood premium pierde su estado `unlocked` después de que el usuario ya registró días con ese Mood
- **THEN** esas entradas ya guardadas siguen mostrándose sin cambios en el calendario y el historial

#### Scenario: Vencimiento de la suscripción
- **WHEN** la suscripción vence y el usuario abre el calendario y el resumen mensual
- **THEN** las entradas con Moods premium se muestran igual, y el mood más frecuente y la mejor racha las siguen contando

### Requirement: El selector soporta texto grande del sistema
La pantalla del Log SHALL mostrarse sin desbordes visuales con cualquier tamaño de texto que permita el sistema, hasta el 200 %, en pantallas desde 390 pt de ancho. Cuando el contenido no quepa en la altura disponible, la pantalla SHALL poder desplazarse en vertical de modo que el encabezado, la cuadrícula de moods, la píldora de nota y el botón Guardar sean alcanzables. Con tamaños de texto normales la cuadrícula SHALL tener 4 columnas y con texto grande 2.

#### Scenario: Texto al 200 % en iPhone de 390 pt
- **WHEN** el texto del sistema está al 200 % en una pantalla de 390×844 pt y el usuario abre el Log
- **THEN** no hay desbordes y el usuario puede desplazarse hasta el botón Guardar

#### Scenario: Texto al 200 % con idioma de etiquetas largas
- **WHEN** el idioma es alemán, la fecha es larga y el texto está al 200 %
- **THEN** el encabezado, los títulos de categoría y la cuadrícula se muestran completos, sin recortes ni desbordes

#### Scenario: Tamaño de texto normal
- **WHEN** el texto del sistema está al 100 %
- **THEN** la cuadrícula tiene 4 columnas y el botón Guardar queda abajo

#### Scenario: Teclado del editor de nota abierto
- **WHEN** el editor de nota está abierto con el teclado visible
- **THEN** el Log detrás no desborda

### Requirement: Catálogo de 19 moods con 11 base y 8 premium
El catálogo SHALL tener 19 Moods: 11 con tier `base` (`happy`, `calm`, `neutral`, `sleepy`, `sad`, `angry`, `anxious`, `stressed`, `scared`, `crying`, `sick`) y 8 con tier `premium` (`laughing`, `confident`, `brave`, `affectionate`, `hugging`, `romantic`, `shy`, `hurt`). Cada uno SHALL tener un ícono propio y un nombre localizado en inglés, español, alemán, francés e italiano. Los ids SHALL NOT cambiar, porque son el identificador estable de las Mood Entry guardadas y de la exportación. Los Moods `sleepy`, `anxious`, `stressed`, `scared`, `crying` y `sick`, que eran premium en versiones anteriores, SHALL pasar a `base` sin afectar a ningún usuario existente.

#### Scenario: Conteo del catálogo
- **WHEN** se consulta el catálogo completo de moods
- **THEN** contiene 19 Moods, 11 `base` y 8 `premium`

#### Scenario: Mood que pasa a gratis
- **WHEN** un usuario sin suscripción abre el Log
- **THEN** `anxious`, `crying` y `sick` están disponibles sin candado

#### Scenario: Usuario que compró un mood que ahora es gratis
- **WHEN** un usuario compró `sleepy` en una versión anterior y actualiza
- **THEN** `sleepy` sigue disponible, sus entradas no cambian y la compra heredada se conserva

#### Scenario: Entradas existentes
- **WHEN** un usuario con entradas guardadas con `crying` actualiza a esta versión
- **THEN** esas entradas se muestran igual en el calendario y se exportan con `crying`

#### Scenario: Nombres en todos los idiomas
- **WHEN** el idioma del dispositivo es cualquiera de los 5 soportados
- **THEN** los 19 Moods muestran su nombre localizado y no caen al id ni a otro idioma

