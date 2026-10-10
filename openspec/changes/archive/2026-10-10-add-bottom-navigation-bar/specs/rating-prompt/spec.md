## MODIFIED Requirements

### Requirement: El pedido nunca interrumpe ni sigue a una falla
La app NO SHALL solicitar el diálogo de calificación si el guardado de la Mood Entry falló, ni mientras el editor de nota esté abierto. Cuando corresponda solicitarlo, la app SHALL hacerlo una vez que el usuario haya llegado a la pestaña del calendario tras guardar.

#### Scenario: Falla el guardado
- **WHEN** el guardado de la Mood Entry falla aunque el total de entradas alcance un hito
- **THEN** la app no solicita el diálogo de calificación ni registra un intento

#### Scenario: Editor de nota abierto
- **WHEN** el editor de nota está abierto
- **THEN** la app no solicita el diálogo de calificación

#### Scenario: Guardado exitoso que cumple el hito
- **WHEN** el usuario guarda con éxito una Mood Entry que cumple las condiciones de un intento y la app cambia a la pestaña del calendario
- **THEN** el diálogo de calificación se solicita en el calendario, no sobre otra pantalla ni sobre el editor de nota
