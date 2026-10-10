## Why

El campo "Tap to add a note" ocupa un bloque completo sobre el botón Guardar y compite con el carrusel de moods por atención, aunque la nota es una función secundaria. Desde que los menús viven en el bottom bar, la esquina superior derecha del selector quedó libre y es un lugar natural para una acción secundaria.

## What Changes

- Se quita el campo inline de nota (preview de solo lectura) de la parte baja del selector de moods.
- Se añade una píldora con icono y texto corto fijo ("Note", "Nota", "Notiz", "Note", "Nota") en la esquina superior derecha, alineada con la fecha y la pregunta del encabezado.
- Tocar la píldora abre el mismo bottom sheet de edición de nota que existe hoy; el sheet no cambia.
- Cuando hay una nota escrita, la píldora lo indica con el icono relleno y un puntito de color fijo (no cambia con el mood). El texto de la nota ya no se previsualiza en la pantalla principal.
- **BREAKING** (solo spec): se eliminan los requisitos "Preview inline de solo lectura" y el truncado a 3 líneas, y el placeholder del preview inline deja de existir.
- El string `noteInlineHint` ("Tap to add a note") se sustituye por `noteButtonLabel` en los 5 idiomas.

## Capabilities

### New Capabilities

### Modified Capabilities
- `daily-note-capture`: el punto de entrada pasa de un preview inline a un botón en el encabezado con indicador de estado; el sheet, el límite de 500 caracteres, el acento por mood y el cubrimiento del bottom bar no cambian.
- `localization-architecture`: el requisito del placeholder deja de cubrir el preview inline; se añade que la etiqueta del botón de nota se muestra localizada.

## Impact

- `lib/features/mood/presentation/screens/mood_screen.dart`: encabezado en `Row` con la píldora; se elimina el `InputDecorator` de la nota.
- `lib/core/localization/app_strings*.dart` (abstracta + en, es, de, fr, it): alta de `noteButtonLabel`, baja de `noteInlineHint`.
- `test/features/mood/presentation/screens/mood_screen_test.dart`: los tests que tocan `noteInlineHint` pasan a usar la píldora; tests nuevos del indicador de estado.
- Sin cambios en datos, Hive, compras ni dependencias.
