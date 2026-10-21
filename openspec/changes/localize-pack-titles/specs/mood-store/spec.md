## MODIFIED Requirements

### Requirement: Nombres de Mood localizados en la tienda
La tienda y las hojas de compra SHALL mostrar los nombres de los Moods premium (incluidos los de la lista de Moods de un Pack) y los títulos de los Packs en el idioma activo del dispositivo, con fallback a inglés. Los títulos de los Packs SHALL salir de las cadenas de la app, no del título del producto de la tienda. Solo para un Pack cuyo identificador no tenga cadena propia, el sistema SHALL mostrar el título del producto de la tienda.

#### Scenario: Tienda en alemán
- **WHEN** el dispositivo está en alemán y se abre la tienda
- **THEN** las filas de moods premium muestran sus nombres en alemán (por ejemplo "Mutig" para `brave`)

#### Scenario: Hoja de compra de Pack
- **WHEN** se abre la hoja de un Pack en francés
- **THEN** la lista de Moods incluidos muestra los nombres en francés

#### Scenario: Título de un Pack en el idioma del dispositivo
- **WHEN** el dispositivo está en español y se abre la tienda
- **THEN** el Pack `confianza` se muestra como "Pack de Confianza" aunque el producto de la tienda devuelva otro texto

#### Scenario: Título del Pack sin sufijos de la tienda
- **WHEN** la tienda devuelve un título con texto añadido, por ejemplo "(unreviewed)"
- **THEN** la Tienda y la hoja de compra muestran el nombre de la app, sin ese texto

#### Scenario: Pack sin cadena propia
- **WHEN** aparece un Pack cuyo identificador no tiene cadena en la app
- **THEN** se muestra el título del producto de la tienda
