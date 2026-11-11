## ADDED Requirements

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

## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Selección bloqueada en el carrusel diario
**Reason**: El carrusel se reemplaza por la cuadrícula del Log y el orden por frecuencia desaparece (orden fijo por categoría).
**Migration**: El comportamiento de Moods bloqueados y la excepción de editar la nota con el mismo Mood caducado pasan a `home-mood-log`; el orden fijo pasa a `mood-categories`.

### Requirement: Indicador de posición del carrusel
**Reason**: Sin carrusel no hay contador "N / M".
**Migration**: Ninguna; la cuadrícula muestra todos los Moods a la vez.

### Requirement: El carrusel indica que se puede deslizar
**Reason**: Sin carrusel no hay Moods vecinos ni flechas.
**Migration**: Ninguna; el Log se desplaza en vertical cuando no cabe.

### Requirement: Selección rápida desde la hoja de todos los moods
**Reason**: La cuadrícula del Log ya muestra todos los Moods, así que la hoja "todos los moods" sobra.
**Migration**: Tocar un Mood en la cuadrícula lo selecciona o abre la hoja de suscripción si está bloqueado, como describe `home-mood-log`.

### Requirement: Moods premium de la primera ola de packs
**Reason**: El catálogo cambia a 11 `base` y 8 `premium`, y los Packs ya no existen.
**Migration**: El nuevo requisito "Catálogo de 19 moods con 11 base y 8 premium" conserva los ids estables y los nombres localizados.
