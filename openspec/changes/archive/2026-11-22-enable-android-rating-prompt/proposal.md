## Why

La app pide calificación automáticamente solo en iOS: `RatingPromptService.maybeRequestAfterSave()` sale de inmediato si la plataforma no es iOS, y el spec `rating-prompt` describe solo el App Store. En Android nadie ve nunca el diálogo, y una parte grande de los usuarios (y la primera compra real, el 2026-11-19) está en Android. Las fichas de Google Play tienen cero calificaciones, y la falta de reseñas es lo que más pesa en el atractivo de la ficha según la auditoría de Applyra.

## What Changes

- El pedido automático de calificación se activa también en Android, con la API de reseñas dentro de la app de Google Play (`in_app_review` ya la usa), con **la misma política**: primer intento al llegar al 3.er día con entradas, segundo al llegar a 7 días y 30 días después del primero, máximo 2 intentos en la vida de la instalación.
- En plataformas que no son iOS ni Android (escritorio, pruebas) el servicio sigue sin hacer nada.
- Se reescriben las partes del spec que dicen "App Store": ahora hablan de "la tienda de la plataforma" (App Store en iOS, Google Play en Android). La fila manual "Calificar Mood Calendar" ya funciona en las dos plataformas; el spec lo dice explícitamente.
- Sin cambios de política, de límites, de textos ni de telemetría. No hay datos nuevos: se reutilizan los mismos eventos, sin entradas ni identificadores.

## Capabilities

### New Capabilities

Ninguna.

### Modified Capabilities

- `rating-prompt`: el pedido automático y la entrada manual se aplican a iOS y Android (antes solo App Store), conservando umbrales, intervalo y límite de intentos.

## Impact

- Código: `lib/features/mood/data/services/rating_prompt_service.dart` (condición de plataforma) y su prueba `test/features/mood/data/services/rating_prompt_service_test.dart`.
- Spec: `openspec/specs/rating-prompt/spec.md` (vía el delta de este change).
- Build: requiere un build nuevo de Android para llegar a los usuarios (versionCode +1 y subida a Play, que se hace aparte y con permiso expreso). Sin cambios de privacidad: no se recogen datos nuevos.
- Límite conocido: Google decide si muestra el diálogo (cuota por usuario) y solo funciona con la app instalada desde Play; en la práctica la app solo solicita, igual que en iOS.
