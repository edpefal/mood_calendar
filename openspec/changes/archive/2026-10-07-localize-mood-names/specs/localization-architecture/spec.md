## ADDED Requirements

### Requirement: Nombres de Mood localizados
Los nombres de los Moods SHALL obtenerse de `AppStrings` por el `id` del Mood y mostrarse en el idioma activo del dispositivo en toda la UI (selector de mood, etiquetas de accesibilidad, calendario, resumen mensual, tienda y hojas de compra). Cada subclase de `AppStrings` SHALL definir un nombre para cada uno de los 10 Moods del catálogo. Para un `id` desconocido SHALL usarse `MoodDefinition.label` como fallback. La localización SHALL NOT alterar `id`, `assetPath`, `intensity` ni ningún dato persistido.

#### Scenario: Mood en español
- **WHEN** el dispositivo está en español y se muestra el Mood `happy`
- **THEN** la UI muestra "Feliz" en lugar de "Happy"

#### Scenario: Idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** los nombres de los Moods se muestran en inglés

#### Scenario: Catálogo completo cubierto
- **WHEN** se consulta el nombre de cada Mood de `allMoodDefinitions` en cada idioma soportado
- **THEN** el resultado es un texto no vacío

#### Scenario: Entradas históricas
- **WHEN** el usuario cambia el idioma del dispositivo con `Mood Entry` ya guardadas
- **THEN** cada entrada se muestra con el nombre del Mood en el nuevo idioma y los datos guardados no cambian

#### Scenario: Etiqueta de accesibilidad
- **WHEN** se anuncia un Mood por Semantics (por ejemplo "mood seleccionado" o "comprar")
- **THEN** el nombre usado en la etiqueta es el localizado
