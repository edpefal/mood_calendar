## Why

Con 10 moods el selector ya pide hasta 9 swipes para llegar al último, y la fila de puntos (un punto de 16 px por mood) llega a 240 px con 15 moods y desborda en pantallas de 390 pt con unos 20. El orden por frecuencia de uso ayuda a los moods habituales, pero llegar a uno poco usado o a un premium bloqueado (siempre al final) sigue siendo cansado, y la cantidad de moods solo va a crecer con los packs.

## What Changes

- La fila de puntos se sustituye por un contador de posición "3 / 15" que escala a cualquier cantidad de moods.
- El carrusel muestra una vista previa de los moods vecinos (más chicos y atenuados) y flechas ‹ › junto al contador, para que siga siendo evidente que se puede avanzar sin el indicador de puntos. Tocar un vecino lo centra.
- Un botón de cuadrícula junto al carrusel abre una hoja inferior con todos los moods (4 columnas, 2 con texto grande; mismo orden que el carrusel, bloqueados al final con su candado).
- Tocar un mood desbloqueado en la hoja cierra la hoja y lleva el carrusel a ese mood (selección, fecha y nota sin guardar se conservan). Tocar un mood bloqueado abre la compra, igual que en el carrusel.
- Nuevos strings localizados (botón y título de la hoja, flechas anterior/siguiente) en los 5 idiomas.
- El orden por frecuencia y su congelamiento mientras el selector está visible no cambian.

## Capabilities

### New Capabilities
<!-- Ninguna -->

### Modified Capabilities
- `premium-moods`: añade los requisitos del indicador de posición del carrusel y de la selección rápida desde la hoja con todos los moods.

## Impact

- **Código**: `lib/features/mood/presentation/screens/mood_screen.dart` (indicador y botón), nuevo widget de la hoja en `lib/features/mood/presentation/widgets/`, `lib/core/localization/` (`AppStrings` y las 5 subclases).
- **Tests**: widget tests de `MoodScreen` (contador, abrir hoja, saltar a un mood, mood bloqueado, orden congelado, texto al 200 %) y de los strings.
- **Docs**: `CLAUDE.md` (sección Selector de moods) al archivar.
- **Dependencias**: ninguna nueva. Sin cambios en compras ni en datos guardados.
