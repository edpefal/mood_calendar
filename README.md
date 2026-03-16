# Mood Calendar

Mood Calendar es una aplicación Flutter para registrar y visualizar el estado de ánimo diario del usuario, siguiendo principios de Clean Architecture, Bloc y Freezed.

## Características

- Registro diario del estado de ánimo con nota opcional.
- Calendario mensual con los días que tienen mood registrado y navegación entre meses.
- **Resumen mensual (gráfica):** debajo del calendario, un card muestra:
  - **Gráfica de línea** del ánimo a lo largo del mes (eje X = día, eje Y = nivel de ánimo).
  - **Eje Y** con los mismos íconos SVG que usa la app (Happy, Calm, Neutral, Sad, Angry), con el más feliz arriba y el más bajo abajo.
  - **Monthly average:** ícono del ánimo que representa el promedio del mes (sin número).
  - **Best streak:** cantidad de días seguidos registrando ánimo.
- Almacenamiento local usando Hive.
- Arquitectura limpia: separación en data, domain y presentation.
- Gestión de estado con Bloc/Cubit y Freezed.
- Recordatorios diarios a las 6:00 pm mediante notificaciones locales (Android/iOS) auto-reprogramadas.
- Monetización opcional con anuncios intersticiales controlados por AdMob que se disparan al guardar un mood.

## Estructura del proyecto

```
lib/
  core/
    notifications/     # Servicio para recordatorios locales
  features/
    ads/               # Servicio de anuncios intersticiales (AdMob)
    mood/
      data/            # Modelos Hive, repositorios concretos
      domain/          # Entidades, repositorios abstractos, casos de uso
      presentation/    # UI, widgets y cubits/blocs
  main.dart
```

`main.dart` inicializa Hive, registra el `MoodModel`, crea los cubits (`MoodCubit`, `CalendarCubit`), arma el servicio de notificaciones (`LocalNotificationService`) y precarga el `AdService` antes de renderizar la UI.

## Resumen mensual (gráfica)

El card **"[Month] Summary"** (p. ej. "January Summary") aparece debajo del calendario y solo cuando hay al menos un registro en ese mes.

- **Gráfica:** línea que une los puntos de ánimo por día. Cada punto usa el nivel de intensidad guardado (1 = Happy, 5 = Angry). En el eje vertical se muestran los íconos de la app (Happy arriba, Angry abajo) en lugar de emojis genéricos.
- **Monthly average:** se muestra solo el ícono del ánimo que corresponde al promedio del mes (según rangos de score).
- **Best streak:** texto tipo "X day(s) in a row recording your mood".
- **Datos legacy:** los registros guardados antes de guardar intensidad real tenían `intensity: 3`. Se deriva la intensidad desde el campo `mood` (ruta del ícono) para que la gráfica y el promedio se vean correctos.

## Publicidad (AdMob)

- `lib/features/ads/ad_service.dart` centraliza el uso de `google_mobile_ads` mediante un singleton que carga y muestra un interstitial reutilizable.
- En modo `kDebugMode` se cargan los IDs de prueba de Google; en *release* se usa `ca-app-pub-6292269650358396/4481436641`. Cambia ese valor y vuelve a compilar si publicarás con tus propios IDs.
- El `AdService` se inicializa en `main.dart`, precarga un anuncio y vuelve a intentarlo hasta 3 veces. Desde la UI (`MoodScreen` y `CalendarScreen`) solo se pregunta a `shouldShowAd()`: en producción la probabilidad es 50 % cada vez que el usuario guarda un mood, mientras que en debug se muestra siempre para poder testear.
- Recuerda emparejar el `adUnitId` con los App ID declarados en Android (`android/app/src/main/AndroidManifest.xml`, meta-data `com.google.android.gms.ads.APPLICATION_ID`) y en iOS (`ios/Runner/Info.plist`, clave `GADApplicationIdentifier` más la lista de `SKAdNetworkItems`).
- Si necesitas desactivar temporalmente los anuncios, retorna `false` desde `shouldShowAd()` o evita llamar `showInterstitialAd()`.

## Dependencias principales

- [Flutter](https://flutter.dev/)
- [hive](https://pub.dev/packages/hive) + [hive_flutter](https://pub.dev/packages/hive_flutter) para persistencia local.
- [path_provider](https://pub.dev/packages/path_provider) para resolver la ruta de almacenamiento.
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) + [equatable](https://pub.dev/packages/equatable) en la presentación.
- [freezed](https://pub.dev/packages/freezed), [freezed_annotation](https://pub.dev/packages/freezed_annotation), [json_serializable](https://pub.dev/packages/json_serializable), [build_runner](https://pub.dev/packages/build_runner) y [hive_generator](https://pub.dev/packages/hive_generator) para generación de código.
- [fl_chart](https://pub.dev/packages/fl_chart) para la gráfica mensual.
- [flutter_svg](https://pub.dev/packages/flutter_svg) para renderizar los íconos SVG de ánimo.
- [google_mobile_ads](https://pub.dev/packages/google_mobile_ads) para los anuncios intersticiales.
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), [timezone](https://pub.dev/packages/timezone) y [flutter_native_timezone](https://pub.dev/packages/flutter_native_timezone) para los recordatorios diarios.

## Instalación y uso

1. **Clona el repositorio:**
   ```sh
   git clone <url-del-repo>
   cd mood_calendar
   ```

2. **Instala las dependencias:**
   ```sh
   flutter pub get
   ```

3. **Genera el código necesario:**
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Corre la app:**
   ```sh
   flutter run
   ```

## Recordatorios diarios

La aplicación programa una notificación local diaria a las 6:00 pm para recordar al usuario registrar su estado de ánimo.

- `lib/core/notifications/local_notification_service.dart` maneja toda la configuración de `flutter_local_notifications`, permisos por plataforma y sincronización de zona horaria usando `timezone` + `flutter_native_timezone` (con fallback a `UTC`).
- Cada arranque hace `scheduleDailyReminder()` después de cancelar cualquier recordatorio previo para evitar duplicados.
- El `payload` `daily_mood_reminder` permite detectar si la app se abrió desde la notificación y navegar directamente a `MoodScreen` con la fecha del día.
- Ajusta la hora cambiando la constante `_reminderHour` dentro del servicio.

### Verificación manual

1. Instala la app en un dispositivo físico o emulador.
2. Concede permisos de notificación cuando la app los solicite:
   - **Android 13+**: acepta el permiso `POST_NOTIFICATIONS`.
   - **iOS**: acepta la alerta nativa de notificaciones.
3. Cierra la app y adelanta el reloj del dispositivo a una hora posterior a
   las 6:00 pm.
4. Verifica que llegue la notificación «How are you feeling today?».
5. Toca la notificación y confirma que la app se abre directamente en
   `MoodScreen` con la fecha actual seleccionada.
6. Repite en ambos sistemas operativos (Android/iOS) si es posible.

> Nota: Cada vez que se inicia la app se reprograma el recordatorio para el
> siguiente día a las 6:00 pm.

## Notas para desarrollo

- Si modificas modelos anotados con `@freezed` o `@JsonSerializable`, vuelve a correr el comando de build_runner.
- Los archivos generados (`*.g.dart`, `*.freezed.dart`) **deben estar versionados** en Git.
- Para desarrollar más rápido usa `flutter pub run build_runner watch --delete-conflicting-outputs`.
- Puedes regenerar los íconos del launcher con `flutter pub run flutter_launcher_icons` (usa `assets/icon/app_icon.png`).
- Sigue la arquitectura y convenciones del proyecto para nuevas features.

## Licencia

MIT
