## 1. Implementación

- [x] 1.1 Añadir `isActive` (por defecto `true`) a `MoodScreen` y pasarlo desde `MainShell` como `_tab == MainTab.moodPicker`
- [x] 1.2 En `MoodScreen.didUpdateWidget`, al pasar de inactivo a activo, recalcular el orden con el historial y el `unlocked` actuales
- [x] 1.3 Conservar fecha, mood seleccionado (por id) y nota sin guardar; saltar el carrusel a la nueva posición del mood
- [x] 1.4 No hacer `setState` ni saltar si el orden recalculado es igual al actual

## 2. Tests

- [x] 2.1 Widget test: tras comprar un mood en otra pestaña y volver, el mood comprado aparece antes de los bloqueados
- [x] 2.2 Widget test: lo mismo tras restaurar compras
- [x] 2.3 Widget test: la selección, la fecha y la nota sin guardar se conservan al reordenar
- [x] 2.4 Widget test: con el selector visible, un cambio de `unlocked` no mueve el carrusel
- [x] 2.5 Ajustar el test existente "the order does not change when a mood is unlocked while open" si hace falta
- [x] 2.6 `flutter analyze` y `flutter test` en verde

## 3. Verificación y documentación

- [ ] 3.1 Probar en simulador: comprar un mood en la Tienda, volver al selector y ver el mood entre los desbloqueados — No se probó a mano; cubierto por el test automático "una compra hecha desde Ajustes reordena el selector al volver". — No probado a mano al archivar.
- [ ] 3.2 Probar restaurar compras y volver al selector — No se probó a mano al archivar.
- [x] 3.3 Actualizar la sección "Selector de moods" de `CLAUDE.md` con la regla nueva
