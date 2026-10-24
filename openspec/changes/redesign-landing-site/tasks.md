## 1. Dirección de diseño

- [x] 1.1 Ejecutar `/impeccable init` y guardar `PRODUCT.md` (público: tráfico de redes y tiendas; promesa: gratis para descargar y privada). Hecho: plataforma `web`, usuario "registro diario simple y privado", sin pruebas citables.
- [x] 1.2 Ejecutar `/impeccable shape` para la landing (modo Persuade) y fijar tono, composición del héroe y si habrá animación; las legales se tratan como modo Read. Hecho: estructura "La página es el selector", ver decisión 10 de `design.md`.
- [ ] 1.3 Opcional: `/impeccable document` para dejar `DESIGN.md` con los tokens del sistema de marca (púrpura `#5F3DC4`→`#6C63FF`, Poppins, pasteles por mood).

## 2. Activos

- [x] 2.1 Copiar Poppins (500 y 700, o los pesos que fije el diseño) de `tool/screenshots/fonts/` a `site/fonts/` con su licencia OFL.
- [x] 2.2 Copiar a `site/img/` los SVG de `happy`, `calm`, `neutral`, `sad` y `angry` desde `assets/icon/`, optimizados, y confirmar que cada uno pesa pocos KB.
- [x] 2.3 Generar la captura limpia del calendario (sin slide ni titular) en en y es con `capture.py`; exportar a WebP/JPEG a ~390 y ~780 px de ancho y comprobar el peso.
- [x] 2.4 Derivar `site/img/og-en.jpg` y `og-es.jpg` (1200×630) de `aso/header/<idioma>/header_search_5244x2950.png`, menos de ~300 KB cada una.
- [x] 2.5 Descargar los badges oficiales de App Store y Google Play (en y es) respetando sus guías de uso, y guardarlos en `site/img/`.
- [x] 2.6 Retirar de `site/img/` las capturas de slide que dejen de usarse (`*-01_calendar.jpg`, `*-02_moods.jpg`, `*-04_notes.jpg`) solo cuando ninguna página las referencie.

## 3. Estilos compartidos

- [x] 3.1 Reescribir `site/style.css` con tokens en `:root`, modo oscuro, `@font-face` de Poppins con `font-display: swap` y la pila de respaldo del sistema.
- [x] 3.2 Definir cabecera, pie y bloques de la home (héroe, captura en marco de teléfono, privacidad, descarga) móvil primero, con objetivos táctiles de al menos 44 px y contraste AA.
- [x] 3.3 Añadir `@media (prefers-reduced-motion)` a cualquier animación y verificar que la página funciona con ella desactivada.

## 4. Landing

- [x] 4.1 Reescribir `site/index.html`: héroe con las 5 caritas, titular, descripción corta ("gratis para descargar y usar"), badges y captura con `srcset`, `width`/`height` y `alt` descriptivo.
- [x] 4.2 Añadir el bloque de privacidad (entradas solo en el dispositivo, sin cuenta, sin ID de publicidad) con enlace a la política; revisar que cada frase coincide con `site/privacy/` y con "Privacidad y declaraciones de las tiendas" de `CLAUDE.md`.
- [x] 4.3 Añadir metadatos: `description`, `canonical`/`hreflang` (se conservan), `og:*`, `twitter:card`, `theme-color` y `apple-itunes-app`.
- [x] 4.4 Repetir 4.1–4.3 en `site/es/index.html` con el texto traducido, sin afirmar que todos los moods sean gratis ni mencionar precios.

## 5. Páginas legales y de soporte

- [x] 5.1 Aplicar la nueva cabecera, pie y hoja de estilos a `privacy`, `terms` y `support` en `site/` y `site/es/` sin tocar su texto ni sus URLs.
- [x] 5.2 Verificar con `git diff` que el contenido de `<article>` de esas 6 páginas no cambió (solo cabecera, pie y enlaces de estilo).

## 6. Verificación

- [x] 6.1 Servir `site/` en local y capturar las 8 páginas a 390, 768 y 1280 px en claro y oscuro; corregir lo que se vea mal.
- [x] 6.2 Comprobar que la primera pantalla a 390 pt muestra caritas, "gratis", la línea de privacidad y los dos badges sin scroll, y que la sección de la captura del calendario empieza justo debajo (decisión 10).
- [x] 6.3 Correr Lighthouse en la home en y es (móvil): rendimiento, accesibilidad y SEO sin regresiones, peso de la carga fría por debajo de ~300 KB.
- [x] 6.4 Verificar que no hay peticiones a dominios externos salvo los enlaces de salida (`curl`/red del navegador) y que los enlaces de tienda, contacto y las 8 páginas responden.
- [x] 6.5 Comparar en y es: mismas secciones, mismos enlaces, `alt` traducidos y fecha de actualización de la política intacta.
- [ ] 6.6 Tras abrir el PR, revisar la vista previa de Vercel en un teléfono real (iOS y Android) y la tarjeta de compartir con un depurador de Open Graph.

## 7. Documentación y cierre

- [x] 7.1 Actualizar `CLAUDE.md`: estado actual (Android 1.8.5 ya publicado, no "en revisión") y la sección "Sitio web" (Poppins, imágenes og, badges, cómo regenerar la captura y las caritas).
- [ ] 7.2 Abrir el PR en la rama `feat/redesign-landing-site` con commits `feat(site)`/`docs`, esperar "Analyze and Test" y mergear.
- [ ] 7.3 Borrar la rama (remota y local) y archivar el change con `/opsx:archive`.
