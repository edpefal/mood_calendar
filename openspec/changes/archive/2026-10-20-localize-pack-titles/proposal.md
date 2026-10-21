## Why

Los títulos de los Packs en la Tienda y en su hoja de compra salen del producto de la tienda (`storeProduct.title`). En Android, mientras la app no está revisada por Google, Play les añade el sufijo "(com.artlab.moodcalendar (unreviewed))" (visto en la prueba interna), y además cada tienda puede devolver el título en otro idioma o con otro texto. Los nombres de los Moods ya salen de las cadenas de la app; los Packs deberían hacer lo mismo para verse iguales en iOS y Android y en el idioma del dispositivo.

## What Changes

- Los títulos de los 4 Packs (`afecto`, `confianza`, `cuerpo`, `intenso`) pasan a ser cadenas localizadas de la app en los 5 idiomas, con fallback a inglés.
- Si aparece un Pack cuyo id no está en las cadenas (por ejemplo, uno nuevo añadido solo en RevenueCat), se sigue mostrando el título del producto de la tienda.
- Nuevo getter `packNames` y método `packName(packId, fallback)` en `AppStrings`, igual que `moodNames` y `moodName`.
- La Tienda y la hoja de compra del Pack usan `packName` en lugar de `pack.label` (incluida la etiqueta de accesibilidad del botón de compra).
- Sin cambios en precios, composición de los Packs ni en RevenueCat.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `mood-store`: el requisito "Nombres de Mood localizados en la tienda" pasa a cubrir también los títulos de los Packs.

## Impact

- **Código**: `lib/core/localization/app_strings.dart` y las 5 subclases, `lib/features/purchases/presentation/screens/mood_store_screen.dart`, `lib/features/purchases/presentation/widgets/pack_purchase_sheet.dart`.
- **Tests**: textos por idioma, fallback de un Pack desconocido, y la Tienda y la hoja mostrando el nombre de la app en vez del título de la tienda.
- **Sin dependencias nuevas.** No cambia nada en iOS salvo que los títulos pasan a ser los de la app (los mismos que ya tiene App Store Connect para inglés, español, alemán, francés e italiano).
