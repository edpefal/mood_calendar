---
name: Mood Calendar (sitio web)
description: Un selector de moods de bolsillo hecho web: caritas sobre pasteles, calma y privacidad.
colors:
  brand: "#5F3DC4"
  brand-signal: "#6C63FF"
  brand-deep: "#3B2494"
  ink: "#1F1637"
  ink-soft: "#2C2650"
  paper: "#FAF8FF"
  muted: "#554E70"
  line: "#E6E1F5"
  card: "#FFFFFF"
  night: "#14111F"
  night-card: "#1D1930"
  night-text: "#F1EEFC"
  night-muted: "#B8B2CE"
  night-heading: "#E4DEFF"
  night-link: "#B3A8FF"
  night-line: "#2E2946"
  bezel: "#17102E"
  happy-from: "#E8F5E9"
  happy-to: "#A5D6A7"
  calm-from: "#E3F2FD"
  calm-to: "#90CAF9"
  neutral-from: "#FAFAFA"
  neutral-to: "#EEEEEE"
  sad-from: "#FFF3E0"
  sad-to: "#FFCC80"
  angry-from: "#FFEBEE"
  angry-to: "#EF9A9A"
typography:
  display:
    fontFamily: "Poppins, system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif"
    fontSize: "clamp(2.1rem, 8.4vw, 3.6rem)"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "clamp(1.7rem, 6vw, 2.6rem)"
    fontWeight: 700
    lineHeight: 1.15
    letterSpacing: "-0.02em"
  title:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "1.1875rem"
    fontWeight: 600
    lineHeight: 1.55
  body:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 500
    lineHeight: 1.65
  label:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "1.0625rem"
    fontWeight: 600
    lineHeight: 1.5
rounded:
  focus: "6px"
  badge: "10px"
  icon: "8px"
  screen: "36px"
  phone: "46px"
  round: "50%"
spacing:
  xs: "8px"
  sm: "14px"
  md: "20px"
  lg: "28px"
  xl: "56px"
  section: "72px"
components:
  picker-nav-button:
    backgroundColor: "transparent"
    textColor: "{colors.brand-deep}"
    rounded: "{rounded.round}"
    size: "48px"
  phone-frame:
    backgroundColor: "{colors.bezel}"
    rounded: "{rounded.phone}"
    width: "300px"
  privacy-block:
    backgroundColor: "{colors.brand}"
    textColor: "#FFFFFF"
    padding: "64px 20px"
---

# Design System: Mood Calendar (sitio web)

## Overview

**Creative North Star: "El selector de bolsillo"**

La web se comporta como la app: una carita grande al centro, un pastel que cambia con ella y todo lo demás en calma. El sitio no explica la app, la deja usar: lo primero que ve una persona es el mismo gesto de elegir cómo se siente, con el color propio de cada mood. Alrededor, la página guarda silencio: aire, un solo mensaje por bloque y una sola pieza de color de marca (el púrpura de la privacidad) para cerrar.

El tono es tranquilo y confiable. Tranquilo, porque casi nada se mueve (solo la carita y su fondo, y sin movimiento si el sistema lo pide). Confiable, porque la privacidad se dice sin adornos ni promesas vagas, sobre el púrpura sólido de la marca. Las caritas llevan toda la expresividad; el resto es tipografía, espacio y planos de color.

**Key Characteristics:**
- Móvil primero: la primera pantalla de 390 pt contiene titular, carita, selector y los dos badges.
- Color de dos fuentes: los pasteles de cada mood (los de la app) y el púrpura de marca, nunca mezclados en la misma superficie.
- Planos y suaves: superficies planas; solo el teléfono lleva sombra.
- Funciona sin JavaScript y sin movimiento; el script solo añade el cambio de color, nombre y contador.
- Sin recursos de terceros: Poppins autoalojada y nada que cargue desde otro dominio.

## Colors

