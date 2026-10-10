## Context

La navegación es un stack: `MoodScreen` es `home` y abre la Tienda y Ajustes con `Navigator.push`; el calendario se abre con `AppNavigator.popOrShowCalendar` (pop o `pushReplacement`) y devuelve a `MoodScreen(selectedDate)` con `pushReplacement`. El guardado llama a `popOrShowCalendar(recentlySavedDate, viewedDate)`, el toque de un día llama a `pushMoodScreen` y espera un resultado, y el recordatorio usa `openMoodFromReminder` (`pushAndRemoveUntil`) desde un `navigatorKey` global en `main.dart`. Los tres cubits de mood, calendario y compras se proveen sobre `MaterialApp`, así que cualquier pestaña los alcanza. Motivación y alcance: ver `proposal.md`; requisitos: ver `specs/`.

## Goals / Non-Goals

**Goals:**
- Un único shell que posea la pestaña activa y la fecha del selector, de modo que guardar, tocar un día y el recordatorio sean cambios de estado y no de rutas.
- Un bar reutilizable y sin dependencias nuevas.

**Non-Goals:**
- No se introduce `go_router`, `Navigator 2.0` ni un cubit de navegación global.
- No se rediseñan los contenidos de Tienda, Ajustes ni Calendario más allá de quitar la flecha y reservar espacio inferior.
- No cambia el modelo de datos, las compras ni el esquema de localización.

## Decisions

### 1. `MainShell` con `IndexedStack` y estado local
Un `StatefulWidget` (`lib/core/navigation/main_shell.dart`) es el nuevo `home`. Guarda `_tabIndex`, `_selectedDate` (el selector) y `_recentlySavedDate`/`_viewedDate` (el calendario) y pinta un `IndexedStack` con las cuatro pantallas más el bar en un `Stack`. `IndexedStack` conserva el estado de cada pestaña, que es lo que pide el spec (la fecha del selector no se pierde). Las pantallas reciben callbacks en lugar de llamar a `AppNavigator`: `onDaySelected(date)` en el calendario y `onSaved(date)` en el selector.

*Alternativas:* un `NavigationCubit` (más piezas para dos valores que solo el shell lee); `Navigator` anidado por pestaña (solo tiene sentido si cada pestaña tuviera sub-rutas, que no tienen).

### 2. El recordatorio habla con el shell por un `GlobalKey` o `ValueNotifier`
`_handleReminderTap` ya depende de `navigatorKey`. Se mantiene: primero `popUntil((r) => r.isFirst)` sobre el navigator raíz (cierra hojas de compra y editor de nota, que son modales), y después se pide al shell, vía un `GlobalKey<MainShellState>` o un `ValueNotifier<ReminderIntent>`, activar la pestaña del selector con la fecha. Se conserva la protección `_isHandlingReminderTap` y el reintento si el shell aún no está montado (arranque en frío).

*Alternativa:* un stream en `LocalNotificationService`. Descartada: añade una API pública para un solo consumidor.

### 3. Los modales cubren el bar; no se oculta por estado
Los modales (editor de nota y hojas de compra) se abren con `showModalBottomSheet` sobre el navigator raíz y, por tanto, **sobre** el shell: un bottom sheet modal dibuja su barrera encima del `Scaffold`, así que el bar queda cubierto sin código extra, y reaparece al cerrarse. Verificado en widget test y en iPhone 16e: el bar queda atenuado bajo la barrera y sin recibir toques (una hoja de compra más angosta que la pantalla deja asomar sus bordes atenuados). Si el bar quedara por encima de la barrera (por ejemplo, si se pone en un `Overlay` propio), se añade un `ValueNotifier<bool>` que los sheets activan.

*Alternativa:* un observer de rutas que oculte el bar. Más código para el mismo efecto.

