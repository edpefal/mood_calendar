## Requirements

### Requirement: Launch screen con identidad visual
El launch screen en iOS y Android SHALL mostrar un fondo blanco a pantalla completa, con el icono de la app centrado horizontal y verticalmente.

#### Scenario: Launch screen en iOS
- **WHEN** el usuario abre la app en un dispositivo iOS
- **THEN** aparece una pantalla con fondo blanco y el icono de la app centrado antes de que cargue la UI principal

#### Scenario: Launch screen en Android
- **WHEN** el usuario abre la app en un dispositivo Android
- **THEN** aparece una pantalla con fondo blanco y el icono de la app centrado antes de que cargue la UI principal

#### Scenario: Launch screen no usa placeholder
- **WHEN** se sube el IPA a App Store Connect
- **THEN** no aparece la advertencia de "default placeholder launch image"
