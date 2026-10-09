## Why

Los ajustes de la app (recordatorio diario y calificar) viven en un bottom sheet privado abierto desde una campana en el header del calendario. Es un lugar poco descubrible, el sheet no puede crecer con más opciones y su lógica está enterrada en `calendar_screen.dart` sin cobertura de tests. Una pantalla de Settings accesible desde la pantalla principal, junto a tienda y calendario, da un hogar estable para esas opciones y para las que vengan.

## What Changes

- Nueva `SettingsScreen`, accesible desde un icono de engrane en el header de `MoodScreen`, a la derecha de tienda y calendario (orden: tienda · calendario · engrane).
- La pantalla se organiza en secciones:
  - **Recordatorios**: switch de recordatorio diario y hora. Los cambios se **guardan al instante** (desaparece el botón "Guardar") y reprograman o cancelan la notificación.
  - **Ayuda y Acerca de**: fila "Calificar Mood Calendar" (movida desde el sheet), fila "Política de privacidad" que abre `https://www.termsfeed.com/live/c7cd2907-6d6c-46d2-9e1a-a715b74979c8` en el navegador, y fila informativa con la versión de la app.
- **BREAKING (UI)**: se elimina la campana del header del calendario y el `_ReminderSettingsSheet`. El calendario queda con `[<] mes [>]`.
- Textos nuevos localizados en los 5 idiomas (título de la pantalla, secciones, privacidad, versión, tooltip del engrane). Se retira el tooltip de la campana.
- Dependencias nuevas: `url_launcher` (privacidad) y `package_info_plus` (versión).
- `tool/screenshots/capture.py` y la sección de screenshots de `CLAUDE.md` asumen que el calendario es el botón más a la derecha del header principal; se ajustan al nuevo orden.
- Fuera de alcance (change aparte, `export-mood-history`): exportar historial con hoja de compartir.

## Capabilities

### New Capabilities
- `settings-screen`: pantalla de Settings, su punto de entrada desde la pantalla principal, configuración de recordatorio diario con autoguardado, enlace a la política de privacidad y visualización de la versión.

### Modified Capabilities
- `rating-prompt`: la entrada manual para calificar deja de estar en "la hoja de ajustes de recordatorios del calendario" y pasa a la pantalla de Settings (requisitos "Entrada manual para calificar la app" y "Textos localizados y accesibles").

## Impact

- **Código**: `lib/features/mood/presentation/screens/mood_screen.dart` (engrane), `calendar_screen.dart` (se quitan campana y sheet, ~200 líneas), nueva pantalla de settings (ubicación a decidir en design.md), `lib/core/localization/app_strings*.dart` (6 archivos).
- **Dependencias**: `pubspec.yaml` suma `url_launcher` y `package_info_plus`; requiere `pod install` en iOS.
- **Specs**: nueva `settings-screen`; delta en `rating-prompt`. `calendar-navigation` no cambia (solo menciona recordatorios como origen de un selector).
- **Tooling/docs**: `tool/screenshots/capture.py`, `CLAUDE.md`.
- **Tests**: se agregan widget tests de la pantalla (hoy no hay cobertura de recordatorios); ver `backlog.md`.
- **Riesgo**: tres iconos en el header de `MoodScreen` junto a una fecha larga pueden apretarse en pantallas angostas y en alemán.