### 4. Widget `FloatingTabBar` en `lib/core/widgets/`
`ClipRRect` con radio completo, `BackdropFilter(ImageFilter.blur(sigma ≈ 20))`, `ColoredBox` blanco al ~70 % de opacidad y un borde fino. Cada pestaña es un `Semantics(button, selected)` con tooltip y un `AnimatedContainer` para la píldora (púrpura de marca al ~12 %). Ancho: `ConstrainedBox(maxWidth: 420)` centrado. Posición: `Align(bottomCenter)` con `SafeArea` y un margen inferior de 12 a 16 pt. Recibe `currentIndex`, `onTap` y una lista de `{icon, label}`; no conoce nada de la app.

### 5. Espacio inferior para el bar
El shell expone la altura del bar (alto + margen + inset inferior) como un valor, vía `MediaQuery` modificado con `padding.bottom` o un `InheritedWidget` sencillo. Las pantallas lo usan en su `padding` inferior: la lista de Tienda, la lista de Ajustes, el scroll del calendario y el botón de guardar del selector. Se prefiere esto a un `Scaffold.bottomNavigationBar` porque este reservaría un bloque opaco y rompería el efecto translúcido.

### 6. Fecha por pestaña y recarga del calendario
`MoodScreen` deja de recibir `selectedDate` en el constructor para leerlo del shell, y se recrea con `key: ValueKey(date)` solo cuando la fecha cambia, de modo que reinicie su carrusel y la nota al cambiar de día pero conserve el estado al cambiar de pestaña. Tras guardar, el shell llama a `calendarCubit.refreshForDate`, activa el calendario y le pasa `recentlySavedDate` para la animación de resaltado y la solicitud de calificación (se mueve de `CalendarScreen` a un `didUpdateWidget`, ya que ahora el calendario no se crea tras el guardado).

### 7. Limpieza de `AppNavigator`
Se eliminan `pushMoodScreen`, `popOrShowCalendar` y `openMoodFromReminder`, junto con `_goBack` y la lógica de etiqueta "Volver a hoy" de `CalendarScreen`. Las claves de localización de esa etiqueta se retiran de los cinco `app_strings_*.dart`. Se agrega una clave para la pestaña de moods; las de tienda, calendario y ajustes reutilizan los `open*Tooltip` existentes.

## Risks / Trade-offs

- [`MoodScreen` es grande y mezcla navegación con UI] → Quitar la navegación primero (callbacks) y recién después tocar el layout; cubrirlo con los tests de `MoodScreen` ya existentes, adaptados.
- [El bar flotante tapa controles] → Padding inferior centralizado (decisión 5) y verificación en iPhone 16e (390 pt) e iPad.
- [`BackdropFilter` es costoso sobre contenido animado, como el carrusel y el gradiente] → Un solo filtro de área pequeña; medir en dispositivo físico antes de subir y, si pesa, bajar el sigma o usar un fondo opaco al 85 %.
- [`IndexedStack` mantiene las cuatro pestañas montadas y sus animaciones corriendo] → Las animaciones del calendario ya se disparan por eventos, no en bucle; se revisa que no haya `AnimationController.repeat`.
- [Regresión del pedido de calificación, porque ahora el calendario no se crea al guardar] → Test que cubra "guardar con hito ⇒ cambia a calendario ⇒ se solicita una sola vez".
- [Arranque en frío desde la notificación llega antes de que el shell exista] → Se conserva el reintento por `addPostFrameCallback` de `_handleReminderTap`.
- [Se pierde el botón explícito de volver a la fecha vista] → Es intencional: la pestaña del selector la conserva (ver spec `calendar-navigation`).

## Migration Plan

Cambio puramente de cliente, sin migración de datos. Se implementa en una rama y un PR, y no se lanza detrás de un flag. Revertir es revertir el PR. Antes de publicar, ejecutar el flujo manual de simulador de `docs/ios-simulator-ui-testing.md` en iPhone 16e y en iPad, y actualizar los screenshots de App Store con `tool/screenshots/`, porque cambia el header del selector y aparece el bar. El entrypoint de screenshots también debe usar el shell.
