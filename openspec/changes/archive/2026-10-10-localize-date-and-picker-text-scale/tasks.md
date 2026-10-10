## 1. Formateador de fecha localizado

- [x] 1.1 Añadir `formatFullDate(DateTime date)` abstracto en `lib/core/localization/app_strings.dart`
- [x] 1.2 Implementarlo en `app_strings_en.dart` ("October 10, 2026") y `app_strings_de.dart` ("10. Oktober 2026")
- [x] 1.3 Implementarlo en `app_strings_es.dart` ("10 de octubre de 2026"), `app_strings_fr.dart` ("10 octobre 2026") e `app_strings_it.dart` ("10 ottobre 2026") con el mes en minúscula, sin modificar `monthNames`
- [x] 1.4 Sustituir `_formatDate` en `mood_screen.dart` y `_formatCalendarDate` en `calendar_screen.dart` por `strings.formatFullDate`, y borrar ambos métodos

## 2. Selector con texto grande

- [x] 2.1 En `mood_screen.dart`, envolver el `Column(spaceBetween)` del cuerpo en `CustomScrollView` + `SliverFillRemaining(hasScrollBody: false)`, conservando `SafeArea` y el padding actuales
- [x] 2.2 Comprobar a mano a 100 % que la disposición no cambia (encabezado arriba, carrusel centrado, Guardar abajo, sin scroll)

## 3. Tests

- [x] 3.1 Test unitario de `formatFullDate` por idioma: 10 de octubre de 2026 en en/es/de/fr/it, 1 de marzo sin cero a la izquierda y fallback a inglés para un locale no soportado
- [x] 3.2 Test de `MoodScreen`: la fecha del encabezado sale en el orden del idioma (es y en como mínimo)
- [x] 3.3 Test del calendario (vía `MainShell`): la etiqueta de accesibilidad de un día usa el mismo formato que el selector
- [x] 3.4 Cambiar el test "stays visible with a long date and large text" de `mood_screen_test.dart` a 2.0 de escala, sin excepciones, y comprobar que Guardar se alcanza desplazando
- [x] 3.5 Test: a 100 % el selector no es desplazable; con el carrusel arrastrado en horizontal sigue cambiando de mood con la pantalla desplazable
- [x] 3.6 Correr `flutter analyze` y `flutter test`

## 4. Verificación en simulador

- [x] 4.1 Capturas en iPhone 16e (390 pt) e iPad en los 5 idiomas con `tool/screenshots/capture.py`: fecha con el orden correcto y selector sin cambios a 100 % (usar simuladores propios y limpios, ver `CLAUDE.md`). Verificado: 16e en en/es/de/fr/it con `capture.py`; iPad solo en inglés con captura directa (`capture.py` se colgó dos veces en un simulador de iPad recién creado)
- [x] 4.2 Con el texto del sistema al 200 % en el 16e, comprobar que no hay desbordes y que se llega a Guardar. Verificado en alemán a ~200 % (cabe, sin desbordes) y al máximo ~310 % (se desplaza y se alcanza Guardar); a ese extremo la pregunta se parte en palabras por el ancho de la píldora

## 5. Documentación

- [x] 5.1 Revisar que `tool/screenshots/compose.py` y `CLAUDE.md` no asuman el formato de fecha anterior; añadir en `CLAUDE.md` la regla de usar `formatFullDate`
