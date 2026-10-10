## ADDED Requirements

### Requirement: La Tienda es una pestaña del bottom bar
La Tienda SHALL abrirse desde la tercera pestaña del bottom bar, con un icono de tienda. La pantalla principal NO SHALL mostrar un icono de tienda en su header, y la Tienda NO SHALL mostrar un botón de regresar. Las hojas de compra de Moods y de Packs SHALL cubrir el bottom bar mientras estén abiertas.

#### Scenario: Abrir la Tienda
- **WHEN** el usuario toca la pestaña de tienda
- **THEN** se muestra la pantalla de Tienda con su catálogo

#### Scenario: Hoja de compra
- **WHEN** el usuario abre la hoja de compra de un Mood o de un Pack desde la Tienda
- **THEN** el bottom bar queda cubierto por la hoja hasta que se cierra
