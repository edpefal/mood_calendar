## Context

`site/` es un sitio estático bilingüe escrito a mano (inglés en `/`, español en `/es/`), sin build, con un único `style.css` de ~2 KB y desplegado por Vercel en cada push a `main` que cambie `site/`. Ver `CLAUDE.md` → "Sitio web" y `proposal.md` para el motivo.

Restricciones que condicionan el enfoque:

- Cada página existe dos veces (en y es) y no hay plantillas: cualquier bloque compartido se duplica a mano, así que el marcado debe ser pequeño y estable.
- La marca promete privacidad: el sitio no puede cargar fuentes, scripts, píxeles ni analíticas de terceros.
- Las URL de `privacy`, `terms` y `support` están registradas en App Store Connect, Play Console y dentro de la app (`privacyPolicyUrl`). No cambian de ruta ni de texto.
- Las capturas de `site/img/` son slides de App Store (titular y fondo pastel incrustados), reutilizados tal cual; no sirven como imagen principal.
- Poppins ya existe como `woff2` (500/600/700, OFL) en `tool/screenshots/fonts/`. `brave.svg` pesa 1 MB y no se usa.
- La hipótesis de tono (cálido y tranquilo) y el sistema visual concreto los fijan `/impeccable init` y `shape` antes de implementar. Este documento decide la estructura y las restricciones técnicas, no los valores finales de color o espaciado.

## Goals / Non-Goals

**Goals:**
- Que en 390 pt, sin scroll, se vea qué es la app (caritas + captura), que es gratis y los dos botones de descarga.
- Peso total de la home por debajo de ~300 KB en una carga fría (HTML, CSS, fuente, imágenes above-the-fold), sin JavaScript necesario para leerla.
- Una sola hoja de estilos compartida por la home y las páginas legales, con tokens del sistema de marca.
- Vista previa decente al compartir el enlace en redes y mensajería.

**Non-Goals:**
- Introducir un generador de sitios, plantillas o paso de build.
- Detección de plataforma con JS para elegir un único botón (ver decisión 5).
- Rediseñar o reescribir el contenido legal.
- Hablar de precios, Packs o moods premium en la web.

## Decisions

1. **Landing de una sola página corta: héroe → captura → privacidad → descarga.**
   El tráfico de redes decide en segundos; cada sección extra baja la conversión de la primera. *Alternativas:* landing larga con una sección por función (se parece a la plantilla actual); página de enlaces tipo "link in bio" (pierde la ficha de marca y el SEO de `moodcalendar.app`).

2. **Las 5 caritas base como héroe, incrustadas como SVG inline o `<img>` de `site/img/`, copiadas de `assets/icon/` (`happy`, `calm`, `neutral`, `sad`, `angry`).**
   Pesan entre 2 y 4 KB cada una, son el activo más reconocible y coinciden con lo gratuito, así que la web no promete moods de pago. El color pastel de cada mood sale de su `MaterialColor` (`.shade50`/`.shade200`), igual que `MoodDefinitionResolver.backgroundGradientForMood`, para no inventar una paleta aparte. *Alternativa:* mostrar los 19 moods (descartada: obliga a hablar de premium y arrastra `brave.svg`).

3. **Captura nueva, grande y sin slide, con marco de teléfono en CSS.**
   Se regenera con `capture.py` desde el simulador (calendario del mes sembrado) y se recorta la pantalla, sin titular. Se exporta en WebP/JPEG con `srcset` (≈390 y ≈780 px de ancho) y dimensiones explícitas para evitar saltos de maquetación. *Alternativa:* seguir con los slides actuales (descartada: texto incrustado en un solo idioma por imagen, ilegible a 194 px y duplica el titular de la página).

4. **Tipografía: Poppins autoalojada en `site/fonts/` con `@font-face` y `font-display: swap`, solo los pesos 500 y 700 si el diseño final lo permite.**
   Misma voz que la app y las tiendas, sin petición a terceros. Pila de respaldo del sistema para el primer pintado. *Alternativa:* Google Fonts (descartada por la promesa de privacidad y por la latencia en redes móviles).

5. **Botones de tienda: los dos visibles, con badges oficiales, sin JavaScript.**
   Dentro de los navegadores internos de redes la detección de plataforma es poco fiable y añade JS. Se muestran ambos, en orden por idioma/convención, y se añade `<meta name="apple-itunes-app" content="app-id=6752843360">` para que Safari ofrezca su banner nativo. Los badges se descargan de las guías oficiales de Apple y Google, se guardan como SVG/PNG locales y se respetan sus reglas de espacio libre y de no modificación. *Alternativa:* resaltar un botón según `navigator.userAgent` (descartada: más código, falla en webviews, no aporta si ambos caben en pantalla).

6. **Metadatos de compartir por idioma: `og:title`, `og:description`, `og:image` (1200×630), `og:locale`, `twitter:card=summary_large_image`, `theme-color`.**
   La imagen se deriva de `aso/header/<idioma>/header_search_5244x2950.png` recortando al centro 1200×630 (el contenido ya vive en la zona central por diseño) y se guarda como `site/img/og-en.png` / `og-es.png`, bajo ~300 KB. Las URL son absolutas (`https://moodcalendar.app/img/...`). *Alternativa:* una sola imagen para ambos idiomas (descartada: el lema de la imagen va traducido).

