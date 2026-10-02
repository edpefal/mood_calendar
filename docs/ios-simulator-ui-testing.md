# Testing ad-hoc de UI/UX en el simulador de iOS (idb)

Workflow para que el agente (Claude) valide por sí mismo cambios de UI/UX en el simulador de iOS, sin intervención manual del usuario. Usa `idb` (iOS Development Bridge) + `simctl`, que operan sobre todo el simulador (no solo la app), por lo que también permiten interactuar con diálogos nativos del sistema (permisos, notificaciones).

No reemplaza tests automatizados ni está integrado a CI — es una herramienta de uso ad-hoc durante desarrollo. Ver `openspec/changes/setup-idb-simulator-testing/` (o su versión archivada en `openspec/specs/ios-simulator-ui-testing/`) para el contexto completo de la decisión.

**Limpieza**: los screenshots y dumps de accesibilidad son descartables — son evidencia de verificación puntual, no artefactos del proyecto. Guardarlos siempre en un directorio temporal dedicado (ej. `/tmp/idb_shots/`, o el scratchpad de la sesión) y borrar ese directorio al terminar la sesión de pruebas (`rm -rf /tmp/idb_shots`). Si un screenshot puntual es relevante como evidencia (ej. para un PR), guardarlo explícitamente en otra ruta antes de limpiar.

## Instalación (una sola vez por máquina)

```bash
brew tap facebook/fb
brew trust facebook/fb        # Homebrew exige confianza explícita en taps de terceros
brew install idb-companion

brew install pipx             # si no está instalado
pipx install fb-idb           # instala el cliente `idb`; `pip3 install fb-idb` falla por
                               # "externally-managed-environment" en Python de Homebrew
```

Verificación:
```bash
idb_companion --version        # responde JSON con build info; no soporta --help de "idb --version"
idb list-targets                # lista simuladores, incluso sin companion conectado
```

Riesgo conocido: en Apple Silicon, `idb_companion` puede fallar por incompatibilidad con la versión de Xcode/Command Line Tools instalada. Si `idb_companion --version` o la instalación fallan, revisar el mensaje de Homebrew (suele indicar actualizar Xcode/CLT) antes de continuar.

## Levantar companion + conectar

El cliente `idb` necesita un `idb_companion` corriendo y conectado al simulador objetivo:

```bash
# UDID de un simulador booteado (ver `xcrun simctl list devices | grep Booted`)
idb_companion --udid <UDID> > /tmp/idb_companion.log 2>&1 &
disown
idb connect localhost 10882     # puerto gRPC default del companion
idb list-targets                # confirmar que ya no dice "No Companion Connected"
```

## Levantar la app con hot reload controlable

`flutter run` normal no permite enviarle teclas (`r` para hot reload) desde comandos posteriores si se lanza sin stdin controlable. Usar un FIFO:

```bash
mkfifo /tmp/flutter_stdin_fifo
cd <ruta del proyecto>
nohup flutter run -d <UDID> < /tmp/flutter_stdin_fifo > /tmp/flutter_run.log 2>&1 &
disown
exec 3<>/tmp/flutter_stdin_fifo   # mantiene el FIFO abierto para que no se bloquee al escribir
```

**Importante**: el `nohup ... &` seguido de `disown` debe ir en el mismo comando — si el proceso en background no se desvincula de la shell, muere cuando termina esa invocación de comando (SIGHUP).

Para hot reload después de editar código:
```bash
printf 'r\n' > /tmp/flutter_stdin_fifo
```

Para salir limpio: `printf 'q\n' > /tmp/flutter_stdin_fifo` (cuidado: si no hay ningún lector activo en el FIFO, un `printf > fifo` se queda bloqueado indefinidamente esperando uno — si no estás seguro de que `flutter run` sigue vivo, usar `pkill -f "flutter run"` en su lugar).

## El loop de validación

```bash
# 1. Screenshot del estado actual
idb screenshot --udid <UDID> /tmp/shot.png
# Leer /tmp/shot.png con el visor de imágenes para inspección visual

# 2. Árbol de accesibilidad (para ubicar elementos por label, no por coordenadas fijas)
idb ui describe-all --udid <UDID> --json > /tmp/tree.json
python3 -c "
import json
data = json.load(open('/tmp/tree.json'))
for el in data:
    label = el.get('AXLabel')
    if label and label.strip():
        print(el.get('type'), repr(label), el.get('frame'))
"

# 3. Tap sobre un elemento ubicado por label: calcular el centro de su frame
#    (frame.x + frame.width/2, frame.y + frame.height/2) — las coordenadas están
#    en puntos lógicos, no en píxeles del screenshot
idb ui tap --udid <UDID> <x> <y>

# Otras interacciones disponibles:
idb ui swipe --udid <UDID> <x1> <y1> <x2> <y2>
idb ui text --udid <UDID> "texto a escribir"
idb ui key --udid <UDID> <keycode>

# 4. Screenshot de verificación
idb screenshot --udid <UDID> /tmp/shot2.png
```

### Fallback: tap por coordenadas sin label

Si un widget Flutter no tiene `Semantics`/etiqueta accesible, `describe-all` no lo resuelve. En ese caso, estimar coordenadas a partir del screenshot: el screenshot está en píxeles físicos (ej. 1206x2622 en iPhone 17), mientras que `idb ui tap` espera puntos lógicos — dividir las coordenadas del screenshot por el scale factor del dispositivo (3x en iPhone 17) antes de tocar.

## Diálogos nativos del sistema

Como `idb` opera sobre todo el simulador (no solo la vista de la app), el mismo loop de screenshot → describe-all → tap funciona igual para diálogos de SpringBoard (permisos, alertas del sistema) que para la UI de Flutter. No requiere ningún manejo especial.

Para forzar que reaparezca un diálogo de permiso ya respondido (ej. notificaciones), `xcrun simctl privacy <UDID> reset|revoke notifications <bundle_id>` no está soportado en todas las versiones de simctl (el servicio "notifications" puede no reconocerse). La alternativa confiable es desinstalar y reinstalar la app:

```bash
idb uninstall <bundle_id> --udid <UDID>
flutter run -d <UDID>   # reinstala y dispara el permission prompt de nuevo
```

## Resumen del loop completo

```
flutter run (vía FIFO) ──► app corriendo
      │
      ▼
idb screenshot ──► inspección visual (Read)
      │
      ▼
idb ui describe-all ──► ubicar elemento por label
      │
      ▼
idb ui tap/swipe/text/key ──► interactuar (app o diálogo nativo, sin distinción)
      │
      ▼
idb screenshot ──► verificar el efecto
      │
      ▼
(si se editó código) printf 'r\n' > fifo ──► hot reload ──► repetir desde screenshot
      │
      ▼
(fin de la sesión de pruebas) rm -rf /tmp/idb_shots ──► limpiar screenshots/dumps descartables
```
