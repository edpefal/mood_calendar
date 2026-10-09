## Why

El carrusel de selección diaria muestra siempre los Moods en el mismo orden fijo del catálogo. Quien usa mucho `calm` o `sad` tiene que deslizar cada día hasta ellos. Ordenar por frecuencia de uso acerca los Moods que la persona realmente registra, sin cambiar la experiencia de quien recién empieza.

## What Changes

- El carrusel de selección diaria ordena los Moods `unlocked` (base y premium comprados) por cantidad de Mood Entry registradas con ese Mood, de mayor a menor, contando todo el historial.
- Empate (incluido 0 usos): se mantiene el orden original del catálogo. Sin historial, el orden es idéntico al actual.
- Los Moods premium no `unlocked` se muestran al final, en su orden original del catálogo, con su marca de bloqueo actual.
- Al abrir una fecha sin Mood Entry, el Mood preseleccionado es el primero de la lista ordenada (el más usado). Con una Mood Entry existente, se posiciona en el Mood guardado.
- El orden se calcula una sola vez al abrir la pantalla y no cambia mientras permanece abierta (ni por guardar, ni por una compra).
- El orden no usa `intensity` (ADR 0001).

## Capabilities

### New Capabilities

### Modified Capabilities
- `premium-moods`: el requisito "Selección bloqueada en el carrusel diario" pasa de un orden implícito fijo a definir el orden del carrusel (desbloqueados por frecuencia, bloqueados al final) y el Mood preseleccionado.

## Impact

- `lib/features/mood/presentation/screens/mood_screen.dart`: deja de usar `allMoodDefinitions` por índice (página inicial, `_applyMoodEntry`, `_onPageChanged`, Semantics, indicadores) y usa la lista ordenada fijada al abrir.
- Nueva lógica pura de ordenamiento en `lib/features/mood/domain/services/` (conteo por Mood sobre las Mood Entry + predicado de desbloqueo).
- Sin cambios en persistencia (Hive), modelos, compras ni localización: la frecuencia se deriva del historial ya cargado por `MoodCubit`.
- Tests: unitarios del ordenamiento y de widget en `MoodScreen`.