7. **Un solo `style.css` con tokens (`:root`) y modo oscuro, compartido por home y legales.**
   Las páginas legales conservan su `<article>` y su texto; solo cambian cabecera, pie y estilos. El pie y la cabecera pasan a ser un marcado idéntico en las 8 páginas, para poder verificar la consistencia con un `grep`. *Alternativa:* CSS aparte para la home (descartada: dos sistemas que se desincronizan).

8. **Movimiento mínimo y opcional.**
   Si el diseño final incluye animación de las caritas, será solo CSS, sin librerías, bajo `@media (prefers-reduced-motion: no-preference)` y sin que nada dependa de ella para entender la página.

9. **Verificación visual obligatoria antes del PR:** capturas a 390, 768 y 1280 px en en y es, en claro y oscuro, con el navegador (Playwright/Chrome); más Lighthouse (rendimiento, accesibilidad, SEO) sobre la home y un chequeo de los enlaces de las 8 páginas.

10. **Dirección visual (resultado de `/impeccable shape`): "La página es el selector".**
    La marca queda fija (púrpura `#5F3DC4`→`#6C63FF` como ancla, Poppins, las caritas); lo que se eligió es la estructura. La primera pantalla imita el selector de moods de la app:
    - Marca arriba y selector de idioma a la derecha; sobre un degradado pastel por mood, una carita enorme al centro con las vecinas atenuadas a los lados y el contador `2 / 5` con ‹ ›.
    - Titular "Pick one. Free to download." y una línea de privacidad; los badges de las dos tiendas visibles abajo sin scroll en 390 pt.
    - Deslizar o tocar ‹ › cambia la carita y el degradado (colores de `MoodDefinitionResolver.backgroundGradientForMood` para los 5 moods base). Funciona con teclado, y sin JavaScript la página muestra una carita fija y sigue siendo legible.
    - Bajo el pliegue: la captura grande del calendario, el bloque de privacidad y una descarga final. El boceto aprobado solo cubre la primera pantalla.
    - `prefers-reduced-motion`: el cambio de carita es instantáneo, sin transición.
    Boceto elegido: `.impeccable/mocks/decision/page-is-picker.html` (local, no se publica). *Alternativas descartadas:* "El mes se llena" (calendario que se completa al hacer scroll) y "Elige. Anota. Mira tu mes." (tres verbos sobre el púrpura con un teléfono asomando).
    *Riesgo asumido:* esta estructura explica menos de entrada qué guarda y qué muestra la app. Se compensa acercando al primer scroll la línea de privacidad y la captura del calendario; si la revisión visual (decisión 9) muestra que el mensaje se pierde, la captura sube al primer pliegue.

## Risks / Trade-offs

- [El diseño final puede discrepar de la estructura de aquí] → La estructura (secciones, restricciones técnicas) es estable; los valores visuales se fijan en `init`/`shape` y quedan documentados en `PRODUCT.md`/`DESIGN.md`.
- [Duplicación manual en/es: un cambio se aplica a una sola versión] → Marcado idéntico y simple, y una tarea de verificación que compara las dos versiones (mismas secciones, mismos enlaces, mismos `alt` traducidos).
- [Los badges oficiales tienen reglas de uso y de espacio] → Usar los assets oficiales sin modificarlos; revisar las guías vigentes al descargarlos.
- [La captura envejece cuando cambie la UI de la app] → Documentar en `CLAUDE.md` cómo regenerarla con los scripts existentes y qué archivo reemplazar.
- [Las caritas de `assets/icon/` pueden cambiar de arte] → Se copian a `site/` (no se enlazan al repo de la app); regenerar al cambiar el arte, anotado en `CLAUDE.md`.
- [Cambios en producción sin vista previa] → Vercel crea un deployment de vista previa por PR; revisarlo en móvil real antes de hacer merge.

## Migration Plan

1. Rama `feat/redesign-landing-site` y PR a `main` (CI no cubre `site/`; la verificación es la de la decisión 9).
2. Revisar la vista previa de Vercel del PR en un teléfono real (iOS y Android) y con un depurador de Open Graph para la tarjeta de compartir.
3. Merge: Vercel despliega solo. Rollback: revertir el merge (o `request_rollback` en Vercel al deployment anterior); las URL legales no cambian, así que nada externo se rompe.
4. Actualizar `CLAUDE.md` (Android publicado, activos del sitio) en el mismo PR y archivar el change tras el merge.

## Open Questions

- Si la carita grande lleva un texto propio por mood (por ejemplo una frase distinta) o solo cambia el color, y si el contador `n / 5` se muestra en la web. Se deciden al implementar la primera pantalla y no cambian el desglose de tareas.
- Dónde exactamente entra la captura del calendario bajo el selector (primer scroll o más abajo); se ajusta en la revisión visual.
