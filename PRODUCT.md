# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Personas que quieren anotar cómo se sienten cada día, en segundos y sin fricción, y revisar su mes a color. Valoran que sus datos no salgan del teléfono. No es una app clínica ni de terapia: es un registro personal de estado de ánimo.

Llegan a moodcalendar.app desde cuentas de redes sociales y desde las fichas de App Store y Google Play, casi siempre en móvil y, en redes, a menudo dentro del navegador interno de la red. Hay visitantes en inglés y en español.

## Product Purpose

Mood Calendar es una app para registrar el estado de ánimo diario con un mood, una nota opcional y un recordatorio, y para ver el mes completo en un calendario de colores, con el mood más frecuente y la mejor racha. Está publicada en iOS y Android (`com.artlab.moodcalendar`).

El éxito del sitio es que quien llega entienda en segundos qué es, que es gratis para descargar y que es privada, y que descargue la app desde la tienda que le corresponde.

## Positioning

Un diario de ánimo privado por diseño: sin cuenta, sin backend y sin ID de publicidad; las entradas (mood, nota, fecha) viven solo en el dispositivo y se pueden exportar. Su identidad visual propia son las caritas, un catálogo de 19 moods con ilustraciones SVG y un color pastel por mood. Un competidor no puede copiar de forma verídica la promesa de que nada de las entradas sale del teléfono sin tener también esa arquitectura.

## Operating Context

La app se descarga desde las tiendas. La web (`site/`) es un sitio estático bilingüe, escrito a mano y sin build: inglés en `/` y español en `/es/`, con inicio, política de privacidad, términos y soporte. Se despliega en Vercel desde `main`. Las URL de privacidad y soporte están registradas en App Store Connect, Play Console y dentro de la app. Contacto: `support@moodcalendar.app`.

## Capabilities and Constraints

- Moods: 5 base gratis (`happy`, `calm`, `neutral`, `sad`, `angry`) y 14 premium que se desbloquean con una suscripción opcional (semanal, mensual o anual, con 3 días de prueba); quien compró moods o Packs en versiones anteriores los conserva. La web comunica "gratis para descargar y usar" y no afirma que todos los moods sean gratis. Por decisión del producto no menciona precios, la suscripción ni la tienda de moods; los Términos de uso y la política de privacidad sí describen la suscripción.
- Funciones: elegir mood con nota opcional, calendario mensual a color, mood más frecuente y mejor racha, recordatorio diario, exportar el historial en JSON.
- Analíticas anónimas de uso (con interruptor en Ajustes) y reporte de fallos; nada de las entradas sale del dispositivo. Todo lo que la web diga sobre privacidad debe coincidir con la política (`site/privacy/`) y con las declaraciones de las tiendas.
- La web no carga fuentes, scripts ni analíticas de terceros. Se edita siempre en inglés y en español, con el mismo contenido y estructura.
- El contenido legal (política, términos, soporte) no cambia de texto ni de URL por motivos de diseño.
- Editor y copyright: "Mood Calendar". Reevo no tiene relación con este producto.
- Terminología: Mood (el catálogo) frente a Mood Entry (lo registrado por el usuario); ver `CONTEXT.md`.

## Brand Commitments

- Nombre: Mood Calendar. Ícono y lema de las tiendas en `AppIcon 1024` y `aso/header/`.
- Color de marca: púrpura `#5F3DC4` a `#6C63FF` (degradado) y fondo del launch screen `#8C52FF`.
- Tipografía de la app y de las tiendas: Poppins (licencia OFL, ya en `tool/screenshots/fonts/`).
- Las caritas de `assets/icon/` y los pasteles por mood son parte de la identidad. `brave.svg` pesa 1 MB y no se usa en la web.

## Evidence on Hand

- Capturas reales de la app en 5 idiomas, generadas con `tool/screenshots/`, y arte de cabecera por idioma en `aso/header/`.
- Los dos enlaces de tienda están activos: `https://apps.apple.com/app/id6752843360` y `https://play.google.com/store/apps/details?id=com.artlab.moodcalendar`.
- Sin calificaciones citables, reseñas, testimonios, cifras de descargas ni prensa. No fabricar ninguna.

## Product Principles

1. Privado antes que persuasivo: lo que la web promete sobre datos debe poder verificarse en la app y en la política.
2. Honesto con lo gratis: "gratis para descargar y usar", sin insinuar que todo el catálogo lo es.
3. Rápido de entender: una persona que viene de una red social decide en segundos; un solo mensaje y una acción clara.
4. Las caritas son la voz del producto: se muestran con sus colores, no se sustituyen por ilustración genérica.
5. Dos idiomas, un mismo producto: lo que se dice en inglés se dice igual en español.

## Accessibility & Inclusion

Contraste AA, modo oscuro, objetivos táctiles de al menos 44 px, textos `alt` descriptivos y `prefers-reduced-motion` respetado si hay movimiento. Sin afirmaciones médicas ni de salud mental: es un registro personal, no un tratamiento.
