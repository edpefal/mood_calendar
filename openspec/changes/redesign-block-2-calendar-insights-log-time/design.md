## Context

Segundo de tres bloques del rediseño (motivación y alcance en `proposal.md`; requisitos en los specs de este change). Diseño de referencia: artefacto `b968c1cf-8592-4534-8a8c-db17961bb6fc` (Calendar, DayDetail e Insights). Partimos del Bloque 1 ya en `main`:

- `MoodEntry` (freezed) y `MoodModel` (Hive, `typeId: 0`, campos 0 a 3) guardan una entrada por día; la clave es la fecha normalizada. `MoodRepositoryImpl.saveMood` reescribe la entrada del día.
- `CalendarScreen` + `CalendarCubit` cargan un mes (`GetMonthlyMoodSummaryUseCase`). `onDaySelected` lleva siempre al Log con la fecha (`MainShell.showLog`), que muestra el estado Saved si hay entrada.
- `InsightsScreen` es un estado vacío. `PurchasesCubit` ya expone `subscription` (estado de suscripción) y `showPremiumSheet(source)` abre la hoja.
- El nivel de categoría (`MoodCategory.level`, ADR 0003) es la única fuente numérica permitida; `MoodStreakCalculator` ya tiene mejor racha y racha actual.
- El reloj aplica sus elecciones con `ProcessWatchInboxUseCase`, que llama a `repository.saveMood` y trae `chosenAt`.

## Goals / Non-Goals

**Goals:**
- Que Calendar e Insights compartan una sola fuente de agregaciones puras (sin Flutter) y testeables: distribución por categoría, tendencia, día de la semana, píxeles del año y rachas.
- Añadir la hora de registro sin migrar ni reescribir datos existentes.
- Una sola dependencia nueva (`fl_chart`) para las gráficas de línea y de barras, aislada en `features/insights/presentation` para poder cambiarla sin tocar el dominio.

**Non-Goals:**
- Palabras frecuentes de las notas, "tu mes en una imagen", exportar la hora de registro y analíticas de uso de Insights.
- Cambiar el catálogo, las categorías, los precios o las ofertas de las tiendas.
- Una vista de año independiente del Calendar: el botón "ver año" reutiliza la tarjeta de Insights.

## Decisions

### 1. `loggedAt` como campo Hive opcional, decidido en el repositorio
`MoodModel` gana `@HiveField(4) DateTime? loggedAt` y `MoodEntry` gana `DateTime? loggedAt`. Las entradas existentes se leen con `null`; no hay migración. El caso de uso recibe `loggedAt` ya resuelto por quien guarda (`MoodCubit` con un reloj inyectable `DateTime Function() now`; el reloj usa su `chosenAt`), y `MoodRepositoryImpl.saveMood` aplica la regla de conservación: si ya existe una entrada de ese día con el mismo `mood`, conserva su `loggedAt`; si el mood cambió o no existía, usa el que llega.
- **Por qué en el repositorio**: es el único punto que ve la entrada previa, y así el reloj y el Log comparten la regla sin duplicarla.
- **Alternativa descartada**: poner la hora en la UI al guardar; el reloj y las ediciones de nota la sobrescribirían.
- **Alternativa descartada**: una caja Hive aparte con las horas; añadiría una segunda fuente por entrada sin ventaja.

### 2. La hora se muestra solo si cae el mismo día de la entrada
La presentación compara `loggedAt` con la fecha de la entrada (día calendario local). Así una entrada de ayer registrada hoy no dice "9:02 PM" como si fuera de ayer, y las anteriores a este change no muestran nada. Se formatea con la hora del dispositivo (`MaterialLocalizations.formatTimeOfDay` con `alwaysUse24HourFormat` de `MediaQuery`), no con cadenas de `AppStrings`.
- **Riesgo asumido**: si el usuario viaja a otra zona horaria, la hora guardada en local puede dejar de caer en el mismo día. Se acepta: solo se ocultaría la hora.

