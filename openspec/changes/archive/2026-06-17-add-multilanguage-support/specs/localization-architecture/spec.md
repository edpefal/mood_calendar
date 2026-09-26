## ADDED Requirements

### Requirement: Arquitectura de localización por subclases
El sistema de localización SHALL implementarse como una clase abstracta `AppStrings` con subclases concretas por idioma. Cada subclase SHALL implementar todos los getters definidos en la clase base. El factory `forLocale(Locale)` SHALL retornar la subclase correspondiente al `languageCode` recibido, con fallback a español para locales no soportados.

#### Scenario: Locale soportado
- **WHEN** el dispositivo tiene un locale soportado (es, en, de, fr, it)
- **THEN** `AppStrings.of(context)` retorna la subclase correspondiente a ese idioma

#### Scenario: Locale no soportado
- **WHEN** el dispositivo tiene un locale no soportado (ej. pt, ja, zh)
- **THEN** `AppStrings.of(context)` retorna la subclase española como fallback

### Requirement: Detección automática del idioma del dispositivo
La app SHALL usar el locale del dispositivo para determinar el idioma de la UI. No SHALL existir un locale hardcodeado en la configuración de la app. Los locales soportados SHALL ser: español (es), inglés (en), alemán (de), francés (fr), italiano (it).

#### Scenario: Dispositivo en alemán
- **WHEN** el dispositivo está configurado en alemán
- **THEN** la app muestra todos los textos de UI en alemán

#### Scenario: Dispositivo en idioma no soportado
- **WHEN** el dispositivo está en un idioma no incluido en supportedLocales
- **THEN** la app muestra los textos en español (primer locale en supportedLocales)

### Requirement: Notificaciones en idioma del dispositivo
Las notificaciones push SHALL enviarse en el idioma almacenado del dispositivo. Dado que `local_notification_service.dart` no tiene acceso a `BuildContext`, SHALL usar el locale del sistema vía `Platform` o almacenar la preferencia de idioma al momento del registro.

#### Scenario: Notificación en dispositivo alemán
- **WHEN** el dispositivo está en alemán y recibe una notificación de recordatorio
- **THEN** el título y cuerpo de la notificación aparecen en alemán
