## Purpose

Permite proteger el texto de las notas con la autenticación del dispositivo (biometría o código), para que quien tenga el teléfono desbloqueado no lea las notas sin una verificación adicional. Es una función Premium.

## ADDED Requirements

### Requirement: Activar el bloqueo de notas requiere Premium y autenticarse
Settings > Privacy and data SHALL ofrecer un interruptor para bloquear las notas, apagado por defecto y marcado como Premium. Sin suscripción, tocarlo SHALL abrir la hoja de suscripción en lugar de activarlo. Con suscripción, activarlo SHALL pedir al sistema una autenticación (biometría o código del dispositivo) y solo SHALL quedar activo si la autenticación tiene éxito. Si el dispositivo no tiene ni biometría ni código configurados, el interruptor NO SHALL poder activarse y la app SHALL explicar que hay que configurar uno.

#### Scenario: Sin suscripción
- **WHEN** un usuario sin suscripción toca el interruptor del bloqueo
- **THEN** se abre la hoja de suscripción y el bloqueo sigue apagado

#### Scenario: Activar con éxito
- **WHEN** un suscriptor activa el bloqueo y se autentica
- **THEN** el bloqueo queda activo

#### Scenario: Autenticación cancelada
- **WHEN** un suscriptor activa el bloqueo y cancela o falla la autenticación
- **THEN** el bloqueo sigue apagado y no se muestra un error alarmante

#### Scenario: Dispositivo sin autenticación
- **WHEN** el dispositivo no tiene biometría ni código y el usuario intenta activar el bloqueo
- **THEN** el bloqueo no se activa y un mensaje explica que hay que configurar un código en el dispositivo

### Requirement: Con el bloqueo activo el texto de las notas solo se muestra desbloqueado
Con el bloqueo activo, la app NO SHALL mostrar el texto de ninguna nota guardada mientras la sesión esté bloqueada: ni en el estado "Saved" del Log, ni en el detalle de un día, ni en el editor de una nota existente. En su lugar SHALL mostrar un marcador "Note locked" con una acción para desbloquear, de modo que el usuario sepa que hay una nota sin ver su contenido. El mood, la categoría, la fecha, la hora de registro y las rachas NO SHALL ocultarse. Abrir el editor de una nota existente SHALL pedir la autenticación antes de mostrar el texto. Escribir una nota nueva, sin texto previo, NO SHALL pedirla.

#### Scenario: Estado Saved bloqueado
- **WHEN** el bloqueo está activo, la sesión está bloqueada y el usuario ve el Log de un día con nota
- **THEN** la tarjeta muestra el mood y "Note locked" en lugar del texto

#### Scenario: Detalle del día bloqueado
- **WHEN** el bloqueo está activo y el usuario abre el detalle de un día con nota sin haberse autenticado
- **THEN** ve el mood, la categoría y la hora, y "Note locked" en lugar de la nota

#### Scenario: Desbloquear
- **WHEN** el usuario toca la acción de desbloquear y se autentica
- **THEN** el texto de las notas se muestra

#### Scenario: Editar una nota existente
- **WHEN** el usuario abre el editor de una nota existente con la sesión bloqueada
- **THEN** la app pide la autenticación y solo al lograrla muestra el texto en el editor

#### Scenario: Escribir una nota nueva
- **WHEN** el usuario abre el editor en una entrada sin nota
- **THEN** el editor se abre sin pedir autenticación

#### Scenario: Bloqueo apagado
- **WHEN** el bloqueo está apagado
- **THEN** las notas se muestran siempre y la app nunca pide autenticación por ellas

### Requirement: La sesión desbloqueada dura mientras la app está en primer plano
Una vez autenticado, el usuario SHALL ver las notas sin repetir la autenticación mientras la app permanezca en primer plano. Al enviarla a segundo plano, la sesión SHALL volver a quedar bloqueada. La app NO SHALL pedir autenticación al abrirse por sí sola: solo cuando el usuario toca desbloquear o abre algo que necesita el texto. Una autenticación cancelada o fallida SHALL dejar la sesión bloqueada sin repetir el diálogo en bucle.

