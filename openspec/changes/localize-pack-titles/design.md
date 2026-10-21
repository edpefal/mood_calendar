## Context

`MoodEntitlementsRepositoryImpl` crea cada `MoodPack` con `label: package.storeProduct.title`. La Tienda (`mood_store_screen.dart`) y `pack_purchase_sheet.dart` pintan `pack.label`. Los nombres de Mood ya se resuelven con `AppStrings.moodName` (mapa por idioma con fallback a inglés).

## Decisions

- **Mismo patrón que `moodNames`**: `Map<String, String> get packNames` abstracto en `AppStrings`, implementado en los 5 idiomas, y `String packName(String packId, {required String fallback})` que prueba el idioma activo, luego inglés y por último el título de la tienda. Así un Pack nuevo creado solo en RevenueCat sigue viéndose.
- **La UI resuelve el nombre, no el repositorio**: `MoodPack.label` sigue siendo el título de la tienda y se usa como fallback; la traducción se hace donde hay `AppStrings` (la Tienda y la hoja). Así el repositorio no depende de localización ni de `BuildContext`.
- **Textos**: se reutilizan los nombres que ya tiene App Store Connect (inglés, español, alemán, francés e italiano). El Pack Confianza solo existía en inglés y español allí; alemán, francés e italiano siguen el patrón de los otros tres Packs ("Selbstvertrauens-Paket", "Pack Confiance", "Pacchetto Fiducia").
- **Etiqueta de accesibilidad** de comprar el Pack usa el mismo nombre localizado.

## Risks / Trade-offs

- Un Pack nuevo sin cadena mostrará el título de la tienda hasta que se añada la cadena (aceptable y es el comportamiento actual).
