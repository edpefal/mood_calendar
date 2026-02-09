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

## Estructura del proyecto

```
lib/
  core/                # Utilidades y recursos compartidos
  features/
    mood/
      data/            # Modelos, datasources, repositorios (implementación)
      domain/          # Entidades, repositorios (abstractos), casos de uso
      presentation/    # UI, widgets, bloc/cubit
    calendar/
    statistics/
  main.dart
```

## Resumen mensual (gráfica)

El card **"[Month] Summary"** (p. ej. "January Summary") aparece debajo del calendario y solo cuando hay al menos un registro en ese mes.

- **Gráfica:** línea que une los puntos de ánimo por día. Cada punto usa el nivel de intensidad guardado (1 = Happy, 5 = Angry). En el eje vertical se muestran los íconos de la app (Happy arriba, Angry abajo) en lugar de emojis genéricos.
- **Monthly average:** se muestra solo el ícono del ánimo que corresponde al promedio del mes (según rangos de score).
- **Best streak:** texto tipo "X day(s) in a row recording your mood".
- **Datos legacy:** los registros guardados antes de guardar intensidad real tenían `intensity: 3`. Si la versión de la app es ≤ 1.2.3+15, se deriva la intensidad desde el campo `mood` (ruta del ícono) para que la gráfica y el promedio se vean correctos.

## Dependencias principales

- [Flutter](https://flutter.dev/)
- [Hive](https://pub.dev/packages/hive)
- [Bloc](https://pub.dev/packages/flutter_bloc)
- [Freezed](https://pub.dev/packages/freezed)
- [fl_chart](https://pub.dev/packages/fl_chart) – gráfica de línea del resumen mensual
- [flutter_svg](https://pub.dev/packages/flutter_svg) – íconos de ánimo en la gráfica y en el card
- [package_info_plus](https://pub.dev/packages/package_info_plus) – versión de la app (mapeo legacy)
- [build_runner](https://pub.dev/packages/build_runner)
- [json_serializable](https://pub.dev/packages/json_serializable)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [timezone](https://pub.dev/packages/timezone)
- [flutter_native_timezone_plus](https://pub.dev/packages/flutter_native_timezone_plus)

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

La aplicación programa una notificación local diaria a las 6:00 pm para
recordar al usuario registrar su estado de ánimo.

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
- Sigue la arquitectura y convenciones del proyecto para nuevas features.

## Licencia

MIT
