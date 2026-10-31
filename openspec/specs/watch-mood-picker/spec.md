# watch-mood-picker Specification

## Purpose

Permite elegir desde un Apple Watch el mood de hoy con un toque, sincronizándolo con la app del iPhone, que sigue siendo la única fuente de los datos.

## Requirements

### Requirement: App de Apple Watch para elegir el mood de hoy
La app SHALL incluir una app de Apple Watch que, al abrirse, muestre los moods disponibles y permita registrar el mood de hoy con un toque. La app del iPhone SHALL seguir funcionando igual cuando no hay un reloj emparejado, sin pantallas ni ajustes nuevos.

#### Scenario: Elegir un mood desde el reloj
- **WHEN** el usuario abre la app del reloj y toca un mood
- **THEN** el reloj confirma la elección de inmediato y el mood de hoy queda registrado en el iPhone

#### Scenario: Sin reloj emparejado
- **WHEN** el usuario no tiene un Apple Watch emparejado
- **THEN** la app del iPhone no muestra ninguna opción ni mensaje relacionado con el reloj

### Requirement: Moods ofrecidos en el reloj
El reloj SHALL ofrecer únicamente los moods que el usuario tiene desbloqueados en ese momento (los moods base y los premium comprados), en el mismo orden de uso que el selector del iPhone. El reloj NO SHALL ofrecer compras, mostrar moods bloqueados ni precios. Cuando el catálogo de moods desbloqueados cambia en el iPhone (por una compra o una restauración), el reloj SHALL actualizar su lista sin intervención del usuario.

#### Scenario: Solo moods desbloqueados
- **WHEN** el usuario tiene desbloqueados los 5 moods base y el mood premium `anxious`
- **THEN** el reloj ofrece esos 6 moods y ningún otro

#### Scenario: Orden de uso
- **WHEN** el selector del iPhone ordena los moods desbloqueados por frecuencia de uso
- **THEN** el reloj los muestra en ese mismo orden

#### Scenario: Compra en el iPhone
- **WHEN** el usuario compra un mood premium en el iPhone
- **THEN** el reloj incluye ese mood la próxima vez que reciba el estado, sin que el usuario haga nada en el reloj

#### Scenario: Sin compras en el reloj
- **WHEN** el usuario usa cualquier pantalla del reloj
- **THEN** no existe ninguna acción de compra, restauración ni enlace a la tienda

### Requirement: Solo se registra el día de hoy
Una elección hecha en el reloj SHALL guardarse como la Mood Entry de la fecha local de hoy. Si ese día ya tenía una Mood Entry, la app SHALL reemplazar el mood y SHALL conservar la nota existente. El reloj NO SHALL permitir elegir otro día ni escribir o editar notas.

#### Scenario: Primer registro del día
- **WHEN** hoy no tiene Mood Entry y el usuario elige `calm` en el reloj
- **THEN** se crea la Mood Entry de hoy con el mood `calm` y sin nota

#### Scenario: Cambiar el mood conservando la nota
- **WHEN** hoy ya tiene una Mood Entry con el mood `happy` y la nota "buen día", y el usuario elige `sad` en el reloj
- **THEN** la Mood Entry de hoy queda con el mood `sad` y la nota "buen día"

#### Scenario: Fecha local
- **WHEN** el usuario elige un mood en el reloj a las 23:50 hora local
- **THEN** la elección se guarda en la fecha local de ese día y no en el siguiente día UTC

### Requirement: Contrato de la elección enviada por el reloj
La elección enviada por el reloj SHALL contener únicamente la fecha local (`YYYY-MM-DD`) y el id estable del mood (por ejemplo `calm`). NO SHALL incluir `intensity`, rutas de assets ni notas. Si el id recibido no corresponde a un mood conocido o desbloqueado, la app del iPhone SHALL ignorar la elección sin modificar ningún dato y sin mostrar un error al usuario.

#### Scenario: Elección válida
- **WHEN** el iPhone recibe `{ "date": "2026-11-02", "mood": "calm" }`
- **THEN** guarda `calm` como mood de ese día

#### Scenario: Mood desconocido
- **WHEN** el iPhone recibe un id de mood que no existe
- **THEN** ignora la elección, no modifica ninguna Mood Entry y no muestra errores

#### Scenario: Mood bloqueado
- **WHEN** el iPhone recibe un id de un mood premium que el usuario no tiene desbloqueado
- **THEN** ignora la elección y no modifica ninguna Mood Entry

### Requirement: El iPhone es la única fuente de verdad
El historial de Mood Entries SHALL vivir solo en el iPhone. El reloj SHALL conservar únicamente el último estado recibido (moods ofrecidos, sus nombres y el mood de hoy) y las elecciones pendientes de entregar, y NO SHALL mantener un historial propio.

