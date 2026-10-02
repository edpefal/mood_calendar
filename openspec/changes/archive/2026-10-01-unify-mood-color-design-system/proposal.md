## Why

Las 3 pantallas de la app (`MoodScreen`, `CalendarScreen`, `MoodStoreScreen`) ya tienen piezas reales de un sistema de diseño coherente — color-por-mood, Poppins, un botón gradiente, candado para moods bloqueados — pero aplicadas de forma inconsistente entre pantallas. Una sesión de exploración visual (screenshots reales en simulador + mockups en Claude Design, ver `design.md`) identificó 8 brechas concretas y acotadas donde un patrón que ya funciona en un lugar simplemente no se extendió al resto. No se trata de inventar un sistema nuevo, sino de terminar de aplicar el que ya existe.

## What Changes

- Generalizar `MoodDefinitionResolver.backgroundGradientForMood()` para derivar el gradiente pastel de `MoodDefinition.color` (vía `.shade50`/`.shade200`), cubriendo los 10 moods (5 base + 5 premium) en vez del switch hardcodeado actual que solo cubre los 5 base — confirmado en vivo que los 5 moods premium hoy comparten un único gradiente lavanda de fallback en `MoodScreen`.
- Adoptar el botón "pill" con gradiente (`#5F3DC4` → `#6C63FF`, radius 20, ya usado en el botón "Save" de `MoodScreen`) como botón primario estándar, reemplazando los `FilledButton`/`OutlinedButton` default de Material en `CalendarScreen` (diálogo de recordatorio), `MoodStoreScreen` y los purchase sheets.
- Unificar tratamiento tipográfico de títulos: bold + color de marca en el AppBar de `MoodStoreScreen` (hoy plano), headers de sección ("Premium moods"/"Packs") en bold sin color de marca (jerarquía de dos niveles).
- Tinte púrpura de marca consistente en íconos de navegación, específicamente la flecha de "volver" de `MoodStoreScreen` (hoy usa el color default del sistema).
- La card de pack en `MoodStoreScreen` (`_MoodPackTile`) muestra los íconos SVG de los moods incluidos, no solo el texto "Includes: ...".
- Agregar `Semantics` con label descriptivo al botón de "volver" de `CalendarScreen` (hoy sin label, a diferencia del resto de los controles de esa pantalla).
- En `CalendarScreen`, la card "Most frequent mood" se tiñe con el gradiente del mood que efectivamente muestra (reutilizando el punto anterior) en vez de un púrpura genérico desconectado del dato; "Best streak" se mantiene púrpura de marca pero gana un ícono para tener la misma composición visual que la card de arriba.
- El campo de nota de `MoodScreen` gana un `focusedBorder` tintado con el color del mood seleccionado — hoy no tiene ningún indicador visual de foco más allá del cursor.

Fuera de alcance:
- `assets/icon/brave.svg` (asset roto/sobredimensionado, ver `backlog.md`) — se resuelve en un change aparte.
- No se modifica el modelo de datos de moods, el flujo de compras, ni se agregan pantallas nuevas.

## Capabilities

### New Capabilities
(ninguna)

### Modified Capabilities
(ninguna — son ajustes visuales y de accesibilidad sobre pantallas existentes, sin cambio de requisitos de comportamiento del sistema; la app sigue haciendo exactamente lo mismo, solo se ve y se anuncia a accesibilidad de forma más consistente. Por eso el change declara `skip_specs: true`.)

## Impact

- `lib/features/mood/domain/services/mood_definition_resolver.dart` — generalización del gradiente.
- `lib/features/mood/presentation/screens/mood_screen.dart` — `focusedBorder` del campo de nota (el botón "Save" ya es la referencia del pill, no cambia).
- `lib/features/mood/presentation/screens/calendar_screen.dart` — label de accesibilidad, color de la card "Most frequent mood", ícono en "Best streak", reemplazo del botón del diálogo de recordatorio por el pill.
- `lib/features/purchases/presentation/screens/mood_store_screen.dart` — título, flecha de volver, botones de compra, iconografía del pack.
- `lib/features/purchases/presentation/widgets/mood_purchase_sheet.dart`, `pack_purchase_sheet.dart` — reemplazo de botones por el pill.
- Posible extracción de un widget reutilizable para el botón pill (se decide en `design.md`), evitando duplicar el `Container`+`LinearGradient` en cada lugar.
- Ningún cambio de modelo de datos, API externa, ni dependencias nuevas.
