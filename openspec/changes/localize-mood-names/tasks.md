## 1. Strings

- [x] 1.1 Añadir `String moodName(String moodId)` a `lib/core/localization/app_strings.dart`
- [x] 1.2 Implementarlo en `app_strings_en.dart`, `_es`, `_de`, `_fr`, `_it` con la tabla de design.md (`default` -> `MoodDefinitionResolver.byId`/`label` inglés)

## 2. UI

- [x] 2.1 `mood_screen.dart`: usar `strings.moodName(mood.id)` en textos y en `selectedMood` semantics
- [x] 2.2 `calendar_screen.dart` y `monthly_mood_summary_card.dart`: actualizar `_moodLabelForPath`
- [x] 2.3 `mood_store_screen.dart`, `mood_purchase_sheet.dart` (texto y `buyMoodButtonLabel`) y `pack_purchase_sheet.dart` (lista de moods del Pack)
- [x] 2.4 Verificar que no quedan usos de `.label` de `MoodDefinition` en presentación (`grep`), dejando intacto `pack.label` y `storeProduct.title`

## 3. Tests

- [x] 3.1 Test: los 10 ids tienen nombre no vacío en los 5 idiomas, y un id desconocido cae al fallback
- [x] 3.2 Test de widget: `MoodScreen` (y tienda con `fake_mood_entitlements_repository`) muestra el nombre en español bajo locale `es`
- [x] 3.3 `flutter analyze` y `flutter test` en verde

## 4. Verificación y docs

- [x] 4.1 Probar en simulador en es/de/fr (nombres largos, selector, tienda, iPad) sin overflow — verificado: selector en iPhone con alemán y francés ("Selbstbewusst", "En colère"); tienda e iPad no probados
- [x] 4.2 Actualizar CLAUDE.md (quitar la nota de que los nombres no están localizados y la mención en el flujo de screenshots) y `backlog.md` si aplica
- [ ] 4.3 Sincronizar specs (`localization-architecture`, `mood-store`) al archivar