#### Scenario: Seguir viendo
- **WHEN** el usuario se autentica y navega entre pestañas con la app en primer plano
- **THEN** las notas siguen visibles sin nuevas autenticaciones

#### Scenario: Volver a bloquear
- **WHEN** el usuario se autentica, envía la app a segundo plano y la reabre
- **THEN** las notas vuelven a mostrarse bloqueadas

#### Scenario: Abrir la app
- **WHEN** el usuario abre la app con el bloqueo activo
- **THEN** no aparece ningún diálogo de autenticación hasta que toca desbloquear o abre algo que lo necesita

#### Scenario: Autenticación fallida
- **WHEN** el usuario cancela el diálogo de autenticación
- **THEN** la sesión sigue bloqueada y el diálogo no vuelve a abrirse por sí solo

### Requirement: Si vence la suscripción el usuario no pierde el acceso a sus notas
Un bloqueo ya activo SHALL seguir aplicándose aunque la suscripción haya vencido, y el usuario SHALL poder desbloquear y leer sus notas con la autenticación del dispositivo. Apagar el bloqueo SHALL requerir autenticarse y NO SHALL requerir suscripción. Volver a encenderlo SHALL requerir Premium.

#### Scenario: Suscripción vencida con el bloqueo activo
- **WHEN** la suscripción vence con el bloqueo activo
- **THEN** las notas siguen bloqueadas hasta autenticarse y el usuario puede desbloquearlas

#### Scenario: Apagar el bloqueo
- **WHEN** el usuario apaga el bloqueo y se autentica
- **THEN** el bloqueo queda apagado y las notas se muestran siempre

#### Scenario: Apagar sin autenticarse
- **WHEN** el usuario apaga el bloqueo y cancela la autenticación
- **THEN** el bloqueo sigue activo

#### Scenario: Reactivar sin suscripción
- **WHEN** un usuario sin suscripción toca el interruptor apagado
- **THEN** se abre la hoja de suscripción

### Requirement: El bloqueo no deja las notas inaccesibles
Si con el bloqueo activo el dispositivo deja de tener biometría y código configurados, la app NO SHALL poder pedir una autenticación y SHALL mostrar las notas en vez de dejarlas inaccesibles; Settings SHALL explicar que el bloqueo no se puede aplicar hasta configurar un código. Al volver a haber autenticación disponible, el bloqueo SHALL aplicarse de nuevo.

#### Scenario: Se elimina el código del dispositivo
- **WHEN** el bloqueo está activo y el usuario quita el código del dispositivo
- **THEN** las notas se muestran y Settings indica que el bloqueo requiere un código

#### Scenario: Se vuelve a configurar
- **WHEN** el usuario configura de nuevo un código en el dispositivo
- **THEN** las notas vuelven a mostrarse bloqueadas hasta autenticarse

### Requirement: Privacidad y honestidad del bloqueo
La autenticación SHALL ocurrir en el sistema operativo y la app solo SHALL conocer si tuvo éxito: no SHALL leer, guardar ni enviar datos biométricos. Los textos de la app NO SHALL decir que las notas están cifradas, porque el bloqueo es una barrera de la interfaz y el texto sigue guardado en el dispositivo. Los eventos de analíticas del bloqueo NO SHALL llevar datos de las notas ni de las entradas.

#### Scenario: Datos biométricos
- **WHEN** el usuario se autentica con su rostro o huella
- **THEN** la app solo recibe si la verificación tuvo éxito

#### Scenario: Texto sobre el bloqueo
- **WHEN** el usuario lee el texto del interruptor o de la hoja de suscripción
- **THEN** ningún texto afirma que las notas están cifradas

### Requirement: Textos localizados y accesibles del bloqueo
Todos los textos del bloqueo (interruptor, detalle, marcador "Note locked", acción de desbloquear y mensajes) SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo, y el motivo del diálogo del sistema también. Todo control SHALL exponer una etiqueta de `Semantics`, y el marcador "Note locked" SHALL anunciarse como una acción de desbloquear.

#### Scenario: Dispositivo en francés
- **WHEN** el idioma del dispositivo es francés
- **THEN** el interruptor, el marcador y el motivo del diálogo se muestran en francés

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla llega a una nota bloqueada
- **THEN** la anuncia como una acción para desbloquear la nota
