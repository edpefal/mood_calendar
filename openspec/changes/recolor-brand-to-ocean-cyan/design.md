## Context

El color de marca vive hoy como literales repetidos: `Color(0xFF5F3DC4)` en ~30 líneas de 8 archivos de `lib/` (cuatro de ellos con su propio `_brandColor`/`_brand` privado), el degradado `#5F3DC4 → #6C63FF` duplicado en `gradient_pill_button.dart` y en la tarjeta de racha de `monthly_mood_summary_card.dart`, `ColorScheme.fromSeed(seedColor: Colors.deepPurple)` en `main.dart` y `Colors.deepPurple` en los chips vacíos del resumen. Fuera de `lib/`, el mismo morado está en el ícono, las imágenes de launch, `site/style.css` (tokens de marca y escala nocturna), los scripts de arte de tienda y los documentos de diseño.

Hechos que condicionan el enfoque:

- El launch screen de iOS y Android es **blanco** con el ícono centrado como imagen (`LaunchImage`, `launch_icon.png`). El `#8C52FF` que cita `CLAUDE.md` es el fondo del propio ícono, no del launch screen; esa frase está desfasada.
- La app no tiene tema oscuro propio (solo el sitio), así que no hay paleta nocturna de la app que migrar.
- `MoodDefinition.color` debe ser `MaterialColor` y los moods premium usan `purple`, `indigo` y `deepPurple`; son colores de mood, no de marca.
- El change activo `replace-mood-purchases-with-subscription` borra `MoodStoreScreen` (que usa el morado en 5 líneas), crea `PremiumScreen`, renombra la pestaña de tienda a Premium y modifica el mismo requisito de `bottom-navigation` que este change.
- Ver `proposal.md` para el motivo y los mocks de referencia (propuesta "G · Ocean Cyan").

## Goals / Non-Goals

**Goals:**
- Un único punto de verdad del color de marca en la app; cambiar la marca otra vez debe ser editar un archivo.
- Que ningún elemento de marca (botón, título, ícono, racha, pestaña activa) use un color que un mood base ya usa.
- Que el texto sobre el relleno de marca cumpla AA (≥ 4.5:1).
- Reutilizar el arte de marketing (caritas, pasteles, marcos); solo se recolorean fondos, degradados y tintas.

**Non-Goals:**
- Un tema oscuro de la app, rediseñar pantallas o cambiar tipografía, espaciado o layout.
- Tocar los colores de los moods ni `MoodDefinitionResolver`.
- Cambiar copy, localización, privacidad o analíticas.
- Migrar a `ColorScheme` completo ni a un sistema de temas (basta el token y el seed).

## Decisions

