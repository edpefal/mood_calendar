## Context

`RatingPromptService.maybeRequestAfterSave()` decide con `RatingPromptPolicy` (puro, sin plataforma) y la primera línea del método corta si la plataforma no es iOS (`isIOS`, inyectable para pruebas). `InAppReviewRequester` ya usa `in_app_review`, que en Android llama a la API de reseñas de Google Play; la fila manual de Settings (`openStoreListing`) ya abre Google Play en Android. Ver `proposal.md` para el motivo.

## Goals / Non-Goals

**Goals:**
- Que Android siga exactamente el mismo flujo que iOS (política, estado persistido, telemetría, momento "Saved").
- Mantener la inyección de la plataforma para las pruebas.

**Non-Goals:**
- Cambiar umbrales, intervalo o límite de intentos.
- Condicionar el pedido al estado de ánimo o a la racha (Apple y Google desaconsejan filtrar por sentimiento; se evalúa aparte si hace falta).
- Mostrar un diálogo propio previo ("¿te gusta la app?").
- Subir el build a Play: se hace aparte y con permiso expreso.

## Decisions

- **La condición de plataforma pasa de "es iOS" a "es iOS o Android".** El servicio recibe `isSupportedPlatform` (por defecto `Platform.isIOS || Platform.isAndroid`) en lugar de `isIOS`. Alternativa descartada: quitar la condición por completo; en escritorio no hay tienda detrás de `in_app_review` y el estado de intentos se consumiría sin mostrar nada.
- **Misma política y mismo estado en las dos plataformas.** `RatingPromptPolicy` y `RatingPromptLocalDataSource` no cambian: los intentos se cuentan por instalación, que es lo que piden los dos sistemas (cuotas por usuario).
- **Sin telemetría nueva.** El evento `rating_prompt_requested` ya existe y Analytics separa iOS y Android por plataforma; no se añaden parámetros ni se amplía la lista permitida.
- **`isAvailable()` sigue guardando la llamada.** En Android devuelve falso si Play Store no está disponible (por ejemplo instalaciones fuera de Play); el intento queda registrado antes de pedirlo, igual que hoy, para no insistir.

## Risks / Trade-offs

- [Google puede no mostrar el diálogo (cuota por usuario) y la app no lo sabe] → es el mismo caso que en iOS; el intento ya se registró y no se repite hasta el hito siguiente.
- [El diálogo de Play no se puede verificar con una build de depuración instalada por USB] → comprobarlo desde la pista interna de Play con una build firmada; las pruebas automáticas cubren la lógica y la plataforma inyectada.
- [Un intento gastado en un dispositivo donde Play no puede mostrar el diálogo] → aceptado: son 2 intentos de por vida y el usuario sigue teniendo la fila manual en Ajustes.

## Migration Plan

No hay migración de datos: el estado de intentos ya existe y vale 0 en las instalaciones de Android. El efecto llega solo con un build nuevo de Android (versionCode +1). Reversión: restaurar la condición solo-iOS.
