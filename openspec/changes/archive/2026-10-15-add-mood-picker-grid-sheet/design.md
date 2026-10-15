## Context

`MoodScreen` (`lib/features/mood/presentation/screens/mood_screen.dart`) muestra un `PageView.builder` de 260 pt sobre `_orderedMoods` (orden congelado por `_fixedOrderedMoods`) y una fila de `Container` de 8 pt por mood como indicador. `_onPageChanged` actualiza `_currentPage` y `selectedMood`; los Moods bloqueados abren `showMoodPurchaseSheet`. El selector ya soporta texto al 200 % (spec vigente).

## Goals / Non-Goals

**Goals:**
- Llegar a cualquier mood en un toque, sin recorrer el carrusel.
- Un indicador de posición que no dependa de cuántos moods hay.

**Non-Goals:**
- Cambiar el orden, el carrusel grande o el congelamiento del orden.
- Agrupar por packs o secciones (no se esperan muchos moods por ahora).
- Reemplazar el carrusel por una cuadrícula como pantalla principal.

## Decisions

- **Contador "N / M" en vez de ventana de puntos.** Un `Text` ocupa siempre lo mismo y es trivial de probar; la ventana deslizante añade lógica de bordes sin dar más información. Alternativa descartada: puntos solo si M ≤ 8, porque dos modos de indicador duplican el código y el caso común (10 moods) ya los superaría.
- **El botón vive en la fila del indicador**, a la derecha del contador (`Icons.grid_view_rounded`, `Semantics` con `moodGridButtonLabel`), para no tocar el encabezado ni el botón de nota. Objetivo táctil mínimo de 44 pt.
- **Hoja inferior vía `showModalBottomSheet`** (`isScrollControlled`, `useSafeArea`), como las demás hojas de la app; se muestra sobre el bottom bar. Widget nuevo `MoodGridSheet` en `presentation/widgets/`, sin estado propio: recibe `moods` (ya ordenados), `selectedId`, `isLocked(mood)` y `onSelect(mood)`.
- **Cuadrícula** `GridView.builder` de 4 columnas (2 si el texto supera 1.5×, para que los nombres quepan a su tamaño real) con celdas de emoji (56 px) + nombre en una o dos líneas; desplazable, así que el 200 % no desborda.
- **Salto reutiliza el carrusel**: `onSelect` cierra la hoja y llama `_pageController.animateToPage(index)`; `_onPageChanged` ya actualiza `_currentPage` y `selectedMood`, así que la nota y la fecha no se tocan. Si el mood es bloqueado, se llama `_openPurchaseFlow` sin mover el carrusel. Se usa `jumpToPage` si `MediaQuery.disableAnimations`.
- **Orden**: la hoja recibe `_orderedMoods` del estado actual, nunca recalcula.
- **Strings nuevos** (en 5 idiomas): `moodGridButtonLabel` ("Ver todos los moods") y `moodGridTitle` ("Todos los moods"). El contador no se localiza.

- **Vecinos visibles**: `PageView` con `viewportFraction` 0.5; cada página se escala (1 → 0.6) y se atenúa (1 → 0.5) según su distancia a `page` del controlador (`AnimatedBuilder`). Solo el seleccionado muestra su nombre. Alternativa descartada: solo flechas, porque el gesto sigue sin ser evidente.
- **Ancho de página con tope**: `viewportFraction = min(0.5, 240 / ancho de pantalla)`. En iPhone queda 0.5; en iPad (1032 pt) las páginas miden 240 pt y los vecinos quedan cerca. El `PageController` es de fracción fija, así que `_syncViewportFraction` lo recrea (nueva `Key`) cuando cambia el ancho (rotación), conservando la página.
- **Botón Guardar con tope de 420 pt** (`FloatingTabBar.maxWidth`, el mismo de la barra inferior): en iPhone sigue a todo el ancho y en iPad queda alineado con la barra. Solo en esta pantalla; los demás `GradientPillButton` no cambian.
- **Carrusel a todo el ancho**: el padding horizontal de 16 pt sale de la columna de la pantalla y lo ponen el encabezado, los controles y el botón Guardar (`_screenGutter`); así los vecinos se asoman desde el borde de la pantalla y sus toques/gestos funcionan en toda esa franja (un `OverflowBox` los dejaría sin hit test).
- **Flechas ‹ ›** a los lados del contador (no sobre el emoji, para no tapar a los vecinos); el botón de cuadrícula va centrado debajo del contador. Se deshabilitan en los extremos. Comparten con la hoja un único `_goToPage(index)` (animado, o `jumpToPage` con animaciones desactivadas).
- **Toque en vecinos**: un vecino (índice distinto de `_currentPage`) solo se centra; únicamente el seleccionado bloqueado abre la compra. Así un deslizamiento corto no compra por accidente.
- **Strings**: además `previousMoodLabel` y `nextMoodLabel`.

## Risks / Trade-offs

- **Dos formas de elegir** (swipe y hoja) → la hoja es secundaria y el carrusel sigue siendo el camino principal.
- **`animateToPage` largo** pasa por moods intermedios → en el carrusel `PageView` construye lazy y el salto dura ~300 ms; aceptable y coherente con el swipe.
- **Retorno de una compra desde la hoja**: al desbloquear, el orden no cambia hasta volver a la pestaña (comportamiento ya especificado).
