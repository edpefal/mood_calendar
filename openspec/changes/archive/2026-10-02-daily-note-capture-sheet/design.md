## Context

Ver `proposal.md` - Why. El estado actual: `MoodScreen` (`lib/features/mood/presentation/screens/mood_screen.dart`) mantiene `_noteController` (un `TextEditingController` declarado en el `State`, poblado desde `MoodEntry?.note` al cargar y leído de vuelta al guardar en `_saveMood()`). El `TextField` de nota vive inline en la columna inferior del screen, junto al `GradientPillButton` de guardar. La app ya tiene dos convenciones de `showModalBottomSheet`: la de `mood_purchase_sheet.dart`/`pack_purchase_sheet.dart` (shape con esquinas redondeadas explícitas, `isScrollControlled: true`, `SafeArea`, contenido envuelto en `BlocProvider.value`) y la de `calendar_screen.dart` (`showDragHandle: true`, sin shape custom). Este cambio sigue la primera convención, sin `BlocProvider` porque no hay estado de Cubit nuevo involucrado — el sheet opera directamente sobre el `_noteController` que ya existe en `MoodScreen`.

## Goals / Non-Goals

**Goals:**
- Reemplazar el `TextField` editable inline por un preview de solo lectura + bottom sheet de edición expandida, reutilizando el mismo `TextEditingController` sin cambiar el flujo de guardado existente.
- Agregar límite de 500 caracteres con contador visible, sin tocar el modelo de datos.
- Mantener consistencia visual con las convenciones de bottom sheet y de acento por mood ya establecidas en la app.

**Non-Goals:**
- No se introduce un estado de "borrador" ni confirmación de descarte: el sheet edita en vivo el mismo valor que ya se persiste solo al pulsar "Guardar" en la pantalla principal (igual que hoy).
- No se cambia `MoodEntry.note` / `MoodModel.note` ni se agrega validación a nivel de persistencia (Hive/freezed) — el límite de 500 caracteres es exclusivamente de entrada en la UI.
- No se gestiona retroactivamente ninguna nota existente que ya exceda 500 caracteres (no hay backfill ni truncado automático).

## Decisions

**1. Un solo widget stateful para el bottom sheet, sin Cubit nuevo.**
El sheet se implementa como un widget separado (sugerido: `lib/features/mood/presentation/widgets/note_editor_sheet.dart`) que recibe el `TextEditingController` existente de `MoodScreen` y el color del mood seleccionado como parámetros. Alternativa descartada: crear un Cubit dedicado para el estado del sheet — innecesario porque no hay lógica async ni estado que sobreviva más allá de la sesión de edición; el controller ya es la única fuente de verdad.

**2. `InputDecorator` + `Text` con `overflow: TextOverflow.ellipsis` dentro de un `GestureDetector`, en vez de un `TextField(readOnly: true)`.**
`TextField`/`EditableText` no exponen una propiedad `overflow`: con `maxLines` fijo, el texto que no cabe simplemente se recorta sin elipsis, lo cual no cumple el requisito de spec de truncar con elipsis. `InputDecorator` reproduce el mismo `InputDecoration` (bordes, `fillColor`, padding) que ya usaba el `TextField`, envolviendo un `Text` que sí soporta `overflow: TextOverflow.ellipsis`. El widget se envuelve en `AnimatedBuilder(animation: _noteController, ...)` para redibujarse cuando el texto cambia en el sheet (el `TextEditingController` es un `ValueNotifier`, por lo que no requiere `setState` manual). `onTap` vive en el `GestureDetector` exterior. Alternativa descartada: `TextField(readOnly: true, maxLines: 3)` — preservaba el estilo pero no truncaba con elipsis, solo recortaba el overflow sin indicador visual.

**3. Contador de caracteres vía `maxLength` + `counterText`/`buildCounter` nativo de Flutter, sin widget de contador custom.**
`TextField(maxLength: 500)` ya trae contador y enforcement de límite gratis. Se usa `counterStyle`/`buildCounter` únicamente para fijar el color neutral (evitando el color de advertencia que Flutter aplica por defecto cerca del límite vía `Theme`), no para cambiar el comportamiento de conteo.

**4. El bottom sheet no usa `BlocProvider` porque no depende de ningún Cubit.**
A diferencia de `mood_purchase_sheet.dart` (que sí envuelve el contenido en `BlocProvider.value` para `PurchasesCubit`), este sheet es puramente de presentación sobre un `TextEditingController` pasado por parámetro. No hay estado asíncrono que requiera un Cubit.

**5. Localización: placeholder inline y placeholder del sheet son dos getters distintos en `AppStrings`.**
Se evita reutilizar un único `noteHint` para ambos contextos porque transmiten intenciones distintas (invitar a tocar vs. invitar a escribir). Ver tabla de strings en `proposal.md` - Impact.

## Risks / Trade-offs

- [Riesgo] Cambiar el `TextField` inline a `readOnly` podría romper algún test de widget existente que simule escribir directamente en ese campo (`test/` cubre `MoodScreen`). → Mitigación: revisar y actualizar los tests de `MoodScreen` que interactúan con el campo de nota para que en su lugar abran el sheet y escriban ahí.
- [Riesgo] El spec de `localization-architecture` ya tiene un escenario "Campo de nota en español" ligado a un único placeholder; el delta lo reemplaza por dos escenarios (preview + sheet). → Mitigación: el delta usa el mismo header de requirement (`### Requirement: Placeholder del campo de nota localizado`) para que el archive lo trate como modificación, no como requirement nuevo.
- [Trade-off] No hay "cancelar" explícito en el sheet — cualquier texto escrito queda en el controller aunque el usuario cierre el sheet sin intención de conservarlo. Se acepta porque es el mismo comportamiento que ya existe hoy con el campo inline (tampoco hay undo), y porque el guardado real solo ocurre al pulsar "Guardar" en la pantalla principal.
