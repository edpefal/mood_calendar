## Context

`LocalNotificationService` no tiene `BuildContext` (corre en background y se crea antes de `runApp`), por eso se usó `Locale('es')` fijo. `scheduleDailyReminder()` se llama en cada arranque (`main.dart`) y al guardar la configuración (`calendar_screen.dart`), así que el texto de la notificación se recalcula con frecuencia. `AppStrings.forLocale` cae hoy a `AppStringsEs` para locales no soportados, contra lo que dice el spec.

## Goals / Non-Goals

**Goals:**
- Notificaciones, canal de Android y título de app en el idioma del dispositivo, con fallback a inglés.
- Resolución del locale testeable sin plugins nativos.

**Non-Goals:**
- Nombres de moods localizados (change aparte).
- Selector manual de idioma.
- Reprogramar el recordatorio en vivo al cambiar el idioma del sistema (sin la app abierta).

## Decisions

- **Locale vía inyección con default `PlatformDispatcher.instance.locale`.** `LocalNotificationService` recibe un `Locale Function()` opcional (`localeResolver`), por defecto `() => PlatformDispatcher.instance.locale`. Alternativa descartada: persistir el locale en Hive; añade estado que puede desincronizarse del sistema y no hace falta porque el servicio se ejecuta con la app arrancada. La inyección permite tests sin plataforma.
- **Strings resueltos en el momento de programar**, no en el constructor, para que el locale sea el vigente en cada `scheduleDailyReminder()`.
- **Textos de `AndroidNotificationDetails` desde `AppStrings`.** Hoy son literales en español y, además, `const`; pasan a construirse en runtime con `notificationChannelName`/`notificationChannelDescription`.
- **Título con `MaterialApp.onGenerateTitle`** y `AppStrings.of(context).appTitle`; sigue el locale ya resuelto por Flutter.
- **`forLocale` con `default` → `AppStringsEn`.** Corrige la discrepancia con el spec. Ojo: cambia el resultado para cualquier llamador que dependiera del fallback a español; hoy no hay (se verificó con grep en `lib/`).

## Risks / Trade-offs

- [Recordatorio ya programado queda en el idioma anterior hasta el siguiente arranque] → aceptable: el usuario que cambia el idioma del sistema normalmente abre la app; queda documentado en el spec.
- [Android: un canal ya creado conserva su nombre/descripción] → Android no actualiza el nombre al re-crear con el mismo id salvo que cambie; se acepta, solo afecta a la pantalla de ajustes del sistema.
- [Cambiar el fallback de `forLocale`] → cubierto con test unitario del factory.
