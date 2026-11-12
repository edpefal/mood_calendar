---
name: Mood Calendar (sitio web)
description: Un selector de moods de bolsillo hecho web: caritas sobre pasteles, calma y privacidad.
colors:
  ink: "#1D1D22"
  ink-soft: "#3A3A48"
  paper: "#F7F7FA"
  muted: "#575969"
  line: "#E3E2EA"
  card: "#FFFFFF"
  link: "#5646D1"
  ring: "#7C5CFF"
  selection: "#DCD3FF"
  bezel: "#17171B"
  night: "#111114"
  night-card: "#1C1C21"
  night-text: "#F4F3F7"
  night-muted: "#B4B6C3"
  night-heading: "#E5E1FF"
  night-link: "#A396FF"
  night-line: "#2A2A33"
  private-night: "#26262C"
  private-muted: "#CFCFDA"
  log-from: "#B9A6FF"
  log-mid: "#F7B2D9"
  log-to: "#FFD3B6"
  happy-from: "#FFF6DE"
  happy-to: "#E1C78F"
  calm-from: "#E5F8F0"
  calm-to: "#9FD2BE"
  neutral-from: "#F3F1F8"
  neutral-to: "#C2BED2"
  sad-from: "#EEECFF"
  sad-to: "#BAB2F1"
  angry-from: "#FEECEA"
  angry-to: "#EBAFAC"
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
    textColor: "{colors.ink}"
    rounded: "{rounded.round}"
    size: "48px"
  phone-frame:
    backgroundColor: "{colors.bezel}"
    rounded: "{rounded.phone}"
    width: "300px"
  privacy-block:
    backgroundColor: "{colors.ink}"
    textColor: "#FFFFFF"
    padding: "64px 20px"
---

# Design System: Mood Calendar (sitio web)

## Overview

**Creative North Star: "El selector de bolsillo"**

La web se comporta como la app: una carita grande al centro, un pastel que cambia con ella y todo lo demás en calma. El sitio no explica la app, la deja usar: lo primero que ve una persona es el mismo gesto de elegir cómo se siente, con el color propio de cada mood. Alrededor, la página guarda silencio: aire, un solo mensaje por bloque y una sola pieza de tinta (el bloque de privacidad, con un filete del degradado del Log) para cerrar.

El tono es tranquilo y confiable. Tranquilo, porque casi nada se mueve (solo la carita y su fondo, y sin movimiento si el sistema lo pide). Confiable, porque la privacidad se dice sin adornos ni promesas vagas, sobre tinta sólida. Las caritas llevan toda la expresividad; el resto es tipografía, espacio y planos de color.

**Key Characteristics:**
- Móvil primero: la primera pantalla de 390 pt contiene titular, carita, selector y los dos badges.
- Color de dos fuentes: los tintes de categoría de cada mood (los de la app) y la tinta del cierre con su filete del Log, nunca mezclados en la misma superficie.
- Planos y suaves: superficies planas; solo el teléfono lleva sombra.
- Funciona sin JavaScript y sin movimiento; el script solo añade el cambio de color, nombre y contador.
- Sin recursos de terceros: Poppins autoalojada y nada que cargue desde otro dominio.

## Colors

