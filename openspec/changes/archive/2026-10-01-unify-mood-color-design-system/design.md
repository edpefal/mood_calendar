## Context

Ver `proposal.md` — "Why" para la motivación completa. Los 8 puntos surgieron de una sesión de exploración (`/opsx:explore`) que combinó: lectura del código real, screenshots en vivo del simulador vía `idb` (ver `openspec/specs/ios-simulator-ui-testing/spec.md`), y mockups hi-fi en Claude Design rooteados en esos valores reales (gradiente `#5F3DC4→#6C63FF`, Poppins, `MoodDefinition.color`). El mockup vive en https://claude.ai/artifact/EGLBy3pyG98TdAok5fzou3 (3 artboards: Mood Store actual/propuesta, Calendar propuesta).

Dato clave verificado en código: `MoodDefinition.color` (en `mood_definition.dart`) usa valores `Colors.green/blue/grey/orange/red/teal/indigo/amber/pink/brown` — todos instancias de `MaterialColor`, que traen `.shade50`/`.shade200` de fábrica. El campo está tipado como `Color`, no `MaterialColor`, así que la generalización necesita un cast.

## Goals / Non-Goals

**Goals:**
- Un solo mecanismo de color-por-mood (no dos paralelos: el switch de `MoodScreen` y el directo de `CalendarScreen`), que cubra los 10 moods automáticamente, incluyendo cualquier mood futuro sin tocar el código de UI.
- Un solo lenguaje de botón primario en toda la app.
- Cerrar los 2 gaps de accesibilidad encontrados (label de "volver" en Calendar, foco visible en el campo de nota).

**Non-Goals:**
- No se construye un design system formal/tokens file — son 8 ajustes puntuales sobre patrones ya existentes.
- No se toca `brave.svg` ni ningún otro asset (change aparte, ver backlog).
- No se cambia el modelo de desbloqueo de moods premium ni el flujo de RevenueCat.
- No se agrega un widget de theming genérico más allá de lo que estos 8 puntos requieren.

## Decisions

### 1. Derivar el gradiente de `MoodDefinition.color` vía cast a `MaterialColor`, no agrandar el switch
`backgroundGradientForMood(MoodDefinition mood)` pasa a:
```dart
static LinearGradient backgroundGradientForMood(MoodDefinition mood) {
  final swatch = mood.color as MaterialColor;
  return LinearGradient(
    colors: [swatch.shade50, swatch.shade200],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```
**Alternativa considerada**: agregar 5 casos más al switch para los moods premium, a mano, con gradientes elegidos manualmente. Se descarta porque perpetúa el problema (cualquier mood futuro vuelve a quedar afuera hasta que alguien se acuerde de actualizar el switch) y porque `CalendarScreen` ya prueba que derivar directo de `.color` funciona bien para los 10 moods sin curaduría manual.
**Riesgo**: el cast `as MaterialColor` rompe si algún `MoodDefinition.color` deja de ser un `MaterialColor` (ej. alguien lo cambia a `Color(0xFF...)` a mano). Mitigación: test unitario que itere `allMoodDefinitions` y verifique el cast no falla (ver tasks.md).

### 2. Extraer un widget `GradientPillButton` reutilizable, no copiar el `Container` 4 veces
En vez de pegar el mismo `Container`+`BoxDecoration`+`LinearGradient` en `CalendarScreen`, `MoodStoreScreen` y los 2 purchase sheets, se extrae un widget compartido (ubicación sugerida: `lib/core/widgets/gradient_pill_button.dart`, ya que no pertenece a una sola feature) parametrizado por label, onPressed y estado de loading/disabled — `MoodScreen` migra a usarlo también, quedando una sola fuente de verdad para el estilo del botón primario.
**Alternativa considerada**: dejar el estilo de `MoodScreen` como está (no es parte de los 8 puntos per se) y solo replicar su apariencia en los otros lugares. Se descarta porque duplicar el mismo `BoxDecoration` en 5 lugares es exactamente el tipo de inconsistencia que esta propuesta busca eliminar — mejor una sola definición.

### 3. El cambio de foco del campo de nota usa el mood *actualmente seleccionado* en el carousel, no el mood guardado
`MoodScreen` ya trackea `selectedMood`/`_currentPage` para el carousel; el `focusedBorder` del `TextField` de nota lee ese mismo estado, así que el color del borde cambia en vivo si el usuario desliza el carousel mientras el campo sigue enfocado (edge case raro pero correcto, no requiere lógica nueva).

### 4. Los headers de sección de `MoodStoreScreen` van en bold sin color de marca (jerarquía de 2 niveles)
Para no saturar la pantalla de púrpura: el título de página ("Mood Store") lleva el tratamiento completo (bold + color), los headers de sección ("Premium moods"/"Packs") solo bold. Esto replica la jerarquía que ya existe implícitamente entre el título y el contenido de `MoodScreen`.

## Risks / Trade-offs

- [Riesgo] Extraer `GradientPillButton` y migrar `MoodScreen` a usarlo es un cambio en una pantalla que hoy funciona bien — una regresión visual ahí sería más visible que en las otras pantallas (es la pantalla principal). → Mitigación: migrar `MoodScreen` al widget compartido como el último paso de la tarea del botón (tasks.md), después de validarlo en las pantallas de menor tráfico, y verificar visualmente con el workflow de `idb` (`docs/ios-simulator-ui-testing.md`) antes de dar la tarea por completa.
- [Riesgo] El cast `mood.color as MaterialColor` es implícito/fragil si se agrega un mood con un `Color` plano en el futuro. → Mitigación: test unitario (ver Decision 1).
- [Trade-off] No se crea un archivo de design tokens ni un objeto `AppColors`/`AppTheme` centralizado — los 8 puntos se resuelven donde ya viven (resolver, widgets). Si en el futuro se agregan más puntos de inconsistencia, puede valer la pena esa inversión; no se justifica todavía para 8 ajustes puntuales.

## Migration Plan

No aplica migración de datos. Rollout: cambios de UI pura, sin flags ni gradualidad — se implementan, se verifican visualmente con `idb` en el simulador (los 3 screens), y se mergean. Rollback trivial: revertir el commit/PR, no hay estado persistente afectado.
