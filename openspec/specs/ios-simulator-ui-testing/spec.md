# ios-simulator-ui-testing Specification

## Purpose

Permite al agente inspeccionar y manipular el simulador de iOS de forma ad-hoc durante desarrollo (screenshots, taps, texto, árbol de accesibilidad, diálogos nativos del sistema) para validar autónomamente los cambios de UI/UX que implementa, sin depender de revisión manual del usuario para cada cambio visual.

## Requirements

### Requirement: Herramientas de control del simulador disponibles
El entorno de desarrollo SHALL tener instalados `idb-companion` y el cliente `idb`, de forma que puedan invocarse desde la línea de comandos contra un simulador de iOS booteado.

#### Scenario: Verificación de instalación
- **WHEN** se ejecuta `idb --version` y `idb list-targets` en la máquina de desarrollo
- **THEN** ambos comandos responden sin error y `idb list-targets` lista al menos un simulador booteado

### Requirement: Captura visual del estado de la app
El agente SHALL poder obtener una captura de pantalla del simulador en cualquier momento para inspeccionar visualmente el resultado de un cambio de UI.

#### Scenario: Screenshot tras un cambio de UI
- **WHEN** el agente modifica código de UI y recarga la app en el simulador
- **THEN** el agente puede ejecutar un comando de screenshot y obtener un archivo de imagen que refleja el estado actual de la pantalla

### Requirement: Inspección del árbol de accesibilidad
El agente SHALL poder obtener la lista de elementos visibles en pantalla (labels, tipo, posición/bounds) para ubicar elementos por nombre en lugar de depender de coordenadas fijas.

#### Scenario: Ubicar un elemento por label
- **WHEN** el agente consulta el árbol de accesibilidad del simulador mientras una pantalla de la app está visible
- **THEN** la respuesta incluye, para cada elemento visible, al menos su label/texto y su frame (posición y tamaño), permitiendo calcular el punto de toque sin coordenadas hardcodeadas

### Requirement: Interacción programática con la UI
El agente SHALL poder simular tap, swipe, entrada de texto y teclas de hardware sobre el simulador para ejecutar flujos de usuario.

#### Scenario: Tocar un elemento encontrado en el árbol de accesibilidad
- **WHEN** el agente calcula el punto central de un elemento a partir del árbol de accesibilidad
- **THEN** el agente puede ejecutar un tap en ese punto y el screenshot subsiguiente refleja el efecto de la interacción (ej. cambio de pantalla, apertura de diálogo)

### Requirement: Interacción con diálogos nativos del sistema
El agente SHALL poder detectar e interactuar con diálogos del sistema operativo (permisos, banners de notificación) que no forman parte del árbol de widgets de Flutter, dado que la captura y los comandos de interacción operan sobre el simulador completo y no solo sobre la vista de la app.

#### Scenario: Responder a un diálogo de permiso de notificaciones
- **WHEN** la app dispara el diálogo nativo de solicitud de permiso de notificaciones y el agente toma un screenshot
- **THEN** el diálogo es visible en la captura y el agente puede tocar sus botones (ej. "Permitir"/"No permitir") usando los mismos comandos de interacción que usa dentro de la app

### Requirement: Workflow documentado para validación ad-hoc
El flujo de trabajo (levantar la app, capturar, inspeccionar, interactuar, verificar, hot reload) SHALL estar documentado para que el agente lo siga de forma consistente sin reconstruirlo cada vez, sin requerir flujos guardados tipo Maestro ni integración en CI.

#### Scenario: Agente valida un cambio de UI sin intervención del usuario
- **WHEN** el agente termina de implementar un cambio de UI y necesita confirmarlo
- **THEN** el agente sigue el workflow documentado (app corriendo → screenshot/árbol de accesibilidad → interacción si aplica → screenshot de verificación) sin pedirle al usuario que lo revise manualmente primero
