## MODIFIED Requirements

### Requirement: Detección automática del idioma del dispositivo
La app SHALL usar el locale del dispositivo para determinar el idioma de la UI. No SHALL existir un locale hardcodeado en la configuración de la app. Los locales soportados SHALL ser: inglés (en), español (es), alemán (de), francés (fr), italiano (it). El idioma de fallback para locales no soportados SHALL ser inglés.

#### Scenario: Dispositivo en idioma no soportado
- **WHEN** el dispositivo está en un idioma no incluido en supportedLocales
- **THEN** la app muestra los textos en inglés (primer locale en supportedLocales)

#### Scenario: Dispositivo en alemán
- **WHEN** el dispositivo está configurado en alemán
- **THEN** la app muestra todos los textos de UI en alemán

## ADDED Requirements

### Requirement: Placeholder del campo de nota localizado
El placeholder del campo de texto para notas SHALL mostrarse en el idioma activo del dispositivo. No SHALL estar hardcodeado en ningún idioma.

#### Scenario: Campo de nota en español
- **WHEN** el dispositivo está en español
- **THEN** el placeholder del campo de nota muestra el texto en español

#### Scenario: Campo de nota en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** el placeholder del campo de nota muestra el texto en inglés
