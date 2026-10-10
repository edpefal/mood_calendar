## 1. Localización

- [x] 1.1 Añadir el getter abstracto `noteButtonLabel` en `lib/core/localization/app_strings.dart` y quitar `noteInlineHint`
- [x] 1.2 Implementar `noteButtonLabel` en `app_strings_en.dart` ("Note"), `_es` ("Nota"), `_de` ("Notiz"), `_fr` ("Note") e `_it` ("Nota") y quitar `noteInlineHint` de cada una

## 2. UI del selector de moods

- [x] 2.1 Crear `_NoteButton` en `mood_screen.dart`: píldora con icono y `noteButtonLabel`, punto indicador de color fijo, `Semantics(button: true, label: ...)` y punto excluido del árbol semántico
- [x] 2.2 Convertir el encabezado en un `Row`: fecha y pregunta en `Expanded` (elipsis), `_NoteButton` alineado arriba a la derecha, reconstruido con `AnimatedBuilder` sobre `_noteController`
- [x] 2.3 Eliminar el `InputDecorator`/`GestureDetector` del campo de nota inline del bloque inferior, dejando Guardar y el texto "guardando"
- [x] 2.4 Conectar `onTap` a `_openNoteEditor` sin cambios en el sheet

## 3. Tests

- [x] 3.1 Actualizar los tests de `mood_screen_test.dart` que tocan `strings.noteInlineHint` (líneas ~351, ~887, ~984) para tocar el botón de nota por su `Semantics`/texto
- [x] 3.2 Añadir test: sin nota muestra el icono de contorno y ningún punto; con nota (entrada existente) muestra el icono relleno y el punto
- [x] 3.3 Añadir test: escribir en el sheet y cerrarlo pasa el botón al estado con nota; borrar todo lo devuelve al estado sin nota
- [x] 3.4 Añadir test: el botón de nota sigue visible con una fecha larga y textScaleFactor alto, sin overflow
- [x] 3.5 Añadir test: la etiqueta del botón sale en español y en inglés para locale no soportado
- [x] 3.6 Correr `flutter analyze` y `flutter test`

## 4. Verificación en simulador

- [x] 4.1 Validar en iPhone 16e (390 pt) y en iPad: encabezado sin overflow, píldora alineada, estados con y sin nota (ver `docs/ios-simulator-ui-testing.md`). Verificado en iPhone 17 Pro Max (en, de), iPhone 16e a 390 pt (en, de, es, fr, it) e iPad (en, de)
- [x] 4.2 Validar en alemán (la etiqueta más larga junto a una fecha larga) y confirmar que el icono relleno elegido se ve bien

## 5. Documentación

- [x] 5.1 Actualizar `CLAUDE.md` donde mencione el campo de nota inline
- [x] 5.2 Actualizar `tool/screenshots/capture.py` (paso "note editor", ~línea 135): hoy localiza el botón de nota por posición en la parte baja (`b[1] > 600`); debe buscar la píldora de la esquina superior derecha
