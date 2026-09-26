## Context

El icono de la app (`assets/icon/app_icon.png`) es un ícono cuadrado púrpura con un emoji blanco. El color principal de la app es `#5F3DC4` (también usado en las cards del resumen mensual). La idea es un launch screen sólido: fondo `#5F3DC4` full screen, icono centrado.

## Goals / Non-Goals

**Goals:**
- Fondo de pantalla completa en `#5F3DC4` en ambas plataformas
- Icono de la app centrado horizontal y verticalmente
- Resolver la advertencia de Apple sobre el placeholder de launch image

**Non-Goals:**
- Animaciones en el launch screen
- Launch screen adaptativo (dark mode) — se usa el mismo color en ambos modos
- Usar Flutter's `flutter_native_splash` package — se editan los archivos nativos directamente

## Decisions

**Color**: `#5F3DC4` — es el color inicio del gradiente usado en las cards, representa bien el brand.

**iOS — enfoque storyboard**:
- Editar `LaunchScreen.storyboard` directamente: cambiar `backgroundColor` de blanco a `#5F3DC4`
- La imagen `LaunchImage` ya está referenciada en el storyboard; se reemplazan los PNG assets
- El icono se redimensiona: 1x=167px, 2x=334px, 3x=500px (tamaño razonable para launch screen centrado)

**Android — enfoque drawable layer-list**:
- `launch_background.xml` ya usa un `layer-list`; se cambia el color de fondo a `@color/launch_background` y se añade un item con el icono centrado
- El icono se copia desde `assets/icon/app_icon.png` a `res/drawable/launch_icon.png`
- Se define `launch_background = #5F3DC4` en `res/values/colors.xml`

## Risks / Trade-offs

- [El icono es cuadrado con esquinas redondeadas — en iOS el launch screen no aplica el mask de icono] → Se ve como cuadrado redondeado, que es correcto y consistente con el ícono de la app
- [En Android el tamaño del icono en pantallas muy pequeñas puede quedar grande] → Usar `android:gravity="center"` con tamaño fijo en dp como fallback natural
