## 1. Android

- [x] 1.1 Agregar `#5F3DC4` como `launch_background` en `android/app/src/main/res/values/colors.xml`
- [x] 1.2 Copiar `assets/icon/app_icon.png` a `android/app/src/main/res/drawable/launch_icon.png`
- [x] 1.3 Actualizar `android/app/src/main/res/drawable/launch_background.xml`: fondo `@color/launch_background` + imagen centrada `@drawable/launch_icon`
- [x] 1.4 Repetir para `android/app/src/main/res/drawable-v21/launch_background.xml` si existe

## 2. iOS

- [x] 2.1 Redimensionar `assets/icon/app_icon.png` a 167×167px y reemplazar `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- [x] 2.2 Redimensionar a 334×334px y reemplazar `LaunchImage@2x.png`
- [x] 2.3 Redimensionar a 500×500px y reemplazar `LaunchImage@3x.png`
- [x] 2.4 Actualizar `ios/Runner/Base.lproj/LaunchScreen.storyboard`: cambiar `backgroundColor` de blanco a `#5F3DC4` (red=0.373, green=0.239, blue=0.769)

## 3. Verificación

- [x] 3.1 Correr `flutter build ipa --release` y confirmar que no aparece la advertencia de placeholder
- [ ] 3.2 Correr en simulador iOS y verificar visualmente el launch screen
- [ ] 3.3 Correr en emulador/dispositivo Android y verificar visualmente el launch screen
