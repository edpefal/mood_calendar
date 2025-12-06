# Mood Calendar

Mood Calendar es una aplicación Flutter para registrar y visualizar el estado de ánimo diario del usuario, siguiendo principios de Clean Architecture, Bloc y Freezed.

## Características

- Registro diario del estado de ánimo con nota opcional.
- Visualización de moods guardados (listo para extender a calendario y estadísticas).
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

## Dependencias principales

- [Flutter](https://flutter.dev/)
- [Hive](https://pub.dev/packages/hive)
- [Bloc](https://pub.dev/packages/flutter_bloc)
- [Freezed](https://pub.dev/packages/freezed)
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
