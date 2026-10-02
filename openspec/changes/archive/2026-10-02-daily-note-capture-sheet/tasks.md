## 1. Localización

- [x] 1.1 Agregar 4 getters abstractos nuevos a `AppStrings` (`lib/core/localization/app_strings.dart`): `noteInlineHint`, `noteSheetTitle`, `noteSheetDoneButton`, `noteSheetPlaceholder`.
- [x] 1.2 Implementar los 4 getters en `app_strings_es.dart` ("Toca para agregar una nota", "Nota del día", "Listo", "Cuéntame sobre tu día...").
- [x] 1.3 Implementar los 4 getters en `app_strings_en.dart` ("Tap to add a note", "Daily note", "Done", "Tell me about your day...").
- [x] 1.4 Implementar los 4 getters en `app_strings_de.dart` ("Zum Hinzufügen einer Notiz tippen", "Tagesnotiz", "Fertig", "Erzähl mir von deinem Tag...").
- [x] 1.5 Implementar los 4 getters en `app_strings_fr.dart` ("Appuyez pour ajouter une note", "Note du jour", "Terminé", "Raconte-moi ta journée...").
- [x] 1.6 Implementar los 4 getters en `app_strings_it.dart` ("Tocca per aggiungere una nota", "Nota del giorno", "Fine", "Raccontami della tua giornata...").
- [x] 1.7 Revisar el uso existente del getter `noteHint` (usado solo en el campo de nota inline): eliminarlo si queda sin otros usos, o dejarlo si se referencia en otro lugar. (Se eliminó por completo: único uso estaba en `mood_screen.dart`, reemplazado por `noteInlineHint`/`noteSheetPlaceholder`.)

## 2. Bottom sheet de edición de nota

- [x] 2.1 Crear `lib/features/mood/presentation/widgets/note_editor_sheet.dart` con una función `showNoteEditorSheet(BuildContext context, {required TextEditingController controller, required Color accentColor})`. (El parámetro se tipó como `Color`, no `MaterialColor`: `MoodDefinition.color` es `Color` en el código real, a diferencia de lo indicado en `CLAUDE.md`.)
- [x] 2.2 Implementar el sheet con `showModalBottomSheet(isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))))`, siguiendo la convención visual de `mood_purchase_sheet.dart`.
- [x] 2.3 Implementar el header del sheet: título (`AppStrings.of(context).noteSheetTitle`) + `TextButton` "Listo" (`AppStrings.of(context).noteSheetDoneButton`) alineado a la derecha, que cierra el sheet (`Navigator.pop`).
- [x] 2.4 Implementar el `TextField` interno: `controller` recibido por parámetro, `autofocus: true`, `maxLines` null/expandido, `maxLength: 500`, placeholder `AppStrings.of(context).noteSheetPlaceholder`, `focusedBorder` con color `accentColor`.
- [x] 2.5 Configurar el contador de caracteres ("320/500") en color neutral, sobrescribiendo el estilo de advertencia por defecto de Flutter cerca del límite (vía `buildCounter` o `counterStyle` fijo).
- [x] 2.6 Envolver el contenido en `SafeArea` + manejo de `Padding` para que el teclado no tape el campo (usar `MediaQuery.viewInsets` o `resizeToAvoidBottomInset` equivalente dentro del sheet).

## 3. Integración en MoodScreen

- [x] 3.1 En `lib/features/mood/presentation/screens/mood_screen.dart`, cambiar el campo de nota (líneas ~419-444) a un preview de solo lectura con `maxLines: 3` y `overflow` por elipsis. (Implementado con `InputDecorator` + `Text(overflow: TextOverflow.ellipsis)` en vez de `TextField(readOnly: true)`, porque `TextField` no soporta `overflow` — ver `design.md` decisión 2 actualizada.)
- [x] 3.2 Cambiar el `hintText` del campo inline a `AppStrings.of(context).noteInlineHint`.
- [x] 3.3 Agregar `onTap` al campo inline que invoque `showNoteEditorSheet(context, controller: _noteController, accentColor: selectedMood.color)`.
- [x] 3.4 Verificar que `_saveMood()` sigue leyendo `_noteController.text` sin cambios (no debería requerir modificación).
- [x] 3.5 Verificar visualmente que el preview inline muestra correctamente hasta 3 líneas con elipsis cuando el texto es largo. (Confirmado en simulador, ver tarea 6.1.)

## 4. Sincronización de specs

- [x] 4.1 Confirmar que el delta de `localization-architecture` en este change refleja fielmente el comportamiento final implementado (dos placeholders distintos) antes de archivar. (Verificado: coincide con `noteInlineHint`/`noteSheetPlaceholder` implementados.)

## 5. Testing

- [x] 5.1 Revisar `test/` en busca de tests de `MoodScreen` que interactúen con el campo de nota directamente (`enterText` sobre el `TextField` inline); actualizarlos para que abran el sheet (tap) y escriban ahí. (Ningún test existente escribía en el campo de nota directamente; no requirió cambios. Confirmado: `flutter test test/widget_test.dart test/features/mood/presentation/screens/mood_screen_test.dart` pasa sin regresiones tras el cambio.)
- [x] 5.2 Agregar un test de widget que verifique que el campo inline es `readOnly` y que tocar el preview abre el bottom sheet. (El preview ya no es un `TextField`, es un `InputDecorator`/`Text` tocable — el test verifica que tocarlo abre el sheet, ver `design.md` decisión 2.)
- [x] 5.3 Agregar un test de widget para el límite de 500 caracteres dentro del sheet (no se puede exceder, el contador refleja el conteo correcto).
- [x] 5.4 Agregar un test de widget que verifique que cerrar el sheet (botón "Listo") conserva el texto escrito en el preview inline.
- [x] 5.5 Correr `flutter analyze` y `flutter test` completos para confirmar que no hay regresiones. (`flutter analyze`: no issues found. `flutter test`: 32/32 tests pasan.)

## 6. Validación manual en simulador

- [x] 6.1 Probar el flujo completo en el simulador de iOS (ver `docs/ios-simulator-ui-testing.md`): abrir el sheet, escribir una nota larga, cerrar con "Listo", confirmar que el preview la muestra truncada, y que se persiste correctamente al guardar el mood. (Validado en simulador iPhone 17 vía idb: sheet abre con autofocus, contador "412/500" visible, "Listo" cierra y conserva el texto, preview trunca a 3 líneas con elipsis.)
- [x] 6.2 Verificar que el acento visual del sheet (borde del campo, botón "Listo") cambia según el mood seleccionado. (Confirmado: con mood "Sad" el borde del campo y el texto de "Done" cambian a naranja, el color de ese mood.)
