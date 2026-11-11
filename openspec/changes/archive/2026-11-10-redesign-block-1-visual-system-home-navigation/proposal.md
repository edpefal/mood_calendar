## Why

El morado de marca y el selector de moods en carrusel hacen que la app se vea genérica, y el rediseño completo (artefacto de diseño `b968c1cf-8592-4534-8a8c-db17961bb6fc`) cambia la identidad, el registro diario, la navegación y la oferta Premium a la vez. Se parte en tres bloques que se prueban en TestFlight y se publican en una sola versión; este es el primero y deja lista la base visual y estructural de los otros dos.

## What Changes

- **Sistema visual nuevo** (reemplaza Ocean Cyan, que nunca se publicó): tinta `#1D1D22`, fondo de malla pastel, tarjetas de vidrio, tintes por categoría de mood y **tema Sistema / Claro / Oscuro** guardado en Hive. Se reescriben `brand_colors.dart`, su test de contraste y el acento del reloj.
- **Registro diario (Log)**: la **cuadrícula de moods agrupada por categorías reemplaza al carrusel** y a la hoja "todos los moods". Estado "Saved" en el mismo Home con la racha actual, atajo "Forgot yesterday? Log it" (solo si ayer no tiene entrada) y saludo sin nombre. Guardar ya no salta al calendario.
- **Categorías de mood** (Positive, Peaceful, Neutral, Hard) con orden fijo, color por categoría y un **puntaje de 3 niveles por categoría** (Positive y Peaceful alto, Neutral medio, Hard bajo). Un ADR nuevo reemplaza al 0001: `intensity` sigue siendo solo un identificador.
- **BREAKING (catálogo)**: pasan a gratis Sleepy, Anxious, Stressed, Scared, Crying y Sick. Quedan **11 moods `base` y 8 `premium`** (Laughing, Confident, Brave, Affectionate, Hugging, Romantic, Shy, Hurt). Los compradores heredados no pierden nada.
- **BREAKING (orden)**: se elimina el orden por frecuencia de uso (`MoodPickerOrder`), también en el reloj.
- **Navegación de 4 pestañas**: Calendar, Insights, Log, Settings. La app abre en Log. Desaparece la pestaña Premium; en su lugar, Insights es una pantalla provisional con estado vacío hasta el Bloque 2.
- **Paywall como hoja** (desde un mood bloqueado y desde Ajustes), con los 3 planes actuales, prueba gratis **solo en el plan anual**, 3 beneficios (Insights, notas con biometría, moods expresivos) y sin promesa de recordatorio de fin de prueba. Suscriptores: la fila de Ajustes dice "Premium · Active" y abre la gestión de la tienda.
- **Ajustes** con las filas finales: Premium, Reminders, Privacy and data (exportar, datos de uso), Appearance (Theme) y Help (Rate, Send feedback, Privacy policy, Terms, Version). Sin Message, Language, App icon ni iCloud.
- **Calificación** desde el estado "Saved" del Home, y `source` del paywall con `locked_mood` y `settings`.
- Todo el texto nuevo en los 5 idiomas (en, es, de, fr, it). iPad: mismo diseño centrado con ancho máximo.
- **Fuera de este bloque**: calendario nuevo, Insights real y hora de registro (Bloque 2); onboarding y bloqueo biométrico (Bloque 3); ícono nuevo; sitio y arte de tienda; cambios de ofertas en App Store Connect y Play (quitar la prueba del mensual y el semanal, que se pide aparte). No se publica versión ni se recapturan capturas.

## Capabilities

### New Capabilities
- `app-theme`: tokens de marca, fondo de malla, tarjetas de vidrio, tintes por categoría, tema Sistema/Claro/Oscuro y su preferencia persistente.
- `mood-categories`: las 4 categorías, la categoría de cada mood, su orden fijo, su color y su puntaje de 3 niveles.
- `home-mood-log`: la pantalla Log con la cuadrícula por categorías, el estado "Saved", el atajo de ayer y el saludo.

### Modified Capabilities
- `premium-moods`: catálogo de 11 base y 8 premium; la cuadrícula sustituye al carrusel, a su contador, a sus flechas y a la hoja de todos los moods; fuera el orden por frecuencia.
- `bottom-navigation`: pestañas Calendar, Insights, Log y Settings; barra oscura; abre en Log; guardar ya no cambia de pestaña.
- `premium-subscription`: la oferta vive en una hoja y en Ajustes (no hay pestaña); prueba solo en el anual; 3 beneficios; estado de suscrito en Ajustes.
- `mood-store`: desaparece la pestaña Premium y el escaparate; restaurar compras se ofrece en la hoja y en Ajustes.
- `settings-screen`: filas y secciones finales, tema, fila Premium, enviar comentarios y términos.
- `rating-prompt`: el pedido sale desde el estado "Saved" del Home.
- `watch-mood-picker`: el reloj lista los moods desbloqueados en el orden fijo por categoría y usa la nueva marca.
- `usage-analytics`: valores de `source` del paywall (`locked_mood`, `settings`) y fin del valor `tab`.
- `daily-note-capture`: la nota se abre desde una píldora sobre Guardar (ya no desde el encabezado); el editor muestra el mood y "Done" y usa el tinte de la categoría.
- `calendar-navigation`: tocar un día lleva al Log con esa fecha, con la tarjeta de la entrada si existe; no se eligen fechas futuras.

## Impact

- **Código (`lib/`)**: `core/theme/` (tokens y tema), `core/widgets/` (barra, botón, vidrio), `core/navigation/main_shell.dart`, `features/mood/domain` (categorías, catálogo, eliminar `mood_picker_order.dart`), `features/mood/presentation` (Log, calendario solo reestilizado, editor de nota), `features/purchases/presentation` (hoja), `features/settings`, `core/localization/*` (5 idiomas), `core/settings` (preferencia de tema), `core/telemetry`.
- **iOS**: `ios/WatchApp` (acento y orden); sin permisos ni capabilities nuevos.
- **Docs**: ADR nuevo que reemplaza al 0001, `CLAUDE.md` (sistema de diseño, estados de ánimo, flujo de Premium), `CONTEXT.md` (categoría, puntaje), `backlog.md`.
- **Tests**: se reescriben los de carrusel, orden por frecuencia, hoja de moods, barra de pestañas y pantalla Premium; nuevos para categorías, tema y contraste.
- **Dependencias externas**: ninguna en este bloque. Las ofertas de las tiendas y RevenueCat no se tocan.
- **Riesgo conocido**: el paywall anuncia notas con biometría, que llega en el Bloque 3; este bloque no puede publicarse solo.
