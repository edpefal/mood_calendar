## Purpose

Define el contenido de la pestaña Insights: qué tarjetas muestra, cómo se calculan sin usar `intensity`, qué hace con pocos datos y qué es gratis o Premium, para que el paywall pueda prometer Insights y Year in Pixels con certeza.

## ADDED Requirements

### Requirement: Contenido de la pestaña Insights
La pestaña Insights SHALL mostrar, de arriba abajo: el resumen del mes en curso (días con entrada, distribución por categoría, mood más frecuente), la racha actual y la mejor racha, la tendencia por rango, el mood por día de la semana y Year in Pixels. Todo SHALL calcularse en el dispositivo a partir de las Mood Entry. Los valores numéricos SHALL salir del nivel de la categoría del Mood (alto, medio, bajo; ADR 0003) y NUNCA de `intensity`. Ninguna tarjeta SHALL presentar una categoría como mejor que otra, y el nombre de cada categoría SHALL poder leerse siempre, sin depender del color.

#### Scenario: Usuario con entradas
- **WHEN** un usuario con entradas abre Insights
- **THEN** ve el resumen del mes, las rachas, la tendencia, el mood por día de la semana y Year in Pixels, y cada categoría aparece con su nombre

#### Scenario: Usuario sin ninguna entrada
- **WHEN** un usuario sin entradas abre Insights
- **THEN** ve un estado vacío localizado que invita a registrar su primer día, sin gráficas ni cifras inventadas

### Requirement: Resumen del mes y rachas
El resumen SHALL mostrar el número de días con entrada del mes en curso, la distribución por categoría en porcentaje (con el nombre de cada categoría) y el Mood más frecuente con su desempate habitual. Las tarjetas de racha SHALL mostrar la racha actual y la mejor racha, con las reglas de días consecutivos ya vigentes. La racha actual SHALL contar desde hoy si hoy tiene entrada, o desde ayer si hoy aún no la tiene, para no romperse antes de que acabe el día.

#### Scenario: Distribución por categoría
- **WHEN** el mes tiene 2 entradas Peaceful y 1 Positive
- **THEN** el resumen muestra "Peaceful 67%" y "Positive 33%"

#### Scenario: Hoy aún sin entrada
- **WHEN** ayer y antier tienen entrada y hoy todavía no
- **THEN** la racha actual muestra 2 días

#### Scenario: Racha rota
- **WHEN** ni hoy ni ayer tienen entrada
- **THEN** la racha actual muestra 0 días

### Requirement: Tendencia por rango
La tarjeta de tendencia SHALL ofrecer los rangos de 7, 30, 90 y 365 días que terminan hoy. En 7 y 30 días SHALL mostrar un punto por día con entrada, coloreado con la categoría del Mood, y dejar un hueco en los días sin entrada. En 90 y 365 días SHALL mostrar un punto por semana con el promedio del nivel de las entradas de esa semana, y dejar un hueco en las semanas sin entradas. Con menos de 2 entradas en el rango elegido, la tarjeta SHALL mostrar un estado de datos insuficientes en lugar de una gráfica. La gráfica SHALL tener una descripción accesible que resuma el rango (por ejemplo, "Últimos 7 días: sobre todo positivos; sin entrada el martes").

#### Scenario: Siete días con un hueco
- **WHEN** el usuario elige 7 días y no tiene entrada el martes
- **THEN** la gráfica muestra seis puntos y un hueco el martes

#### Scenario: Rango largo
- **WHEN** un suscriptor elige 90 días
- **THEN** la gráfica muestra un punto por semana con el nivel promedio de esa semana

#### Scenario: Datos insuficientes
- **WHEN** el rango elegido tiene una sola entrada
- **THEN** la tarjeta muestra el estado de datos insuficientes y no dibuja la gráfica

### Requirement: Mood por día de la semana
La tarjeta SHALL mostrar, para cada día de la semana, el nivel promedio de todas las entradas de ese día de la semana y la categoría más frecuente, con su nombre en la descripción accesible. Un día de la semana con menos de 2 entradas SHALL mostrarse vacío. Con menos de 14 entradas en total, la tarjeta SHALL mostrar el estado de datos insuficientes.

#### Scenario: Datos suficientes
- **WHEN** el usuario tiene 20 entradas repartidas en la semana
- **THEN** la tarjeta muestra una barra por día de la semana

#### Scenario: Pocos datos
- **WHEN** el usuario tiene 9 entradas
- **THEN** la tarjeta muestra el estado de datos insuficientes

### Requirement: Year in Pixels
La tarjeta SHALL mostrar el año elegido (el actual por defecto) como una cuadrícula con un píxel por día, teñido con la categoría del Mood de ese día; los días sin entrada SHALL verse vacíos y los futuros inertes. SHALL permitir ir a años anteriores que tengan entradas y SHALL incluir una leyenda con el nombre de las cuatro categorías. Tocar un píxel con entrada SHALL abrir el detalle de ese día.

#### Scenario: Año en curso
- **WHEN** un suscriptor abre Year in Pixels en noviembre
- **THEN** ve los días registrados teñidos por categoría, los días sin entrada vacíos y los posteriores a hoy inertes

#### Scenario: Año sin entradas
- **WHEN** el usuario intenta ir a un año anterior sin entradas
- **THEN** la navegación hacia ese año no está disponible

#### Scenario: Tocar un píxel
- **WHEN** el usuario toca el píxel de un día con entrada
- **THEN** se abre el detalle de ese día

### Requirement: Qué es gratis y qué es Premium
El resumen del mes, las rachas y la tendencia de 7 y 30 días SHALL estar disponibles sin suscripción. La tendencia de 90 y 365 días, el mood por día de la semana y Year in Pixels SHALL requerir la suscripción. Quien no está suscrito SHALL ver esas tarjetas con una vista previa difuminada y la acción "Ver con Premium", que abre la hoja de suscripción; la vista previa NO SHALL mostrar datos reales del usuario. Los suscriptores SHALL verlo todo sin avisos. Un usuario cuya suscripción vence SHALL conservar sus entradas y volver a ver los candados.

#### Scenario: Usuario gratis ve una tarjeta bloqueada
- **WHEN** un usuario sin suscripción abre Insights
- **THEN** el resumen, las rachas y la tendencia de 7 y 30 días se ven completos, y Year in Pixels y el mood por día de la semana aparecen difuminados con "Ver con Premium"

#### Scenario: Elegir un rango Premium sin suscripción
- **WHEN** un usuario sin suscripción elige 90 o 365 días en la tendencia
- **THEN** se abre la hoja de suscripción y el rango activo sigue siendo el anterior

#### Scenario: Suscriptor
- **WHEN** un suscriptor abre Insights
- **THEN** todas las tarjetas se muestran con sus datos y ninguna lleva candado ni acción de suscripción

#### Scenario: Vista previa sin datos reales
- **WHEN** una tarjeta bloqueada se muestra difuminada
- **THEN** su contenido es una ilustración fija y no refleja las entradas del usuario
