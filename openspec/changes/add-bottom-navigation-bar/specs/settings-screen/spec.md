## MODIFIED Requirements

### Requirement: Acceso a Settings desde la pantalla principal
Settings SHALL ser la cuarta pestaña del bottom bar, con un icono de engrane, y abrirse al tocarla. La pantalla principal NO SHALL mostrar un engrane en su header. Settings NO SHALL mostrar un botón de regresar. El calendario NO SHALL ofrecer acceso a la configuración de recordatorios.

#### Scenario: Abrir Settings
- **WHEN** el usuario toca la pestaña de ajustes del bottom bar
- **THEN** se muestra la pantalla de Settings

#### Scenario: Orden de las pestañas
- **WHEN** se muestra el bottom bar
- **THEN** la pestaña de ajustes es la última, a la derecha de moods, calendario y tienda

#### Scenario: El calendario no tiene acceso a recordatorios
- **WHEN** el usuario está en la vista del calendario
- **THEN** el header no muestra el icono de campana ni ningún control que abra la configuración de recordatorios

#### Scenario: Salir de Settings
- **WHEN** el usuario toca otra pestaña del bottom bar
- **THEN** Settings deja de mostrarse y al volver conserva su estado
