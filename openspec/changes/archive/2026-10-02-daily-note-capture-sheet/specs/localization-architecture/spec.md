## MODIFIED Requirements

### Requirement: Placeholder del campo de nota localizado
El preview inline de solo lectura y el campo de edición dentro del bottom sheet SHALL mostrar cada uno su propio placeholder localizado cuando la nota está vacía. Ambos placeholders SHALL mostrarse en el idioma activo del dispositivo. Ninguno SHALL estar hardcodeado en un solo idioma.

#### Scenario: Preview inline vacío en español
- **WHEN** el dispositivo está en español y la nota está vacía
- **THEN** el preview inline muestra el placeholder que invita a tocar para agregar una nota, en español

#### Scenario: Campo del sheet vacío en español
- **WHEN** el dispositivo está en español, el usuario abre el bottom sheet y la nota está vacía
- **THEN** el campo de texto del sheet muestra el placeholder que invita a escribir sobre el día, en español

#### Scenario: Placeholders en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** tanto el placeholder del preview inline como el del campo del sheet se muestran en inglés
