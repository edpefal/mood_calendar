## Purpose

Define la suscripción que desbloquea los moods premium: sus tres planes, el precio y la prueba gratis que vienen de la tienda del sistema, la compra, el estado de quien está suscrito y la convivencia con las compras sueltas heredadas.

## ADDED Requirements

### Requirement: Tres planes de suscripción que desbloquean todos los moods premium
La app SHALL ofrecer una suscripción con tres planes: semanal, mensual y anual. Mientras la suscripción esté activa, todos los Moods premium del catálogo SHALL estar `unlocked`, incluidos los que se añadan después. La app NO SHALL ofrecer compras sueltas de Moods ni Packs. Los precios SHALL ser los que devuelve la tienda del sistema en la moneda del usuario; la app NO SHALL fijar ningún precio en su código ni en sus textos.

#### Scenario: Suscripción activa
- **WHEN** el usuario tiene una suscripción activa de cualquiera de los tres planes
- **THEN** los 14 Moods premium del catálogo están `unlocked`

#### Scenario: Moods premium nuevos
- **WHEN** una versión posterior añade un Mood premium al catálogo
- **THEN** un usuario con suscripción activa lo tiene `unlocked` sin comprar nada más

#### Scenario: Sin compras sueltas
- **WHEN** el usuario abre la pantalla Premium o toca un Mood bloqueado
- **THEN** solo ve los planes de suscripción, sin precios por Mood ni Packs

#### Scenario: Precio en la moneda del usuario
- **WHEN** el usuario abre la pantalla Premium con la tienda de un país distinto de Estados Unidos
- **THEN** cada plan muestra el precio que devuelve la tienda para ese país

### Requirement: Presentación de los planes
La pantalla Premium SHALL mostrar los tres planes como tarjetas, con el plan anual preseleccionado y marcado con la etiqueta "Mejor valor". El ahorro del plan anual SHALL calcularse a partir de los precios que devuelve la tienda. El precio que se cobra en cada ciclo SHALL ser el dato más prominente de la tarjeta; un precio equivalente por mes, si se muestra, SHALL ser secundario. La pantalla SHALL mostrar también un escaparate con los Moods premium.

#### Scenario: Plan anual preseleccionado
- **WHEN** el usuario abre la pantalla Premium sin suscripción activa
- **THEN** el plan anual aparece seleccionado y con la etiqueta "Mejor valor"

#### Scenario: Cambiar de plan
- **WHEN** el usuario toca la tarjeta del plan mensual
- **THEN** el plan mensual queda seleccionado y el botón principal se refiere a ese plan

#### Scenario: Ahorro calculado
- **WHEN** la tienda devuelve precios distintos a los previstos
- **THEN** el ahorro mostrado se recalcula con esos precios y nunca usa un porcentaje fijo

#### Scenario: Escaparate de moods
- **WHEN** el usuario abre la pantalla Premium
- **THEN** ve las caritas de los Moods premium con su nombre en el idioma del dispositivo

#### Scenario: El escaparate indica que se desliza
- **WHEN** el escaparate tiene más Moods de los que caben en pantalla
- **THEN** el último Mood visible queda cortado por el borde y ese borde se desvanece mientras haya más contenido por ver, de modo que se note que se puede deslizar

### Requirement: Prueba gratis de 3 días según elegibilidad
Cada plan SHALL ofrecer una prueba gratis de 3 días. El botón principal SHALL decir "Probar 3 días gratis" únicamente cuando la tienda confirma que el usuario es elegible para la prueba. Si el usuario ya la usó, o la elegibilidad no se puede comprobar, el botón SHALL decir "Suscribirme" junto con el precio y la pantalla NO SHALL mencionar la prueba.

#### Scenario: Usuario elegible
- **WHEN** la tienda confirma que el usuario no ha usado la prueba
- **THEN** el botón principal dice "Probar 3 días gratis" y el texto legal indica cuándo termina la prueba y cuánto se cobra después

#### Scenario: Prueba ya usada
- **WHEN** el usuario ya usó la prueba
- **THEN** el botón principal dice "Suscribirme", muestra el precio y ningún texto menciona una prueba gratis

#### Scenario: No se puede comprobar la elegibilidad
- **WHEN** la comprobación de elegibilidad falla
- **THEN** la pantalla se comporta como si el usuario no fuera elegible

### Requirement: Texto legal y enlaces en la pantalla
La pantalla Premium SHALL mostrar el nombre del plan elegido, su duración, el precio, que la suscripción se renueva automáticamente salvo que se cancele y cómo cancelarla, y SHALL incluir enlaces a los Términos y a la Política de Privacidad del sitio. Los textos SHALL estar en el idioma del dispositivo, con fallback a inglés.

#### Scenario: Información de renovación
- **WHEN** el usuario tiene un plan seleccionado sin suscripción activa
- **THEN** la pantalla indica el precio, la duración, la renovación automática y que se cancela desde los ajustes de suscripciones de la tienda

#### Scenario: Enlaces legales
- **WHEN** el usuario toca el enlace de Términos o el de Privacidad
- **THEN** se abre la página correspondiente del sitio en el idioma del dispositivo

