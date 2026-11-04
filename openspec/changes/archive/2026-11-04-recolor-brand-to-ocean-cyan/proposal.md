## Why

El morado de marca (`#5F3DC4` → `#6C63FF`) se lee como el degradado genérico de "producto hecho con IA" y no dice nada de Mood Calendar: lo que sí es propio de la marca son las caritas y los pasteles por mood. Se cambia por **Ocean Cyan** (`#00727D` → `#00838F`), un teal profundo que sale de los colores que la app ya usa (el cian de moods premium), no choca con los 5 moods base y mantiene intactas las caritas, los pasteles y los marcos del marketing.

## What Changes

- **App**: el color de marca pasa a `#00727D` → `#00838F` (tinta `#00727D`; texto blanco sobre el relleno: contraste 5.67 y 4.52). Se centraliza en un único token de marca en `lib/core/` en lugar de repetir `0xFF5F3DC4` en ~30 líneas y cuatro `_brandColor`/`_brand` privados; el `seedColor` de `ColorScheme.fromSeed` y los chips de `monthly_mood_summary_card.dart` (hoy `Colors.deepPurple`) usan el mismo token.
- **Ícono y launch**: nuevo `assets/icon/app_icon.png` con fondo Ocean Cyan, regenerado con `flutter_launcher_icons`, y las imágenes de launch de iOS (`LaunchImage`) y Android (`launch_icon.png`), que llevan el ícono dentro de un fondo blanco.
- **Sitio** (`site/`, inglés y español): `style.css`, `index.html` y `es/index.html` pasan a la nueva marca, incluida la escala del modo oscuro (hoy lavanda) y las imágenes Open Graph; `DESIGN.md` y `.impeccable/design.json` se actualizan.
- **Arte de tienda**: `tool/screenshots/header.py` y `compose.py` (degradado, titulares y slide 6) se recolorean y se regeneran el header de App Store, los gráficos de funciones de Play y las capturas. Las caritas, los pasteles por mood y los marcos de dispositivo se reutilizan tal cual.
- **No cambia**: los colores de los moods (incluidos `purple`, `indigo` y `deepPurple` de moods premium en `mood_definition.dart`), el comportamiento de cualquier pantalla, las cadenas localizadas ni los datos.
- La redacción del requisito de `bottom-navigation` deja de nombrar un color ("el púrpura de marca" → "el color de marca"), para que el spec no vuelva a quedar desfasado con un cambio de paleta.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `bottom-navigation`: el requisito "Cuatro pestañas en un bottom bar" deja de fijar el color de los íconos como "púrpura" y lo expresa como "color de marca". Ningún comportamiento observable cambia más allá del color.

## Impact

- **Código**: `lib/main.dart`, `lib/core/widgets/floating_tab_bar.dart`, `lib/core/widgets/gradient_pill_button.dart`, `lib/features/mood/presentation/screens/{mood_screen,calendar_screen}.dart`, `lib/features/mood/presentation/widgets/{monthly_mood_summary_card,mood_grid_sheet}.dart`, `lib/features/settings/presentation/screens/settings_screen.dart` y, si todavía existen, `lib/features/purchases/presentation/screens/` (ver design: secuenciación). Un token nuevo en `lib/core/`.
- **Assets**: `assets/icon/app_icon.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset` y `LaunchImage.imageset`, `android/app/src/main/res/{mipmap-*,drawable/launch_icon.png}`.
- **Sitio y marketing**: `site/`, `DESIGN.md`, `PRODUCT.md`, `tool/screenshots/{header,compose,capture_android}.py`, `aso/header/`, `aso/play/`, `aso/screenshots/` (se regeneran) y `site/img/og-*.jpg`.
- **Tiendas**: el ícono y las capturas se suben a mano a App Store Connect y Play Console; el ícono de la app va en el binario, así que el cambio solo sale en la siguiente versión.
- **Dependencias externas**: ninguna. Sin cambios en privacidad, SDKs ni declaraciones de las tiendas.
- **Coordinación**: toca archivos del change `replace-mood-purchases-with-subscription` (borra `MoodStoreScreen`, crea `PremiumScreen`, y modifica el mismo requisito de `bottom-navigation`); este change se implementa y se archiva después de aquel.
