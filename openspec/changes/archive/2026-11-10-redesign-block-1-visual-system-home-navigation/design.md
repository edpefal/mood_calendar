## Context

Este es el primero de tres bloques del rediseño (motivación y alcance en `proposal.md`; requisitos en los specs de este change). Hoy:

- El color de marca vive en `lib/core/theme/brand_colors.dart` (Ocean Cyan) y `ColorScheme.fromSeed` en `lib/main.dart`; no hay tema oscuro.
- Cada mood trae un `MaterialColor` (`MoodDefinition.color`) del que `MoodDefinitionResolver.backgroundGradientForMood` deriva el degradado pastel (`.shade50`/`.shade200`). El catálogo está partido en `baseMoodDefinitions` (5) y `premiumMoodDefinitions` (14).
- El selector es `mood_screen.dart` (831 líneas): carrusel, flechas, contador, `MoodGridSheet` y el orden por frecuencia (`MoodPickerOrder`) que se calcula al entrar a la pestaña.
- `MainShell` aloja 4 pestañas (selector, calendario, Premium, ajustes) con `FloatingTabBar`; guardar cambia a la pestaña del calendario y es `CalendarScreen` quien dispara el pedido de calificación (`_requestRatingAfterSave` → `RatingPromptService`).
- La oferta de suscripción es la pestaña `PremiumScreen` y la hoja `PremiumSheet`, que comparten `PremiumPlansView` (548 líneas); `PurchasesCubit` ya expone planes, elegibilidad de la prueba y estado.
- `AppSettings` (Hive) guarda recordatorio y analíticas; `SettingsCubit` autoguarda y revierte si falla.
- El reloj recibe del iPhone la lista de moods desbloqueados ya ordenada (`PublishWatchStateUseCase`), de modo que el orden se decide en Dart.

## Goals / Non-Goals

**Goals:**
- Que el rediseño se pueda construir por capas sin dejar la app rota entre commits: tokens y tema primero, luego catálogo/categorías, luego Log, luego navegación y oferta.
- Una sola fuente para colores, categorías y orden, de modo que Calendar, Log, reloj e Insights (Bloque 2) las compartan.
- Cero migración de datos de usuario en este bloque.

**Non-Goals:**
- Rediseñar Calendar más allá del color por categoría y el vidrio (el Bloque 2 lo rehace).
- Contenido real de Insights, hora de registro, onboarding, biometría, ícono, sitio y arte de tienda.
- Tocar productos, ofertas o precios en App Store Connect, Play o RevenueCat.

## Decisions

### 1. Tema con `ThemeExtension` y colores por brillo, no constantes sueltas
Se sustituye `brand_colors.dart` por una paleta con variante clara y oscura expuesta como `ThemeExtension` (tinta, superficies, vidrio, malla, tintes por categoría, texto secundario) y un `ThemeData` por brillo. `MaterialApp` recibe `theme`, `darkTheme` y `themeMode`.
- **Por qué**: el tema oscuro obliga a que cada color dependa del brillo; con constantes habría `if (dark)` en cada widget.
- **Alternativa descartada**: dejar `ColorScheme.fromSeed` y mapear a mano; no sirve para los tintes por categoría ni para la malla, que no existen en Material.
- La preferencia se guarda en `AppSettings` (nuevo campo con valor por defecto Sistema) y la lee un cubit en la raíz; `SettingsCubit` la cambia con el mismo patrón de autoguardado y reversión que el recordatorio.

### 2. Widgets base: fondo de malla y tarjeta de vidrio
Dos widgets en `core/widgets/`: un fondo de malla (varios `RadialGradient` apilados, con el tinte de la categoría arriba en el Log) y una tarjeta de vidrio (`BackdropFilter` + borde + sombra) con alternativa opaca cuando `MediaQuery` indica reducir transparencia o alto contraste. `GradientPillButton` pasa a ser la píldora de tinta y conserva su nombre para no tocar todos los usos.
- **Por qué**: el diseño repite el mismo patrón en todas las pantallas; centralizarlo mantiene el contraste y la accesibilidad en un solo lugar.
- **Riesgo**: `BackdropFilter` es caro en listas largas → solo se usa en tarjetas de nivel superior, no por celda.

### 3. La categoría es el dato; el color y el puntaje se derivan
`MoodDefinition` gana `category` y pierde `color`. Una enumeración `MoodCategory` con su orden, su nivel (alto, medio, bajo) y su clave de tinte; `angry` define su propio tinte. El catálogo pasa a una sola lista en el orden de pantalla, y `tier` queda como propiedad aparte. `MoodDefinitionResolver.backgroundGradientForMood` se reescribe sobre el tinte de la categoría. `intensity` y los ids siguen igual: `MoodEntry.mood` ya guarda la ruta del asset, así que no hay migración.
- **Por qué una lista y no `base` + `premium`**: el orden de pantalla mezcla tiers dentro de cada categoría; dividir el catálogo obligaba a reordenar en cada consumidor.
- **Alternativa descartada**: guardar el tinte por mood; contradice la decisión de color por categoría y obligaría a mantenerlo a mano para cada mood nuevo. Un test exige que todo mood declare categoría.
- El ADR nuevo (reemplaza al 0001) fija que el puntaje es por categoría, que `intensity` no se usa para nada más que identificar, y que ninguna pantalla presenta una categoría como "mejor" que otra.

