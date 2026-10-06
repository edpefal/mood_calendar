## Context

Ver `proposal.md` (Why) y `specs/rating-prompt/spec.md` (requisitos). Estado actual relevante:

- El guardado ocurre en `MoodScreen`: `MoodCubit.save` emite `saved`, el listener refresca y llama `AppNavigator.popOrShowCalendar`. Ese método termina siempre en `CalendarScreen`, ya sea haciendo `pop` con la fecha guardada o con `pushReplacement` a un `CalendarScreen(recentlySavedDate: ...)`.
- El editor de nota es un bottom sheet de `MoodScreen`; ya está cerrado cuando el usuario toca Guardar.
- `AppSettings` (entidad + `AppSettingsLocalDataSource`) guarda preferencias editables del usuario en el box Hive `app_settings`, y `saveSettings` reescribe todas sus claves.
- No hay pantalla de Ajustes: el único panel de ajustes es `_ReminderSettingsSheet`, abierto desde la campana del calendario.
- `in_app_review` 2.0.12 resuelve sin tocar dependencias existentes (verificado con `flutter pub add --dry-run`: solo agrega paquetes, entre ellos `url_launcher` como transitiva).

## Goals / Non-Goals

**Goals:**
- Regla de disparo pura y testeable, separada de UI y de plataforma.
- Que el pedido ocurra siempre en el calendario, después de que la navegación terminó.
- Estado de intentos persistente sin acoplarlo a las preferencias del usuario.

**Non-Goals:**
- Medir si iOS mostró el diálogo (la API no lo informa); solo se mide que se solicitó.
- Android: el servicio no hace nada fuera de iOS.
- Encuestas o "¿te gusta la app?" previas: la guía de Apple desaconseja pre-filtrar quién puede calificar.

## Decisions

**1. Paquete `in_app_review` en vez de un canal nativo propio.**
`requestReview()` para el pedido automático y `openStoreListing(appStoreId: '6752843360')` para la fila manual. Alternativa descartada: escribir un `MethodChannel` hacia `SKStoreReviewController` (más código Swift que mantener sin ganancia). También se descartó usar `url_launcher` con `?action=write-review` para abrir directo el redactor de reseña: obligaría a declarar `url_launcher` como dependencia directa y no se puede comprobar en el simulador (no tiene App Store). `openStoreListing` lleva a la ficha, desde donde el usuario toca "Escribir una reseña".

**2. La regla vive en una clase de dominio pura: `RatingPromptPolicy`.**
`shouldRequest({totalEntryDays, attempts, lastAttemptAt, now}) → bool`, en `lib/features/mood/domain/services/` junto a `MoodStreakCalculator`. Las constantes (hitos 3 y 7, máximo 2 intentos, 30 días) quedan en un solo lugar. Se usa "total ≥ hito" y no "total == hito" para que un usuario existente con muchas entradas también reciba el primer intento y para que un intento perdido se recupere en el siguiente guardado; el intervalo de 30 días evita que el segundo intento caiga justo después del primero en esos usuarios.

**3. Un servicio orquesta: `RatingPromptService.maybeRequestAfterSave()`.**
Cuenta los días distintos con entrada (lee todas las entradas con `GetMoodsUseCase` y deduplica por fecha: el total no crece al editar un día), lee el estado persistido, consulta la política y, si corresponde, **registra el intento y emite la telemetría antes** de llamar al solicitante. Registrar antes evita repetir el intento si la app se cierra durante el diálogo. Un error del solicitante se reporta con `recordError` y no se propaga. El solicitante (`requestReview`) se inyecta detrás de una interfaz mínima para poder usar un fake en tests. Si la plataforma no es iOS, el servicio retorna sin hacer nada.

**4. El disparo está en `CalendarScreen`, no en `MoodCubit`.**
Cuando el calendario recibe una fecha recién guardada (por el resultado del `pop` o por `recentlySavedDate` en el reemplazo de ruta; ya existe `_recentlySavedDate` para la animación), llama al servicio tras el primer frame y una espera corta (~600 ms) para no mostrar el diálogo en mitad de la transición. Poner el disparo en `MoodCubit.save` obligaría a pensar en tiempos de navegación y contexto de UI dentro del estado de presentación, y el pedido saldría antes de que el usuario vuelva al calendario. Como solo se llega por la rama `saved`, un guardado fallido nunca dispara nada, y el editor de nota ya está cerrado.

**5. Persistencia en el box `app_settings`, con claves propias y datasource aparte.**
Un `RatingPromptLocalDataSource` guarda `rating_prompt_attempts` (int) y `rating_prompt_last_attempt_at` (milisegundos desde epoch, int). Alternativa descartada: ampliar `AppSettings`; mezclaría contadores internos con preferencias editables y haría que `saveSettings` y el código de la hoja de recordatorios tengan que conocerlos. Hive guarda primitivos, así que no hace falta adaptador nuevo ni `build_runner`.

**6. Fila manual en `_ReminderSettingsSheet`.**
Un `ListTile` con ícono, texto localizado y `Semantics`, que llama `openStoreListing` y registra el evento manual. No toca el estado de intentos. El `appStoreId` va como constante, no como secreto.

**7. Telemetría.** Eventos nuevos en `AppTelemetryEvents`: `rating_prompt_requested` (propiedades: número de intento y total de días con entrada) y `rating_manual_opened`.

**8. Verificación.** Tests unitarios de la política (tabla de casos: hitos, límite de 2, 30 días, edición de un día) y del servicio con fakes de entradas, solicitante y telemetría, y un box Hive temporal para el estado (como los tests de settings). Un test de `MoodScreen` comprueba que guardar dispara el pedido al llegar al calendario. El diálogo nativo se comprueba en el simulador con `idb` registrando 3 días; en builds de debug iOS lo muestra siempre. La fila manual no se puede completar en el simulador (no hay App Store), así que se verifica que se invoque la llamada y que no cambie el estado de intentos.

## Risks / Trade-offs

- [iOS no muestra el diálogo (límite de 3 por año, o el usuario lo desactivó) pero el intento queda consumido] → Se aceptan solo 2 intentos propios, separados 30 días, y la fila manual siempre está disponible.
- [Usuarios existentes con ≥3 entradas reciben el primer intento en su próximo guardado tras actualizar] → Es intencional: son los usuarios más comprometidos.
- [Plugin nativo nuevo en iOS (Pods, `url_launcher`)] → Hay que repetir el checklist de release de `CLAUDE.md`: build con `--dart-define=REVENUECAT_IOS_API_KEY`, `MoodStoreScreen` cargando el catálogo en iPhone e iPad y UI antes del diálogo de notificaciones.
- [Apple penaliza prompts de calificación propios (Guideline 5.6.1)] → Solo se usa el diálogo del sistema; la fila manual abre la ficha del App Store y no es un pre-filtro.
- [Dos diálogos del sistema seguidos (calificación y permiso de notificaciones)] → El permiso de notificaciones se pide en el arranque, mucho antes de 3 entradas registradas; no coinciden en la práctica.
