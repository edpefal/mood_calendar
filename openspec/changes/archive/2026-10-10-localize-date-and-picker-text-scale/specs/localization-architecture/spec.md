## ADDED Requirements

### Requirement: Fechas completas localizadas
Toda fecha completa (día, mes y año) mostrada al usuario, como el encabezado del selector de moods y la etiqueta que los lectores de pantalla anuncian para cada día del calendario, SHALL seguir el orden, los separadores y la capitalización del idioma activo del dispositivo. Para idiomas no soportados SHALL usarse el formato en inglés. El orden NO SHALL estar fijo en un solo idioma.

#### Scenario: Fecha en inglés
- **WHEN** el dispositivo está en inglés y se muestra el 10 de octubre de 2026
- **THEN** la fecha se muestra como "October 10, 2026"

#### Scenario: Fecha en español
- **WHEN** el dispositivo está en español y se muestra el 10 de octubre de 2026
- **THEN** la fecha se muestra como "10 de octubre de 2026", con el mes en minúscula

#### Scenario: Fecha en alemán
- **WHEN** el dispositivo está en alemán y se muestra el 10 de octubre de 2026
- **THEN** la fecha se muestra como "10. Oktober 2026"

#### Scenario: Fecha en francés
- **WHEN** el dispositivo está en francés y se muestra el 10 de octubre de 2026
- **THEN** la fecha se muestra como "10 octobre 2026", con el mes en minúscula

#### Scenario: Fecha en italiano
- **WHEN** el dispositivo está en italiano y se muestra el 10 de octubre de 2026
- **THEN** la fecha se muestra como "10 ottobre 2026", con el mes en minúscula

#### Scenario: Primer día del mes
- **WHEN** se muestra el 1 de marzo de 2026 en cualquier idioma soportado
- **THEN** el día se muestra sin cero a la izquierda (por ejemplo "1 de marzo de 2026" en español)

#### Scenario: Idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** la fecha se muestra con el formato en inglés

#### Scenario: Misma fecha en selector y calendario
- **WHEN** el usuario ve la misma fecha en el encabezado del selector y en la etiqueta del día en el calendario
- **THEN** ambas se muestran con el mismo formato