### 3. Agregaciones puras en `features/insights/domain`
Servicios sin Flutter, cada uno con tests: `CategoryDistribution` (porcentajes por categoría), `TrendCalculator` (rangos 7/30 diarios y 90/365 por semana con el promedio del nivel; `MoodLevel` se mapea a 3, 2 y 1 solo dentro de este servicio), `WeekdayProfile` (nivel promedio y categoría más frecuente por día de la semana, umbrales 2 por día y 14 en total), `YearPixels` (un valor por día del año) y la racha actual (se extiende `MoodStreakCalculator`: hoy o ayer como punto de partida). Todos reciben la lista de entradas y "hoy" por parámetro.
- **Por qué los números 3/2/1**: el ADR 0003 pide un valor numérico solo para análisis y por categoría; mantenerlo dentro del servicio evita que otra pantalla lo reutilice como puntaje por mood.
- **Alternativa descartada**: promediar `intensity`; prohibido por el ADR 0003.

### 4. Insights lee las entradas de `MoodCubit`; el rango y el año viven en la pantalla
`MoodCubit` ya carga todas las entradas y se refresca al guardar y cuando `WatchSyncHost` aplica elecciones del reloj, así que Insights no necesita su propio cubit ni una segunda carga: escucha `MoodCubit` (como el Log y el calendario) y calcula con los servicios puros en cada cambio. El rango de la tendencia y el año de Year in Pixels son estado de la pantalla. La racha actual del calendario sale de las mismas entradas, no del mes visible. El volumen es de a lo sumo unos cientos de entradas, así que no hace falta paginar ni cachear.
- **Alternativa descartada**: un `InsightsCubit` con su propia carga; duplicaba el refresco que ya resuelve `MoodCubit` y no aportaba estado que valga la pena probar aparte.

### 5. Bloqueo por candado difuminado con ilustración fija
Una tarjeta Premium bloqueada muestra una ilustración estática (asset o `CustomPaint` con datos de muestra fijos) bajo un `ImageFiltered` y un botón "Ver con Premium". **Nunca** pasa los datos reales al widget bloqueado (spec: sin datos reales en la vista previa). La decisión de mostrar datos o candado sale de `PurchasesCubit.state.subscription`, igual que el desbloqueo de moods, para que quien deja de pagar vuelva a ver los candados sin tocar sus entradas. El blur es uno por tarjeta bloqueada (no por celda), en línea con la advertencia de rendimiento del vidrio del Bloque 1.
- **Alternativa descartada**: calcular y difuminar los datos reales como "gancho"; filtra información que el usuario no pagó y complica la accesibilidad.

### 6. Gráficas con `fl_chart`; Year in Pixels con widgets
La tendencia (`LineChart` con puntos coloreados por categoría y huecos en los días sin entrada) y las barras por día de la semana (`BarChart`) usan el paquete `fl_chart`. Year in Pixels es una cuadrícula de cuadros de color, que `fl_chart` no ofrece, y se construye con widgets (`GridView`/`CustomPaint`). Las tres llevan `Semantics` que resume la gráfica (spec: descripción accesible), porque `fl_chart` dibuja en un canvas sin árbol de accesibilidad, y los colores salen de `BrandPalette`, nunca de los valores por defecto del paquete.
- **Por qué**: ejes, escalas, huecos en la serie y animación de entrada ya resueltos; menos código propio que mantener y probar.
- **Costo asumido**: una dependencia nueva, solo Dart, sin plugins nativos ni acceso a red o a datos; no cambia App Privacy, Data safety ni la política. La versión se fija en `1.1.0`: el CI usa Flutter 3.32.1, que fija `vector_math` 2.1.4, y desde la 1.1.1 `fl_chart` pide `^2.2.0` (lo detectó el CI del PR del Bloque 2). Subirla exige subir antes el Flutter del CI.
- **Alternativa descartada**: dibujar todo con `CustomPaint`; evitaba la dependencia, pero obligaba a escribir ejes, escalas y huecos a mano.

