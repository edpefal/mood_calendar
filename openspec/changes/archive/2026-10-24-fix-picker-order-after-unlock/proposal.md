## Why

Tras comprar un mood o un Pack, o tras restaurar compras, los moods recién desbloqueados no pasan al inicio del carrusel: siguen en su posición anterior hasta reiniciar la app. El spec fija el orden "al abrir la pantalla", pero desde que el selector es una pestaña que nunca se cierra (`IndexedStack`), "abrir la pantalla" solo ocurre al arrancar la app, al tocar un día del calendario o al tocar el recordatorio. Con 14 moods premium el desfase se nota mucho.

## What Changes

- El orden del carrusel se recalcula cada vez que el usuario regresa a la pestaña del selector, además de al abrirlo.
- Al recalcular se conservan la fecha, el mood seleccionado (aunque cambie de posición) y la nota sin guardar.
- Mientras el selector permanece visible el orden sigue sin cambiar, para que el carrusel no se reacomode bajo el usuario.
- No cambia la regla de ordenamiento (desbloqueados por frecuencia, después bloqueados en orden de catálogo) ni su independencia de `intensity`.

## Capabilities

### New Capabilities
<!-- ninguna -->

### Modified Capabilities
- `premium-moods`: el momento en que se calcula el orden del carrusel pasa de "al abrir la pantalla" a "al abrir el selector y cada vez que se vuelve a su pestaña".

## Impact

- **Código**: `MoodScreen` (recalcular el orden al activarse la pestaña, preservando selección y nota), `MainShell` (informar a `MoodScreen` si su pestaña está activa, como ya hace con `CalendarScreen`).
- **Tests**: widget tests en `mood_screen_test.dart` para compra, restauración y conservación de la selección.
- **Docs**: la sección "Selector de moods" de `CLAUDE.md` describe la regla anterior.
- **Sin cambios** en datos, compras, RevenueCat ni en las demás pestañas.
