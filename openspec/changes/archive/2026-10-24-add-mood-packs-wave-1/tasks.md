## 1. Verificación previa

- [x] 1.1 Leer `/Users/eder/Downloads/983034-emoji/license/license.pdf` y confirmar uso comercial en app de pago y si exige atribución; anotar el resultado en `design.md`
- [x] 1.2 Confirmar los ids definitivos (en especial `affectionate` vs `kiss`) y la asignación de colores
- [x] 1.3 Revisar los 12 emojis (9 finales tras la decisión de packs de 3) a tamaño de calendario (~40 pt) y sustituir los que no se distingan

## 2. Assets y catálogo

- [x] 2.1 Copiar los 9 SVG a `assets/icon/<id>.svg` (ver tabla de `design.md`) y verificar que cada uno pese pocos KB y se renderice con `flutter_svg`
- [x] 2.2 Añadir las 9 `MoodDefinition` premium a `premiumMoodDefinitions` en el orden de `design.md`, con `intensity` 11–19 y `MaterialColor` asignado
- [x] 2.3 Confirmar que `MoodDefinitionResolver` y `backgroundGradientForMood` generan un gradiente legible para cada color nuevo

## 3. Localización

- [x] 3.1 Añadir los 9 nombres a `moodNames` en `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart` y `app_strings_it.dart`
- [ ] 3.2 Revisar cada traducción viendo el emoji (no el nombre de archivo) y con texto largo en alemán — No se hizo una revisión visual dedicada al archivar.

## 4. Tests

- [x] 4.1 Actualizar o añadir tests de catálogo: 19 moods, 5 base, 14 premium, ids únicos, `MaterialColor` en todos
- [x] 4.2 Test de que cada id tiene nombre en los 5 idiomas
- [x] 4.3 Test del orden del selector con moods nuevos bloqueados y desbloqueados
- [x] 4.4 Test del repositorio de compras con una oferta que incluya los 3 packs nuevos y sus metadata
- [x] 4.5 Test de exportación con un mood nuevo (`sleepy`)
- [x] 4.6 `flutter analyze` y `flutter test` en verde

## 5. App Store Connect y RevenueCat

- [x] 5.1 Crear en ASC los 9 productos `mood_<id>_unlock` ($0.99) y los 3 `pack_<pack>_unlock` ($1.99), con nombre y descripción en 5 idiomas y captura de revisión
- [x] 5.2 Crear en RevenueCat los 12 productos, los 9 entitlements `mood_<id>` y asociar cada entitlement a su producto y al de su pack
- [x] 5.3 Añadir a la oferta `default` los 12 paquetes `$rc_custom_mood_<id>` y `$rc_custom_pack_<pack>`
- [x] 5.4 Añadir a la metadata de la oferta `pack_afecto_moodIds`, `pack_cuerpo_moodIds` y `pack_intenso_moodIds` sin tocar `pack_confianza_moodIds`
- [x] 5.5 Verificar con el MCP de RevenueCat (`list-offerings`, `list-entitlements`) que la configuración quedó completa (14 entitlements con sus productos, metadata de los 4 packs y 17 paquetes; los últimos 8 se confirmaron en la tienda real del simulador, 6.1)

## 6. Verificación en simulador

- [x] 6.1 Correr con `--dart-define=REVENUECAT_IOS_API_KEY=<key>` en un simulador iPhone limpio y confirmar que la Tienda lista los 4 packs y los 14 moods premium sin errores
- [x] 6.2 Repetir en iPad y confirmar que la UI aparece antes del diálogo de permisos
- [ ] 6.3 Probar una compra sandbox de un mood suelto y de un pack nuevo, y el aviso de solape — No se probó una compra sandbox dedicada al archivar.
- [x] 6.4 Revisar el selector y el calendario con los 19 moods en iPhone 390 pt y con texto grande (selector OK con 19 moods y a ≈190 % de texto; calendario OK con entradas de sleepy, sick, hurt, crying y hugging; la tienda desborda con texto grande, limitación previa fuera de este change)

## 7. Release 1.8.4

- [x] 7.1 Subir la versión en `pubspec.yaml` — Hecho: el cambio ya está publicado (según el usuario), dentro de las versiones 1.8.4 y 1.8.5.
- [x] 7.2 Generar el build con `REVENUECAT_IOS_API_KEY=<key> STORE_VERIFIED=1 scripts/build_ios_release.sh` — Hecho: el cambio ya está publicado (según el usuario), dentro de las versiones 1.8.4 y 1.8.5.
- [x] 7.3 Redactar promotional text y What's New en los 5 idiomas — Hecho: el cambio ya está publicado (según el usuario), dentro de las versiones 1.8.4 y 1.8.5.
- [x] 7.4 Asociar el build y los 12 productos a la versión y enviar a revisión — Hecho: el cambio ya está publicado (según el usuario), dentro de las versiones 1.8.4 y 1.8.5.
- [x] 7.5 Actualizar `CLAUDE.md` (conteo de moods y packs), `CONTEXT.md` si cambia el glosario y `backlog.md` — `CLAUDE.md` ya describe 19 moods (14 premium) y los 4 packs.
