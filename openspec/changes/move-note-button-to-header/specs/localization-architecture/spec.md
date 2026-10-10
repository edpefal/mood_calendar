## MODIFIED Requirements

### Requirement: Placeholder del campo de nota localizado
La etiqueta del botón de nota del encabezado y el placeholder del campo de edición dentro del bottom sheet SHALL mostrarse cada uno en el idioma activo del dispositivo. Ninguno SHALL estar hardcodeado en un solo idioma.

#### Scenario: Botón de nota en español
- **WHEN** el dispositivo está en español
- **THEN** el botón de nota muestra su etiqueta en español

#### Scenario: Campo del sheet vacío en español
- **WHEN** el dispositivo está en español, el usuario abre el bottom sheet y la nota está vacía
- **THEN** el campo de texto del sheet muestra el placeholder que invita a escribir sobre el día, en español

#### Scenario: Textos de la nota en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** tanto la etiqueta del botón de nota como el placeholder del campo del sheet se muestran en inglés
