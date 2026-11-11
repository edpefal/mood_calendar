## Why

El Bloque 1 dejó el sistema visual, el Log y las 4 pestañas, pero Insights es un estado vacío y el calendario solo cambió de color. El paywall ya promete "Insights y Year in Pixels", así que el Bloque 2 tiene que cumplir esa promesa y rehacer el calendario con el diseño de referencia (artefacto `b968c1cf-8592-4534-8a8c-db17961bb6fc`, pantallas Calendar, DayDetail e Insights). Es el segundo de tres bloques; el rediseño se publica en una sola versión cuando estén los tres.

## What Changes

- **Calendario nuevo**: encabezado con botón "ver año", selector de mes y año, celdas teñidas por la categoría del mood con su carita, día sin entrada con borde punteado y "+", hoy con aro de tinta y días futuros inertes. Debajo, la tarjeta del mood más frecuente, la barra "Tu mes hasta ahora" con el porcentaje por categoría (los nombres siempre visibles) y las tarjetas de racha actual y mejor racha.
- **Detalle del día** como hoja inferior: al tocar un día **con entrada** se abre una hoja con el mood, su categoría, la hora de registro, la nota y el botón Edit (que lleva al Log con esa fecha). Al tocar un día **pasado sin entrada** se va directo al Log con esa fecha, como hoy. **BREAKING (comportamiento del Bloque 1)**: tocar un día con entrada ya no salta al Log.
- **Hora de registro**: cada entrada nueva guarda cuándo se registró (campo opcional en Hive, sin migración de las existentes). Se muestra en el detalle del día solo si se registró el mismo día calendario de la entrada; las entradas antiguas y las registradas con retraso no muestran hora. No sale del dispositivo y no entra a las analíticas.
- **Insights real** (reemplaza el estado vacío): resumen del mes, racha actual y mejor racha, tendencia por rango (7, 30, 90 y 365 días), mood por día de la semana y Year in Pixels. El puntaje sale del nivel de la categoría (ADR 0003), nunca de `intensity`.
- **Qué es gratis y qué es Premium**: gratis el resumen del mes, las rachas y la tendencia de 7 y 30 días; Premium la tendencia de 90 y 365 días, el mood por día de la semana y Year in Pixels. Quien no está suscrito ve esas tarjetas con una vista previa difuminada y "Ver con Premium", que abre la hoja de suscripción (`source` = `insights`). Con muy pocos datos se muestra un estado vacío por tarjeta, nunca una gráfica inventada.
- **Fuera de este bloque**: palabras frecuentes de las notas y "tu mes en una imagen" (marcadas Pro en el diseño; van a un change posterior), onboarding y bloqueo biométrico (Bloque 3), exportar la hora de registro en el JSON, ícono, sitio y arte de tienda, y cambios en las ofertas de las tiendas. No se publica versión ni se recapturan capturas.

## Capabilities

### New Capabilities
- `insights-screen`: contenido de la pestaña Insights (resumen, rachas, tendencia por rango, día de la semana, Year in Pixels), reglas de datos insuficientes y qué tarjetas son gratis o Premium.
- `entry-log-time`: la hora de registro de una entrada, cuándo se captura, cuándo se conserva y cuándo se muestra.

### Modified Capabilities
- `calendar-navigation`: tocar un día con entrada abre la hoja de detalle; un día pasado sin entrada va al Log; selector de mes y año y vista de año.
- `monthly-mood-summary`: el resumen del calendario añade la distribución por categoría y la racha actual junto a la mejor racha y el mood más frecuente.
- `premium-subscription`: la hoja se ofrece también desde las tarjetas bloqueadas de Insights, con `source` = `insights`; los suscriptores nunca la ven.
- `usage-analytics`: nuevo valor `insights` de `source` en el paywall; sin eventos nuevos con datos de entradas.

## Impact

- **Código (`lib/`)**: `features/mood/domain/entities/mood_entry.dart` y `data/models/mood_model.dart` (campo `loggedAt`, regenerar freezed y Hive), `MoodRepositoryImpl`, `SaveMoodUseCase` y el procesamiento del buzón del reloj (la elección del reloj lleva su `chosenAt`); `features/mood/presentation` (`calendar_screen.dart`, resumen mensual, hoja de detalle, selector de mes/año, vista de año); `features/insights` (casos de uso de agregación, cubit, tarjetas y gráficas); `features/purchases` (`source` = `insights`); `core/localization/*` en los 5 idiomas.
- **Datos**: un campo Hive nuevo (`HiveField(4)`, nulo en lo existente); sin migración ni cambio de claves. El export JSON no cambia.
- **Dependencias externas**: `fl_chart` para la tendencia y las barras por día de la semana (paquete solo Dart, sin red ni acceso a datos); Year in Pixels se dibuja con widgets (ver `design.md`).
- **Privacidad**: sin cambios en App Privacy, Data safety ni la política; todo se calcula en el dispositivo y los eventos nuevos no llevan datos de entradas.
- **Docs**: `CONTEXT.md` (Hora de registro, Tendencia, Year in Pixels), `CLAUDE.md` y `backlog.md` (palabras frecuentes e imagen del mes).
- **Tests**: nuevos para agregaciones (tendencia por rango, día de la semana, rachas), `loggedAt` y su visibilidad, hoja de detalle, calendario, tarjetas bloqueadas y vista de año; se adaptan los del calendario y los de navegación del Bloque 1.
- **Dependencia de orden**: los deltas de `calendar-navigation` y `premium-subscription` parten de los del Bloque 1; archivar primero el Bloque 1 (le falta la tarea 9.3).
