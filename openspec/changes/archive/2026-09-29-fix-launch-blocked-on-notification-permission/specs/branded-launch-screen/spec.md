## ADDED Requirements

### Requirement: Launch screen no bloqueado por permisos o SDKs de terceros
El launch screen SHALL desaparecer tan pronto la app termina de renderizar su primer frame, y ese primer frame SHALL renderizarse sin esperar a que el usuario responda un diálogo de permisos del sistema operativo (por ejemplo, notificaciones) ni a que un SDK de terceros (por ejemplo, RevenueCat) termine de configurarse.

#### Scenario: Primer lanzamiento en un dispositivo nuevo
- **WHEN** un usuario abre la app por primera vez en un dispositivo donde aún no se ha otorgado o denegado el permiso de notificaciones
- **THEN** la UI principal de la app se renderiza inmediatamente, y el diálogo de permisos de notificaciones aparece sobre esa UI (no antes de ella)

#### Scenario: El usuario ignora el diálogo de permisos
- **WHEN** el diálogo de permisos de notificaciones aparece y el usuario no interactúa con él de inmediato
- **THEN** la app sigue siendo utilizable — la UI principal ya está visible e interactiva, no bloqueada detrás del launch screen
