## Purpose

Define a qué fecha vuelve la persona al usar el botón de volver del calendario, para que revisar o editar varios días no pierda el contexto de la fecha que estaba viendo.

## ADDED Requirements

### Requirement: Volver del calendario a la última fecha vista
El botón de volver del calendario SHALL abrir el selector de moods de la última fecha cuyo selector se abrió, y no siempre el de hoy. La última fecha vista SHALL ser, en este orden: la del último día tocado en el calendario; si no se tocó ninguno, la fecha del selector desde el cual se abrió el calendario; si no hay ninguna, hoy.

#### Scenario: Tras editar otra fecha
- **WHEN** la persona toca un día distinto de hoy en el calendario, guarda su mood y vuelve al calendario
- **THEN** el botón de volver abre el selector de moods de ese día

#### Scenario: Sin haber tocado ningún día
- **WHEN** la persona abre el calendario desde el selector de hoy y usa el botón de volver sin tocar ningún día
- **THEN** se abre el selector de moods de hoy

#### Scenario: Calendario abierto desde el selector de otra fecha
- **WHEN** la persona abre el calendario desde un selector cuya fecha no es hoy (por ejemplo, abierto desde un recordatorio) y usa el botón de volver sin tocar ningún día
- **THEN** se abre el selector de moods de esa fecha

#### Scenario: Varios días editados
- **WHEN** la persona toca el día A, vuelve al calendario, toca el día B y vuelve al calendario
- **THEN** el botón de volver abre el selector de moods del día B

#### Scenario: El selector muestra la entrada de esa fecha
- **WHEN** el botón de volver abre el selector de una fecha que ya tiene una Mood Entry
- **THEN** el selector se posiciona en el Mood de esa entrada

### Requirement: Etiqueta accesible del botón de volver
El botón de volver del calendario SHALL tener una etiqueta accesible que describa su destino real: "Volver a hoy" cuando la fecha destino es hoy, y una etiqueta que no mencione "hoy" cuando es otra fecha. La etiqueta SHALL existir en todos los idiomas soportados.

#### Scenario: Destino es hoy
- **WHEN** la última fecha vista es hoy
- **THEN** el botón de volver conserva la etiqueta "Volver a hoy"

#### Scenario: Destino es otra fecha
- **WHEN** la última fecha vista no es hoy
- **THEN** el botón de volver tiene una etiqueta que no dice "hoy"
