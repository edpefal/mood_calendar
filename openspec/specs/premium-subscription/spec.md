# premium-subscription Specification

## Purpose
Define la suscripción que desbloquea los moods premium: sus tres planes, el precio y la prueba gratis que vienen de la tienda del sistema, la compra, el estado de quien está suscrito y la convivencia con las compras sueltas heredadas.
## Requirements
### Requirement: Tres planes de suscripción que desbloquean todos los moods premium
La app SHALL ofrecer una suscripción con tres planes: semanal, mensual y anual. Mientras la suscripción esté activa, todos los Moods premium del catálogo SHALL estar `unlocked`, incluidos los que se añadan después. La app NO SHALL ofrecer compras sueltas de Moods ni Packs. Los precios SHALL ser los que devuelve la tienda del sistema en la moneda del usuario; la app NO SHALL fijar ningún precio en su código ni en sus textos.

#### Scenario: Suscripción activa
- **WHEN** el usuario tiene una suscripción activa de cualquiera de los tres planes
- **THEN** los 8 Moods premium del catálogo están `unlocked`

#### Scenario: Moods premium nuevos
- **WHEN** una versión posterior añade un Mood premium al catálogo
- **THEN** un usuario con suscripción activa lo tiene `unlocked` sin comprar nada más

#### Scenario: Sin compras sueltas
- **WHEN** el usuario toca un Mood bloqueado o abre la oferta desde Ajustes
- **THEN** solo ve los planes de suscripción, sin precios por Mood ni Packs

#### Scenario: Precio en la moneda del usuario
- **WHEN** el usuario abre la hoja de suscripción con la tienda de un país distinto de Estados Unidos
- **THEN** cada plan muestra el precio que devuelve la tienda para ese país

### Requirement: Presentación de los planes
La oferta SHALL mostrarse como una hoja inferior que cubre el bottom bar. Arriba SHALL llevar el título "Understand how you feel" y tres beneficios con ícono: (1) Insights y Year in Pixels, con tendencias de 90 y 365 días; (2) notas protegidas con biometría; (3) moods expresivos (Laughing, Confident, Brave y más). Cuando se abre al tocar un Mood bloqueado, SHALL mostrar además una cápsula con ese Mood y su nombre como contexto. Debajo SHALL mostrar los tres planes como tarjetas, con el anual preseleccionado y marcado con la etiqueta "Mejor valor". El ahorro del plan anual SHALL calcularse a partir de los precios que devuelve la tienda. El precio que se cobra en cada ciclo SHALL ser el dato más prominente de la tarjeta; un precio equivalente por mes, si se muestra, SHALL ser secundario. La hoja SHALL tener un botón de cerrar con etiqueta de accesibilidad. La hoja NO SHALL mencionar el respaldo en la nube, widgets ni temas.

#### Scenario: Plan anual preseleccionado
- **WHEN** el usuario abre la hoja sin suscripción activa
- **THEN** el plan anual aparece seleccionado y con la etiqueta "Mejor valor"

#### Scenario: Cambiar de plan
- **WHEN** el usuario toca la tarjeta del plan mensual
- **THEN** el plan mensual queda seleccionado y el botón principal se refiere a ese plan

#### Scenario: Ahorro calculado
- **WHEN** la tienda devuelve precios distintos a los previstos
- **THEN** el ahorro mostrado se recalcula con esos precios y nunca usa un porcentaje fijo

#### Scenario: Contexto del Mood bloqueado
- **WHEN** el usuario abre la hoja tocando `brave`
- **THEN** la hoja muestra una cápsula con `brave` y su nombre en el idioma del dispositivo

#### Scenario: Abierta desde Ajustes
- **WHEN** el usuario abre la hoja desde la fila Premium de Ajustes
- **THEN** no aparece la cápsula de contexto y el resto es igual

#### Scenario: Tres beneficios
- **WHEN** el usuario abre la hoja
- **THEN** ve exactamente los tres beneficios y ninguno menciona respaldo, widgets ni temas

#### Scenario: Cerrar la hoja
- **WHEN** el usuario toca cerrar
- **THEN** la hoja se cierra y el Log conserva su selección, fecha y nota

