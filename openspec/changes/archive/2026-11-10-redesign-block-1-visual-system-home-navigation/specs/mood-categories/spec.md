## Purpose

Define las cuatro categorías de mood (Positive, Peaceful, Neutral y Hard), a cuál pertenece cada mood, su orden fijo, su color y su puntaje de tres niveles, para que el selector, el calendario y los análisis hablen el mismo idioma sin tratar `intensity` como una escala.

## ADDED Requirements

### Requirement: Cuatro categorías con pertenencia exacta
Todo Mood del catálogo SHALL pertenecer a exactamente una de cuatro categorías: Positive, Peaceful, Neutral o Hard. La pertenencia SHALL ser: Positive: `happy`, `laughing`, `confident`, `brave`; Peaceful: `calm`, `affectionate`, `hugging`, `romantic`; Neutral: `neutral`, `sleepy`, `shy`; Hard: `sad`, `angry`, `anxious`, `stressed`, `scared`, `crying`, `sick`, `hurt`. Un Mood nuevo SHALL declarar su categoría al añadirse al catálogo. La categoría SHALL ser independiente del tier (`base` o `premium`) y de `intensity`.

#### Scenario: Cada mood tiene una categoría
- **WHEN** se consulta el catálogo completo
- **THEN** los 19 Moods tienen una categoría y ninguno tiene más de una

#### Scenario: Categoría y tier son independientes
- **WHEN** se consulta `brave` (premium) y `happy` (base)
- **THEN** ambos pertenecen a Positive

#### Scenario: Mood nuevo sin categoría
- **WHEN** se añade un Mood al catálogo sin declarar su categoría
- **THEN** las pruebas del catálogo fallan

### Requirement: Orden fijo por categoría
Donde la app liste los Moods (el Log, el reloj), SHALL hacerlo en un orden fijo: las categorías en el orden Positive, Peaceful, Neutral, Hard y, dentro de cada una, los Moods en el orden en que se listan arriba. El orden SHALL NOT depender de la frecuencia de uso, de si el Mood está `unlocked` ni de `intensity`.

#### Scenario: Orden de categorías
- **WHEN** el Log muestra los Moods
- **THEN** aparecen las secciones Positive, Peaceful, Neutral y Hard en ese orden

#### Scenario: Orden dentro de una categoría
- **WHEN** el Log muestra la categoría Hard
- **THEN** los Moods aparecen como `sad`, `angry`, `anxious`, `stressed`, `scared`, `crying`, `sick`, `hurt`

#### Scenario: El uso no reordena
- **WHEN** el usuario registra `hugging` veinte veces
- **THEN** `hugging` sigue en su posición fija de Peaceful

#### Scenario: Bloqueados en su categoría
- **WHEN** un Mood premium no está `unlocked`
- **THEN** aparece en su categoría y posición habituales, no al final de la lista

### Requirement: Color por categoría
El color con que la app pinta un Mood (celdas, tarjetas, fondos y acentos) SHALL ser el tinte de su categoría: amarillo para Positive, verde para Peaceful, lavanda grisácea para Neutral y violeta para Hard. La excepción SHALL ser `angry`, cuyo tinte es rojo. Cada tinte SHALL tener variante clara y oscura y SHALL mantener el contraste de 4.5:1 con el texto que lleve encima. El color SHALL NOT significar por sí solo la categoría: la categoría SHALL poder leerse también por su nombre.

#### Scenario: Mood de Peaceful
- **WHEN** la app pinta `calm` en una celda
- **THEN** usa el tinte verde de Peaceful

#### Scenario: Excepción de Angry
- **WHEN** la app pinta `angry`
- **THEN** usa el tinte rojo y no el violeta de Hard

#### Scenario: Tema oscuro
- **WHEN** el tema es Oscuro
- **THEN** cada tinte usa su variante oscura y el texto sigue con contraste de al menos 4.5:1

### Requirement: Puntaje de tres niveles por categoría
Para los análisis que necesiten un valor numérico, cada categoría SHALL tener un nivel: Positive y Peaceful, alto; Neutral, medio; Hard, bajo. Todo Mood SHALL heredar el nivel de su categoría y NO SHALL tener un puntaje propio. `intensity` SHALL seguir siendo solo un identificador interno y NO SHALL usarse para ordenar, comparar ni puntuar.

#### Scenario: Nivel por categoría
- **WHEN** se pide el nivel de `shy` (Neutral) y de `crying` (Hard)
- **THEN** devuelve medio y bajo respectivamente

#### Scenario: Intensity no interviene
- **WHEN** se calcula el nivel de cualquier Mood
- **THEN** el resultado no depende de su `intensity`

#### Scenario: Mood premium nuevo
- **WHEN** se añade un Mood premium a la categoría Peaceful
- **THEN** su nivel es alto sin asignarle ningún puntaje propio

### Requirement: Nombres de categoría localizados
Los nombres de las cuatro categorías SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo.

#### Scenario: Categorías en español
- **WHEN** el dispositivo está en español
- **THEN** las secciones del Log muestran los nombres de las categorías en español

#### Scenario: Idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** los nombres de las categorías aparecen en inglés
