## 1. Generalizar el color-por-mood

- [x] 1.1 Cambiar `MoodDefinitionResolver.backgroundGradientForMood()` para derivar `[shade50, shade200]` de `mood.color as MaterialColor`, eliminando el switch hardcodeado.
- [x] 1.2 Agregar un test unitario que itere `allMoodDefinitions` (los 10) y verifique que `backgroundGradientForMood()` no lanza y devuelve 2 colores distintos por mood.
- [x] 1.3 Verificar visualmente en el simulador (vía `idb`, ver `docs/ios-simulator-ui-testing.md`) que `MoodScreen` muestra un fondo distinto para cada uno de los 5 moods premium (hoy comparten el lavanda de fallback) — swipe por el carousel y screenshot de al menos 2 moods premium.

## 2. Botón primario unificado

- [x] 2.1 Extraer `GradientPillButton` (label, onPressed, loading/disabled) en `lib/core/widgets/gradient_pill_button.dart`, con el gradiente y radius exactos del botón "Save" actual de `MoodScreen`.
- [x] 2.2 Reemplazar el `FilledButton` del diálogo de recordatorio en `CalendarScreen` por `GradientPillButton`.
- [x] 2.3 Reemplazar los `FilledButton`/`OutlinedButton` de compra en `MoodStoreScreen` (`_MoodOfferTile`, `_MoodPackTile`) por `GradientPillButton` para la acción de comprar; mantener el pill suave ("Unlocked") como está, sin gradiente (es informativo, no una acción).
- [x] 2.4 Reemplazar los `FilledButton` de `mood_purchase_sheet.dart` y `pack_purchase_sheet.dart` por `GradientPillButton`.
- [x] 2.5 Migrar el botón "Save" de `MoodScreen` para usar el nuevo `GradientPillButton` (en vez de su `Container` inline), confirmando visualmente que no cambia nada perceptible.
- [x] 2.6 Decidir y aplicar el tratamiento del botón "Restore purchases" (hoy `OutlinedButton`) — ¿pill outline o se deja como está por ser una acción secundaria? (ver nota en design.md sobre jerarquía de acciones).

## 3. Tipografía y color de íconos en MoodStoreScreen

- [x] 3.1 Aplicar bold + `Color(0xFF5F3DC4)` al título "Mood Store" del `AppBar`.
- [x] 3.2 Aplicar bold (peso 600, sin color de marca) a los headers "Premium moods" y "Packs".
- [x] 3.3 Tintar de púrpura (`Color(0xFF5F3DC4)`) el ícono de "volver" del `AppBar` de `MoodStoreScreen`.

## 4. Iconografía del pack

- [x] 4.1 En `_MoodPackTile`, reemplazar el texto "Includes: X, Y, Z" por una fila de íconos SVG (`SvgPicture.asset`) de cada mood incluido en el pack, con un label corto debajo o al lado (ver mockup: fila de círculos + texto breve).

## 5. Accesibilidad

- [x] 5.1 Agregar `Semantics` con label descriptivo (ej. "Volver al calendario" / string localizado) al botón de "volver" de `CalendarScreen`. Nota: el código actual de `CalendarScreen` no tenía ningún botón de volver (sin `AppBar`, sin `IconButton` — confirmado leyendo el código y con `idb` antes del fix); se agregó un `IconButton` real (`Icons.arrow_back`, tinte `#5F3DC4`, tooltip `backToTodayTooltip` localizado en los 5 idiomas) que hace `pop` o, si no hay nada para popear, navega a `MoodScreen`.
- [x] 5.2 Verificar con `idb ui describe-all` que el label aparece en el árbol de accesibilidad.

## 6. CalendarScreen — cards de resumen

- [x] 6.1 Tintar la card "Most frequent mood" con `backgroundGradientForMood()` del mood que efectivamente muestra (reemplazando el gradiente púrpura genérico), ajustando el color de texto para mantener contraste (oscuro/tono del mood en vez de blanco).
- [x] 6.2 Agregar un ícono (ej. racha/flama) a la card "Best streak" para que tenga la misma composición (ícono + título + texto) que "Most frequent mood".

## 7. Campo de nota — foco visible

- [x] 7.1 Agregar `focusedBorder` (2px) al `TextField` de nota en `MoodScreen`, tintado con el `MoodDefinition.color` del mood actualmente seleccionado en el carousel (no el guardado).

## 8. Verificación final

- [x] 8.1 Recorrer las 3 pantallas en el simulador (vía `idb`) después de todos los cambios: `MoodScreen` (con un mood base y uno premium seleccionados), `CalendarScreen` (con datos reales de al menos 2 moods distintos), `MoodStoreScreen` (catálogo cargado) — confirmar que no quedó ningún botón/ícono/título usando el estilo anterior. Nota: el catálogo de `MoodStoreScreen` se verificó vacío ("No premium moods/packs available") porque este run de dev no tiene `REVENUECAT_IOS_API_KEY`; título/headers/back-icon/restore-button se confirmaron igual. `CalendarScreen` se verificó sin datos reales (mes sin entries) — ver nota en 5.1/5.2 sobre el botón de volver ausente.
- [x] 8.2 Correr `flutter analyze` y la suite de tests para confirmar que no se rompió nada.
