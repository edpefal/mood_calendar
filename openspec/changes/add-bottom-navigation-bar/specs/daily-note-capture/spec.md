## ADDED Requirements

### Requirement: El editor de nota cubre el bottom bar
Mientras el bottom sheet de edición de la nota esté abierto, el bottom bar SHALL quedar cubierto por el sheet y no recibir toques, y SHALL volver a estar disponible al cerrarse el sheet.

#### Scenario: Abrir el editor
- **WHEN** el usuario toca el preview de nota
- **THEN** el bottom sheet se abre y el bottom bar queda cubierto por el sheet

#### Scenario: Cerrar el editor
- **WHEN** el usuario cierra el bottom sheet
- **THEN** el bottom bar vuelve a estar disponible
