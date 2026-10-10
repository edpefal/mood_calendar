## Why

El bottom bar se anuncia como cápsula translúcida, pero en la práctica parece casi opaco: con un blanco al 72 % y un desenfoque fuerte (sigma 20) el contenido que pasa por debajo (p. ej. el botón "Restore purchases" en la Tienda) apenas se distingue. El efecto de "cristal" no se percibe y el bar se ve como una barra blanca plana.

## What Changes

- Se reduce la opacidad del relleno de la cápsula y el sigma del desenfoque, de modo que el contenido que queda detrás sea reconocible (formas y colores) sin dejar de ser legible el icono de cada pestaña.
- Se refuerza el borde y la sombra lo justo para que la cápsula siga separándose del fondo con menos relleno.
- El requisito de apariencia pasa de "desenfoca el contenido" (que un blur fuerte cumple sin dejar ver nada) a exigir que el contenido de debajo sea reconocible a través del bar.
- Sin cambios en tamaño, posición, pestañas, píldora activa ni en cómo las pantallas reservan espacio.

## Capabilities

### New Capabilities

### Modified Capabilities
- `bottom-navigation`: el requisito "Apariencia del bar como cápsula translúcida flotante" exige que el contenido detrás del bar se pueda reconocer, no solo que esté desenfocado.

## Impact

- `lib/core/widgets/floating_tab_bar.dart`: valores de `ImageFilter.blur`, alpha del relleno, borde y sombra.
- Sin cambios en datos, strings, compras ni dependencias. Verificación visual en simulador (Tienda y Ajustes, con contenido bajo el bar).
