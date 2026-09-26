## Requirements

### Requirement: Arquitectura de localización por subclases
El sistema de localización SHALL implementarse como una clase abstracta `AppStrings` con subclases concretas por idioma. Cada subclase SHALL implementar todos los getters definidos en la clase base. El factory `forLocale(Locale)` SHALL retornar la subclase correspondiente al `languageCode` recibido, con fallback a inglés para locales no soportados.

#### Scenario: Locale soportado
- **WHEN** el dispositivo tiene un locale soportado (es, en, de, fr, it)
- **THEN** `AppStrings.of(context)` retorna la subclase correspondiente a ese idioma

#### Scenario: Locale no soportado
- **WHEN** el dispositivo tiene un locale no soportado (ej. pt, ja, zh)
- **THEN** `AppStrings.of(context)` retorna la subclase inglesa como fallback

### Requirement: Detección automática del idioma del dispositivo
La app SHALL usar el locale del dispositivo para determinar el idioma de la UI. No SHALL existir un locale hardcodeado en la configuración de la app. Los locales soportados SHALL ser: inglés (en, fallback), español (es), alemán (de), francés (fr), italiano (it).

#### Scenario: Dispositivo en alemán
- **WHEN** el dispositivo está configurado en alemán
- **THEN** la app muestra todos los textos de UI en alemán

#### Scenario: Dispositivo en idioma no soportado
- **WHEN** el dispositivo está en un idioma no incluido en supportedLocales
- **THEN** la app muestra los textos en inglés (primer locale en supportedLocales)

### Requirement: Placeholder del campo de nota localizado
El placeholder del campo de texto para notas SHALL mostrarse en el idioma activo del dispositivo. No SHALL estar hardcodeado en ningún idioma.

#### Scenario: Campo de nota en español
- **WHEN** el dispositivo está en español
- **THEN** el placeholder del campo de nota muestra el texto en español

#### Scenario: Campo de nota en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** el placeholder del campo de nota muestra el texto en inglés
