## ADDED Requirements

### Requirement: Fecha del selector tras tocar un día del calendario
Al tocar un día en la pestaña del calendario, la app SHALL cambiar a la pestaña del selector de moods mostrando la fecha de ese día, y esa fecha SHALL permanecer hasta que el usuario toque otro día. Si la fecha ya tiene una Mood Entry, el selector SHALL posicionarse en el Mood de esa entrada.

#### Scenario: Tocar un día distinto de hoy
- **WHEN** el usuario toca un día distinto de hoy en el calendario
- **THEN** el selector se muestra con la fecha de ese día

#### Scenario: Varios días tocados
- **WHEN** el usuario toca el día A, guarda, toca el día B y vuelve a la pestaña del selector
- **THEN** el selector muestra el día B

#### Scenario: El selector muestra la entrada de esa fecha
- **WHEN** el usuario toca un día que ya tiene una Mood Entry
- **THEN** el selector se posiciona en el Mood de esa entrada

## REMOVED Requirements

### Requirement: Volver del calendario a la última fecha vista
**Reason**: El calendario deja de ser una pantalla apilada a la que se vuelve: es una pestaña del bottom bar, y el selector conserva su fecha por sí mismo.
**Migration**: La pestaña del selector conserva la última fecha elegida (ver el requisito de arriba y `bottom-navigation`).

### Requirement: Etiqueta accesible del botón de volver
**Reason**: Ya no existe el botón de volver del calendario.
**Migration**: La pestaña del selector tiene su propia etiqueta localizada (ver `bottom-navigation`).
