## Why

Hoy no hay forma de que el agente (Claude) verifique de forma autónoma los cambios de UI/UX que implementa: no puede ver la pantalla del simulador de iOS ni interactuar con ella, así que cada cambio visual requiere que el usuario lo revise manualmente. Se necesita un flujo tipo "Playwright para iOS": tomar screenshots, tocar/escribir sobre la UI, y verificar el resultado, incluyendo diálogos nativos del sistema (permisos, notificaciones) que están fuera del árbol de widgets de Flutter.

## What Changes

- Instalar `idb-companion` (Homebrew, tap `facebook/fb`) y el cliente `idb` (`pip3 install fb-idb`) como herramientas de desarrollo locales.
- Documentar el loop de trabajo ad-hoc para que el agente lo siga cada vez que necesite validar un cambio de UI: `flutter run` en un simulador booteado → `idb screenshot` → `idb ui describe-all` (árbol de accesibilidad) → `idb ui tap|swipe|text|key` → nuevo `idb screenshot` para verificar → hot reload (`r`) si se edita código.
- Documentar cómo interactuar con diálogos nativos del sistema (permisos de notificaciones, banners) ya que `idb` opera sobre todo el simulador, no solo sobre la vista de la app.
- Documentar el riesgo conocido de compatibilidad de `idb_companion` en Apple Silicon según la versión de Xcode instalada, y cómo detectarlo/mitigarlo.
- Validar el flujo completo con un caso de prueba simple (abrir la app, navegar una pantalla, tomar screenshot, confirmar que el árbol de accesibilidad resuelve un elemento conocido).

Fuera de alcance (explícito):
- No se agregan flujos guardados tipo Maestro ni tests automatizados en CI.
- No se agregan dependencias Flutter/Dart (`integration_test`, `patrol`) — esto es una herramienta externa a nivel de simulador, no una suite de tests compilada dentro de la app.
- No se modifica código de la app.

## Capabilities

### New Capabilities
- `ios-simulator-ui-testing`: Flujo de trabajo y herramientas (`idb` + `simctl`) para que el agente inspeccione y manipule el simulador de iOS de forma ad-hoc durante desarrollo, incluyendo diálogos nativos del sistema.

### Modified Capabilities
(ninguna — no hay specs existentes de comportamiento de la app que cambien)

## Impact

- **Dependencias del sistema (no del proyecto Flutter)**: `idb-companion` vía Homebrew, cliente `idb` vía pip. No se tocan `pubspec.yaml` ni código de la app.
- **Documentación**: nuevo documento de workflow (parte de este change, ver `design.md`) que el agente consulta antes de validar cambios de UI.
- **Entorno de desarrollo**: requiere Xcode + simulador de iOS booteado (ya disponible en la máquina del usuario).
- **Sin impacto en CI/build**: es una herramienta de uso local/ad-hoc, no se integra al pipeline "Analyze and Test".
