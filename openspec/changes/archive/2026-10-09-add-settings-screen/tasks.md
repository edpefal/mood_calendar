## 1. Dependencias y strings

- [x] 1.1 Agregar `url_launcher` y `package_info_plus` a `pubspec.yaml`, correr `flutter pub get` y `pod install` en `ios/`; confirmar que el build de simulador compila con deployment target 15.0
- [x] 1.2 Añadir en `app_strings.dart` los getters nuevos: título de Settings, tooltip del engrane (`openSettingsTooltip`), encabezados de sección (recordatorios, ayuda y acerca de), fila de privacidad (título y `Semantics`), etiqueta de versión, mensaje de "no se pudo abrir el enlace" y mensaje de error al guardar ajustes
- [x] 1.3 Implementar los getters nuevos en `app_strings_en.dart`, `_es`, `_de`, `_fr` e `_it`
- [x] 1.4 Eliminar los strings que queden sin uso al final del change (`reminderSettingsTooltip`, `saveReminderSettings`, `reminderSavedAt`, `remindersTurnedOff`) en `app_strings.dart` y en los 5 idiomas; verificar con `grep` que no se usan

## 2. Cubit de Settings

- [x] 2.1 Crear `lib/features/settings/presentation/bloc/settings_state.dart` (`isLoading`, `remindersEnabled`, `reminderTime`, `appVersion`, `errorMessage` transitorio) y `settings_cubit.dart`
- [x] 2.2 `load()` lee `AppSettingsRepository.getSettings()` y la versión vía una función inyectable que envuelve `PackageInfo.fromPlatform()`; formato `versión (build)`
- [x] 2.3 `setRemindersEnabled(bool)` y `setReminderTime(TimeOfDay)`: actualizar estado de inmediato, persistir `AppSettings` y llamar `scheduleDailyReminder()` o `cancelDailyReminder()`, encadenando las operaciones en una cola secuencial
- [x] 2.4 Ante error al guardar o programar, revertir al último valor persistido y emitir el error para que la UI muestre un SnackBar
- [x] 2.5 Tests del cubit (`test/features/settings/presentation/bloc/`): carga inicial, activar, desactivar, cambiar hora, dos toques rápidos al switch sin entrelazar, error con reversión; usar fakes de repositorio y de servicio de notificaciones

## 3. Pantalla de Settings

- [x] 3.1 Crear `lib/features/settings/presentation/screens/settings_screen.dart`: AppBar con título en bold + color de marca, secciones con encabezados en bold sin color de marca, íconos de navegación con tinte púrpura
- [x] 3.2 Sección Recordatorios: `SwitchListTile` y fila de hora (deshabilitada si el recordatorio está desactivado) que abre `showTimePicker`; sin botón de guardar; cerrar el selector sin elegir no cambia nada
- [x] 3.3 Sección Ayuda y Acerca de: fila "Calificar Mood Calendar" (mismo `Semantics` y `RatingPromptService.openStoreListing()` que el sheet actual), fila "Política de privacidad" y fila de versión no interactiva
- [x] 3.4 Fila de privacidad: constante con la URL de TermsFeed, `launchUrl(..., mode: LaunchMode.externalApplication)` inyectable; si devuelve `false` o lanza, SnackBar con el mensaje localizado
- [x] 3.5 Etiquetas de `Semantics` en todos los controles interactivos (switch, hora, calificar, privacidad)
- [x] 3.6 Widget tests (`test/features/settings/presentation/screens/`): muestra valores guardados, el switch guarda y programa, la fila de hora se deshabilita con el switch apagado, calificar llama al servicio, privacidad abre la URL y muestra mensaje si falla, versión visible, render en alemán y fallback a inglés

## 4. Integración en la pantalla principal y calendario

- [x] 4.1 En `mood_screen.dart`, agregar un `IconButton` con `Icons.settings_outlined` (tinte `0xFF5F3DC4`, tooltip `openSettingsTooltip`) después del botón de calendario, que hace `Navigator.push` a `SettingsScreen` con su `BlocProvider<SettingsCubit>`
- [x] 4.2 Limitar el texto de la fecha a `maxLines: 2` con `TextOverflow.ellipsis` para que tres iconos no desborden el header
- [x] 4.3 En `calendar_screen.dart`, quitar la campana del `_CalendarHeader` (parámetro `onOpenReminderSettings`), `_openReminderSettingsSheet` y toda la clase `_ReminderSettingsSheet`, y limpiar imports sin uso
- [x] 4.4 Actualizar tests existentes de `MoodScreen`/calendario que dependan de la campana o del sheet; agregar un test de que el engrane abre Settings y de que el header del calendario ya no tiene la campana

## 5. Tooling y documentación

- [x] 5.1 Actualizar `tool/screenshots/capture.py`: `header_buttons()` ahora devuelve `[tienda, calendario, engrane]` (calendario = `hb[-2]`); el paso "reminders" abre Settings con el engrane (`hb[-1]`) en vez de la campana; `calendar_row_buttons()` pasa a ser `[anterior, siguiente]`
- [ ] 5.2 Revisar que `compose.py` enmarque bien la captura de Settings a pantalla completa (antes era un bottom sheet) y ajustar el encuadre o el texto del slide `05_reminders` si hace falta
- [x] 5.3 Actualizar `CLAUDE.md`: estructura de `lib/` (feature `settings`), notas del flujo de capturas (orden de botones del header y del calendario) y la lista de specs vigentes (`settings-screen`)
- [x] 5.4 Actualizar `backlog.md`: marcar que los recordatorios se configuran desde Settings y dejar anotado el pendiente de manejo del permiso de notificaciones denegado

## 6. Verificación

- [x] 6.1 `flutter analyze` y `flutter test` sin errores
- [x] 6.2 En simulador iPhone SE (pantalla angosta) y en iPad, con idioma alemán: el header de la pantalla principal no desborda, Settings se ve completa y las filas responden (workflow de `docs/ios-simulator-ui-testing.md`)
- [x] 6.3 En simulador: activar y desactivar el recordatorio y cambiar la hora; reabrir la app y confirmar que persiste y que la notificación se reprograma
- [x] 6.4 Confirmar que `https://www.termsfeed.com/live/c7cd2907-6d6c-46d2-9e1a-a715b74979c8` responde 200 y que el Privacy Policy URL de App Store Connect coincide
- [x] 6.5 `openspec validate add-settings-screen --strict`
