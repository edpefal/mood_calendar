# Mood Calendar

Mood Calendar es una app Flutter para registrar el estado de animo diario, revisar el calendario mensual y consultar un resumen del mes. El proyecto usa una arquitectura por capas, persistencia local con Hive y estado con Cubit.

## Estado actual

- Registro diario de mood por fecha.
- Calendario mensual con navegacion entre meses.
- Resumen mensual con grafica, promedio y mejor racha.
- Recordatorios diarios configurables.
- Exportacion local del historial en JSON.
- Localizacion base para `es` y `en`.
- Logging y telemetria desacoplados del proveedor.
- CI con `flutter analyze` y `flutter test`.

## Arquitectura

La app esta organizada en `core/` y `features/`.

```text
lib/
  core/
    localization/   # Textos y estructura base de localizacion
    logging/        # Abstraccion de logger + implementacion con package:logger
    navigation/     # Navegacion principal entre pantallas
    notifications/  # Notificaciones locales y manejo de payloads
    settings/       # Preferencias tipadas de la aplicacion
    telemetry/      # Eventos y errores relevantes desacoplados del proveedor
  features/
    mood/
      data/         # Datasources, modelos Hive, repositorios y servicios
      domain/       # Entidades, contratos, servicios y casos de uso
      presentation/ # Pantallas, widgets y cubits
  main.dart
```

### Flujo de datos

1. La UI interactua con `MoodCubit` y `CalendarCubit`.
2. Los cubits llaman casos de uso en `features/mood/domain/usecases`.
3. Los casos de uso delegan en repositorios o servicios del dominio.
4. Las implementaciones concretas viven en `features/mood/data`.
5. Hive persiste moods y settings localmente.

Reglas del proyecto:

- La capa `presentation` no accede directo a `Hive`.
- La persistencia de settings pasa por `AppSettingsRepository`.
- Logging y telemetria van por abstracciones, no por paquetes usados directo en la UI.

## Componentes principales

### Moods

- `MoodRepositoryImpl` guarda los registros diarios normalizados por clave `YYYY-MM-DD`.
- Los datos legacy se migran automaticamente al leer o guardar.
- `MoodCubit` maneja carga, guardado, errores y telemetria de eventos clave.

### Calendario y resumen

- `CalendarCubit` calcula el resumen mensual con `GetMonthlyMoodSummaryUseCase`.
- `MonthlyMoodSummaryCard` muestra:
  - grafica del mes
  - animo promedio del mes
  - mejor racha

### Settings y recordatorios

- `AppSettingsLocalDataSource` centraliza las claves de configuracion.
- `LocalNotificationService` inicializa permisos, zona horaria y programacion diaria.
- La hora del recordatorio puede activarse, desactivarse o ajustarse desde la UI.

### Exportacion

- `JsonMoodHistoryExporter` genera un archivo JSON con:
  - `date`
  - `mood`
  - `note`
  - `intensity`
- Los archivos se guardan en una carpeta `exports` dentro del directorio de la app.

### Localizacion

- `AppStrings` expone la estructura base de textos.
- La app arranca actualmente en espanol.
- La base de `supportedLocales` ya soporta `es` y `en`.

## Dependencias principales

- `flutter_bloc`
- `freezed` y `freezed_annotation`
- `json_serializable`
- `hive` y `hive_flutter`
- `logger`
- `flutter_local_notifications`
- `timezone`
- `flutter_native_timezone`
- `flutter_svg`
- `fl_chart`
- `path_provider`

## Requisitos

- Flutter compatible con el SDK declarado en `pubspec.yaml`
- Dart incluido con tu instalacion de Flutter
- Xcode o Android Studio segun la plataforma objetivo

## Como correr el proyecto

1. Instala dependencias:

```sh
flutter pub get
```

2. Genera codigo si cambias modelos `freezed`, `json_serializable` o adapters:

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Corre la app:

```sh
flutter run
```

## Comandos de desarrollo

Analisis estatico:

```sh
flutter analyze
```

Pruebas:

```sh
flutter test
```

Formato:

```sh
dart format lib test
```

Modo watch para generacion:

```sh
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Convenciones del proyecto

- Los archivos generados `*.g.dart` y `*.freezed.dart` se versionan.
- Si agregas una nueva configuracion persistente, pasa por `core/settings/`.
- Si agregas eventos o errores trazables, usa `core/telemetry/`.
- Si agregas logs, usa la abstraccion de `core/logging/`.
- Si una pantalla necesita datos, consume cubits o casos de uso, no almacenamiento directo.
- Mantener `flutter analyze` limpio es parte del criterio de merge.

## Notificaciones

`LocalNotificationService`:

- pide permisos segun plataforma
- resuelve la zona horaria local
- programa un recordatorio diario
- detecta si la app fue abierta desde la notificacion
- navega a `MoodScreen` con la fecha actual cuando aplica

La configuracion actual se guarda en settings y no en constantes sueltas.

## Telemetria

La telemetria actual usa una implementacion basada en logger, pero quedo abstraida para cambiar de proveedor despues.

Eventos ya registrados:

- guardado de mood
- apertura desde recordatorio
- programacion y cancelacion de recordatorios
- exportacion del historial

Errores relevantes:

- fallos de guardado
- fallos de carga
- problemas de notificaciones o zona horaria
- fallos de exportacion

Configuracion por entorno:

- `ENABLE_APP_TELEMETRY`
- `ENABLE_ERROR_TELEMETRY`

## CI

El workflow de `.github/workflows/ci.yml` corre en `push`, `pull_request` y `workflow_dispatch`.

Pasos:

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Pruebas existentes

Hay pruebas para:

- repositorio de moods
- datasource de settings
- resumen mensual
- telemetria del `MoodCubit`
- exportacion JSON del historial
- widget principal de `MoodScreen`

## Archivos clave

- `lib/main.dart`
- `lib/features/mood/data/repositories/mood_repository_impl.dart`
- `lib/features/mood/presentation/bloc/mood_cubit.dart`
- `lib/features/mood/presentation/bloc/calendar_cubit.dart`
- `lib/core/notifications/local_notification_service.dart`
- `lib/core/settings/data/datasources/app_settings_local_datasource.dart`
- `lib/core/localization/app_strings.dart`

## Notas pendientes

- El Project de GitHub puede quedar temporalmente desalineado del estado de los issues cuando `gh project` falla contra la API.
- La localizacion ya tiene base para ingles, pero la app arranca en espanol.