Una paleta de tinta y pastel, como la app: tinte de categoría en el héroe y tinta sólida en el cierre de privacidad, sobre un papel perla casi blanco (o un grafito en modo oscuro). El ícono (una carita blanca dibujada a mano sobre un degradado diagonal #7C5CFF → #E0509F → #FF8A5B) es un archivo, no un token.

### Primary
- **Tinta Violeta** (#1D1D22): texto principal, titulares en claro, cabecera sobre el héroe y fondo del bloque de privacidad. Es la tinta de la app.
- **Enlace Índigo** (#5646D1): enlaces en claro (#A396FF en oscuro).
- **Anillo Violeta** (#7C5CFF): anillo de foco en claro (#A396FF en oscuro) y selección de texto (#DCD3FF, con tinta encima).

### Secondary
- **Tintes de categoría**: cada mood base va de un tono muy claro a uno medio, los tintes de categoría de la app. Feliz, categoría Positive (#FFF6DE → #E1C78F); Tranquilo, Peaceful (#E5F8F0 → #9FD2BE); Neutral (#F3F1F8 → #C2BED2); Triste, Hard (#EEECFF → #BAB2F1); Enojado, el rojo de angry (#FEECEA → #EBAFAC). Solo se usan como fondo del héroe, en diagonal de 135deg. La tinta mide al menos 8.5:1 sobre todos y la tinta suave al menos 5.7:1.
- **Filete del Log** (#B9A6FF → #F7B2D9 → #FFD3B6): el degradado del botón Log de la app, solo como filete de 4 px en el borde superior del bloque de privacidad.

### Neutral
- **Tinta Suave** (#3A3A48): línea de apoyo bajo el titular, sobre el tinte.
- **Papel Perla** (#F7F7FA): fondo en claro; tarjeta blanca (#FFFFFF).
- **Gris Pizarra** (#575969): texto de apoyo y pie.
- **Línea Bruma** (#E3E2EA): divisores y borde del pie.
- **Noche Grafito** (#111114), con tarjeta (#1C1C21), texto (#F4F3F7), apoyo (#B4B6C3), titular (#E5E1FF), enlace y anillo (#A396FF) y línea (#2A2A33): el modo oscuro. El bloque de privacidad pasa a #26262C.
- **Apoyo sobre Tinta** (#CFCFDA): texto secundario del bloque de privacidad; los divisores son blanco al 18%.
- **Bisel del Teléfono** (#17171B): marco del teléfono, el mismo en claro y en oscuro.

### Named Rules
**The Tint And Ink Rule.** El tinte de un mood pertenece al héroe y la tinta con el filete del Log pertenece al cierre de privacidad; nunca comparten superficie. Mezclarlos diluye a ambos.

**The Mood Owns The Hero Rule.** El fondo del héroe es siempre el degradado del tinte de categoría del mood seleccionado; no se fija tinta ni otro color encima.

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
- **Controles:** botones circulares de 48 px con chevron de trazo 2.5 px y contador `n / 5` en tinta.
- **Sin JavaScript:** una fila de caritas que se desliza a mano.

### Teléfono
- Marco de 10 px en Bisel del Teléfono, corte inferior sin borde y la captura limpia del calendario rediseñado de la app; ancho máximo de 300 px y alto de 480 px.

### Bloque de privacidad
- Tinta sólida (Tinta Violeta; #26262C en oscuro) a todo el ancho con un filete superior de 4 px del degradado del Log (un filete, no texto con degradado ni franja lateral), titular blanco de hasta 16ch y tres puntos separados por una línea blanca al 18%. Texto de apoyo en #CFCFDA.

### Badges de tienda
- Los oficiales de App Store y Google Play, tal cual los entregan Apple y Google, a 48 px de alto. No se recolorean ni se recortan. El de Google Play lleva un margen negativo para compensar su espacio libre.

### Enlaces y pie
- Enlaces subrayados con desplazamiento de 0.2em, en Enlace Índigo (claro) o #A396FF (oscuro). El pie y la cabecera son idénticos en las ocho páginas, con objetivos táctiles de al menos 44 px.

## Do's and Don'ts

### Do:
- **Do** dejar que el mood seleccionado tiña todo el héroe con el tinte de su categoría en la app.
- **Do** mantener la primera pantalla de 390 pt con titular, carita, selector y los dos badges sin hacer scroll.
- **Do** usar Poppins autoalojada y nada que cargue desde otro dominio.
- **Do** mantener un contraste mínimo de 4.5:1 en texto de cuerpo y 3:1 en grande, en claro y en oscuro.
- **Do** mantener la edición en inglés y en español a la vez, con el mismo marcado.

### Don't:
- **Don't** mezclar un tinte de mood con la tinta del bloque de privacidad en la misma superficie.
- **Don't** usar el degradado del Log como texto ni como franja lateral: solo es el filete de 4 px del bloque de privacidad.
- **Don't** poner sombra a nada que no sea el teléfono, ni sombras de color.
- **Don't** usar texto con degradado, ni tarjetas idénticas de ícono más título como estructura de página.
- **Don't** afirmar que todos los moods son gratis ni mostrar precios; la web dice "gratis para descargar y usar".
- **Don't** modificar, recolorear ni recortar los badges oficiales de las tiendas.
- **Don't** tocar el texto de las páginas legales por motivos de diseño.
