## Why

El launch screen actual es un fondo blanco sin imagen en Android, y un placeholder vacío en iOS. Apple advirtió sobre esto durante el build del IPA. Un launch screen con la identidad visual de la app mejora la primera impresión y cumple los requisitos de App Store.

## What Changes

- **iOS**: Actualizar `LaunchScreen.storyboard` con fondo púrpura (`#5F3DC4`) y el icono de la app (`app_icon.png`) centrado
- **iOS**: Reemplazar los assets `LaunchImage.png/@2x/@3x` con el icono de la app redimensionado
- **Android**: Actualizar `launch_background.xml` con fondo púrpura (`#5F3DC4`) y el icono centrado
- **Android**: Agregar `colors.xml` con el color del launch screen, y copiar el icono como drawable

## Capabilities

### New Capabilities
- `branded-launch-screen`: Pantalla de inicio con identidad visual de la app en iOS y Android

### Modified Capabilities

## Impact

- `ios/Runner/Base.lproj/LaunchScreen.storyboard` — fondo púrpura, imagen centrada
- `ios/Runner/Assets.xcassets/LaunchImage.imageset/` — reemplazar PNGs con el icono de la app
- `android/app/src/main/res/drawable/launch_background.xml` — fondo púrpura + icono centrado
- `android/app/src/main/res/drawable/launch_icon.png` — icono copiado como drawable
- `android/app/src/main/res/values/colors.xml` — color `launch_background` = `#5F3DC4`