### Requirement: Compra de un plan
El usuario SHALL poder suscribirse a un plan desde la pantalla Premium. Al completarse la compra, los Moods premium SHALL pasar a `unlocked` de inmediato y la pantalla SHALL mostrar el estado de suscrito.

#### Scenario: Compra exitosa
- **WHEN** el usuario completa la compra de un plan
- **THEN** todos los Moods premium quedan `unlocked` de inmediato y quedan disponibles en el carrusel

#### Scenario: Compra cancelada o fallida
- **WHEN** el usuario cancela la compra o esta falla
- **THEN** los Moods siguen sin `unlocked`, no se cobra nada y la pantalla permite intentarlo de nuevo

#### Scenario: Sin conexión al comprar
- **WHEN** la compra falla por falta de conexión
- **THEN** la app muestra un mensaje de conexión y no cambia el estado de ningún Mood

### Requirement: Estado de quien está suscrito
Con una suscripción activa, la pestaña Premium SHALL mostrar el plan actual y la fecha de renovación (o la de fin de la prueba si está en prueba), SHALL ocultar los planes y SHALL ofrecer "Gestionar suscripción", que abre los ajustes de suscripciones del sistema, y "Restaurar compras". La app NO SHALL cancelar la suscripción por sí misma.

#### Scenario: Suscrito
- **WHEN** el usuario tiene una suscripción mensual activa
- **THEN** la pestaña muestra el plan mensual, la fecha en que se renueva, el botón "Gestionar suscripción" y no muestra las tarjetas de planes

#### Scenario: En prueba
- **WHEN** el usuario está dentro de la prueba de 3 días
- **THEN** la pestaña indica que está en prueba y la fecha en que termina

#### Scenario: Gestionar
- **WHEN** el usuario toca "Gestionar suscripción"
- **THEN** se abren los ajustes de suscripciones del sistema

### Requirement: Vencimiento de la suscripción
Cuando la suscripción deja de estar activa (cancelación que llega a su fin, falta de pago o reembolso), los Moods premium SHALL volver a estar bloqueados salvo los desbloqueados por una compra heredada. La app NO SHALL ocultar ni modificar las Mood Entry ya guardadas, y NO SHALL mostrar avisos ni la pantalla Premium por iniciativa propia. La pestaña Premium SHALL volver a mostrar los planes.

#### Scenario: Suscripción vencida
- **WHEN** la suscripción vence
- **THEN** los Moods premium aparecen bloqueados en el selector, las Mood Entry con esos Moods siguen visibles en el calendario y no aparece ningún aviso

#### Scenario: Reanudar
- **WHEN** el usuario con la suscripción vencida abre la pestaña Premium
- **THEN** ve de nuevo los tres planes

### Requirement: Las compras sueltas heredadas se siguen reconociendo
Un usuario que compró un Mood premium o un Pack en una versión anterior SHALL conservar `unlocked` esos Moods sin necesitar una suscripción, y "Restaurar compras" SHALL recuperarlos en un dispositivo nuevo. Una suscripción activa SHALL desbloquear todos los Moods además de los heredados.

#### Scenario: Comprador anterior sin suscripción
- **WHEN** un usuario que compró el Mood `brave` en la versión 1.8.5 actualiza a esta versión
- **THEN** `brave` sigue `unlocked` y los demás Moods premium siguen bloqueados

#### Scenario: Comprador anterior que se suscribe
- **WHEN** ese usuario se suscribe
- **THEN** todos los Moods premium quedan `unlocked`; si la suscripción vence, `brave` sigue `unlocked`

#### Scenario: Restaurar en un dispositivo nuevo
- **WHEN** un comprador anterior ejecuta "Restaurar compras" en un dispositivo nuevo con su cuenta de la tienda
- **THEN** sus Moods heredados vuelven a estar `unlocked`

### Requirement: La suscripción solo se ofrece a petición del usuario
La pantalla de suscripción SHALL mostrarse únicamente cuando el usuario la pide: al tocar la pestaña Premium o al intentar usar un Mood premium bloqueado. La app NO SHALL mostrarla al abrirse, después de guardar un Mood, en un onboarding ni interrumpiendo el registro diario, y NO SHALL mostrar contadores ni avisos de presión sobre la oferta.

#### Scenario: Abrir la app
- **WHEN** el usuario abre la app, con o sin suscripción
- **THEN** se muestra el selector de moods y no aparece la pantalla de suscripción

#### Scenario: Guardar un mood base
- **WHEN** el usuario guarda un Mood base
- **THEN** la app va al calendario como siempre, sin ofrecer la suscripción

#### Scenario: Tocar un mood bloqueado
- **WHEN** el usuario toca el Mood premium bloqueado ya seleccionado
- **THEN** se abre la pantalla de suscripción como hoja

### Requirement: Privacidad de la suscripción
La suscripción NO SHALL añadir recolección de datos: RevenueCat, Apple y Google ya reciben el identificador anónimo de la instalación y el historial de compras, y nada de las entradas (mood, nota, fecha, intensidad) SHALL salir del dispositivo.

#### Scenario: Compra de un plan
- **WHEN** el usuario se suscribe
- **THEN** ningún dato de sus Mood Entry se envía a la tienda, a RevenueCat ni a las analíticas