#### Scenario: Reinstalar la app de reloj
- **WHEN** el usuario desinstala y vuelve a instalar la app del reloj
- **THEN** no se pierde ninguna Mood Entry y el reloj recupera el estado en cuanto el iPhone lo publica

### Requirement: Entrega diferida y orden de las elecciones
Si el iPhone no está disponible cuando el usuario elige un mood en el reloj, la elección SHALL quedar en cola y SHALL entregarse cuando el iPhone vuelva a estar al alcance, sin perderse. El iPhone SHALL aplicar las elecciones recibidas la próxima vez que se abra o reanude la app, o de inmediato si ya está en primer plano. Cuando haya varias elecciones para la misma fecha, SHALL prevalecer la última según el momento en que se hizo en el reloj.

#### Scenario: Elección sin el iPhone cerca
- **WHEN** el usuario elige `calm` con el iPhone fuera de alcance y después el iPhone vuelve a estar disponible
- **THEN** la elección llega y se aplica sin que el usuario la repita

#### Scenario: App del iPhone cerrada
- **WHEN** el iPhone recibe una elección con la app cerrada y luego el usuario abre la app
- **THEN** la app aplica la elección al abrirse y el calendario muestra el mood elegido

#### Scenario: Varias elecciones del mismo día
- **WHEN** el usuario elige `happy` y luego `sad` en el reloj para el mismo día antes de que lleguen al iPhone
- **THEN** la Mood Entry de ese día queda con `sad`

#### Scenario: App en primer plano
- **WHEN** el iPhone recibe una elección con la app abierta en el calendario
- **THEN** el calendario refleja el mood nuevo sin que el usuario cambie de pantalla

### Requirement: Nombres localizados
Los nombres de los moods en el reloj SHALL mostrarse en el idioma de la app del iPhone (inglés, español, alemán, francés o italiano, con inglés como respaldo). El reloj SHALL conservar el último juego de nombres recibido para usarlo aunque el iPhone no esté disponible.

#### Scenario: Idioma del dispositivo
- **WHEN** el iPhone está en español
- **THEN** el reloj muestra "Feliz" para el mood `happy`

#### Scenario: Sin conexión con el iPhone
- **WHEN** el iPhone no está disponible y el reloj ya había recibido el estado antes
- **THEN** el reloj sigue mostrando los moods con sus nombres

### Requirement: Estado del reloj mientras se sincroniza
El reloj SHALL resaltar el mood de hoy. Mientras una elección no haya llegado al iPhone, el reloj SHALL indicar que está pendiente de sincronizar y SHALL quitar esa indicación cuando el iPhone confirme el mood de hoy. Si el reloj aún no recibió ningún estado del iPhone, SHALL mostrar un mensaje que pida abrir Mood Calendar en el iPhone y NO SHALL ofrecer moods.

#### Scenario: Elección pendiente
- **WHEN** el usuario elige un mood y el iPhone aún no lo confirmó
- **THEN** el reloj muestra el mood elegido como el de hoy con la indicación de pendiente

#### Scenario: Confirmación del iPhone
- **WHEN** el iPhone publica que el mood de hoy es el que el usuario eligió
- **THEN** el reloj quita la indicación de pendiente

#### Scenario: Primera vez sin estado
- **WHEN** el usuario abre la app del reloj antes de que el iPhone publique el estado por primera vez
- **THEN** el reloj muestra el mensaje de abrir Mood Calendar en el iPhone y ningún mood

### Requirement: Privacidad del reloj
La sincronización SHALL ocurrir solo entre el iPhone y el reloj emparejado del usuario. La app del reloj NO SHALL usar la red, NO SHALL enviar datos a servicios de terceros ni incluir analíticas o reporte de fallos, y NO SHALL usar el identificador de publicidad. Elegir un mood desde el reloj NO SHALL cambiar qué datos recoge la app respecto a hacerlo en el iPhone.

#### Scenario: Sin tráfico propio del reloj
- **WHEN** el usuario usa la app del reloj
- **THEN** el reloj no realiza peticiones de red propias ni envía datos a terceros

### Requirement: Efectos sobre otras funciones de la app
Registrar un mood desde el reloj NO SHALL disparar el pedido automático de calificación ni contarse como un intento de ese pedido. La elección SHALL ser visible como cualquier otra Mood Entry en el calendario, el resumen mensual, la racha y la exportación del historial.

#### Scenario: Sin pedido de calificación
- **WHEN** una elección del reloj completa el tercer día con entradas
- **THEN** la app no muestra el pedido de calificación por esa elección

#### Scenario: Visible en el resumen
- **WHEN** el usuario registra hoy desde el reloj
- **THEN** el calendario, el mood más frecuente, la racha y la exportación incluyen esa entrada
