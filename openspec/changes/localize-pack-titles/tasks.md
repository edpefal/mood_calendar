## 1. Cadenas

- [x] 1.1 Añadir `packNames` y `packName(packId, fallback)` a `AppStrings` y los nombres de los 4 Packs en en, es, de, fr, it
- [x] 1.2 Test de cadenas: los 5 idiomas definen los 4 Packs, el fallback a inglés y el título de la tienda para un Pack desconocido

## 2. UI

- [x] 2.1 La Tienda usa `packName` para el título del Pack
- [x] 2.2 La hoja de compra del Pack usa `packName` (título y etiqueta de accesibilidad)
- [x] 2.3 Tests: un título de tienda con sufijo "(unreviewed)" se muestra como el nombre de la app; un Pack desconocido muestra el título de la tienda

## 3. Cierre

- [x] 3.1 `flutter analyze` y `flutter test` limpios
- [ ] 3.2 Sincronizar el spec `mood-store` y archivar con `/opsx:archive`
