## Why

Al editar otra fecha desde el calendario y guardar, el botón de volver del calendario abre el selector de moods de **hoy**, no el de la fecha que la persona estaba viendo. Se pierde el contexto: quien revisa o corrige varios días seguidos tiene que volver a navegar a cada uno, y ver el mood de hoy justo después de guardar otro día se interpreta como un error.

## What Changes

- El calendario recuerda la última fecha cuya pantalla de selección se abrió durante la sesión de navegación (por tocar un día, o la fecha de la pantalla desde la que se abrió el calendario).
- El botón de volver del calendario abre el selector de moods de esa fecha, no siempre el de hoy.
- Si esa fecha es hoy, el comportamiento y la etiqueta accesible son los actuales ("Volver a hoy"). Si es otra fecha, la etiqueta accesible deja de decir "hoy" y refleja el destino real.
- Al abrir el calendario desde un selector de una fecha distinta de hoy (por ejemplo, abierto desde un recordatorio), esa fecha es la inicial.
- Sin cambios en el flujo de guardado: guardar sigue llevando al calendario con la animación del día guardado.

## Capabilities

### New Capabilities
- `calendar-navigation`: a qué fecha del selector de moods vuelve el botón de volver del calendario.

### Modified Capabilities

## Impact

- `lib/features/mood/presentation/screens/calendar_screen.dart`: estado de la última fecha vista; el botón de volver abre el selector de esa fecha; la etiqueta depende de si es hoy.
- `lib/features/mood/presentation/screens/mood_screen.dart` y `lib/core/navigation/app_navigator.dart`: pasar la fecha vista al calendario al abrirlo.
- Localización: un string nuevo para la etiqueta cuando la fecha no es hoy, en `app_strings.dart` y en los cinco idiomas.
- Tests de widget del flujo editar otra fecha → guardar → volver.
- No toca persistencia ni compras. No depende del change `order-moods-by-usage`.