### Requirement: Prueba gratis de 3 días según elegibilidad
Solo el plan anual SHALL ofrecer una prueba gratis de 3 días. El botón principal SHALL decir "Probar 3 días gratis" únicamente cuando el plan anual está seleccionado y la tienda confirma que el usuario es elegible para la prueba; la tarjeta del anual SHALL mostrar entonces la etiqueta "3 días gratis". Con el plan mensual o el semanal, o si el usuario ya usó la prueba, o si la elegibilidad no se puede comprobar, el botón SHALL decir "Suscribirme" junto con el precio y la hoja NO SHALL mencionar la prueba. Con la prueba mostrada, una línea de tiempo SHALL indicar "Hoy · Acceso completo a Premium" y la fecha del primer cobro con su precio; NO SHALL prometer ningún recordatorio de fin de prueba.

#### Scenario: Anual elegible
- **WHEN** el plan anual está seleccionado y la tienda confirma que el usuario no ha usado la prueba
- **THEN** el botón principal dice "Probar 3 días gratis", la tarjeta muestra "3 días gratis" y la línea de tiempo indica hoy y la fecha del primer cobro

#### Scenario: Mensual seleccionado
- **WHEN** el usuario selecciona el plan mensual
- **THEN** el botón dice "Suscribirme" con el precio y no hay mención de prueba

#### Scenario: Prueba ya usada
- **WHEN** el usuario ya usó la prueba
- **THEN** el botón principal dice "Suscribirme", muestra el precio y ningún texto menciona una prueba gratis

#### Scenario: No se puede comprobar la elegibilidad
- **WHEN** la comprobación de elegibilidad falla
- **THEN** la hoja se comporta como si el usuario no fuera elegible

#### Scenario: Sin promesa de recordatorio
- **WHEN** la línea de tiempo de la prueba se muestra
- **THEN** no hay ninguna línea que diga que la app avisará antes de que termine

### Requirement: Texto legal y enlaces en la pantalla
La hoja de suscripción SHALL mostrar el nombre del plan elegido, su duración, el precio, que la suscripción se renueva automáticamente salvo que se cancele y cómo cancelarla, y SHALL incluir enlaces a los Términos y a la Política de Privacidad del sitio, y la acción "Restaurar compras". Los textos SHALL estar en el idioma del dispositivo, con fallback a inglés.

#### Scenario: Información de renovación
- **WHEN** el usuario tiene un plan seleccionado sin suscripción activa
- **THEN** la hoja indica el precio, la duración, la renovación automática y que se cancela desde los ajustes de suscripciones de la tienda

#### Scenario: Enlaces legales
- **WHEN** el usuario toca el enlace de Términos o el de Privacidad
- **THEN** se abre la página correspondiente del sitio en el idioma del dispositivo

#### Scenario: Restaurar desde la hoja
- **WHEN** el usuario toca "Restaurar compras" en la hoja
- **THEN** se ejecuta la restauración descrita en `mood-store`

### Requirement: Compra de un plan
El usuario SHALL poder suscribirse a un plan desde la hoja de suscripción. Al completarse la compra, los Moods premium SHALL pasar a `unlocked` de inmediato, la hoja SHALL cerrarse y el Log SHALL conservar su fecha, selección y nota.

#### Scenario: Compra exitosa
- **WHEN** el usuario completa la compra de un plan
- **THEN** todos los Moods premium quedan `unlocked` de inmediato, la hoja se cierra y los Moods aparecen sin candado en el Log

#### Scenario: Compra cancelada o fallida
- **WHEN** el usuario cancela la compra o esta falla
- **THEN** los Moods siguen sin `unlocked`, no se cobra nada y la hoja permite intentarlo de nuevo

#### Scenario: Sin conexión al comprar
- **WHEN** la compra falla por falta de conexión
- **THEN** la app muestra un mensaje de conexión y no cambia el estado de ningún Mood

### Requirement: Estado de quien está suscrito
Con una suscripción activa, la fila Premium de Ajustes SHALL decir "Premium · Active" y mostrar como detalle el plan actual y la fecha de renovación (o la de fin de la prueba si está en prueba). Tocarla SHALL abrir los ajustes de suscripciones del sistema. La app NO SHALL mostrar la hoja de suscripción ni Moods bloqueados a un usuario con suscripción activa, y "Restaurar compras" SHALL seguir disponible en Ajustes. La app NO SHALL cancelar la suscripción por sí misma.

#### Scenario: Suscrito
- **WHEN** el usuario tiene una suscripción mensual activa y abre Ajustes
- **THEN** la fila Premium dice "Premium · Active", muestra el plan mensual y la fecha en que se renueva

#### Scenario: En prueba
- **WHEN** el usuario está dentro de la prueba de 3 días
- **THEN** la fila indica que está en prueba y la fecha en que termina

