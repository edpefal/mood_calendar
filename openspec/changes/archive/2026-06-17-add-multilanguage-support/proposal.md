## Why

La localización actual usa ternarios binarios (`isEnglish ? ... : ...`) que no escalan más allá de dos idiomas. Para expandir la app a mercados europeos clave (Alemania, Francia, Italia) se necesita una arquitectura que permita añadir idiomas sin modificar getters existentes, y activar la selección automática de idioma basada en el dispositivo.

## What Changes

- **BREAKING** Refactorizar `AppStrings` de clase concreta con ternarios a clase abstracta con subclases por idioma
- Crear implementaciones separadas: `AppStringsEs`, `AppStringsEn`, `AppStringsDe`, `AppStringsFr`, `AppStringsIt`
- Añadir soporte para alemán (`de`), francés (`fr`) e italiano (`it`) en `supportedLocales`
- Eliminar `locale: const Locale('es')` hardcodeado en `main.dart` para usar el locale del dispositivo
- El fallback cuando el dispositivo usa un idioma no soportado es español

## Capabilities

### New Capabilities
- `localization-architecture`: Arquitectura de localización basada en subclases por idioma, escalable a nuevos locales sin modificar código existente

### Modified Capabilities
- `monthly-mood-summary`: El resumen mensual ahora se muestra en el idioma del dispositivo (antes siempre en español por el locale hardcodeado)

## Impact

- `lib/core/localization/app_strings.dart` — se convierte en clase abstracta (breaking: elimina `isEnglish`, `spanish`, `english` statics, ternarios)
- `lib/core/localization/app_strings_es.dart` — nuevo archivo con implementación española (extraído del archivo actual)
- `lib/core/localization/app_strings_en.dart` — nuevo archivo con implementación inglesa
- `lib/core/localization/app_strings_de.dart` — nuevo archivo con traducción alemana
- `lib/core/localization/app_strings_fr.dart` — nuevo archivo con traducción francesa
- `lib/core/localization/app_strings_it.dart` — nuevo archivo con traducción italiana
- `lib/main.dart` — eliminar `locale: const Locale('es')`, actualizar `supportedLocales`
- Sin cambios en BLoC, repositorios, ni dependencias externas
