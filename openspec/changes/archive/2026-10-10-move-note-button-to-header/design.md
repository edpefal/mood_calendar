## Context

`MoodScreen` (`lib/features/mood/presentation/screens/mood_screen.dart`) es una `Column` con `spaceBetween`: encabezado (fecha + pregunta), carrusel de moods y un bloque inferior con el campo de nota inline y el botón Guardar. El campo inline es un `InputDecorator` dentro de un `GestureDetector` que llama a `_openNoteEditor`, y se reconstruye con `AnimatedBuilder` sobre `_noteController`. Ese mismo campo hacía de preview del texto guardado.

El bottom bar (`MainShell`) ya contiene la navegación, así que la esquina superior derecha del selector está libre. Ver proposal.md para la motivación.

## Goals / Non-Goals

**Goals:**
- Reemplazar el campo inline por una píldora en el encabezado sin tocar el sheet de edición ni el flujo de guardado.
- Que el estado "hay nota" siga siendo visible sin previsualizar el texto.

**Non-Goals:**
- Rediseñar `note_editor_sheet.dart`, el límite de 500 caracteres o el modelo de datos.
- Previsualizar la nota en otra parte de la pantalla.
- Cambiar el calendario o cómo se muestran las notas allí.

## Decisions

**1. Encabezado en `Row` con `Expanded` a la izquierda.** La fecha y la pregunta quedan en un `Expanded` para que se recorten con elipsis antes de empujar la píldora; la píldora va alineada arriba (`crossAxisAlignment.start`). Alternativa descartada: `Stack` con `Positioned`, porque no cede espacio al texto y se solapa con fechas largas en alemán o con Dynamic Type grande.

**2. Widget privado `_NoteButton` en el mismo archivo.** Es de un solo uso y depende de `_noteController`, así que no justifica `core/widgets/`. Recibe `hasNote` y `onTap`, y se reconstruye con el mismo `AnimatedBuilder` sobre `_noteController` para reaccionar al texto mientras se escribe en el sheet.

**3. Estado con icono + punto, no con texto.** `Icons.sticky_note_2_outlined` sin nota y `Icons.sticky_note_2_rounded` con nota (par contorno/relleno; `edit_note` no tiene variante rellena). El punto usa el púrpura de marca fijo (no `selectedMood.color`: la nota pertenece a la fecha, no al mood, y un color que cambia al deslizar parecería un cambio en la nota) y va en la esquina del icono con borde blanco. La etiqueta de texto no cambia entre estados, para que la píldora no cambie de ancho. Alternativa descartada: etiqueta "Add note"/"Edit note", por duplicar strings (10 en total) y por el riesgo de desborde en alemán.

**4. Estilo de la píldora.** Fondo blanco con ligera transparencia sobre el gradiente pastel, icono y texto en púrpura de marca `#5F3DC4`, bordes redondeados. No es un `GradientPillButton`: ese es el botón primario y aquí competiría con Guardar.

**5. Semantics.** La píldora lleva `Semantics(button: true, label: strings.noteButtonLabel)`, igual que hacía el campo con `noteInlineHint`. El punto es decorativo y se excluye del árbol (`ExcludeSemantics`); el estado "con nota" se comunica por el icono y no añade string nuevo, en línea con la decisión de usar un solo string.

**6. Strings.** Se añade `noteButtonLabel` en `AppStrings` y las 5 subclases (en: "Note", es: "Nota", de: "Notiz", fr: "Note", it: "Nota") y se elimina `noteInlineHint`. Se borra en lugar de dejarlo huérfano porque nada más lo usa fuera de los tests.

**7. Layout del cuerpo.** Al quitar el campo, el bloque inferior queda solo con Guardar (y el texto "guardando"). Se mantiene `spaceBetween`; el carrusel sigue centrado visualmente por los otros dos bloques.

## Risks / Trade-offs

- [El usuario no ve el texto de su nota en la pantalla principal] → Es una decisión de producto aceptada; el punto indica que existe y el sheet la muestra completa al tocar.
- [Quien ya usaba el campo puede no encontrar la nota] → La píldora está visible y etiquetada en todo momento, no solo como icono.
- [Fecha larga + píldora en iPhone angosto (390 pt) o alemán] → `Expanded` con elipsis; verificar en el simulador iPhone 16e y en iPad.
- [Cobertura de tests] → Los tests que tocan `noteInlineHint` se reescriben contra la píldora; se añaden tests de ambos estados del indicador.
