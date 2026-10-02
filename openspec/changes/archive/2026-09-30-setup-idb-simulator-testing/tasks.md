## 1. Instalación de herramientas

- [x] 1.1 Instalar `idb-companion` vía Homebrew (`brew tap facebook/fb && brew install idb-companion`)
- [x] 1.2 Instalar el cliente `idb` vía pip (en la práctica: `pipx install fb-idb`, ya que `pip3 install` falla por "externally-managed-environment" en Python de Homebrew; pipx aísla la instalación sin romper el sistema)
- [x] 1.3 Verificar `idb_companion --version` y `idb list-targets` contra un simulador booteado; sin incompatibilidad en Apple Silicon. Nota: hace falta levantar `idb_companion --udid <udid>` en background y luego `idb connect localhost <grpc-port>` (default 10882) antes de que `list-targets` muestre el companion conectado — `idb` client solo no tiene flag `--version`, usar `idb_companion --version`

## 2. Validar primitivas básicas contra el simulador

- [x] 2.1 Levantar la app con `flutter run` en uno de los simuladores booteados
- [x] 2.2 Tomar un screenshot con `idb screenshot` (o `xcrun simctl io <udid> screenshot`) y confirmar que refleja la pantalla actual
- [x] 2.3 Ejecutar `idb ui describe-all --udid <udid> --json` y confirmar que resuelve labels/bounds (`AXLabel`/`AXFrame`) de elementos visibles; nota: frames vienen en puntos (coordenadas lógicas), hay que multiplicar por el scale factor del dispositivo (ej. 3x en iPhone 17) para mapear a coordenadas de un screenshot en píxeles — pero `idb ui tap` espera coordenadas en puntos, no píxeles, así que se usa el `AXFrame` directo sin escalar
- [x] 2.4 Ejecutar un `idb ui tap --udid <udid> <x> <y>` sobre el centro del frame de un elemento ubicado por label (se probó con el botón "Not Now" de un diálogo nativo) y confirmar con un nuevo screenshot que la interacción tuvo efecto (el diálogo se cerró y se reveló la pantalla principal de la app)
- [x] 2.5 Confirmar hot reload: editar un valor visual trivial, enviar `r` al proceso de `flutter run`, y verificar el cambio con un nuevo screenshot. Nota de implementación: `flutter run` debe lanzarse con su stdin conectado a un FIFO (`mkfifo`, `flutter run < fifo`) para poder enviarle teclas (`printf 'r\n' > fifo`) desde comandos posteriores — lanzarlo en background sin stdin controlable impide el hot reload interactivo

## 3. Validar diálogos nativos del sistema

- [x] 3.1 Disparar el diálogo nativo de permiso de notificaciones (desinstalando y reinstalando la app con `idb uninstall` + `flutter run` para resetear el estado de autorización) y confirmar que aparece en un `idb screenshot` y en `idb ui describe-all` (labels "Allow"/"Don't Allow"). Nota: `xcrun simctl privacy ... notifications` no es un servicio soportado en esta versión de simctl para forzar el re-prompt
- [x] 3.2 Confirmar que `idb ui tap` puede interactuar con los botones del diálogo nativo: se calculó el centro del frame del botón "Allow" resuelto por `describe-all` y se tocó, cerrando el diálogo y revelando la app por debajo — prueba que `idb` interactúa igual con UI del sistema y UI de Flutter, sin distinción

## 4. Documentar el workflow

- [x] 4.1 Documentar el loop de trabajo completo (app corriendo → screenshot → árbol de accesibilidad → interacción → screenshot de verificación → hot reload si aplica) como referencia reutilizable para el agente — ver `docs/ios-simulator-ui-testing.md`
- [x] 4.2 Documentar el fallback de tap por coordenadas para elementos sin label accesible — ver sección "Fallback" en `docs/ios-simulator-ui-testing.md`
- [x] 4.3 Documentar los comandos de instalación y el riesgo de compatibilidad en Apple Silicon, incluyendo cómo detectarlo — ver sección "Instalación" en `docs/ios-simulator-ui-testing.md`
- [x] 4.4 Confirmar que el workflow documentado es suficiente para que el agente valide un cambio de UI real sin pedir revisión manual previa al usuario — demostrado en las tareas 2.5/3.1/3.2: cambio de color de texto + hot reload + verificación visual + reversión, y el permission prompt nativo de notificaciones, todo sin intervención del usuario
