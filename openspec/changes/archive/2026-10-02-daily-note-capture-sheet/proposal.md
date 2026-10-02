## Why

El campo de nota diaria hoy es un `TextField` inline de solo 3 líneas visibles en `MoodScreen`, sin límite de caracteres. Esto genera una mala experiencia al escribir notas largas (el texto se desplaza dentro de un cuadro pequeño) y permite pegar texto arbitrariamente largo sin ningún tope, lo que puede degradar el layout y el export JSON. Se necesita una superficie de edición más amplia (bottom sheet) y un límite de caracteres explícito y visible.

## What Changes

- El campo de nota en `MoodScreen` pasa a ser de solo lectura (preview de hasta 3 líneas con `overflow: ellipsis`); ya no se escribe directamente ahí.
- Tocar el preview abre un bottom sheet (`isScrollControlled: true`, esquinas superiores redondeadas, consistente con `mood_purchase_sheet.dart`) con un campo de texto expandido para escribir la nota.
- El sheet tiene encabezado con título y botón "Listo" (estilo iOS, `TextButton`); se puede cerrar con "Listo", swipe hacia abajo o tap afuera — todos equivalentes, sin confirmación de descarte (el texto se edita en vivo sobre el mismo controller que ya usa `MoodScreen`, igual que el comportamiento actual).
- El campo del sheet tiene autofocus al abrirse y usa el color del mood seleccionado como acento visual (borde enfocado, botón "Listo"), consistente con `MoodDefinitionResolver`.
- Se agrega un límite de 500 caracteres (`maxLength`) con contador visible ("320/500") en color neutral, sin alertas de color al acercarse al límite.
- El placeholder vacío del preview inline cambia a un texto que indica la acción de tocar; el placeholder vacío dentro del sheet usa un texto distinto, más evocador, para invitar a escribir.
- Se agregan 4 strings nuevos a `AppStrings` (clase abstracta + 5 subclases: en, es, de, fr, it).

## Capabilities

### New Capabilities
- `daily-note-capture`: define el flujo de captura de la nota diaria mediante un bottom sheet (preview inline de solo lectura, apertura del sheet, límite de caracteres, cierre, autofocus, acento visual por mood).

### Modified Capabilities
- `localization-architecture`: el requisito existente "Placeholder del campo de nota localizado" se reemplaza/extiende porque ahora hay dos placeholders distintos (el del preview inline, que invita a tocar, y el del campo dentro del sheet, que invita a escribir) en lugar de un único placeholder de nota.

## Impact

- `lib/features/mood/presentation/screens/mood_screen.dart`: el `TextField` de nota pasa a `readOnly` con `onTap` que abre el nuevo bottom sheet; se mantiene el mismo `_noteController` y el mismo flujo de guardado (`_saveMood`).
- Nuevo widget para el bottom sheet (ubicación sugerida: `lib/features/mood/presentation/widgets/`), siguiendo la convención de `mood_purchase_sheet.dart`.
- `lib/core/localization/app_strings.dart` y las 5 subclases (`app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`): 4 getters nuevos.
- `openspec/specs/localization-architecture/spec.md`: actualizar el requisito del placeholder de nota.
- No hay cambios al modelo de datos (`MoodEntry.note` / `MoodModel.note` siguen siendo `String?` sin validación de longitud en el modelo); el límite de 500 caracteres es solo de entrada en la UI.
