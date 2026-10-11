## Context

`FloatingTabBar` (`lib/core/widgets/floating_tab_bar.dart`) usa `BackdropFilter` con blur sigma 20 y un relleno `Colors.white` al 0.72 de alpha, más un borde blanco al 0.6. Sobre fondos pastel claros (todas las pantallas), un blur de 20 borra los detalles y el 72 % de blanco los lava: visualmente es una barra opaca. Ver proposal.md - Why.

## Goals / Non-Goals

**Goals:**
- Que el contenido bajo el bar (texto, bordes, tarjetas) se reconozca a través de la cápsula.
- Mantener contraste suficiente para los iconos púrpura `#5F3DC4` y la píldora activa.

**Non-Goals:**
- Cambiar tamaño, margen, ancho máximo, iconos o animaciones.
- Modo oscuro (la app no lo tiene hoy).
- Cambiar cómo las pantallas reservan espacio inferior.

## Decisions

- **Valores de partida**: alpha del relleno 0.72 → ~0.40 y sigma 20 → ~10. Se afinan en simulador sobre la Tienda y Ajustes; el criterio es el del spec, no el número exacto.
  - *Alternativa*: quitar el blur y dejar solo alpha bajo. Descartada: sin blur el texto detrás compite con los iconos del bar y baja la legibilidad.
  - *Alternativa*: `BackdropFilter` con `ColorFilter` de saturación (estilo iOS material). Descartada por complejidad para un ajuste visual.
- **Borde y sombra**: el borde blanco sube a ~0.75 y la sombra se mantiene, para que la cápsula se siga leyendo como objeto aparte con menos relleno.
- **Constantes con nombre** en el archivo para alpha/sigma, en lugar de literales, para que el ajuste futuro sea de una línea.

## Risks / Trade-offs

- [Texto de fondo compite con los iconos] → blur moderado (no cero) y comprobar sobre la Tienda (texto y botón con borde justo debajo).
- [Cápsula se pierde sobre fondos blancos] → borde más marcado y sombra existente.
- [Valores subjetivos] → validar en iPhone y en iPad antes de dar por cerrado.
