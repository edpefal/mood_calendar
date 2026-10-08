## Why

Los nombres de los moods (`Happy`, `Calm`, `Romantic`, `Brave`...) viven hardcodeados en inglés en `MoodDefinition.label` y se muestran así en todos los idiomas: selector de mood, calendario, resumen mensual, tienda y hojas de compra. Es la única parte visible de la UI que no sigue el locale del dispositivo, y rompe el requisito de que "la app muestra todos los textos de UI" en el idioma activo. También impide mostrar la tienda en los screenshots de App Store (ver CLAUDE.md).

## What Changes

- Añadir a `AppStrings` un acceso localizado al nombre de cada Mood por su `id` (getter abstracto + implementación en `app_strings_en/es/de/fr/it.dart`).
- Reemplazar los usos de `MoodDefinition.label` en la UI (selector, semántica, calendario, resumen mensual, tienda, hojas de compra de mood y de pack) por el nombre localizado.
- `MoodDefinition.label` se conserva como nombre interno en inglés (fallback y logs); deja de usarse para mostrar texto al usuario.
- Tests: cobertura de que los 10 ids tienen nombre no vacío en los 5 idiomas y de que la UI usa el nombre localizado.
- Sin cambios en `id`, `assetPath`, `intensity`, `tier`, `color`, Hive, export JSON ni productos de RevenueCat.
- Fuera de alcance: notificaciones y `title` de `MaterialApp` (change `localize-notifications-and-title`) y el título del Pack, que viene de `storeProduct.title` de RevenueCat/App Store Connect.

## Capabilities

### New Capabilities

### Modified Capabilities
- `localization-architecture`: nuevo requisito: los nombres de los Moods se localizan vía `AppStrings` y se muestran en el idioma del dispositivo, con fallback a inglés.
- `mood-store`: los nombres de Moods mostrados en la tienda y hojas de compra (incluida la lista de moods de un Pack) se muestran localizados.

## Impact

- Código: `lib/core/localization/app_strings*.dart` (6 archivos), `mood_screen.dart`, `calendar_screen.dart`, `monthly_mood_summary_card.dart`, `mood_store_screen.dart`, `mood_purchase_sheet.dart`, `pack_purchase_sheet.dart`.
- Datos: ninguno. Los `Mood Entry` guardan asset path/intensity, no el nombre; no hay migración.
- Docs: nota de CLAUDE.md ("los nombres de los moods no están localizados") queda obsoleta y se actualiza; `tool/screenshots` podrá reconsiderar incluir la tienda (decisión separada).
- Nuevos mood premium futuros deberán añadir su nombre en los 5 idiomas.
