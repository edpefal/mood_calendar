## Context

El flujo actual: el selector raíz (`MoodScreen`) abre el calendario con `pushReplacement`, así que el calendario no tiene nada debajo a donde hacer `pop`. Su botón de volver (`_goBack`) entonces reemplaza el calendario por `MoodScreen()` sin fecha, o sea hoy. Tocar un día hace `push` de `MoodScreen(selectedDate)`; al guardar se hace `pop` de vuelta al calendario con la fecha guardada. Ver proposal.md para la motivación y specs/calendar-navigation para el comportamiento.

El selector raíz puede tener una fecha distinta de hoy cuando se abre desde un recordatorio (`openMoodFromReminder`).

## Goals / Non-Goals

**Goals:**
- Recordar la última fecha vista sin persistirla.
- Cambiar solo a dónde vuelve el botón del calendario.

**Non-Goals:**
- Cambiar el flujo de guardado (sigue llevando al calendario).
- Recordar la fecha entre arranques de la app.
- Cambiar el botón de abrir calendario del selector ni el de la tienda.

## Decisions

**1. La última fecha vista vive en el estado del `CalendarScreen`**, no en un cubit ni en storage. Es estado de navegación efímero y el calendario es quien lanza cada selector hijo. Se inicializa con una fecha opcional recibida al abrir el calendario (la del selector de origen) y, a falta de ella, hoy; se actualiza justo antes de hacer `push` al tocar un día.
- Alternativa descartada: guardarla en `CalendarCubit`. Ese cubit gira en torno al mes mostrado y a las entradas; mezclar navegación ahí lo ensucia sin beneficio, porque el estado se pierde igual cuando el calendario se reemplaza.
- Alternativa descartada: persistir en `AppSettings`. Una fecha vista el mes pasado no debería reaparecer en el siguiente arranque.

**2. `popOrShowCalendar` y `MoodScreen` pasan la fecha vista al calendario.** `MoodScreen` ya conoce su fecha (`_selectedDate`) y la usa como `recentlySavedDate` al guardar; el botón del calendario del selector no la pasa hoy. Se añade un parámetro con la fecha vista para ambos caminos, y el calendario toma `viewedDate ?? recentlySavedDate ?? hoy`.

**3. `_goBack` abre `MoodScreen(selectedDate: lastViewedDate)`.** Si el calendario sí puede hacer `pop`, se mantiene el `pop` actual.

**4. Etiqueta accesible condicional.** Se mantiene `backToTodayTooltip` cuando la fecha es hoy y se añade un string nuevo (`backToMoodPickerTooltip`, "Volver al selector de ánimo" o equivalente) cuando no. Se evita renombrar el existente para no alterar el caso más común ni los flujos de captura de pantallas, que localizan los botones por posición.
- Alternativa descartada: una sola etiqueta genérica siempre. Cambia el caso habitual sin necesidad.

## Risks / Trade-offs

- [El calendario se recrea (`pushReplacement`) y pierde la fecha] → la fecha vista se pasa como parámetro en cada reemplazo; el único estado que no sobrevive es el de salir del calendario por otra vía, lo cual es aceptable.
- [Etiqueta nueva en 5 idiomas] → seguir el procedimiento de `AppStrings`; el test existente de localización cubre que ningún idioma se quede sin implementar.
- [Fecha futura] → no puede ocurrir: el calendario no permite abrir días futuros.

## Open Questions

- Redacción exacta de la etiqueta nueva en cada idioma (se puede cerrar en la implementación sin cambiar specs).