### 7. Detalle del día como hoja modal compartida
`DayDetailSheet` se abre con `showModalBottomSheet` desde el calendario y desde un píxel de Year in Pixels. Muestra mood, categoría, hora (decisión 2), nota y "Edit"; "Edit" cierra la hoja y llama a `MainShell.showLog(date, edit: true)`, que deja el Log con la cuadrícula en edición (el Log ya tiene `_editing`). Tocar un día sin entrada sigue llamando `showLog(date)`. La hoja cubre la barra, como el resto de modales del Bloque 1.

### 8. "Ver año" lleva a Insights, y el selector de mes es una hoja
El botón "ver año" del Calendar llama a `MainShell.showInsights(scrollTo: yearInPixels)`. El selector de mes y año es una hoja con un paso de año y doce meses, con los futuros deshabilitados; elige y llama a `CalendarCubit.loadMonth`.
- **Alternativa descartada**: una pantalla de año propia con su paywall; duplica Year in Pixels.

### 9. Analíticas y `source`
`AppTelemetryEvents` no suma eventos. `showPremiumSheet(source: 'insights')` reutiliza el evento existente; el valor se añade a lo que ya acepta el parámetro `source` (que ya está en la lista permitida). Ver Insights, cambiar de rango o abrir el detalle no emiten nada.

## Risks / Trade-offs

- [Más memoria y trabajo en el primer frame de Insights con muchos años de entradas] → Los servicios son lineales sobre pocos cientos de entradas; se calculan en el cubit, no en `build`, y se miden en el simulador más lento (como la tarea 9.3 del Bloque 1).
- [Los deltas de `calendar-navigation` y `premium-subscription` parten de los del Bloque 1, que aún no se archiva] → Archivar el Bloque 1 antes de este; si no, `openspec archive` fallaría al no encontrar los requisitos modificados.
- [Regenerar `mood_model.g.dart` y `mood_entry.freezed.dart` toca archivos grandes] → Es mecánico (`build_runner`); el campo nuevo es nulo, así que los tests de Hive existentes y la lectura de cajas viejas siguen pasando (se añade uno que abre una caja con el esquema anterior).
- [`fl_chart` sin descripción accesible propia y con rendimiento variable en dispositivos viejos] → Cada gráfica va envuelta en `Semantics` con su resumen; la tendencia limita puntos (365 días son 52 semanales) y se mide con la tarea 7.3.
- [Una tarjeta bloqueada puede sentirse como presión de venta] → Sin contadores ni avisos; solo la acción "Ver con Premium" en la tarjeta, y nunca la hoja al abrir la pestaña (spec).
- [El rango Premium cambia el comportamiento de un chip (el rango activo no cambia al abrir la hoja)] → Cubierto por un escenario y un test del cubit.
- [Los umbrales de datos insuficientes (2 por rango, 2 por día, 14 en total) son una decisión de producto] → Constantes con nombre en un solo lugar para ajustarlas tras probar en TestFlight.

## Migration Plan

- Sin migración de datos: `loggedAt` es opcional y las cajas existentes se leen igual.
- Orden de construcción y de merge a `main` (una sola rama, PR con commits agrupados; en el Bloque 1 las capas quedaron entrelazadas y no se pudo separar): campo y repositorio de `loggedAt` → agregaciones puras → calendario y detalle → Insights → bloqueo Premium → docs. `flutter analyze` y `flutter test` en verde en cada commit.
- Reversión: revertir el PR devuelve la app al Bloque 1; el campo `loggedAt` guardado queda ignorado en la caja sin dañarla (Hive tolera campos desconocidos al leer con el adaptador anterior).
- No se publica versión ni se recapturan capturas; el rediseño sale cuando estén los tres bloques y se pida el cambio de versión.

## Open Questions

- Si "tu mes en una imagen" y las palabras frecuentes van como un Bloque 2.5 o dentro del Bloque 3 (afecta solo al backlog, no a este change).
