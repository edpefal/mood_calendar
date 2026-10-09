## Context

Hoy la configuración del recordatorio y la fila de calificar viven en `_ReminderSettingsSheet`, una clase privada de `calendar_screen.dart` abierta desde una campana del header del calendario. El sheet lee `AppSettingsRepository`, `LocalNotificationService` y `RatingPromptService` vía `context.read` (proveídos por `MultiRepositoryProvider` en `main.dart`), y guarda con un botón "Guardar". Ver `proposal.md` para la motivación.

`AppSettings` contiene solo `dailyReminderEnabled`, `dailyReminderHour` y `dailyReminderMinute`. `LocalNotificationService.scheduleDailyReminder()` ya cancela y reprograma leyendo los ajustes guardados, y `cancelDailyReminder()` cancela. `RatingPromptService.openStoreListing()` ya registra la telemetría de la entrada manual.

La arquitectura declara dos features (`mood`, `purchases`) más `core/`. `RatingPromptService` vive en `features/mood/data/services/`, por lo que una pantalla en `core/` dependería de una feature.

## Goals / Non-Goals

**Goals:**
- Sacar la lógica del sheet a una pantalla propia y testeable, sin cambiar la persistencia ni la programación de notificaciones.
- Dejar la pantalla organizada en secciones para sumar opciones sin rediseñarla.

**Non-Goals:**
- Exportar historial (change `export-mood-history`).
- Cambiar el modelo `AppSettings`, su datasource o `LocalNotificationService`.
- Resolver el caso de permiso de notificaciones denegado en el sistema (se mantiene el comportamiento actual).
- Selector de idioma, tema u otras preferencias nuevas.

## Decisions

**1. Ubicación: `lib/features/settings/presentation/` (screen + cubit).**
La pantalla necesita `RatingPromptService` (de `mood`) y `AppSettingsRepository` (de `core`). Ponerla en `core/` invertiría la dependencia `core → feature`. Una feature `settings` solo con `presentation/` reutiliza los servicios existentes por `context.read`, sin capas `data`/`domain` vacías, porque la persistencia ya vive en `core/settings/`. *Alternativa descartada*: dejarla en `features/mood/presentation/screens/`; mezcla una preocupación transversal con la del calendario de ánimos.

**2. `SettingsCubit` con estado simple, no `StatefulWidget`.**
El proyecto usa Cubit y el autoguardado añade lógica (guardar, reprogramar, revertir ante error) que se prueba mejor sin widgets. El estado es una clase inmutable pequeña (`isLoading`, `remindersEnabled`, `reminderTime`, `appVersion`) sin freezed, para no sumar generación de código a un estado de cuatro campos. El cubit se crea en la propia ruta con `BlocProvider`, no globalmente en `main.dart`, porque solo vive mientras la pantalla está abierta.

**3. Autoguardado secuencial con UI optimista.**
Cada cambio actualiza el estado de inmediato, persiste `AppSettings` y luego llama a `scheduleDailyReminder()` o `cancelDailyReminder()`. Las operaciones se encadenan (una cola de `Future`) para que dos toques rápidos al switch no entrelacen escrituras ni reprogramaciones. Si guardar o programar falla, el cubit revierte al último valor persistido y la pantalla muestra un SnackBar de error. Se elimina el SnackBar de éxito "Recordatorio guardado a las X": con autoguardado, el control ya refleja el estado. *Alternativa descartada*: mantener el botón Guardar; se siente fuera de lugar en una pantalla de ajustes y permite salir sin guardar.

**4. Enlace de privacidad con `url_launcher`.**
`launchUrl(uri, mode: LaunchMode.externalApplication)` y se usa su valor de retorno (sin `canLaunchUrl`, que en iOS exigiría `LSApplicationQueriesSchemes`). La URL es una constante (`https://www.termsfeed.com/live/c7cd2907-6d6c-46d2-9e1a-a715b74979c8`); no se localiza porque la política publicada está en un solo idioma. Se inyecta una función de apertura en la pantalla para poder probar el caso de falla sin plugin.

**5. Versión con `package_info_plus`.**
`PackageInfo.fromPlatform()` se lee una vez al abrir la pantalla y se muestra como `version (buildNumber)`. Se inyecta como función en el cubit para tests. *Alternativa descartada*: constante manual en código; se desincroniza de `pubspec.yaml`.

**6. El engrane abre una ruta `MaterialPageRoute` como la tienda.**
Mismo patrón que `MoodStoreScreen` en `mood_screen.dart`. Los servicios se resuelven por `context.read` dentro de la ruta, ya que `RepositoryProvider` está por encima del `MaterialApp`. No hace falta `BlocProvider.value`.

**7. Header de `MoodScreen`: la fecha ya está en `Expanded`; se permite `maxLines: 2` con elipsis.**
Con tres `IconButton` (48 px cada uno) quedan ~140 px menos para la fecha. Para que no desborde en pantallas angostas ni en alemán, el texto se limita a 2 líneas con `TextOverflow.ellipsis`. *Alternativa descartada*: reducir `iconSize` o `padding`; estrecha el área táctil por debajo de lo recomendado.

**8. Strings.**
Nuevos getters abstractos en `AppStrings` implementados en los 5 idiomas. Se reutilizan `reminderSheetTitle`/`reminderSheetDescription`, `reminderEnabledTitle`/`reminderEnabledSubtitle`, `reminderTimeTitle`, `rateAppTitle` y `rateAppSemanticLabel`. Se eliminan `reminderSettingsTooltip`, `saveReminderSettings`, `reminderSavedAt` y `remindersTurnedOff` si ya no tienen uso (`remindersTurnedOff` y `reminderSavedAt` pueden aprovecharse en el SnackBar de error solo si encajan; si no, se borran para no dejar strings muertos).

## Risks / Trade-offs

- **Header apretado con tres iconos** → `maxLines: 2` en la fecha y verificar en simulador iPhone SE y con idioma alemán (workflow de `docs/ios-simulator-ui-testing.md`).
- **Permiso de notificaciones denegado**: activar el switch guarda el ajuste pero iOS no entregará la notificación → comportamiento ya existente; queda como mejora futura (mostrar aviso con acceso a Ajustes del sistema).
- **Autoguardado reprograma en cada cambio** → `scheduleDailyReminder()` es barato y ya cancela antes de programar; la cola secuencial evita carreras.
- **`edpefal.github.io/privacy` da 404 y se usa la URL de TermsFeed** → si la política se muda a un dominio propio, hay que actualizar la constante y el campo Privacy Policy URL de App Store Connect; ambos deben coincidir.
- **Dos dependencias nuevas con código nativo** (`url_launcher`, `package_info_plus`) → requieren `pod install` y un build de iOS completo; hay que confirmar que compilan con deployment target 15.0.
- **`capture.py` rompe si no se actualiza**: identifica el calendario como el botón más a la derecha → se ajusta la lógica para el nuevo orden (calendario = penúltimo, tienda = antepenúltimo).

## Migration Plan

Sin migración de datos: `AppSettings` y su almacenamiento en Hive no cambian, y un recordatorio ya programado sigue vigente. Rollback: revertir el PR; no deja estado persistente nuevo.

Antes de enviar el build a App Store Connect hay que confirmar que la URL de privacidad responde 200 y coincide con la declarada en ASC.
