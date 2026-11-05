## 1. Hora de registro

- [x] 1.1 Añadir `DateTime? loggedAt` a `MoodEntry` y `@HiveField(4)` a `MoodModel`; regenerar con `build_runner` y pasar `loggedAt` por `MoodRepositoryImpl` (guardar, leer, migración de claves)
- [x] 1.2 Aplicar la regla en `MoodRepositoryImpl.saveMood`: conservar `loggedAt` si la entrada del día ya existe con el mismo mood; usar el recibido si el mood cambió o no había entrada
- [x] 1.3 Dar a `MoodCubit` un reloj inyectable y enviar `loggedAt` al guardar; hacer que `ProcessWatchInboxUseCase` use el `chosenAt` de la elección del reloj
- [x] 1.4 Tests: entrada nueva, editar solo la nota, cambiar el mood, elección del reloj, abrir una caja Hive con el esquema anterior sin `loggedAt`, y que el export JSON y los eventos de analíticas no incluyan la hora
- [x] 1.5 Función de presentación `loggedTimeFor(entry)` (solo si cae el mismo día calendario) con tests, incluidos formato de 12 y 24 horas

## 2. Agregaciones puras

- [x] 2.1 Extender `MoodStreakCalculator` con la racha actual que parte de hoy o de ayer, con tests (hoy sin entrada, racha rota, cruce de mes y de año)
- [x] 2.2 `CategoryDistribution`: porcentajes por categoría de un conjunto de entradas, con tests (redondeo que suma 100, mes vacío)
- [x] 2.3 `TrendCalculator`: rangos 7 y 30 diarios y 90 y 365 semanales con el promedio del nivel (3, 2, 1 solo dentro del servicio), huecos y mínimo de 2 entradas, con tests
- [x] 2.4 `WeekdayProfile`: nivel promedio y categoría más frecuente por día de la semana, umbrales de 2 por día y 14 en total como constantes con nombre, con tests
- [x] 2.5 `YearPixels`: un valor por día del año con días vacíos y futuros, y años con entradas, con tests
- [x] 2.6 Test que falle si alguna agregación lee `intensity`

## 3. Calendario

- [x] 3.1 Rehacer el encabezado de `CalendarScreen` (título, botón "ver año") y el título del mes tocable con el selector de mes y año (hoja con paso de año; futuros deshabilitados)
- [x] 3.2 Celdas nuevas: tinte de categoría con carita, borde punteado y "+" en días pasados sin entrada, aro de tinta en hoy, futuros inertes y etiquetas de `Semantics`
- [x] 3.3 Reemplazar el resumen por la card de mood más frecuente, la barra "Tu mes hasta ahora" con nombres visibles, y las cards de racha actual y mejor racha (la actual independiente del mes visible)
- [x] 3.4 `DayDetailSheet`: mood, categoría, hora de registro condicional, nota y "Edit"; abrirla al tocar un día con entrada y mantener `showLog(date)` para días sin entrada
- [x] 3.5 `MainShell.showLog(date, edit: true)` para que "Edit" deje el Log con la cuadrícula en edición, y `showInsights` para "ver año"
- [x] 3.6 Adaptar y ampliar los tests del calendario, del resumen mensual, del shell y del detalle (con y sin hora, cerrar sin editar, fechas futuras)

## 4. Insights

- [x] 4.0 Añadir `fl_chart` con `flutter pub add`, confirmar que `flutter analyze`, `flutter test` y un build de simulador siguen en verde (Dart 3.6, Flutter 3.32) y que `verify_ios_archive_no_ad_id.sh` no detecta cambios en los binarios
- [x] 4.1 Estado de Insights: las entradas salen de `MoodCubit` (ya se refresca al guardar y al volver del reloj) y el rango de la tendencia y el año de Year in Pixels viven en la pantalla
- [x] 4.2 Reemplazar `InsightsScreen` por la lista de tarjetas: resumen del mes, rachas y estado vacío sin entradas
- [x] 4.3 Tarjeta de tendencia con `LineChart` de `fl_chart`: selector 7/30/90/365, puntos coloreados por categoría con colores de `BrandPalette`, huecos y estado de datos insuficientes, y `Semantics` que resume el rango
- [x] 4.4 Tarjeta del mood por día de la semana con `BarChart` de `fl_chart` (categoría más frecuente, estados vacío e insuficiente) y `Semantics`
- [x] 4.5 Tarjeta Year in Pixels con widgets propios (cuadrícula, leyenda con los nombres de las categorías, años con entradas, píxel que abre el detalle del día) con `Semantics`
- [x] 4.6 Tests de widget de las tarjetas con ventana de 390×844: con datos, sin datos, datos insuficientes y texto grande

## 5. Premium en Insights

- [x] 5.1 Contenedor de tarjeta bloqueada: ilustración fija difuminada que nunca recibe datos reales, "Ver con Premium" y un solo blur por tarjeta
- [x] 5.2 Bloquear 90 y 365 días, el mood por día de la semana y Year in Pixels según `PurchasesCubit`; elegir un rango Premium sin suscripción abre la hoja y conserva el rango activo; "ver año" sin suscripción muestra la tarjeta bloqueada
- [x] 5.3 Pasar `source: 'insights'` a `showPremiumSheet` y confirmar que ver Insights o cambiar entre 7 y 30 días no emite eventos
- [x] 5.4 Tests: usuario gratis, suscriptor, suscripción vencida que recupera los candados, evento con `source` igual a `insights` y la vista previa sin datos reales

## 6. Textos y accesibilidad

- [x] 6.1 Añadir a `AppStrings` los textos de Calendar, detalle del día, Insights (títulos, rangos, estados vacíos e insuficientes, "Ver con Premium", leyendas y descripciones accesibles) en `en`, `es`, `de`, `fr` e `it`
- [x] 6.2 Revisar `Semantics` de todo control nuevo y que ninguna categoría dependa solo del color

## 7. Verificación y cierre

- [x] 7.1 `flutter analyze` y `flutter test` en verde
- [ ] 7.2 Revisar en simulador de iPhone y de iPad, en claro y oscuro, en inglés y alemán, con texto al 200 %, con datos de un año completo y con una caja con entradas antiguas sin hora
- [ ] 7.3 Medir la fluidez de Insights (varias tarjetas con blur y gráficas) en un iPhone real o en el simulador más lento disponible
- [x] 7.4 Actualizar `CLAUDE.md` (estado, Insights, calendario, hora de registro), `CONTEXT.md` (Hora de registro, Tendencia, Year in Pixels) y `backlog.md` (palabras frecuentes e imagen del mes)
- [x] 7.5 Un build de TestFlight solo si el usuario lo pide; no publicar versión ni recapturar capturas