1. **Valores: relleno `#00727D → #00838F`, tinta `#00727D`.** Blanco sobre `#00727D` da 5.67:1 y sobre `#00838F` 4.52:1; la tinta (títulos, flechas, íconos sobre claro) da 5.67:1 sobre blanco. Es un teal más verdoso y oscuro que el azul de Calm (`Colors.blue`) y que el cian claro de los moods premium, y no coincide con ningún mood base. *Alternativas*: `#0097A7` (más viva, pero solo 3.5:1 con blanco: obligaría a texto grande); un pastel cian (no admite texto blanco; ver mocks P5); amarillo o rosa (descartados en la exploración por identidad o por parecerse al estado de error).
2. **Token en `lib/core/theme/brand_colors.dart`** (constantes `brandInk`, `brandGradientStart`/`End` y un `LinearGradient brandGradient`), usado por `GradientPillButton`, el bar, la tarjeta de racha y todas las pantallas; se borran los `_brandColor` privados. Se prefirió un archivo de constantes a un `ThemeExtension` porque la app no tiene una capa de temas y el token se usa también en widgets `const`. *Alternativa*: `ColorScheme.primary` por todas partes; se descartó porque obligaría a reescribir ~30 puntos de uso en un cambio que es solo de color.
3. **`ColorScheme.fromSeed(seedColor: brandInk)`** para que los componentes de Material que no pintamos a mano (diálogos, switches, hojas) hereden la marca. Se revisa a ojo `Switch`, selector de hora y `SnackBar`, que son los que hoy se ven morados por el seed.
4. **Los chips vacíos del resumen** (`Colors.deepPurple.shade50` y `.deepPurple`) pasan a una versión tintada del token (fondo `brandInk` al ~8 % y ícono `brandInk`), sin añadir una constante por cada tono.
5. **Ícono: fondo `#00838F` con la carita blanca** (mismo trazo, solo cambia el fondo); la variante amarilla de los mocks quedó fuera porque el blanco sobre el color de marca es lo que ya hace reconocible al ícono en las tiendas. Es una decisión revisable en la implementación: si el ícono se ve apagado en iOS, se prueba un degradado `#00727D → #00838F`.
6. **Sitio**: los tokens de `style.css` se renombran por rol, no por color (`--brand`, `--brand-signal`, `--brand-deep`…) si hoy no lo están, y la escala nocturna (hoy lavanda: `night-heading`, `night-link`…) se rehace con tonos cian que mantengan AA sobre `night` y `night-card`. `DESIGN.md` y `.impeccable/design.json` se editan a mano a partir de los valores finales; no se corre `document` desde cero para no perder las reglas con nombre.
7. **Arte de tienda desde los scripts**: `header.py` y `compose.py` ya generan todo, así que se cambian sus constantes (degradado, `#2B1B78`/`#2A1A6B` de los titulares, fondos pastel del slide 1 en adelante, sombra del marco `rgba(36,18,110,…)`) y se regenera; no se edita ninguna imagen a mano. Los fondos pastel por slide no son marca y se conservan, salvo el slide 1 (lavanda `#E8E1FF → #F7E6FF`) y el 6 (`#5F3DC4 → #6C63FF`), que sí lo son.
8. **Secuenciación**: este change se implementa **después** de `replace-mood-purchases-with-subscription` (1.10.0). Así no se rehace `MoodStoreScreen` (se borra) ni se mezcla un cambio visual en el PR #117, y la redacción final del requisito de `bottom-navigation` de este change parte del texto que deja aquel (por eso el delta ya dice "Premium"). Si el orden de archivo se invierte, hay que rebasar el delta.

## Risks / Trade-offs

- [Ícono nuevo en las tiendas sin que las capturas y el header coincidan] → regenerar todo el arte desde los scripts en el mismo PR y subirlo a las tiendas junto con el binario que trae el ícono nuevo.
- [Capturas con UI de la app vieja en una tienda mientras la otra ya tiene la nueva] → subir iOS y Android el mismo día, o dejar las capturas hasta que la versión esté aprobada.
- [Se pierde un morado con identidad reconocible en usuarios actuales] → es un cambio de color de marca de bajo contenido semántico (sin copy ni pantallas nuevas); se anuncia solo en las notas de versión si la 1.10.0 ya las cubre.
- [El teal parece el color de otro mood] → los mocks lo comparan con Calm y Happy; en el calendario el teal de marca solo aparece en flechas, título y racha, nunca como fondo de un día. Se valida con capturas reales antes de subir el arte.
- [Un `grep` de literales deja algún `0xFF5F3DC4` fuera del token] → tarea de verificación con búsqueda y test de que no quede ninguna referencia a `5F3DC4`, `6C63FF` ni `deepPurple` en `lib/` fuera de `mood_definition.dart`.
- [`flutter_launcher_icons` regenera los íconos de iOS y Android y puede pisar cambios manuales] → ejecutar sobre una rama limpia y revisar el diff de los `mipmap-*` y del `AppIcon.appiconset`.

## Migration Plan

1. Esperar a que `replace-mood-purchases-with-subscription` esté mergeado (1.10.0 en revisión o publicada).
2. Rama `style/brand-ocean-cyan` desde `main`: token y recoloreo de `lib/`, tests en verde, capturas en simulador.
3. Ícono e imágenes de launch; regeneración con `flutter_launcher_icons`.
4. Sitio y documentos de diseño; el despliegue es automático por push a `main` que toca `site/`, así que se mergea justo antes de publicar la versión con el ícono nuevo.
5. Arte de tienda regenerado y subido a mano (App Store Connect y Play Console) cuando la versión con el ícono nuevo esté aprobada.
6. Rollback: es solo color; revertir el PR de la app y volver a subir el arte anterior (que sigue en `aso/` en git).

## Open Questions

- Ícono en degradado `#00727D → #00838F` en vez de plano, si el plano se ve apagado (decidir con el ícono real en la pantalla de inicio de un iPhone).
- Qué versión lleva el cambio (1.10.x o una 1.11.0) una vez cerrada la suscripción.
