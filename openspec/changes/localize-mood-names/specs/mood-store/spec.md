## ADDED Requirements

### Requirement: Nombres de Mood localizados en la tienda
La tienda y las hojas de compra SHALL mostrar los nombres de los Moods premium (incluidos los de la lista de Moods de un Pack) en el idioma activo del dispositivo, con fallback a inglés. El título de un Pack, que proviene del producto de la tienda, no está cubierto por este requisito.

#### Scenario: Tienda en alemán
- **WHEN** el dispositivo está en alemán y se abre la tienda
- **THEN** las filas de moods premium muestran sus nombres en alemán (por ejemplo "Mutig" para `brave`)

#### Scenario: Hoja de compra de Pack
- **WHEN** se abre la hoja de un Pack en francés
- **THEN** la lista de Moods incluidos muestra los nombres en francés
