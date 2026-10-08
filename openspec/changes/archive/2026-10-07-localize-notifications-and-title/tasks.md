## 1. Fallback de AppStrings

- [x] 1.1 Cambiar el `default` de `AppStrings.forLocale` a `AppStringsEn`
- [x] 1.2 Test unitario en `test/core/localization/` para los 5 idiomas y un locale no soportado (pt → inglés)

## 2. Notificaciones

- [x] 2.1 Añadir `localeResolver` opcional a `LocalNotificationService` (default `PlatformDispatcher.instance.locale`)
- [x] 2.2 Usar el locale resuelto para título y cuerpo en `scheduleDailyReminder()`
- [x] 2.3 Construir `AndroidNotificationDetails` con `notificationChannelName`/`notificationChannelDescription` en vez de literales en español
- [x] 2.4 Usar el locale resuelto en `_ensureAndroidChannel()`
- [x] 2.5 Tests en `test/core/notifications/` que verifiquen el idioma elegido para de/fr/it/en/es y el fallback a inglés (extraer la selección de strings a un método testeable si el plugin impide verificarlo directo)

## 3. Título de la app

- [x] 3.1 Reemplazar `title` por `onGenerateTitle` en `MaterialApp` (`lib/main.dart`)
- [x] 3.2 Widget test que verifique el título en un locale no español

## 4. Verificación

- [x] 4.1 `flutter analyze` y `flutter test` en verde
- [x] 4.2 Probar en simulador con idioma alemán: programar recordatorio y revisar el texto de la notificación
- [x] 4.3 Actualizar `CLAUDE.md` (quitar la nota de español fijo) y `backlog.md` (mover el ítem a completado)
