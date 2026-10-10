## 1. Widget del bar

- [x] 1.1 Crear `FloatingTabBar` en `lib/core/widgets/` (cápsula con `BackdropFilter`, tinte blanco translúcido, borde fino, píldora animada en la pestaña activa, ancho máximo ~420 pt centrado, `Semantics` con `selected` y tooltip por pestaña)
- [x] 1.2 Tests de widget del bar: orden de pestañas, `onTap` con el índice correcto, píldora solo en la activa, `Semantics` seleccionada, ancho máximo en pantalla ancha

## 2. Textos localizados

- [x] 2.1 Añadir el getter de la etiqueta de la pestaña de moods en `app_strings.dart` e implementarlo en `app_strings_en/es/de/fr/it.dart`
- [x] 2.2 Retirar `backToTodayTooltip` (y cualquier clave de "volver a la fecha") de `AppStrings` y sus cinco subclases
- [x] 2.3 Ajustar el test de localización para cubrir la clave nueva y que no sobren claves

## 3. Shell de navegación

- [x] 3.1 Crear `MainShell` en `lib/core/navigation/` con `IndexedStack` de cuatro pestañas, `_tabIndex`, la fecha del selector (hoy al iniciar) y los datos del calendario (`recentlySavedDate`, `viewedDate`), con el bar flotante encima
- [x] 3.2 Exponer a las pantallas la altura que ocupa el bar (insets inferiores) para reservar espacio
- [x] 3.3 Usar `MainShell` como `home` en `lib/main.dart` y en `tool/screenshots/main.dart`

## 4. Selector de moods

- [x] 4.1 Quitar de `MoodScreen` los botones de tienda, calendario y ajustes y sus imports de navegación
- [x] 4.2 Reemplazar `popOrShowCalendar` tras guardar por un callback `onSaved(date)` que el shell usa para refrescar el calendario y cambiar a la pestaña Calendario
- [x] 4.3 Recibir la fecha desde el shell y recrear la pantalla con `ValueKey(date)` solo si la fecha cambia
- [x] 4.4 Reservar espacio inferior para que el bar no tape el carrusel ni el botón de guardar
- [x] 4.5 Actualizar los tests de `MoodScreen` (sin botones del header, guardado dispara `onSaved`, guardado fallido no cambia de pestaña)

## 5. Calendario

- [x] 5.1 Reemplazar `pushMoodScreen` por un callback `onDaySelected(date)` que lleva al shell a la pestaña del selector con esa fecha
- [x] 5.2 Mover la animación de resaltado del día guardado y el pedido de calificación a un `didUpdateWidget` (el calendario ya no se crea al guardar) y verificar que el pedido ocurre una sola vez
- [x] 5.3 Eliminar `_goBack`, la flecha de regresar y la etiqueta "Volver a hoy"; añadir un AppBar con el título "Calendario" (nueva clave `calendarTitle` en los 5 idiomas), en bold y color de marca
- [x] 5.4 Reservar espacio inferior en el scroll del calendario
- [x] 5.5 Actualizar los tests del calendario y del pedido de calificación

## 6. Tienda y Ajustes

- [x] 6.1 Quitar la flecha de regresar del AppBar de `MoodStoreScreen` y `SettingsScreen` (conservan su título) y reservar espacio inferior en sus listas
- [x] 6.2 Quitar `SettingsScreen.route()` y los puntos de entrada por `push`; la tienda recibe `PurchasesCubit` del contexto ya provisto
- [x] 6.3 Actualizar los tests de `SettingsScreen` y de la Tienda

## 7. Modales y recordatorio

- [x] 7.1 Comprobar que el editor de nota y las hojas de compra de Mood y de Pack cubren el bar; si no, añadir un notifier de visibilidad que los sheets activan
- [x] 7.2 Reescribir `_handleReminderTap` en `lib/main.dart`: `popUntil` a la raíz, luego pedir al shell la pestaña del selector con la fecha del recordatorio, conservando `_isHandlingReminderTap` y el reintento si el shell aún no existe
- [x] 7.3 Eliminar `pushMoodScreen`, `popOrShowCalendar` y `openMoodFromReminder` de `AppNavigator` (y el archivo si queda vacío)
- [x] 7.4 Test del shell: arranque en hoy, la fecha se conserva al cambiar de pestaña, tocar un día lleva al selector, guardar lleva al calendario, el recordatorio activa el selector

## 8. Verificación

- [x] 8.1 `flutter analyze` y `flutter test` en verde
- [x] 8.2 Probar en simulador iPhone 16e (390 pt) y iPad: bar visible en las cuatro pestañas, nada tapado por el bar, bar cubierto en editor de nota y en hojas de compra (el rendimiento del desenfoque sobre el carrusel queda por medir en un dispositivo físico)
- [x] 8.3 Probar el toque del recordatorio con la app cerrada y con la app abierta en otra pestaña (cubierto con widget tests de `handleReminderTap`: otra pestaña, modal abierto y toque antes de montar el shell; el toque real en simulador no se pudo reproducir)
- [x] 8.4 Regenerar los screenshots de App Store con `tool/screenshots/` (cambia el header y aparece el bar); `capture.py` y `tool/screenshots/main.dart` quedaron adaptados al bar. Las capturas de los 5 idiomas en iPhone y iPad y los slides se generan aparte, fuera de este change
- [x] 8.5 Sincronizar `openspec/specs/` y actualizar `CLAUDE.md` (sección de arquitectura y de comportamientos con spec)
