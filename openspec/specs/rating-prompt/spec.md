# rating-prompt Specification

## Purpose

Define cuándo y cómo la app le pide al usuario que califique Mood Calendar en el App Store: un pedido automático en momentos de éxito, con límites estrictos para no molestar, y una entrada manual siempre disponible.

## Requirements

### Requirement: Pedido automático de calificación por hitos de entradas
La app SHALL solicitar el diálogo nativo de calificación del sistema tras un guardado exitoso de una Mood Entry, en función de la cantidad total de días con una Mood Entry guardada:
- Primer intento: cuando el total sea 3 o más y no exista ningún intento previo.
- Segundo intento: cuando el total sea 7 o más, exista exactamente un intento previo y hayan pasado al menos 30 días desde ese intento.

La app NO SHALL hacer más de 2 intentos automáticos en toda la vida de la instalación. La app solicita el diálogo; la decisión de mostrarlo corresponde a iOS, que puede limitarlo.

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

### Requirement: El pedido nunca interrumpe ni sigue a una falla
La app NO SHALL solicitar el diálogo de calificación si el guardado de la Mood Entry falló, ni mientras el editor de nota esté abierto. Cuando corresponda solicitarlo, la app SHALL hacerlo una vez que el usuario haya vuelto a la vista del calendario tras guardar.

#### Scenario: Falla el guardado
- **WHEN** el guardado de la Mood Entry falla aunque el total de entradas alcance un hito
- **THEN** la app no solicita el diálogo de calificación ni registra un intento

#### Scenario: Editor de nota abierto
- **WHEN** el editor de nota está abierto
- **THEN** la app no solicita el diálogo de calificación

#### Scenario: Guardado exitoso que cumple el hito
- **WHEN** el usuario guarda con éxito una Mood Entry que cumple las condiciones de un intento y la app vuelve a mostrar el calendario
- **THEN** el diálogo de calificación se solicita en el calendario, no sobre otra pantalla ni sobre el editor de nota

### Requirement: El estado de los intentos persiste entre sesiones
La app SHALL conservar localmente la cantidad de intentos automáticos realizados y la fecha del último, de modo que sobrevivan al cierre y reapertura de la app.

#### Scenario: Reapertura tras el primer intento
- **WHEN** la app se cierra y se vuelve a abrir después de haber hecho el primer intento
- **THEN** el primer intento no se repite y el conteo de intentos sigue siendo 1

### Requirement: Entrada manual para calificar la app
La pantalla de Settings SHALL incluir una fila "Calificar Mood Calendar" que abre la página de reseñas de la app en el App Store. Esta acción SHALL estar disponible siempre, sin depender de los intentos automáticos, y NO SHALL contar como un intento automático ni modificar su estado.

#### Scenario: Usuario toca la fila de calificar
- **WHEN** el usuario toca "Calificar Mood Calendar" en Settings
- **THEN** se abre la página de reseñas de la app en el App Store

#### Scenario: El uso manual no consume intentos
- **WHEN** el usuario usa la fila manual de calificar, con 0, 1 o 2 intentos automáticos previos
- **THEN** la cantidad de intentos automáticos registrada no cambia

### Requirement: Textos localizados y accesibles
El texto de la fila manual SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano (con inglés como respaldo), y el control SHALL exponer una etiqueta de `Semantics`.

#### Scenario: Dispositivo en alemán
- **WHEN** el idioma del dispositivo es alemán y el usuario abre Settings
- **THEN** la fila de calificar se muestra con su texto en alemán

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla recorre Settings
- **THEN** la fila de calificar se anuncia con una etiqueta que describe su acción

### Requirement: Telemetría del pedido de calificación
La app SHALL registrar un evento de telemetría cuando solicita automáticamente el diálogo de calificación y otro cuando el usuario usa la entrada manual en Settings.

#### Scenario: Intento automático
- **WHEN** la app solicita automáticamente el diálogo de calificación
- **THEN** se registra el evento de intento automático

#### Scenario: Uso de la entrada manual
- **WHEN** el usuario toca la fila manual de calificar en Settings
- **THEN** se registra el evento de entrada manual
