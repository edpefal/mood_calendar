## Context

Ya existen `MoodHistoryExporter` (dominio), `ExportMoodHistoryUseCase` y `JsonMoodHistoryExporter` (datos), con tests y con strings (`exportHistoryTooltip`, `exportingHistory`, `historyExportedTo`, `historyExportFailed`). Nada de eso está conectado a la UI ni expuesto por `RepositoryProvider` en `main.dart`. El exportador escribe en `getApplicationDocumentsDirectory()/exports`, y cada llamada crea un archivo nuevo con timestamp que nunca se borra. Su JSON usa `MoodEntry.mood` tal cual (ruta de asset) e incluye `intensity`.

`MoodDefinitionResolver.byAssetPath` hace `orElse: baseMoodDefinitions.first`, o sea que un mood desconocido se resuelve como *happy*. Ver `proposal.md` para la motivación. Este change agrega una fila a la pantalla de Settings de `add-settings-screen`, por lo que se implementa después de que ese change esté mergeado.

## Goals / Non-Goals

**Goals:**
- Conectar el exportador existente a Settings con una experiencia completa (progreso, vacío, error, cancelar).
- Fijar un formato de archivo estable antes de que llegue a usuarios.
- No dejar copias del historial acumuladas dentro de la app.

**Non-Goals:**
- Importar o restaurar desde el archivo (el `formatVersion` deja abierta esa puerta, pero no se construye).
- Otros formatos (CSV, PDF) o filtros por rango de fechas.
- Exportación automática o respaldos en la nube.
- Exportar ajustes, entitlements ni datos de compras.

## Decisions

**1. La fila vive dentro de `SettingsScreen`, con estado local, sin cubit.**
El estado de la exportación (idle / exportando) es efímero y de una sola fila, así que un `StatefulWidget` privado (`_ExportHistoryRow`) basta. Recibe `ExportMoodHistoryUseCase` por `context.read` y una función `shareFile` inyectable para poder probarla sin el plugin. *Alternativa descartada*: sumarlo a `SettingsCubit`; mezclaría ajustes persistidos con una acción puntual y lo haría crecer sin necesidad.

**2. `share_plus` para la hoja de compartir, con `sharePositionOrigin` calculado de la fila.**
En iPad la hoja es un popover y falla o se ve mal sin un rect de origen. Se calcula con el `RenderBox` de la fila (`localToGlobal`) justo antes de compartir. Se usa la API vigente de la versión de `share_plus` instalada, compartiendo un `XFile` con `application/json`. *Alternativa descartada*: exponer la carpeta en la app Archivos (`UIFileSharingEnabled`); poco descubrible y expone todo `Documents`.

**3. Archivo en el directorio temporal.**
El proveedor por defecto del exportador pasa de `getApplicationDocumentsDirectory` a `getTemporaryDirectory`, escribiendo en una subcarpeta `exports/`. iOS puede limpiar esa carpeta cuando necesite espacio, no entra a respaldos y las notas no se acumulan en el almacenamiento permanente. Antes de escribir se borran los archivos previos de esa subcarpeta, para no depender de que el sistema limpie. El proveedor sigue siendo inyectable (`ExportDirectoryProvider`), así que los tests no cambian de forma.

**4. Formato JSON v1: `{formatVersion, generatedAt, entryCount, entries[{date, mood, note}]}`.**
`mood` es `MoodDefinition.id`. `intensity` se elimina porque es un identificador interno (ADR 0001) que un lector externo interpretaría como "nivel". `formatVersion` permite evolucionar el formato sin romper a quien lo consuma. Es seguro cambiarlo ahora porque el exportador nunca se publicó.

**5. Mood desconocido: se exporta el valor crudo.**
Se agrega una búsqueda estricta (por asset path, sin `orElse`) en el exportador, o un método nuevo del resolver que devuelva nulo; si no hay coincidencia, `mood` toma el valor guardado. Con eso no se falsifica un dato por el fallback a *happy* de `byAssetPath` ni se pierde información. *Alternativa descartada*: omitir esas entradas; el conteo y el historial dejarían de coincidir con lo que el usuario ve.

**6. Historial vacío se resuelve en la UI, no en el exportador.**
El exportador sigue devolviendo `MoodHistoryExportResult` con `entryCount`. La fila revisa `entryCount == 0`, no abre la hoja y muestra un SnackBar. Evita compartir un archivo sin entradas y mantiene el exportador sin lógica de presentación.

**7. Mensajes: un string nuevo para vacío y se retira `historyExportedTo`.**
La hoja de compartir ya es la confirmación, y el texto "exportado a <archivo>" hablaba de una ruta que el usuario no puede ver. Se reutilizan `exportingHistory` (progreso) y `historyExportFailed` (error); `exportHistoryTooltip` se reutiliza como título de la fila.

## Risks / Trade-offs

- **Las notas son datos sensibles y salen del dispositivo** → solo por acción explícita; el archivo es temporal; la telemetría no incluye notas. Revisar que la política de privacidad no contradiga una exportación manual.
- **`sharePositionOrigin` incorrecto en iPad** (rect nulo o fuera de pantalla) → calcularlo del `RenderBox` en el momento, y probarlo en el simulador de iPad antes del PR.
- **El usuario cierra la hoja sin compartir** → no es un error; no se muestra nada. `share_plus` no siempre distingue "cancelado" de "compartido" en iOS, por lo que no se muestra confirmación de éxito.
- **Limpieza del directorio temporal borra un export en uso** → solo se borra al iniciar una nueva exportación, cuando la anterior ya terminó (la fila está deshabilitada mientras exporta).
- **Mood desconocido exportado crudo** → el lector del archivo puede ver una ruta de asset en ese caso raro; es preferible a datos falsos. Cubierto por un test.
- **Dependencia nueva con código nativo** (`share_plus`) → `pod install` y build de iOS completo para confirmar que compila con deployment target 15.0.

## Migration Plan

Sin migración de datos: el exportador nunca se publicó, no hay archivos ni formato previo en manos de usuarios. Rollback: revertir el PR. Orden de merge: primero `add-settings-screen` (PR #60) y archivarlo, después este change.

## Open Questions

- ¿Nombre del archivo visible al usuario? Hoy es `mood-history-<timestamp>.json`; se deja así salvo que se prefiera uno más legible (por ejemplo `mood-calendar-history.json`).
