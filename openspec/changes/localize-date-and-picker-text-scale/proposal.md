## Why

Dos defectos visibles en el selector de moods, detectados al verificar `move-note-button-to-header`: la fecha del encabezado sale con orden inglés en todos los idiomas ("Octubre 10, 2026", "Ottobre 10, 2026") y, con el texto del sistema al 200 %, el selector desborda 119 px en vertical a 390×844 pt. El primero hace que la app se vea mal traducida; el segundo rompe la pantalla principal para quien usa tamaños de texto grandes.

## What Changes

- La fecha del encabezado del selector y la etiqueta de accesibilidad de cada día del calendario se formatean según las convenciones de cada idioma: "October 10, 2026", "10 de octubre de 2026", "10. Oktober 2026", "10 octobre 2026", "10 ottobre 2026". Hoy el selector usa `{mes} {día}, {año}` y el calendario `{día} {mes} {año}` para todos los idiomas, y es/fr/it muestran el mes con mayúscula inicial.
- Ambos sitios pasan a usar un único formateador de fecha localizado, en lugar de armar el texto a mano.
- El selector de moods deja de desbordar con texto grande: si el contenido no cabe en la altura disponible, la pantalla se desplaza en vertical. Con tamaños normales el aspecto no cambia.

## Capabilities

### New Capabilities

### Modified Capabilities
- `localization-architecture`: se añade el requisito de que las fechas completas mostradas al usuario sigan el orden y la capitalización de cada idioma.
- `premium-moods`: se añade el requisito de que el selector de moods (carrusel) no desborde ni oculte controles con texto grande del sistema.

## Impact

- `lib/core/localization/app_strings.dart` y las 5 subclases (en, es, de, fr, it): nuevo formateador de fecha completa por idioma.
- `lib/features/mood/presentation/screens/mood_screen.dart`: usa el formateador y envuelve el cuerpo en un contenedor desplazable cuando no cabe.
- `lib/features/mood/presentation/screens/calendar_screen.dart`: la etiqueta de accesibilidad de cada día usa el mismo formateador.
- `test/`: tests del formateador por idioma y del selector con texto al 200 % (incluido el escenario que hoy falla).
- Sin cambios en datos, Hive, compras ni dependencias nuevas. Los nombres de mes (`monthNames`) del encabezado del calendario y del resumen mensual no cambian.