#### Scenario: Gestionar
- **WHEN** el usuario suscrito toca la fila Premium
- **THEN** se abren los ajustes de suscripciones del sistema

#### Scenario: Sin hoja para suscriptores
- **WHEN** el usuario tiene una suscripción activa
- **THEN** ningún Mood aparece bloqueado y no hay forma de abrir la hoja de suscripción

### Requirement: Vencimiento de la suscripción
Cuando la suscripción deja de estar activa (cancelación que llega a su fin, falta de pago o reembolso), los Moods premium SHALL volver a estar bloqueados salvo los desbloqueados por una compra heredada. La app NO SHALL ocultar ni modificar las Mood Entry ya guardadas, y NO SHALL mostrar avisos ni la hoja de suscripción por iniciativa propia. La fila Premium de Ajustes SHALL volver a ofrecer "Get Premium".

#### Scenario: Suscripción vencida
- **WHEN** la suscripción vence
- **THEN** los Moods premium aparecen bloqueados en el Log, las Mood Entry con esos Moods siguen visibles en el calendario y no aparece ningún aviso

#### Scenario: Reanudar
- **WHEN** el usuario con la suscripción vencida abre Ajustes
- **THEN** la fila Premium vuelve a ofrecer "Get Premium"

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
La hoja de suscripción SHALL mostrarse únicamente cuando el usuario la pide: al tocar un Mood premium bloqueado, al tocar "Get Premium" en Ajustes, al tocar el interruptor del bloqueo de notas sin suscripción, al tocar una tarjeta o un rango bloqueado de Insights ("Ver con Premium") o, **una sola vez**, al terminar el onboarding. La app NO SHALL mostrarla al abrirse, después de guardar un Mood fuera del onboarding ni interrumpiendo el registro diario, NO SHALL mostrarla a un suscriptor y NO SHALL mostrar contadores ni avisos de presión sobre la oferta.

#### Scenario: Abrir la app
- **WHEN** el usuario abre la app, con o sin suscripción, habiendo terminado el onboarding
- **THEN** se muestra el Log y no aparece la hoja de suscripción

#### Scenario: Guardar un mood base
- **WHEN** el usuario guarda un Mood base desde el Log
- **THEN** el Log muestra el estado "Saved" sin ofrecer la suscripción

#### Scenario: Tocar un mood bloqueado
- **WHEN** el usuario toca un Mood premium bloqueado
- **THEN** se abre la hoja de suscripción

#### Scenario: Fila de Ajustes
- **WHEN** el usuario sin suscripción toca "Get Premium" en Ajustes
- **THEN** se abre la hoja de suscripción

#### Scenario: Interruptor del bloqueo de notas
- **WHEN** el usuario sin suscripción toca el interruptor del bloqueo de notas en Ajustes
- **THEN** se abre la hoja de suscripción

#### Scenario: Tarjeta bloqueada de Insights
- **WHEN** el usuario sin suscripción toca "Ver con Premium" en una tarjeta de Insights
- **THEN** se abre la hoja de suscripción

#### Scenario: Abrir Insights sin suscripción
- **WHEN** el usuario sin suscripción abre la pestaña Insights
- **THEN** no se abre la hoja de suscripción por sí sola

#### Scenario: Suscriptor en Insights
- **WHEN** un suscriptor abre Insights
- **THEN** no ve candados ni acciones de suscripción

#### Scenario: Fin del onboarding
- **WHEN** un usuario sin suscripción toca "Continue" en la confirmación del primer registro del onboarding
- **THEN** se abre la hoja de suscripción una sola vez y, al cerrarla, el usuario queda en el Log

#### Scenario: Suscriptor al terminar el onboarding
- **WHEN** un suscriptor termina el onboarding
- **THEN** la hoja de suscripción no se abre

#### Scenario: Omitir el onboarding
- **WHEN** el usuario omite el onboarding en el paso 1
- **THEN** la hoja de suscripción no se abre

### Requirement: Privacidad de la suscripción
La suscripción NO SHALL añadir recolección de datos: RevenueCat, Apple y Google ya reciben el identificador anónimo de la instalación y el historial de compras, y nada de las entradas (mood, nota, fecha, intensidad) SHALL salir del dispositivo.

#### Scenario: Compra de un plan
- **WHEN** el usuario se suscribe
- **THEN** ningún dato de sus Mood Entry se envía a la tienda, a RevenueCat ni a las analíticas

