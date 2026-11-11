## MODIFIED Requirements

### Requirement: El pedido nunca interrumpe ni sigue a una falla
La app NO SHALL solicitar el diálogo de calificación si el guardado de la Mood Entry falló, ni mientras el editor de nota o la hoja de suscripción estén abiertos. Cuando corresponda solicitarlo, la app SHALL hacerlo una vez que el Log muestre el estado "Saved" tras guardar.

#### Scenario: Falla el guardado
- **WHEN** el guardado de la Mood Entry falla aunque el total de entradas alcance un hito
- **THEN** la app no solicita el diálogo de calificación ni registra un intento

#### Scenario: Editor de nota abierto
- **WHEN** el editor de nota está abierto
- **THEN** la app no solicita el diálogo de calificación

#### Scenario: Guardado exitoso que cumple el hito
- **WHEN** el usuario guarda con éxito una Mood Entry que cumple las condiciones de un intento y el Log pasa al estado "Saved"
- **THEN** el diálogo de calificación se solicita sobre el Log en estado "Saved", no sobre otra pantalla ni sobre el editor de nota

#### Scenario: El usuario sale antes de ver el estado Saved
- **WHEN** el guardado fue exitoso pero el usuario cambia de pestaña antes de que el Log muestre "Saved"
- **THEN** la app no solicita el diálogo en esa pestaña y no registra el intento
