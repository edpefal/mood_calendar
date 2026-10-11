# ASO Audit: Mood Calendar: Daily Tracker (iOS, US storefront)

Fecha: 2026-10-02 · App ID: 6752843360 · Versión auditada: 1.8.0

Datos obtenidos de la API pública de iTunes. No expone **subtitle**, **keyword field**, **promotional text**, **preview video**, **In-App Events** ni **Custom Product Pages**; esos puntajes son estimaciones.

## Hallazgos del listing en vivo

- **Título:** "Mood Calendar: Daily Tracker" (28 de 30 caracteres).
- **Categoría:** Health & Fitness (secundaria: Utilities). Los competidores directos están en Lifestyle.
- **Versión:** 1.8.0, publicada el 2026-10-02. Primera publicación: 2025-10-06.
- **Localización:** el listing solo está en **EN**, aunque la app tiene 5 idiomas.
- **Descripción:** ~70 palabras. Dice "6 different emotions" pero lista 5. No menciona moods premium, resumen mensual, rachas, notas ni privacidad.
- **Screenshots:** 4 en iPhone, 6 en iPad.
- **Ratings:** US 1 rating (1 estrella). MX 1 rating (5 estrellas). ES ninguno.
- **Reseña:** la única reseña de US es de 1 estrella (v1.7.0): la fecha muestra el día de la semana incorrecto y el teclado se cierra antes de poder guardar una nota.

## ASO Score Card

```
Overall ASO Score: 38/100

Title:              6/10  ██████░░░░
Subtitle:           4/10  ████░░░░░░  (estimado)
Keyword Field:      4/10  ████░░░░░░  (estimado)
Description:        3/10  ███░░░░░░░
Screenshots:        4/10  ████░░░░░░
Preview Video:      0/10  ░░░░░░░░░░  (se asume que no hay)
Ratings & Reviews:  1/10  █░░░░░░░░░
Icon:               6/10  ██████░░░░
Keyword Rankings:   3/10  ███░░░░░░░
Conversion Signals: 4/10  ████░░░░░░
```

- **Title (6):** tiene "Mood" y "Calendar". "Daily Tracker" es genérico y falta el término principal "Mood Tracker".
- **Keyword rankings (3):** posición **#7 para "mood calendar"**; **fuera del top 200 para "mood tracker"**, el término con volumen real.
- **Ratings (1):** un solo rating de 1 estrella y sin prueba social. Daylio tiene 61k ratings, EMMO 29k.
- **Screenshots (4):** 4 de 10 slots usados; los competidores usan 8–10.
- **Description (3):** corta y sin los moods premium.

## Quick Wins (hoy)

1. **Corregir la descripción.** Cambiar "6 emotions" por 10. Agregar moods premium, resumen mensual con mejor racha, notas diarias, vista de calendario, privacidad (datos locales) y recordatorios. Abrir con un gancho de una línea.
2. **Pedir rating en un momento de éxito.** `SKStoreReviewController` tras el 3.º o 7.º mood registrado o un hito de racha. Es la mayor brecha.
3. **Responder la reseña de 1 estrella** en App Store Connect indicando que la fecha y el teclado se corrigieron en 1.8.0 (verificar antes).
4. **Usar promotional text** para el lanzamiento premium, ej. "Nuevo: 5 moods premium + Confidence Pack." Se cambia sin revisión.
5. **Revisar subtitle y keyword field.** No repetir "mood", "calendar", "daily", "tracker". Sugerencia: `journal,diary,feelings,emotion,wellness,mental,health,habit,streak,check-in,log,anxiety` (minúsculas, comas sin espacios).

## High-Impact Changes (esta semana)

1. **Agregar subtitle** con keywords nuevas, ej. "Mood Journal & Emotion Log" o "Track Feelings, Streaks & Notes". Probar un título como "Mood Tracker: Calendar Diary" para capturar el término principal.
2. **Localizar el listing** a ES, DE, FR e IT. La app ya está traducida, así que el costo es casi cero y abre storefronts con menos competencia (MX, ES, AR, DE).
3. **Rehacer screenshots a 8–10 slots** con captions de beneficio. Orden sugerido: calendario de colores, 10 moods expresivos, resumen mensual y racha, notas diarias, packs premium, privacidad/datos locales, recordatorios. Los primeros 3 deben ser los más fuertes.
4. **Reconsiderar la categoría primaria.** Lifestyle agrupa a Daylio, DailyBean y EMMO. Probar Lifestyle como primaria y Health & Fitness como secundaria, y comparar impresiones durante 2–4 semanas.
5. **Reescribir las notas de versión** para usuarios, abriendo con "Corregido: fecha y guardado de notas".

## Strategic Recommendations (este mes)

1. **Construir volumen de ratings:** prompt inteligente más una entrada "Calificar la app" en Ajustes. Meta: 25+ ratings con 4.5 o más.
2. **Agregar un App Preview** de 15–25 s: registrar un mood, el calendario llenándose y la racha. Que funcione sin sonido.
3. **Product Page Optimization:** probar orden de screenshots e ícono (ver skill `ab-test-store-listing`).
4. **Custom Product Pages** por audiencia (ansiedad/autoconocimiento, journaling, parejas con el mood romantic), junto con Apple Search Ads para términos de nicho.
5. **In-App Events** estacionales (ej. check-in de Año Nuevo, semana de salud mental) para visibilidad extra (ver skill `seasonal-aso`).

## Comparación con competidores (US)

| App | Rating | Cantidad | Categoría | Screenshots |
|---|---|---|---|---|
| Daylio Journal - Mood Tracker | 4.8 | 61,846 | Lifestyle | 10 |
| DailyBean | 4.8 | 70,668 | Lifestyle | 8 |
| How We Feel | 4.9 | 29,881 | Health & Fitness | 8 |
| EMMO: Mood Tracker & Diary | 4.8 | 29,291 | Lifestyle | 7 |
| Bearable | 4.8 | 6,395 | Health & Fitness | 10 |
| **Mood Calendar** | **1.0** | **1** | Health & Fitness | **4** |

**Brecha:** todos los competidores tienen "Mood Tracker" o "Journal" en título o subtítulo y miles de ratings. La mejor apuesta es un ángulo de nicho: calendario como protagonista, privado y local, moods coloridos y expresivos, y compras únicas en lugar de suscripción (los competidores empujan suscripciones).

## Próximos pasos

- Compartir subtitle y keyword field actuales para afinar esos dos puntajes.
- Correr `metadata-optimization` para redactar título, subtitle y keyword field finales, o `keyword-research` para términos principales y de cola larga.
