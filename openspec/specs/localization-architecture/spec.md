## Purpose

Define cómo la app elige y muestra sus textos según el idioma del dispositivo: arquitectura de `AppStrings`, idiomas soportados, fallback a inglés y qué superficies (UI, notificaciones, nombres de moods) deben estar localizadas.

## Requirements

### Requirement: Arquitectura de localización por subclases
El sistema de localización SHALL implementarse como una clase abstracta `AppStrings` con subclases concretas por idioma. Cada subclase SHALL implementar todos los getters definidos en la clase base. El factory `forLocale(Locale)` SHALL retornar la subclase correspondiente al `languageCode` recibido, con fallback a inglés para locales no soportados.

#### Scenario: Locale soportado
- **WHEN** el dispositivo tiene un locale soportado (es, en, de, fr, it)
- **THEN** `AppStrings.of(context)` retorna la subclase correspondiente a ese idioma

#### Scenario: Locale no soportado
- **WHEN** el dispositivo tiene un locale no soportado (ej. pt, ja, zh)
- **THEN** `AppStrings.of(context)` retorna la subclase inglesa como fallback

### Requirement: Detección automática del idioma del dispositivo
La app SHALL usar el locale del dispositivo para determinar el idioma de la UI. No SHALL existir un locale hardcodeado en la configuración de la app. Los locales soportados SHALL ser: inglés (en, fallback), español (es), alemán (de), francés (fr), italiano (it).

#### Scenario: Dispositivo en alemán
- **WHEN** el dispositivo está configurado en alemán
- **THEN** la app muestra todos los textos de UI en alemán

#### Scenario: Dispositivo en idioma no soportado
- **WHEN** el dispositivo está en un idioma no incluido en supportedLocales
- **THEN** la app muestra los textos en inglés (primer locale en supportedLocales)

### Requirement: Placeholder del campo de nota localizado
La etiqueta del botón de nota del encabezado y el placeholder del campo de edición dentro del bottom sheet SHALL mostrarse cada uno en el idioma activo del dispositivo. Ninguno SHALL estar hardcodeado en un solo idioma.

#### Scenario: Botón de nota en español
- **WHEN** el dispositivo está en español
- **THEN** el botón de nota muestra su etiqueta en español

#### Scenario: Campo del sheet vacío en español
- **WHEN** el dispositivo está en español, el usuario abre el bottom sheet y la nota está vacía
- **THEN** el campo de texto del sheet muestra el placeholder que invita a escribir sobre el día, en español

#### Scenario: Textos de la nota en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado
- **THEN** tanto la etiqueta del botón de nota como el placeholder del campo del sheet se muestran en inglés

### Requirement: Notificaciones y título de la app localizados
Las notificaciones locales (título y cuerpo del recordatorio diario, nombre y descripción del canal de notificaciones) y el título de la app que expone el sistema operativo SHALL mostrarse en el idioma del dispositivo. Ninguno SHALL estar fijo en un solo idioma. Para idiomas no soportados SHALL usarse inglés. Un recordatorio ya programado SHALL actualizar su idioma la próxima vez que la app se abra y reprograme el recordatorio.

#### Scenario: Recordatorio en alemán
- **WHEN** el dispositivo está en alemán y la app programa el recordatorio diario
- **THEN** el título y el cuerpo de la notificación están en alemán

#### Scenario: Recordatorio en idioma no soportado
- **WHEN** el dispositivo está en un idioma no soportado (ej. pt) y la app programa el recordatorio diario
- **THEN** el título y el cuerpo de la notificación están en inglés

#### Scenario: Canal de notificaciones en Android
- **WHEN** el dispositivo Android está en francés y la app crea el canal de notificaciones
- **THEN** el nombre y la descripción del canal están en francés

#### Scenario: Título de la app
- **WHEN** el dispositivo está en italiano
- **THEN** el título de la app que ve el sistema (por ejemplo en el selector de apps) está en italiano

#### Scenario: Cambio de idioma del dispositivo
- **WHEN** el usuario cambia el idioma del dispositivo y vuelve a abrir la app
- **THEN** el recordatorio se reprograma con título y cuerpo en el nuevo idioma

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
