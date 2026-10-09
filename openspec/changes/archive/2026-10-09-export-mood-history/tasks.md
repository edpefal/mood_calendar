## 1. Dependencia y strings

- [x] 1.1 Agregar `share_plus` a `pubspec.yaml`, correr `flutter pub get` y `pod install`; confirmar que el build de simulador compila con deployment target 15.0
- [x] 1.2 Añadir en `app_strings.dart` los getters nuevos: título de la sección de datos (`settingsDataSection`), título y etiqueta `Semantics` de la fila (`exportHistoryTitle`, `exportHistorySemanticLabel`) y mensaje de historial vacío (`exportHistoryEmpty`)
- [x] 1.3 Implementarlos en `app_strings_en.dart`, `_es`, `_de`, `_fr` e `_it`
- [x] 1.4 Eliminar `historyExportedTo` (y `exportHistoryTooltip` si queda sin uso tras reutilizarlo como título) de `app_strings.dart` y de los 5 idiomas; verificar con `grep` que nada más los usa

## 2. Exportador

- [x] 2.1 En `json_mood_history_exporter.dart`, cambiar el formato a `{formatVersion: 1, generatedAt, entryCount, entries[{date, mood, note}]}`, con `mood` igual al `MoodDefinition.id` y sin `intensity`
- [x] 2.2 Resolver el id con una búsqueda estricta por asset path; si no hay coincidencia, exportar el valor guardado sin sustituirlo
- [x] 2.3 Cambiar el directorio por defecto a `getTemporaryDirectory()` y borrar los archivos previos de `exports/` antes de escribir
- [x] 2.4 Actualizar `json_mood_history_exporter_test.dart` al nuevo formato y agregar tests: id estable sin `intensity` ni rutas, `formatVersion`, orden ascendente, mood desconocido exportado crudo, mood premium exportado, limpieza de archivos previos y telemetría sin contenido de notas

## 3. Cableado

- [x] 3.1 En `lib/main.dart`, crear `JsonMoodHistoryExporter` y exponer `ExportMoodHistoryUseCase` con `RepositoryProvider`

## 4. Fila en Settings

- [x] 4.1 En `settings_screen.dart`, agregar la sección "Tus datos" entre Recordatorios y Ayuda y Acerca de, con el encabezado y la fila
- [x] 4.2 Crear `_ExportHistoryRow`: al tocar, exporta con el use case; mientras tanto muestra progreso, se deshabilita y cambia su etiqueta de `Semantics`
- [x] 4.3 Con `entryCount == 0`, mostrar SnackBar de historial vacío sin abrir la hoja; si falla, SnackBar con `historyExportFailed` y la fila vuelve a estar disponible
- [x] 4.4 Compartir el archivo con `share_plus` (`application/json`), con `sharePositionOrigin` calculado del `RenderBox` de la fila; la función de compartir es inyectable para tests
- [x] 4.5 Widget tests (`settings_screen_test.dart`): éxito comparte el archivo, vacío no comparte y avisa, error avisa y no comparte, la fila se deshabilita mientras exporta, no se inician dos exportaciones, `Semantics`, render en alemán

## 5. Docs

- [x] 5.1 Actualizar `backlog.md`: la exportación ya tiene UI en Settings y formato versionado
- [x] 5.2 Revisar `CLAUDE.md` (descripción de `features/settings`, specs vigentes con `mood-history-export`)

## 6. Verificación

- [x] 6.1 `flutter analyze` y `flutter test` sin errores
- [x] 6.2 En simulador iPhone: exportar con historial real, ver la hoja de compartir, guardar en Archivos y abrir el JSON; confirmar el formato y que no hay `intensity`
- [x] 6.3 En simulador iPad: la hoja aparece anclada a la fila, sin error de `sharePositionOrigin`
- [ ] 6.4 Probar historial vacío, cancelar la hoja y exportar dos veces seguidas (sin archivos acumulados en el directorio de la app)
- [ ] 6.5 Confirmar que la política de privacidad de App Store Connect no contradice la exportación manual del historial
- [x] 6.6 `openspec validate export-mood-history --strict`
