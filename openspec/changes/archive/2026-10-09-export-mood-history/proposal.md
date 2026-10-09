## Why

El historial de moods es un dato personal del usuario, pero hoy no hay forma de sacarlo de la app. Ya existe un exportador a JSON (`JsonMoodHistoryExporter`, su use case y strings), pero nunca se conectó a ninguna pantalla, y escribe el archivo en una carpeta de la app a la que un usuario de iOS no puede llegar. Con la pantalla de Settings (change `add-settings-screen`) ya hay un lugar natural para ofrecerlo, y exportar es una forma directa de que el usuario conserve o respalde sus datos.

## What Changes

- Nueva fila **"Exportar historial"** en Settings, en una sección propia "Tus datos". Al tocarla se genera el archivo y se abre la **hoja de compartir** de iOS (Guardar en Archivos, AirDrop, Mail…) con dependencia nueva `share_plus`. En iPad la hoja se ancla a la fila.
- La fila muestra progreso mientras exporta y se deshabilita para evitar exportaciones simultáneas. Si no hay entradas, no se abre la hoja y se avisa. Si falla, se muestra un mensaje.
- **BREAKING (formato, aún no publicado)**: el JSON deja de exponer datos internos. Cada entrada pasa de `{date, mood: "assets/icon/calm.svg", note, intensity}` a `{date, mood: "calm", note}`: se usa el id estable del mood y se quita `intensity` (identificador interno, ADR 0001). Se agrega `formatVersion: 1` en la raíz. Como el exportador nunca llegó a los usuarios, no hay archivos existentes que migrar.
- El archivo se escribe en el directorio temporal del sistema en vez de `Documents/exports`, para que no se acumulen copias con las notas del usuario dentro de la app.
- Un mood que la app no reconoce se exporta tal cual estaba guardado, en vez de mapearse en silencio a otro mood.
- Strings nuevos en en/es/de/fr/it; se retira `historyExportedTo`, que no aplica con la hoja de compartir.
- Dependiente de `add-settings-screen` (PR #60): este change agrega una fila a esa pantalla.

## Capabilities

### New Capabilities
- `mood-history-export`: exportar el historial completo de Mood Entries a un archivo JSON y compartirlo con la hoja del sistema desde Settings, incluyendo formato del archivo, estados de la acción y manejo de errores.

### Modified Capabilities
<!-- Ninguna. La fila de Settings se describe dentro de `mood-history-export` para no depender de que `settings-screen` ya esté sincronizada en openspec/specs/. -->

## Impact

- **Código**: `lib/features/mood/data/services/json_mood_history_exporter.dart` (formato, directorio temporal, mood desconocido), nueva fila en `lib/features/settings/presentation/screens/settings_screen.dart`, `lib/main.dart` (proveer `ExportMoodHistoryUseCase`), `lib/core/localization/app_strings*.dart` (6 archivos).
- **Dependencias**: `share_plus` (requiere `pod install`).
- **Tests**: se actualiza `json_mood_history_exporter_test.dart` al nuevo formato y se agregan tests de widget de la fila (exportando, vacío, error, éxito).
- **Privacidad**: las notas salen del dispositivo solo por una acción explícita del usuario; no hay envío automático. Conviene revisar que la política de privacidad de App Store Connect no contradiga la exportación manual.
- **Docs**: `backlog.md` (la exportación deja de ser "local sin UI") y `CLAUDE.md` si cambia la estructura documentada.
