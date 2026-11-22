## ADDED Requirements

### Requirement: Disponibilidad del pedido automático por plataforma
La app SHALL solicitar automáticamente el diálogo nativo de calificación en iOS y en Android, con la misma política de hitos, intervalo y límite de intentos en las dos plataformas. En cualquier otra plataforma la app NO SHALL solicitarlo ni registrar intentos.

#### Scenario: Android con los hitos cumplidos
- **WHEN** la app corre en Android, el usuario guarda con éxito una Mood Entry y el total de días con entrada pasa a ser 3, sin intentos previos
- **THEN** la app solicita el diálogo nativo de calificación de Google Play y registra el intento

#### Scenario: iOS con los hitos cumplidos
- **WHEN** la app corre en iOS, el usuario guarda con éxito una Mood Entry y el total de días con entrada pasa a ser 3, sin intentos previos
- **THEN** la app solicita el diálogo nativo de calificación del sistema y registra el intento

#### Scenario: Plataforma sin tienda soportada
- **WHEN** la app corre en una plataforma distinta de iOS y de Android y el usuario guarda con éxito una Mood Entry que cumpliría un hito
- **THEN** la app no solicita el diálogo de calificación ni registra un intento

## MODIFIED Requirements

### Requirement: Pedido automático de calificación por hitos de entradas
La app SHALL solicitar el diálogo nativo de calificación del sistema tras un guardado exitoso de una Mood Entry, en función de la cantidad total de días con una Mood Entry guardada:
- Primer intento: cuando el total sea 3 o más y no exista ningún intento previo.
- Segundo intento: cuando el total sea 7 o más, exista exactamente un intento previo y hayan pasado al menos 30 días desde ese intento.

La app NO SHALL hacer más de 2 intentos automáticos en toda la vida de la instalación. La app solicita el diálogo; la decisión de mostrarlo corresponde al sistema (iOS o Google Play), que puede limitarlo.

#### Scenario: Se alcanza el tercer día registrado
- **WHEN** el usuario guarda con éxito una Mood Entry y el total de días con entrada pasa a ser 3, sin intentos previos
- **THEN** la app solicita el diálogo nativo de calificación y registra el intento

#### Scenario: Aún no hay suficientes entradas
- **WHEN** el usuario guarda con éxito una Mood Entry y el total de días con entrada es menor que 3
- **THEN** la app no solicita el diálogo de calificación

#### Scenario: Segundo intento tras pasar el hito y el intervalo mínimo
- **WHEN** el usuario guarda con éxito una Mood Entry, el total es 7 o más, existe un intento previo y pasaron al menos 30 días desde él
- **THEN** la app solicita el diálogo nativo de calificación y registra el segundo intento

#### Scenario: Segundo intento dentro del intervalo mínimo
- **WHEN** el usuario guarda con éxito una Mood Entry, el total es 7 o más, existe un intento previo y pasaron menos de 30 días desde él
- **THEN** la app no solicita el diálogo de calificación

#### Scenario: Ya se hicieron los dos intentos
- **WHEN** el usuario guarda con éxito una Mood Entry y ya existen 2 intentos automáticos registrados
- **THEN** la app no solicita el diálogo de calificación, sin importar el total de entradas

#### Scenario: Editar la entrada de un día ya registrado
- **WHEN** el usuario guarda con éxito una Mood Entry de una fecha que ya tenía entrada (el total no aumenta), el total es 3 y el primer intento ya se hizo
- **THEN** la app no solicita el diálogo de calificación

### Requirement: Entrada manual para calificar la app
La pantalla de Settings SHALL incluir una fila "Calificar Mood Calendar" que abre la página de reseñas de la app en la tienda de la plataforma (App Store en iOS, Google Play en Android). Esta acción SHALL estar disponible siempre, sin depender de los intentos automáticos, y NO SHALL contar como un intento automático

#### Scenario: Usuario toca la fila de calificar
- **WHEN** el usuario toca "Calificar Mood Calendar" en Settings
- **THEN** se abre la página de reseñas de la app en la tienda de su plataforma

#### Scenario: El uso manual no consume intentos
- **WHEN** el usuario usa la fila manual de calificar, con 0, 1 o 2 intentos automáticos previos
- **THEN** la cantidad de intentos automáticos registrada no cambia
