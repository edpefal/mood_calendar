## Why

La app tiene un único rating en el App Store de EE.UU. (1 estrella) frente a decenas de miles en los competidores directos (Daylio 61k, EMMO 29k). Sin prueba social el listing convierte mal, y es la mayor brecha detectada en `aso/aso_report.md`. Hoy la app nunca pide una calificación ni ofrece una forma de darla.

## What Changes

- Pedir la calificación con el diálogo nativo de iOS (`SKStoreReviewController`, vía el paquete `in_app_review`) en un momento de éxito: tras un guardado correcto de una Mood Entry, cuando el total de entradas guardadas llega a **3** y, como segundo intento, a **7**.
- Límites propios: máximo 2 intentos automáticos en la vida de la instalación, nunca en el primer arranque, nunca si el guardado falló, y nunca encima del bottom sheet de nota. iOS además limita a 3 prompts por 365 días y decide si lo muestra.
- Persistir localmente (Hive) cuántos intentos se hicieron y cuándo fue el último.
- Agregar una fila **"Calificar Mood Calendar"** en la hoja de ajustes de recordatorios del calendario que abre la ficha de reseñas del App Store (`appStoreId` 6752843360). Esta apertura manual no está limitada por Apple.
- Textos nuevos en los 5 idiomas (en, es, de, fr, it), `Semantics` en el control nuevo y eventos de `AppTelemetry` para el intento automático y la entrada manual.
- Fuera de alcance: disparo por racha, encuesta de satisfacción previa al prompt, Android.

## Capabilities

### New Capabilities
- `rating-prompt`: cuándo y cómo la app pide una calificación en el App Store (disparo automático por cantidad de entradas guardadas, límites de intentos, persistencia) y la entrada manual "Calificar la app".

### Modified Capabilities
(ninguna — ningún spec vigente cambia de requisitos; los strings nuevos siguen la convención ya definida en `localization-architecture`)

## Impact

- Dependencia nueva: `in_app_review` en `pubspec.yaml`.
- `lib/features/mood/presentation/bloc/mood_cubit.dart` (o su capa de presentación) para detectar el guardado exitoso y el total de entradas.
- `lib/features/mood/presentation/screens/calendar_screen.dart`: nueva fila en `_ReminderSettingsSheet`.
- `lib/core/settings/` o un datasource nuevo en el box Hive `app_settings` (claves nuevas) para el contador y la fecha del último intento.
- `lib/core/localization/`: getters nuevos en `app_strings.dart` y en las 5 subclases por idioma.
- `lib/core/telemetry/`: eventos nuevos.
- Sin cambios de backend ni de compras; no afecta a RevenueCat.
