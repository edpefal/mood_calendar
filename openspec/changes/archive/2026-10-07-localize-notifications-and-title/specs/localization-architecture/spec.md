## ADDED Requirements

### Requirement: Notificaciones y título de la app localizados
Las notificaciones locales (título y cuerpo del recordatorio diario, nombre y descripción del canal de notificaciones) y el título de la app que expone el sistema operativo SHALL mostrarse en el idioma del dispositivo. Ninguno SHALL estar fijo en un solo idioma. Para idiomas no soportados SHALL usarse inglés. Un recordatorio ya programado SHALL actualizar su idioma la próxima vez que la app se abra y reprograme el recordatorio.

#### Scenario: Recordatorio en alemán
- **WHEN** el dispositivo está en alemán y la app programa el recordatorio diario
- **THEN** el título y el cuerpo de la notificación están en alemán

#### Scenario: Recordatorio en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado (ej. pt) y la app programa el recordatorio diario
- **THEN** el título y el cuerpo de la notificación están en inglés

#### Scenario: Canal de notificaciones en Android
- **WHEN** el dispositivo Android está en francés y la app crea el canal de notificaciones
- **THEN** el nombre y la descripción del canal están en francés

#### Scenario: Título de la app
- **WHEN** el dispositivo está en italiano
- **THEN** el título de la app que ve el sistema (por ejemplo en el selector de apps) está en italiano

#### Scenario: Cambio de idioma del dispositivo
- **WHEN** el usuario cambia el idioma del dispositivo y vuelve a abrir la app
- **THEN** el recordatorio se reprograma con título y cuerpo en el nuevo idioma
