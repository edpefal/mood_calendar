## Why

La landing de `moodcalendar.app` es hoy una plantilla genérica: hero con degradado plano, cuatro tarjetas idénticas y tres capturas de App Store a 194 px que traen su propio titular incrustado. No muestra lo más reconocible de la app (las caritas y sus colores pastel), usa la fuente del sistema en vez de Poppins y, al compartir el enlace, no genera vista previa (`og:image`, `twitter:card`).

El tráfico llega de cuentas de redes sociales y de las fichas de las tiendas: casi todo en móvil, a menudo dentro del navegador interno de Instagram/TikTok, con unos segundos de atención. La app ya está publicada en iOS y Android (los dos enlaces de tienda responden 200), así que la web es ahora la primera impresión de marca y debe reforzar lo que la distingue: es gratis de descargar y privada por diseño.

## What Changes

- Rediseño de la landing (`site/index.html` y `site/es/index.html`), móvil primero:
  - Héroe con una hilera de las 5 caritas base (`happy`, `calm`, `neutral`, `sad`, `angry`) sobre su color pastel, el titular y los botones de tienda visibles sin hacer scroll en 390 pt.
  - Una captura grande y limpia (sin titular ni fondo de slide incrustado) en marco de teléfono, regenerada con los scripts de `tool/screenshots/`, en lugar de los tres slides pequeños en carrusel. Con `alt` descriptivo.
  - Bloque de privacidad como argumento (las entradas viven solo en el dispositivo, sin cuenta, sin ID de publicidad), que reemplaza las cuatro tarjetas genéricas. Solo afirma lo que la app y la política ya declaran.
  - Copy "gratis para descargar y usar". No afirma que todos los moods sean gratis: 5 son base y 14 son premium; la web no menciona precios ni la tienda de moods.
- Botones de tienda con los badges oficiales de App Store y Google Play (hoy son píldoras de texto), ambos enlaces activos.
- Poppins autoalojada (`tool/screenshots/fonts/`, licencia OFL) en `site/`, sin fuentes, scripts ni analíticas de terceros.
- Metadatos para compartir: `og:image` 1200×630 por idioma (derivada de `aso/header/`), `og:*`, `twitter:card` y `theme-color`.
- Pase ligero de tipografía, cabecera y pie sobre `privacy`, `terms` y `support` (en y es): mismo CSS compartido, sin cambiar su texto ni sus URLs.
- Accesibilidad: contraste AA, `prefers-reduced-motion` si hay animación, `alt` descriptivos, objetivos táctiles de al menos 44 px, modo oscuro conservado.
- `CLAUDE.md`: reflejar que Android ya está publicado y describir los nuevos activos del sitio.

Fuera de alcance:
- Contenido legal (política, términos, soporte): solo estilo, nunca texto.
- Mencionar la tienda de moods, precios o los moods premium en la web.
- Backend, formularios, analíticas del sitio o cualquier script de terceros.
- Cambios en la app Flutter.

## Capabilities

### New Capabilities
(ninguna)

### Modified Capabilities
(ninguna — es un cambio visual y de contenido del sitio estático, sin cambio de requisitos de comportamiento de la app. Por eso el change declara `skip_specs: true`.)

## Impact

- `site/index.html`, `site/es/index.html`: reescritura de la landing.
- `site/style.css`: nuevo CSS compartido (tokens, tipografía, héroe, privacidad, legales).
- `site/privacy/`, `site/terms/`, `site/support/` y sus versiones en `site/es/`: solo se enlazan los nuevos estilos y se ajusta el marcado de cabecera y pie; el texto no cambia.
- `site/fonts/` (Poppins woff2), `site/img/` (captura nueva, `og-en.png`, `og-es.png`, badges de tienda y SVG de las 5 caritas base).
- `tool/screenshots/`: posible ajuste para generar la captura sin marco de slide.
- `CLAUDE.md`: sección de estado actual y "Sitio web".
- Despliegue: automático en Vercel al hacer merge a `main` (el proyecto ya tiene `site/` como raíz). Ninguna dependencia nueva ni paso de build.
- Pendiente antes de implementar: `/impeccable init` y `shape` para fijar el tono (hipótesis: cálido y tranquilo).
