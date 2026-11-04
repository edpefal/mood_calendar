## ADDED Requirements

### Requirement: El reloj se actualiza cuando una elección deja de ser válida
Cuando el iPhone descarta una elección del reloj porque su Mood ya no está `unlocked` (por ejemplo, porque la suscripción venció con la app cerrada), SHALL confirmar la elección como entregada, no modificar ninguna Mood Entry y publicar al reloj el estado actualizado, indicando que esa elección ya fue procesada. Al recibir un estado que indica que su elección pendiente ya fue procesada, el reloj SHALL quitar la marca de elección pendiente y mostrar solo los Moods del estado recibido. Un estado que no menciona la elección pendiente (por ejemplo, tras un cambio de idioma mientras la elección sigue en cola) NO SHALL quitar la marca. El reloj NO SHALL mostrar un error ni ofrecer una compra.

#### Scenario: Suscripción vencida con la app cerrada
- **WHEN** la suscripción venció con la app del iPhone cerrada, el reloj aún mostraba un Mood premium y el usuario lo eligió
- **THEN** al llegar la elección el iPhone no cambia la Mood Entry de hoy, confirma la elección y publica un estado sin los Moods premium

#### Scenario: El reloj quita la marca pendiente
- **WHEN** el reloj recibe el estado actualizado
- **THEN** la marca de elección pendiente desaparece y la lista solo muestra los Moods desbloqueados

#### Scenario: Estado que no menciona la elección
- **WHEN** el reloj tiene una elección en cola y recibe un estado nuevo que no la menciona
- **THEN** la marca de elección pendiente se conserva

#### Scenario: Elección válida no se afecta
- **WHEN** el reloj envía un Mood que sigue `unlocked`
- **THEN** la elección se aplica como siempre y el estado recibido de vuelta la refleja como el Mood de hoy