Una paleta de dos voces: pasteles de mood en el héroe y púrpura de marca en el cierre, sobre un papel lavanda muy claro (o un negro violáceo en modo oscuro).

### Primary
- **Violeta de Marca** (#5F3DC4): botones y enlaces en claro, inicio del bloque de privacidad y fondo del ícono. Es el color de la app y de la tienda.
- **Violeta Señal** (#6C63FF): extremo del degradado de marca y anillo de foco.
- **Violeta Profundo** (#3B2494): titulares de sección, el selector ‹ n / 5 › y el final del degradado de privacidad.

### Secondary
- **Pasteles de mood**: cada mood base va de un tono muy claro a uno medio, tomados de la escala 50 y 200 de los colores Material de la app. Feliz verde (#E8F5E9 → #A5D6A7), Tranquilo azul (#E3F2FD → #90CAF9), Neutral gris (#FAFAFA → #EEEEEE), Triste naranja (#FFF3E0 → #FFCC80) y Enojado rojo (#FFEBEE → #EF9A9A). Solo se usan como fondo del héroe, en diagonal de arriba-izquierda a abajo-derecha.

### Neutral
- **Tinta de Noche Suave** (#1F1637): texto principal en claro y titular sobre pastel.
- **Tinta Secundaria** (#2C2650): línea de apoyo bajo el titular, sobre pastel.
- **Papel Lavanda** (#FAF8FF): fondo en claro.
- **Gris Violeta** (#554E70): texto de apoyo y pie.
- **Línea Lila** (#E6E1F5): divisores y borde del pie.
- **Noche Violeta** (#14111F), con tarjeta (#1D1930), texto (#F1EEFC), apoyo (#B8B2CE), titular (#E4DEFF), enlace (#B3A8FF) y línea (#2E2946): el modo oscuro.
- **Bisel del Teléfono** (#17102E): marco del teléfono, el mismo en claro y en oscuro.

### Named Rules
**The Two Voices Rule.** Un pastel de mood y el púrpura de marca nunca comparten superficie: el pastel pertenece al selector, el púrpura al cierre de privacidad. Mezclarlos diluye a ambos.

**The Mood Owns The Hero Rule.** El fondo del héroe es siempre el degradado del mood seleccionado; no se fija un color de marca encima de él.

## Typography

**Display Font:** Poppins 700 (con respaldo del sistema)
**Body Font:** Poppins 500 (con respaldo del sistema)
**Label/Mono Font:** Poppins 600; no hay mono.

**Character:** La misma Poppins redondeada de la app y de las tiendas, con pesos altos y apretados para los titulares y un cuerpo cómodo y pausado. Al compartir fuente con la app, el salto de la tienda a la web no cambia de voz.

### Hierarchy
- **Display** (700, clamp(2.1rem, 8.4vw, 3.6rem), 1.15): el titular del héroe en dos líneas ("Pick one." / "Free to download.").
- **Headline** (700, clamp(1.7rem, 6vw, 2.6rem), 1.15): títulos de sección; sobre privacidad sube a clamp(1.9rem, 7vw, 3.2rem).
- **Title** (600, 1.1875rem, 1.55): los encabezados de cada punto de privacidad.
- **Body** (500, 1rem a 1.0625rem, 1.65): párrafos, con medida máxima de 52ch.
- **Label** (600, 1.0625rem): el nombre del mood y el contador `2 / 5` (cifras tabulares).

### Named Rules
**The Two Weights Rule.** Los titulares son 700 y todo lo demás 500 o 600. No se añade otro peso ni cursiva.

**The Balanced Headline Rule.** Todo titular usa `text-wrap: balance` y un interletrado de -0.02em; nunca por debajo de -0.04em.

## Layout

Una sola columna centrada, a ancho completo en móvil y con un contenedor de 1040 px en escritorio (960 px en las páginas de lectura, 720 px para el artículo). La página se ordena de arriba abajo: héroe a pantalla completa, un bloque con la captura del calendario, un bloque de privacidad a todo el ancho y una descarga final.

El ritmo vertical es generoso: 72 px sobre cada sección y 20 px de margen lateral en móvil. A partir de 900 px el bloque del calendario pasa a dos columnas (texto a la izquierda, teléfono a la derecha) y el héroe gana aire. La cabecera es transparente y va sobre el héroe en la home; en las demás páginas es una barra normal.

## Elevation & Depth

Plano y suave. Las superficies no tienen sombra: el color, el espacio y los bordes finos bastan. La única excepción es el teléfono, que lleva una sombra amplia y neutra para despegarse del papel.

### Shadow Vocabulary
- **Phone lift** (`box-shadow: 0 36px 60px -28px rgba(0,0,0,.5), 0 12px 24px -12px rgba(0,0,0,.3)`): solo el marco del teléfono.

### Named Rules
**The One Shadow Rule.** Solo el teléfono proyecta sombra. Ningún botón, tarjeta ni badge la lleva, y las sombras son siempre negras translúcidas, nunca de color.

## Shapes

Formas redondas y sin esquinas duras. Los controles circulares son de 48 px (50%), los badges de tienda llevan 10 px de radio, el ícono de la cabecera 8 px y el foco 6 px. El teléfono es la forma grande: 46 px por fuera y 36 px en la pantalla, y se corta de golpe por abajo, como si saliera del borde.

## Components

### Selector de caritas
- **Estructura:** lista horizontal con `scroll-snap`; cada carita ocupa el 80% de su ancho y las vecinas se ven a 40% de escala y 50% de opacidad.
- **Estado actual:** la carita central a escala completa; el cambio dura 0.6 s con una curva exponencial de salida y se anula con movimiento reducido.
- **Controles:** botones circulares de 48 px con chevron de trazo 2.5 px y contador `n / 5` en Violeta Profundo.
- **Sin JavaScript:** una fila de caritas que se desliza a mano.

### Teléfono
- Marco de 10 px en Bisel del Teléfono, corte inferior sin borde y la captura limpia del calendario; ancho máximo de 300 px y alto de 480 px.

### Bloque de privacidad
- Degradado de Violeta Profundo a Violeta de Marca a todo el ancho, titular blanco de hasta 16ch y tres puntos separados por una línea blanca al 28%. Texto de apoyo en #EDE9FF (contraste 6:1 o más).

### Badges de tienda
- Los oficiales de App Store y Google Play, tal cual los entregan Apple y Google, a 48 px de alto. No se recolorean ni se recortan. El de Google Play lleva un margen negativo para compensar su espacio libre.

### Enlaces y pie
- Enlaces subrayados con desplazamiento de 0.2em, en Violeta de Marca (claro) o #B3A8FF (oscuro). El pie y la cabecera son idénticos en las ocho páginas, con objetivos táctiles de al menos 44 px.

## Do's and Don'ts

### Do:
- **Do** dejar que el mood seleccionado tiña todo el héroe con su degradado de la app.
- **Do** mantener la primera pantalla de 390 pt con titular, carita, selector y los dos badges sin hacer scroll.
- **Do** usar Poppins autoalojada y nada que cargue desde otro dominio.
- **Do** mantener un contraste mínimo de 4.5:1 en texto de cuerpo y 3:1 en grande, en claro y en oscuro.
- **Do** mantener la edición en inglés y en español a la vez, con el mismo marcado.

### Don't:
- **Don't** mezclar un pastel de mood con el púrpura de marca en la misma superficie.
- **Don't** poner sombra a nada que no sea el teléfono, ni sombras de color.
- **Don't** usar texto con degradado, ni tarjetas idénticas de ícono más título como estructura de página.
- **Don't** afirmar que todos los moods son gratis ni mostrar precios; la web dice "gratis para descargar y usar".
- **Don't** modificar, recolorear ni recortar los badges oficiales de las tiendas.
- **Don't** tocar el texto de las páginas legales por motivos de diseño.
