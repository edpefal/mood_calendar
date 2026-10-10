## Why

Hoy las tres secciones secundarias (tienda, calendario y ajustes) se abren con iconos en el header de `MoodScreen` y con `Navigator.push`. Eso las esconde detrás del selector, obliga a "volver" a una pantalla concreta y no escala si se suman más secciones. Un bottom bar translúcido, como el de Instagram, vuelve esos cuatro destinos siempre visibles y a un toque.

## What Changes

- Se agrega un **bottom bar flotante** con cuatro pestañas, en este orden: selector de moods (icono `sentiment_satisfied_outlined`), calendario, tienda y ajustes. Los iconos son de Material en estilo outlined y en púrpura de marca, igual que los actuales; no se usan SVG.
- El bar es una cápsula translúcida (desenfoque más tinte blanco), con la pestaña activa marcada por una píldora translúcida detrás del icono. En pantallas anchas (iPad) tiene un ancho máximo de unos 400 a 440 pt y va centrado.
- Las cuatro pestañas viven en un shell que conserva su estado (`IndexedStack`). La fecha del selector solo cambia al tocar un día del calendario.
- El bar está siempre visible, y los modales (editor de nota y hojas de compra) lo cubren mientras están abiertos.
- Se quitan del header de `MoodScreen` los botones de tienda, calendario y ajustes.
- Tienda, Calendario y Ajustes pierden la flecha de regresar y muestran su título en bold y color de marca; el calendario gana un título nuevo, "Calendario" traducido.
- Guardar una Mood Entry cambia a la pestaña Calendario, con el día guardado resaltado y el pedido de calificación igual que hoy.
- Tocar la notificación del recordatorio va a la pestaña del selector con la fecha del recordatorio y cierra los modales abiertos.
- Cada pantalla reserva espacio inferior para que el bar flotante no tape contenido (botón de guardar, listas de Tienda y Ajustes).
- **BREAKING**: se elimina el botón "volver a la última fecha vista" del calendario; esa regla pasa a ser el estado conservado de la pestaña del selector.

## Capabilities

### New Capabilities

- `bottom-navigation`: bottom bar flotante con cuatro pestañas, su apariencia (cápsula translúcida, píldora de pestaña activa, ancho máximo), cómo lo cubren los modales, la conservación de estado de las pestañas, y los cambios de pestaña automáticos (guardar y recordatorio).

### Modified Capabilities

- `calendar-navigation`: desaparece el botón de volver del calendario; la fecha que muestra la pestaña del selector pasa a ser la conservada por el shell y se actualiza al tocar un día del calendario.
- `settings-screen`: Settings deja de abrirse desde un engrane del header y pasa a ser una pestaña del bar, sin botón de volver.
- `mood-store`: la Tienda deja de abrirse desde un icono del header y pasa a ser una pestaña del bar, sin botón de volver.
- `rating-prompt`: la condición "vuelve a mostrar el calendario" se cumple al cambiar a la pestaña Calendario tras guardar.
- `daily-note-capture`: el editor de nota cubre el bottom bar mientras está abierto.

## Impact

- **Código**: nuevo shell y widget del bar en `lib/core/navigation/` y `lib/core/widgets/`; refactor de `AppNavigator` (se eliminan `pushMoodScreen`, `popOrShowCalendar` y `openMoodFromReminder` tal como existen); `MoodScreen` pierde los botones del header y la navegación a tienda y ajustes; `CalendarScreen`, `MoodStoreScreen` y `SettingsScreen` pierden su flecha de regresar; `lib/main.dart` arranca en el shell.
- **Localización**: se reutilizan las claves de tooltip existentes; hacen falta textos nuevos en los 5 idiomas: la etiqueta de la pestaña de moods y el título del calendario (`en`, `es`, `de`, `fr`, `it`).
- **Tests**: los tests de widget de `MoodScreen`, `SettingsScreen` y la navegación asumen `push` y habrá que actualizarlos; se agregan tests del shell y del bar.
- **Accesibilidad**: cada pestaña necesita `Semantics` con etiqueta y estado seleccionado.
- **Dependencias**: ninguna nueva; el desenfoque se hace con `BackdropFilter`.
