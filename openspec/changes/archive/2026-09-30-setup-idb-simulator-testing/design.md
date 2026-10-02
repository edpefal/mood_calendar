## Context

Mood Calendar es una app Flutter sin tests de UI automatizados (ver `CLAUDE.md`). El usuario quiere que el agente pueda validar por sí mismo los cambios de UI/UX que implementa, de forma ad-hoc (no flujos guardados, no CI), incluyendo diálogos nativos del sistema. Ver `proposal.md` - Why.

Se evaluaron varias opciones (idb+simctl, Maestro, Patrol/integration_test, Appium). Patrol/integration_test queda descartado porque corre dentro del proceso Flutter y no puede ver ni tocar UI del sistema (SpringBoard/diálogos nativos). Maestro y Appium agregan una capa de flujos/servidor que no aporta valor para uso ad-hoc exploratorio. `idb` + `simctl` es la opción más directa: control de bajo nivel sobre todo el simulador, sin instrumentar la app.

## Goals / Non-Goals

**Goals:**
- Dejar `idb-companion` + cliente `idb` instalados y funcionando contra un simulador booteado.
- Documentar un workflow repetible (no automatizado) que el agente siga cada vez que necesite validar un cambio de UI.
- Confirmar que el workflow cubre: screenshot, árbol de accesibilidad, tap/swipe/texto, y diálogos nativos del sistema.
- Detectar y documentar si hay problemas de compatibilidad de `idb_companion` en esta máquina (Apple Silicon).

**Non-Goals:**
- No se crean flujos guardados (Maestro-style) ni se integra nada a CI/"Analyze and Test".
- No se agregan dependencias Dart/Flutter al proyecto (`pubspec.yaml` no cambia).
- No se automatiza la decisión de qué probar — el agente decide ad-hoc qué pantallas/flujos validar en cada caso.
- No se cubre Android (fuera de alcance; CLAUDE.md indica iOS como plataforma principal).

## Decisions

### Usar `idb` (idb-companion + cliente) en vez de Maestro/Patrol/Appium
- **Por qué**: `idb` opera a nivel de simulador completo (como un "driver" de SO), así que ve y toca tanto la app Flutter como diálogos nativos del sistema. Maestro y Patrol/integration_test no tienen acceso a UI fuera de la app bajo test; Appium requiere levantar un servidor WebDriver adicional sin aportar nada más para este caso de uso ad-hoc.
- **Alternativas consideradas**:
  - Maestro: mejor si se quisieran flujos guardados/reproducibles (explícitamente fuera de alcance ahora).
  - Patrol/integration_test: útil a futuro para tests de regresión en CI, pero no resuelve el caso de diálogos nativos y requeriría agregar dependencias Dart.
  - Appium: mismo poder que idb pero con infraestructura adicional (servidor, driver XCUITest) injustificada para uso ad-hoc por un solo agente en una sola máquina.

### Instalación vía Homebrew (`facebook/fb/idb-companion`) + pip (`fb-idb`)
- **Por qué**: es el camino de instalación oficial/documentado de idb y no requiere compilar nada manualmente.
- **Alternativa considerada**: compilar `idb_companion` desde fuente — descartado salvo que el binario de Homebrew falle por incompatibilidad.

### Workflow basado en árbol de accesibilidad (`idb ui describe-all`) en vez de coordenadas fijas
- **Por qué**: coordenadas hardcodeadas se rompen con cualquier cambio de layout; el árbol de accesibilidad da labels/bounds que permiten calcular el punto de toque dinámicamente, de forma similar a los selectores de Playwright.
- **Alternativa considerada**: tap por coordenadas fijas leídas "a ojo" del screenshot — más frágil, se mantiene como fallback cuando un elemento no tiene label accesible.

### Documentación como artefacto de este change, no como feature de la app
- **Por qué**: lo que se entrega es un documento de workflow (y la instalación de herramientas) para que el agente lo siga; no hay código de producción que cambie. Vive en `tasks.md`/este `design.md` y, si corresponde, en `CLAUDE.md` como referencia rápida.

## Risks / Trade-offs

- [Riesgo] `idb_companion` instalado vía Homebrew puede no ser compatible con la versión de Xcode/Command Line Tools instalada en Apple Silicon (problema conocido en versiones pasadas de idb). → Mitigación: validar con `idb --version` y `idb list-targets` apenas se instale; si falla, documentar el error exacto y evaluar instalar `idb-companion` vía el tap específico de arquitectura o usar una build reciente antes de continuar.
- [Riesgo] `idb` depende de Python/pip; conflictos de entorno (versión de Python, pip vs pip3, entornos virtuales) pueden romper la instalación del cliente. → Mitigación: instalar con `pip3 install fb-idb` explícitamente y verificar `idb --version` antes de dar la tarea por completa.
- [Riesgo] El árbol de accesibilidad puede no resolver labels para widgets Flutter sin `Semantics`/etiquetas explícitas, forzando fallback a coordenadas. → Mitigación: documentar el fallback (tap por coordenadas leídas del screenshot) como parte del workflow, no como bloqueante.
- [Trade-off] Esto es una herramienta de uso manual/ad-hoc, no una suite de regresión: no detecta regresiones automáticamente entre sesiones. Aceptado explícitamente por el usuario (fuera de alcance CI/Maestro).

## Migration Plan

No aplica (no hay estado previo que migrar ni rollback de producción). Si la instalación de `idb-companion`/`idb` falla y bloquea el flujo, el rollback es simplemente desinstalar los paquetes (`brew uninstall idb-companion`, `pip3 uninstall fb-idb`) sin ningún impacto en la app.
