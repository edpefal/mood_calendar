## 1. Prerrequisitos y rama

- [x] 1.1 Confirmar que `replace-mood-purchases-with-subscription` está mergeado a `main` (si no, no empezar: toca los mismos archivos y el mismo requisito de `bottom-navigation`)
- [x] 1.2 Crear la rama `style/brand-ocean-cyan` desde `main` actualizado y comprobar `flutter analyze` y `flutter test` en verde
- [x] 1.3 Confirmar con el usuario el hex final (`#00727D → #00838F`) y el ícono (carita blanca sobre fondo plano o degradado) mirando el mock "G · Ocean Cyan" antes de tocar nada

## 2. Token de marca en la app

- [x] 2.1 Crear `lib/core/theme/brand_colors.dart` con `brandInk`, `brandGradientStart`, `brandGradientEnd` y `brandGradient`
- [x] 2.2 Sustituir los literales `0xFF5F3DC4` y `0xFF6C63FF` y los `_brandColor`/`_brand` privados por el token en `floating_tab_bar.dart`, `gradient_pill_button.dart`, `mood_screen.dart`, `calendar_screen.dart`, `monthly_mood_summary_card.dart`, `mood_grid_sheet.dart`, `settings_screen.dart` y las pantallas de `purchases/` que existan tras la suscripción
- [x] 2.3 `main.dart`: `ColorScheme.fromSeed(seedColor: brandInk)`
- [x] 2.4 `monthly_mood_summary_card.dart`: reemplazar `Colors.deepPurple` y `Colors.deepPurple.shade50` de los chips vacíos por el token tintado (D4)
- [x] 2.5 Verificar con `grep` que no quedan `5F3DC4`, `6C63FF` ni `deepPurple` en `lib/` fuera de `mood_definition.dart`
- [x] 2.6 `flutter analyze` y `flutter test`; añadir un test del token si hay una forma barata (p. ej. contraste ≥ 4.5 de blanco sobre `brandGradientStart` y `brandGradientEnd`)

## 3. Verificación visual de la app

- [x] 3.1 En un simulador limpio (no el de capturas compartido), revisar selector, calendario, tienda/Premium, ajustes y el bottom bar: botón principal, flechas, títulos, racha y píldora de la pestaña activa
- [x] 3.2 Revisar los widgets que heredan del seed (`Switch`, selector de hora, `SnackBar`, diálogos y hojas)
- [ ] 3.3 Comprobar en iPad y con texto al 200 % que no hay desbordes (solo cambió el color, pero se verifica de todos modos)
- [x] 3.4 En el calendario con datos reales, confirmar que el teal de marca no se confunde con el azul de Calm ni con el verde de Happy

## 4. Ícono y launch

- [ ] 4.1 Rediseñar `assets/icon/app_icon.png` (fondo Ocean Cyan, misma carita blanca; sin transparencia en iOS)
- [ ] 4.2 Correr `dart run flutter_launcher_icons` y revisar el diff de `AppIcon.appiconset` y de los `mipmap-*`
- [ ] 4.3 Regenerar `ios/Runner/Assets.xcassets/LaunchImage.imageset` y `android/app/src/main/res/drawable/launch_icon.png` con el ícono nuevo sobre fondo blanco
- [ ] 4.4 Comprobar el arranque en simulador iOS y emulador Android: launch screen blanco con el ícono nuevo, sin parpadeo morado
- [ ] 4.5 Corregir la frase de `CLAUDE.md` y `PRODUCT.md` sobre el "fondo del launch screen `#8C52FF`" (el launch screen es blanco)

## 5. Sitio

- [ ] 5.1 `site/style.css`: reemplazar los tokens de marca y la escala nocturna (`night-heading`, `night-link`…) por tonos cian que cumplan AA sobre `night` y `night-card`
- [ ] 5.2 `site/index.html` y `site/es/index.html`: reemplazar los hex incrustados (fondos de héroe, `theme-color`, íconos) y revisar que las dos versiones sigan iguales
- [ ] 5.3 Regenerar `site/img/og-en.jpg` y `og-es.jpg` desde el header nuevo, y `calendar-<idioma>-{390,780}.webp` con la UI nueva de la app
- [ ] 5.4 Actualizar `DESIGN.md` y `.impeccable/design.json` con los valores finales, y la fecha de "última actualización" de la política solo si cambia texto legal (no cambia)
- [ ] 5.5 Revisar el sitio en 390 pt y 1280 pt, claro y oscuro, y contrastes de enlaces y botones

## 6. Arte de tienda

- [ ] 6.1 `tool/screenshots/header.py`: degradado de fondo y tinta; regenerar `aso/header/<idioma>/` y `aso/play/<idioma>/feature_1024x500.png` para los 5 idiomas
- [ ] 6.2 `tool/screenshots/compose.py`: titulares (`#2A1A6B`), sombra del marco, fondo del slide 1 (lavanda) y slide 6 (`#5F3DC4 → #6C63FF`); conservar los demás pasteles por slide
- [ ] 6.3 Recapturar con la app nueva (`capture.py` para iPhone e iPad, `capture_android.py` para Android) y recomponer; revisar los 5 idiomas
- [ ] 6.4 Subir el ícono, las capturas y los gráficos a App Store Connect y Play Console cuando la versión con el ícono nuevo esté aprobada (acción manual del usuario)

## 7. Documentación y specs

- [ ] 7.1 `CLAUDE.md`: color de marca, sección "Sistema de diseño" y la nota del launch screen; `PRODUCT.md`: "Brand Commitments"
- [ ] 7.2 `/opsx:sync` o `/opsx:archive` para aplicar el delta de `bottom-navigation` (verificar que el texto base ya es el de la suscripción)
- [ ] 7.3 Actualizar la sección "Estado actual" de `CLAUDE.md` con el estado del change
