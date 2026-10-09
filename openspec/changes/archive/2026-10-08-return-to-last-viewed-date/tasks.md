## 1. Navegación

- [x] 1.1 Añadir a `CalendarScreen` un parámetro opcional con la fecha del selector de origen y un estado con la última fecha vista (`origen ?? recentlySavedDate ?? hoy`)
- [x] 1.2 Actualizar la última fecha vista al tocar un día, antes de abrir su selector
- [x] 1.3 `_goBack` abre `MoodScreen(selectedDate: última fecha vista)` cuando no se puede hacer `pop`
- [x] 1.4 `AppNavigator.popOrShowCalendar` y el botón de calendario de `MoodScreen` pasan la fecha vista del selector

## 2. Accesibilidad y localización

- [x] 2.1 Añadir `backToMoodPickerTooltip` a `AppStrings` y a los cinco idiomas (en, es, de, fr, it)
- [x] 2.2 Usar `backToTodayTooltip` si la fecha destino es hoy y `backToMoodPickerTooltip` en otro caso

## 3. Tests

- [x] 3.1 Editar otra fecha, guardar y volver: el selector abre en esa fecha y en el mood de su entrada
- [x] 3.2 Sin tocar ningún día, volver abre hoy
- [x] 3.3 Varios días editados: vuelve al último
- [x] 3.4 Calendario abierto desde un selector de otra fecha: vuelve a esa fecha
- [x] 3.5 Etiqueta accesible: "Volver a hoy" si es hoy, la nueva si no

## 4. Cierre

- [x] 4.1 `flutter analyze` y `flutter test` en verde
- [x] 4.2 Verificación manual en simulador limpio: editar otra fecha → guardar → volver
