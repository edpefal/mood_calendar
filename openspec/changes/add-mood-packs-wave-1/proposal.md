## Why

El catálogo tiene solo 5 moods premium y la tienda ya no ofrece novedad. El set de emojis disponible (`983034-emoji`) trae ~19 caras claras y sin usar, y los packs son la palanca de ingreso con mejor relación valor/esfuerzo. La release 1.8.4 está en espera de una funcionalidad que la justifique; esta lo es.

## What Changes

- Añadir **9 moods premium** nuevos al catálogo (ids estables): `affectionate`, `hugging`, `laughing`, `sleepy`, `sick`, `hurt`, `crying`, `scared`, `stressed`. Cada uno con su SVG, color y nombre localizado en los 5 idiomas.
- Vender cada mood suelto a **$0.99** (`mood_<id>_unlock`).
- Crear **3 Packs nuevos** de 3 moods a **$1.99** (33 % de descuento frente a $2.97 sueltos, el mismo precio y descuento que Pack Confianza), lanzados juntos:
  - **Afecto** (`pack_afecto_unlock`): affectionate, hugging, laughing
  - **Cuerpo** (`pack_cuerpo_unlock`): sleepy, sick, hurt
  - **Intenso** (`pack_intenso_unlock`): crying, scared, stressed
- `giggly`, `nauseous` y `weary` se dejan para una segunda ola (emoji más sutil o solapado con otro mood del mismo pack).
- Pack Confianza (brave + confident + romantic) **no cambia** (ADR 0002).
- Los moods base y los 5 premium existentes no cambian; el catálogo pasa a 19 (5 base, 14 premium).
- No hay cambios de comportamiento en el selector, calendario, exportación ni resumen: los moods nuevos entran por el catálogo existente.

## Capabilities

### New Capabilities
<!-- ninguna -->

### Modified Capabilities
- `premium-moods`: el catálogo incluye los 9 moods premium nuevos, con ids estables y orden definido.
- `mood-store`: la Tienda ofrece los 3 Packs nuevos y los 9 moods sueltos, sin alterar Pack Confianza.

## Impact

- **Código**: `mood_definition.dart` (9 entradas), `assets/icon/*.svg` (9 nuevos), `moodNames` en `app_strings_{en,es,de,fr,it}.dart`, tests de catálogo/resolver/orden del selector/tienda.
- **Servicios externos**: App Store Connect (12 productos no consumibles con nombre, descripción y captura de revisión localizados) y RevenueCat (12 productos, 9 entitlements `mood_<id>`, 12 paquetes en la oferta `default`, 3 claves de metadata `pack_<id>_moodIds`). No requiere cambios en `MoodEntitlementsRepositoryImpl`: ya descubre moods y packs por prefijo de paquete y metadata.
- **Release**: entra en 1.8.4 (bump de `pubspec.yaml`, build con `scripts/build_ios_release.sh`, What's New y promo text en 5 idiomas).
- **Riesgos**: colores `MaterialColor` que obligan a repetir 2 entre packs distintos; el descubrimiento de packs depende de configuración externa, un error ahí se ve como tienda vacía (ver rechazo 2.1(b)).
