## Why

La UI ya sigue el idioma del dispositivo (en, es, de, fr, it), pero el recordatorio diario, el canal de notificaciones de Android y el `title` de `MaterialApp` siguen fijos en español (`AppStrings.forLocale(const Locale('es'))`). Un usuario en alemán, francés, italiano o inglés recibe el recordatorio en español. Ya que la ficha de App Store está localizada a esos idiomas, es la inconsistencia más visible que queda.

Además, `AppStrings.forLocale` hace fallback a **español** para idiomas no soportados, lo que contradice el spec `localization-architecture` (fallback a inglés). Hoy no se nota porque Flutter resuelve el locale con `supportedLocales` (primer elemento: inglés) antes de llegar ahí; al resolver el locale desde `PlatformDispatcher` sin `BuildContext`, ese atajo desaparece y el bug se manifestaría.

## What Changes

- `LocalNotificationService` resuelve el idioma con el locale del dispositivo (`PlatformDispatcher.instance.locale`) al programar el recordatorio y al crear el canal de Android, en vez de `Locale('es')`.
- Los textos de `AndroidNotificationDetails` (nombre y descripción del canal) pasan a usar `AppStrings` en lugar de literales en español.
- `MaterialApp` usa `onGenerateTitle` con `AppStrings.of(context).appTitle` en lugar de `title` fijo en español.
- `AppStrings.forLocale` hace fallback a inglés (`AppStringsEn`) para locales no soportados.
- El recordatorio se reprograma en cada arranque (`main.dart`), así que un cambio de idioma del sistema se refleja en la siguiente apertura de la app; se documenta como comportamiento aceptado.
- Tests para la selección de idioma de las notificaciones y del fallback de `forLocale`.
- Fuera de alcance: localizar los nombres de los moods (change aparte) y un selector manual de idioma.

## Capabilities

### New Capabilities

### Modified Capabilities
- `localization-architecture`: se añade el requisito de que notificaciones locales y título de la app usen el idioma del dispositivo. El fallback a inglés de `forLocale` ya está especificado; el código lo incumplía y se corrige.

## Impact

- Código: `lib/core/notifications/local_notification_service.dart`, `lib/main.dart`, `lib/core/localization/app_strings.dart`.
- Tests nuevos en `test/core/notifications/` y `test/core/localization/`.
- Sin cambios de dependencias, datos persistidos ni strings nuevos (los getters ya existen en los 5 idiomas).
- Riesgo: el título/cuerpo de un recordatorio ya programado se queda en el idioma anterior hasta el siguiente arranque de la app.
