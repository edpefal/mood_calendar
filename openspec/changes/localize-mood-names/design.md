## Context

`MoodDefinition.label` (inglés, const) se usa directamente en ~10 sitios de UI. `AppStrings` ya localiza el resto de la UI con subclases por idioma (en fallback). `MoodDefinition` es const, de dominio y sin `BuildContext`, así que no puede localizarse sola. ADR 0001: `intensity` es solo un identificador; ADR 0002: composición de Packs congelada (no afecta). `Mood Entry` persiste asset path/intensity, nunca el nombre.

## Goals / Non-Goals

**Goals:**
- Nombres de Mood en en/es/de/fr/it siguiendo el patrón AppStrings.
- Cero cambios en datos persistidos e identificadores.

**Non-Goals:**
- Notificaciones y `title` de `MaterialApp` (change `localize-notifications-and-title`).
- Título del Pack (viene de RevenueCat/App Store Connect).
- Localizar precios o descripciones de producto.
- Reordenar o comparar moods por nombre/intensity.

## Decisions

1. **Método `String moodName(String moodId)` en `AppStrings`**, no 10 getters. Cada subclase implementa un `switch` sobre el id con `default: return fallback` (inglés). Alternativa: 10 getters abstractos (`moodHappy`...): más verboso y cada mood premium futuro obliga a tocar la API base; el `switch` mantiene el contrato en un punto. Para garantizar cobertura, un test recorre `allMoodDefinitions` x 5 idiomas.
2. **`MoodDefinition.label` se mantiene** como nombre interno inglés y fallback del `default`; evita tocar `noop`/repos y `const`. Su uso en widgets se sustituye por `strings.moodName(mood.id)`.
3. **Helper de UI**: `_moodLabelForPath` en calendario y resumen pasa a `AppStrings.of(context).moodName(byAssetPath(path).id)`.
4. **Traducciones propuestas** (revisar con hablante nativo; formas masculinas/neutras):

| id | en | es | de | fr | it |
|---|---|---|---|---|---|
| happy | Happy | Feliz | Glücklich | Heureux | Felice |
| calm | Calm | Tranquilo | Ruhig | Calme | Calmo |
| neutral | Neutral | Neutral | Neutral | Neutre | Neutro |
| sad | Sad | Triste | Traurig | Triste | Triste |
| angry | Angry | Enojado | Wütend | En colère | Arrabbiato |
| anxious | Anxious | Ansioso | Ängstlich | Anxieux | Ansioso |
| brave | Brave | Valiente | Mutig | Courageux | Coraggioso |
| confident | Confident | Seguro | Selbstbewusst | Confiant | Sicuro |
| romantic | Romantic | Romántico | Romantisch | Romantique | Romantico |
| shy | Shy | Tímido | Schüchtern | Timide | Timido |

5. **Layout**: nombres como "Selbstbewusst" o "En colère" son más largos; verificar overflow en selector, chips y filas de la tienda (iPhone SE e iPad).

## Risks / Trade-offs

- [Textos largos desbordan] -> revisar con `maxLines`/`ellipsis` donde falte y probar en simulador (docs/ios-simulator-ui-testing.md).
- [Género gramatical en es/fr/it] -> usar forma masculina/neutra, igual que el resto de la app; anotar como decisión aceptada.
- [Mood nuevo sin traducción] -> el `default` cae a `label` en inglés y el test de cobertura falla en CI, forzando añadirlo.
- [Screenshots] -> la nota de CLAUDE.md sobre nombres sin localizar deja de aplicar; la razón de excluir la tienda de los screenshots queda parcialmente resuelta (siguen los precios en USD), decisión aparte.
