## 1. Dependencia

- [x] 1.1 Agregar `in_app_review: ^2.0.12` a `pubspec.yaml`, correr `flutter pub get` y confirmar que el diff de `pubspec.lock` solo agrega paquetes (ninguna dependencia existente cambia de versión)
- [x] 1.2 Compilar en debug para iOS y confirmar que el plugin nuevo (Pods) no rompe el build

## 2. Política de disparo

- [x] 2.1 Crear `RatingPromptPolicy` en `lib/features/mood/domain/services/` con las constantes (hitos 3 y 7, máximo 2 intentos, 30 días de separación) y la decisión `decide({totalEntryDays, attempts, lastAttemptAt, now})`
- [x] 2.2 Tests unitarios de la política: menos de 3 días no pide; 3 días sin intentos pide; 7 días con 1 intento y 30 días o más pide; 7 días con 1 intento y menos de 30 días no pide; 2 intentos nunca pide; total 3 con el primer intento ya hecho no pide

## 3. Persistencia

- [x] 3.1 Crear `RatingPromptLocalDataSource` sobre el box Hive `app_settings` con las claves `rating_prompt_attempts` (int, por defecto 0) y `rating_prompt_last_attempt_at` (milisegundos desde epoch, int, nulo por defecto) y una operación que registra un intento
- [x] 3.2 Test del datasource siguiendo el patrón de los tests de settings existentes: valores por defecto, registrar un intento, y que el estado se conserva al crear otra instancia sobre el mismo box

## 4. Servicio

- [x] 4.1 Definir la interfaz `ReviewRequester` con una implementación que usa `InAppReview` (`requestReview` para el pedido automático, `openStoreListing(appStoreId: '6752843360')` para el manual)
- [x] 4.2 Crear `RatingPromptService.maybeRequestAfterSave()`: contar los días distintos con entrada (vía `GetMoodsUseCase`, deduplicando por fecha), leer el estado, consultar la política, registrar el intento antes de solicitar, llamar al solicitante, emitir telemetría; no hacer nada si la plataforma no es iOS
- [x] 4.3 Tests del servicio con fakes (entradas, solicitante, telemetría, reloj) y un box Hive temporal para el estado: pide en el 3.er día, no pide con editar un día ya contado, registra el intento antes de solicitar, no pide con 2 intentos, no hace nada fuera de iOS
- [x] 4.4 Agregar `rating_prompt_requested` y `rating_manual_opened` a `AppTelemetryEvents` y proveer el servicio desde `main.dart` junto a los demás servicios

## 5. Interfaz

- [x] 5.1 En `CalendarScreen`, llamar a `maybeRequestAfterSave()` cuando llega una fecha recién guardada (por el resultado del `pop` y por `recentlySavedDate` del reemplazo de ruta), después del primer frame y con una espera corta (~600 ms), protegido con `mounted`
- [x] 5.2 Agregar los getters nuevos a `app_strings.dart` e implementarlos en `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart` y `app_strings_it.dart`
- [x] 5.3 Agregar la fila "Calificar Mood Calendar" a `_ReminderSettingsSheet` con `Semantics`, que llama a `openStoreListing` y emite `rating_manual_opened` sin tocar el estado de intentos

## 6. Verificación

- [x] 6.1 `flutter analyze` y `flutter test` en verde
- [x] 6.2 En el simulador con `idb`: registrar 3 días distintos y confirmar que el diálogo nativo aparece en el calendario tras el tercer guardado, y que no reaparece en el cuarto
- [x] 6.3 En el simulador: abrir la hoja de recordatorios, tocar la fila y confirmar que se invoca la apertura (log) y que el conteo de intentos no cambia
- [ ] 6.4 Antes de subir cualquier build con este cambio, seguir el checklist de release de `CLAUDE.md` (key de RevenueCat con `--dart-define`, `MoodStoreScreen` cargando en iPhone e iPad)

## 7. Cierre

- [ ] 7.1 Al archivar, actualizar en `CLAUDE.md` la lista de specs vigentes (agregar `rating-prompt`) y la nota del flujo de guardado si cambió
