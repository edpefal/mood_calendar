## 1. Localización

- [x] 1.1 Añadir `moodGridButtonLabel` y `moodGridTitle` a `app_strings.dart` y a las 5 subclases (en, es, de, fr, it)
- [x] 1.2 Test de strings: los 5 idiomas definen ambos textos no vacíos

## 2. Indicador de posición

- [x] 2.1 Sustituir la fila de puntos de `mood_screen.dart` por el contador "N / M" (fuera del árbol de accesibilidad como elemento aparte)
- [x] 2.2 Tests: el contador muestra la posición inicial, avanza al deslizar y no desborda con 20 moods en 390 pt

## 2b. Indicar que se puede deslizar

- [x] 2b.1 Añadir `previousMoodLabel` y `nextMoodLabel` a `AppStrings` y las 5 subclases, con test
- [x] 2b.2 Carrusel con `viewportFraction` 0.5, escala y opacidad por distancia, y nombre solo en el seleccionado
- [x] 2b.3 Extraer `_goToPage(index)` y usarlo en la hoja; tocar un vecino lo centra, tocar el seleccionado bloqueado abre la compra
- [x] 2b.4 Flechas ‹ › junto al contador (deshabilitadas en los extremos) y botón de cuadrícula centrado debajo del contador
- [x] 2b.5 Tests: se ven los vecinos sin nombre, flechas avanzan/retroceden y se deshabilitan en los extremos, tocar un vecino bloqueado lo centra sin abrir compra, tocar el seleccionado bloqueado sí la abre
- [x] 2b.6 Limitar el ancho de página a 240 pt en pantallas anchas y recrear el controlador al girar; tests de teléfono, iPad y rotación
- [x] 2b.7 Limitar el botón Guardar a 420 pt (como la barra inferior) y test de teléfono vs. iPad

## 3. Hoja con todos los moods

- [x] 3.1 Crear `MoodGridSheet` en `lib/features/mood/presentation/widgets/` (cuadrícula de 4 columnas, 2 con texto grande, mood actual marcado, bloqueados atenuados con candado, `Semantics` por celda)
- [x] 3.2 Añadir el botón de cuadrícula junto al contador (`Semantics`, objetivo ≥ 44 pt) y abrir la hoja con el orden vigente
- [x] 3.3 Al tocar un mood desbloqueado: cerrar la hoja y `animateToPage` (o `jumpToPage` con animaciones desactivadas); al tocar uno bloqueado: abrir la compra sin cambiar la selección

## 4. Tests de la hoja

- [x] 4.1 Abrir la hoja muestra todos los moods en el orden del carrusel con el actual marcado
- [x] 4.2 Saltar a un mood lejano actualiza carrusel, contador y mood guardado; la nota sin guardar y la fecha se conservan
- [x] 4.3 Tocar un mood bloqueado abre la compra y no cambia la selección
- [x] 4.4 El orden no cambia con la hoja abierta aunque cambie el estado `unlocked`
- [x] 4.5 Texto al 200 % en 390×844 sin desbordes (también en alemán)

## 5. Cierre

- [x] 5.1 Probar en el simulador (iPhone 17: contador, hoja, salto a un mood; falta iPad y texto grande a mano)
- [x] 5.2 `flutter analyze` y `flutter test` limpios
- [ ] 5.3 Actualizar `CLAUDE.md` (Selector de moods) y archivar con `/opsx:archive`
