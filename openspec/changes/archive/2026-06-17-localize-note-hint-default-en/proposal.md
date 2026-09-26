## Why

El placeholder del campo de nota en `mood_screen.dart` está hardcodeado en inglés (`"Write a note..."`) y no usa el sistema de localización. Además, el idioma de fallback es español cuando debería ser inglés, ya que la app apunta al mercado global.

## What Changes

- Añadir el getter `noteHint` a `AppStrings` (abstracta) y a las 5 subclases de idioma (es, en, de, fr, it)
- Reemplazar el `hintText` hardcodeado en `mood_screen.dart` por `AppStrings.of(context).noteHint`
- Cambiar el orden de `supportedLocales` en `app_strings.dart` para que inglés (`en`) sea el primero y actúe como fallback por defecto

## Capabilities

### New Capabilities

### Modified Capabilities
- `localization-architecture`: El idioma de fallback cambia de español a inglés (primer elemento de `supportedLocales`)

## Impact

- `lib/core/localization/app_strings.dart` — reordenar `supportedLocales`, añadir getter abstracto `noteHint`
- `lib/core/localization/app_strings_es.dart` — añadir `noteHint`
- `lib/core/localization/app_strings_en.dart` — añadir `noteHint`
- `lib/core/localization/app_strings_de.dart` — añadir `noteHint`
- `lib/core/localization/app_strings_fr.dart` — añadir `noteHint`
- `lib/core/localization/app_strings_it.dart` — añadir `noteHint`
- `lib/features/mood/presentation/screens/mood_screen.dart` — usar `AppStrings.of(context).noteHint`
