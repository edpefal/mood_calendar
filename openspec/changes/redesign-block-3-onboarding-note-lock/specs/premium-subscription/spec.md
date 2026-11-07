## MODIFIED Requirements

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
