## Context

`mood_screen.dart` arma la fecha del encabezado con `'${months[month-1]} ${day}, ${year}'` (orden inglés para todos los idiomas) y `calendar_screen.dart` (`_formatCalendarDate`) con `'${day} ${month} ${year}'`, que es la etiqueta de accesibilidad (`Semantics`) de cada día del calendario, no un texto visible. Ambos leen `AppStrings.monthNames`, que en es/fr/it trae el mes con mayúscula inicial porque también sirve de título en el encabezado del calendario y en el resumen mensual. `intl` solo es dependencia transitiva (vía `flutter_localizations`), no directa.

El cuerpo del selector es `SafeArea > SizedBox.expand > Padding > Column(spaceBetween)` con un carrusel de altura fija (260). Con texto al 200 % en 390×844 pt el encabezado crece (fecha a 2 líneas, pregunta a 2-3) y la columna no cabe: desborde de 119 px. Ver proposal.md para la motivación.

## Goals / Non-Goals

**Goals:**
- Un único formateador de fecha completa, por idioma, usado por selector y calendario.
- Cero desbordes del selector hasta texto al 200 %, sin cambiar el aspecto a tamaños normales.

**Non-Goals:**
- Cambiar `monthNames`, el encabezado de mes del calendario o el resumen mensual.
- Mostrar día de la semana en la fecha.
- Reescalar o rediseñar el carrusel para texto grande, o añadir `intl` como dependencia directa.

## Decisions

**1. Formateador en `AppStrings`: `String formatFullDate(DateTime date)`.** Getter/método abstracto en `app_strings.dart` e implementación en las 5 subclases, con el patrón de cada idioma: en `October 10, 2026`; es `10 de octubre de 2026`; de `10. Oktober 2026`; fr `10 octobre 2026`; it `10 ottobre 2026`. Alternativas descartadas: (a) `intl` `DateFormat.yMMMMd(locale)`: exige declarar `intl` como dependencia directa e inicializar datos de fecha, para cubrir 5 idiomas que ya controlamos; (b) `MaterialLocalizations.formatFullDate`: incluye el día de la semana y no deja controlar el formato. La opción elegida sigue la arquitectura de `localization-architecture` (una subclase por idioma).

**2. Mes en minúscula en es/fr/it sin tocar `monthNames`.** Las subclases es/fr/it usan `monthNames[m - 1].toLowerCase()` dentro de `formatFullDate`; alemán conserva la mayúscula (sustantivo) e inglés también (los meses se escriben con mayúscula). `monthNames` sigue capitalizado para los títulos del calendario y el resumen. Así no se duplica la lista de meses.

**3. Un solo punto de uso.** `mood_screen.dart` y `calendar_screen.dart` llaman a `strings.formatFullDate(date)`; se borran `_formatDate` y `_formatCalendarDate`. Garantiza que el mismo día se vea igual en ambas pantallas.

**4. Desplazamiento solo cuando no cabe: `CustomScrollView` + `SliverFillRemaining(hasScrollBody: false)`.** El `Column(spaceBetween)` actual pasa a ser el hijo del sliver, y el `CustomScrollView` lleva `primary: false`: por defecto un scroll primario usa `AlwaysScrollableScrollPhysics`, que mantiene activo el arrastre vertical aunque el contenido quepa (en iOS rebotaría y, al competir con el swipe horizontal, el carrusel dejaba de cambiar de mood en los tests). A tamaños normales el sliver ocupa todo el alto disponible y la columna se distribuye igual que hoy (sin scroll); con texto grande el contenido supera el alto y se desplaza. Alternativas descartadas: (a) `SingleChildScrollView` + `ConstrainedBox(minHeight)` + `IntrinsicHeight`: equivalente, pero con el costo de intrínsecos y más anidamiento; (b) reducir el carrusel o escalar con `FittedBox`: cambia el aspecto del selector y esconde el problema en vez de dar acceso al contenido; (c) fijar el botón Guardar fuera del scroll: cambiaría la distribución a 100 % (tres bloques con `spaceBetween` pasarían a dos), así que se prefiere conservar el aspecto actual y aceptar que Guardar se desplaza en el caso extremo.

**5. Padding del bottom bar.** El espacio que reserva `MainShell` vía `MediaQuery.padding.bottom` sigue aplicándose con el `SafeArea` existente, de modo que al llegar al final del scroll el botón Guardar no queda tapado por el bar.

## Risks / Trade-offs

- [El botón Guardar sale de pantalla con texto muy grande] → Es el compromiso de la decisión 4; el usuario se desplaza para alcanzarlo. Si resulta incómodo, se puede fijar Guardar en un cambio aparte.
- [Un cambio sutil en el aspecto a 100 %] → Verificar en simulador con capturas antes/después en iPhone 16e e iPad que la distribución no cambia.
- [El `PageView` del carrusel dentro de un scroll vertical] → Los gestos son de ejes distintos; se cubre con un test de arrastre horizontal con la pantalla desplazable.
- [Formatos hechos a mano para 5 idiomas] → Un test por idioma fija el formato; al añadir un idioma, el getter abstracto obliga a implementarlo.