### 4. Log como pantalla con dos modos, sin pestaña nueva
`mood_screen.dart` se reemplaza por una pantalla Log con dos modos (elegir y "Saved"), dirigidos por `MoodCubit`: el modo "Saved" se activa tras un guardado exitoso o al abrir una fecha que ya tiene entrada, y "Edit" vuelve al modo elegir con la selección y la nota. La cuadrícula es un widget propio que recibe los moods ya agrupados; el desbloqueo sigue viniendo de `MoodEntitlementsRepository` y la excepción de editar la nota con el mismo mood caducado se conserva (`can_save_with_mood.dart`). Se eliminan `mood_picker_order.dart`, `mood_grid_sheet.dart` y sus tests.
- **Por qué**: separar "elegir" y "Saved" en dos pantallas obligaba a sincronizar fecha, selección y nota entre ambas; con un solo cubit el estado ya existe.
- **Sin mood preseleccionado** (decisión de este change): hoy se preselecciona el primero del carrusel ordenado; con orden fijo no hay un "primero" con sentido y el onboarding del diseño exige elegir. Guardar queda deshabilitado hasta elegir.

### 5. El pedido de calificación se mueve al Log
`RatingPromptService.maybeRequestAfterSave()` se llama desde el Log cuando entra al modo "Saved" tras un guardado exitoso (una vez por guardado, tras el primer frame), no desde `CalendarScreen`. Si el usuario cambia de pestaña antes, no se pide ni se registra el intento (spec `rating-prompt`).
- **Por qué**: la política (hitos 3 y 7, 30 días, máx. 2) no cambia; solo cambia dónde se muestra.

### 6. Navegación: `MainShell` renombra y reordena, Insights es provisional
`MainShell` pasa a Calendar, Insights, Log, Settings, con Log como pestaña inicial, y `FloatingTabBar` se rediseña (cápsula de tinta, Log como botón central con degradado). Tocar un día del calendario y el recordatorio activan Log con su fecha, como hoy con el selector. La pestaña Insights muestra un estado vacío localizado hasta el Bloque 2. La campana del encabezado del Log activa la pestaña Settings.
- **Alternativa descartada**: ocultar la pestaña Insights hasta el Bloque 2; el diseño y las pruebas de navegación dependen de las 4 pestañas, y no hay publicación entre bloques.

### 7. La oferta es solo la hoja; Settings aloja el estado y la restauración
`PremiumScreen` y su pestaña desaparecen. `PremiumSheet` se rediseña con título, cápsula del mood (opcional), tres beneficios, tarjetas de planes y el texto legal; `PremiumPlansView` se adapta en lugar de reescribirse, porque ya resuelve precios, ahorro y elegibilidad. Settings gana la sección Premium: "Get Premium" abre la hoja y, con suscripción, "Premium · Active" abre la gestión de la tienda (la acción "Gestionar suscripción" ya existe). La prueba solo se muestra con el anual seleccionado.
- **Por qué no esperar a la biometría para el texto del beneficio**: el copy de la hoja se escribe una sola vez en los 5 idiomas; mientras la biometría no exista, el bloque no se publica (ver Riesgos).

### 8. Analíticas: solo cambian los valores de `source`
`AppTelemetryEvents` y la lista permitida no cambian; la hoja envía `source` = `locked_mood` o `settings`. Los valores `insights` y `onboarding` y los eventos de onboarding, Insights y biometría llegan con sus bloques.

### 9. Reloj
Cambia el acento de `MoodGridView.swift` a la tinta de marca y el orden sale ya de Dart (`PublishWatchStateUseCase` usa el orden fijo del catálogo). No se tocan el contrato de sincronización ni los permisos; el ícono lo cambia el change del ícono.

## Risks / Trade-offs

- [El bloque no es publicable solo: el paywall anuncia notas con biometría y la prueba gratis sigue activa en el mensual y el semanal de las tiendas] → Se prueba solo en TestFlight. Antes de publicar hay que (a) tener el Bloque 3 y (b) pedir permiso para quitar la prueba de esos dos planes en App Store Connect y Play; ambos quedan en `backlog.md`.
- [Cambiar 6 moods a gratis reduce el motivo de compra y cambia la ficha de las tiendas] → Decisión de producto ya tomada; los compradores heredados no pierden nada y el texto de las tiendas se revisa en el paso de marketing.
- [El tema oscuro duplica la superficie de pruebas de contraste] → Un test recorre cada par texto/fondo del tema en ambos brillos y falla bajo 4.5:1; los tintes por categoría se prueban igual.
- [`BackdropFilter` puede costar fluidez en dispositivos viejos (iOS 15)] → Solo tarjetas de nivel superior y la barra; alternativa opaca disponible; se mide en un iPhone real antes de cerrar el bloque.
- [Reescribir `mood_screen.dart`, la barra, Premium y Settings rompe muchos tests] → Los tests se reescriben junto a cada capa (ver `tasks.md`) y `flutter analyze` + `flutter test` deben quedar en verde en cada commit.
- [Quitar `MoodDefinition.color` afecta a cualquier consumidor olvidado (calendario, resumen, reloj)] → Se elimina el campo al final de la capa de catálogo, de modo que el compilador señale cada uso.
- [Los tintes del diseño son pastel claros; el texto sobre ellos puede quedar justo en 4.5:1] → El test de contraste manda: si falla, se oscurece el texto, no el tinte.

## Migration Plan

- Sin migración de Hive: ids, rutas de asset y entradas no cambian. El campo de tema es nuevo con valor por defecto, así que los ajustes guardados siguen válidos.
- Compradores heredados: los entitlements `mood_<id>` se siguen leyendo; los 6 moods que pasan a base simplemente dejan de depender de ellos.
- Orden de construcción y de merge a `main` (una rama por capa, PR cada una, sin publicar versión): tokens y tema → categorías y catálogo → Log y nota → navegación y Settings → hoja de suscripción → reloj y limpieza. Cada PR deja la app compilando y con tests verdes.
- Reversión: cada PR se puede revertir por separado; el bloque no sale a las tiendas hasta que los tres estén en `main` y se pida el cambio de versión.
