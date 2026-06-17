# Mood Calendar

Flutter app para registrar y revisar estados de ánimo diarios. iOS como plataforma principal.

## Stack

- **Flutter** 3.x, Dart SDK `>=3.4.4 <4.0.0`
- **Estado**: flutter_bloc + Cubit
- **Persistencia**: Hive (local, sin backend)
- **Generación de código**: freezed, json_serializable, hive_generator → correr con `flutter pub run build_runner build`
- **Notificaciones**: flutter_local_notifications + timezone
- **UI**: flutter_svg (emojis SVG), google_fonts (Poppins), lottie

## Arquitectura

Clean Architecture con una sola feature (`mood`):

```
lib/
├── core/
│   ├── localization/     # AppStrings (abstracta) + subclases por idioma
│   ├── notifications/    # LocalNotificationService
│   ├── settings/         # AppSettings (Hive)
│   ├── telemetry/        # AppTelemetry (logging)
│   └── navigation/
└── features/mood/
    ├── data/             # datasources (Hive), models, repositories
    ├── domain/           # entities, usecases, repositories (interfaces)
    └── presentation/     # screens, widgets, bloc (Cubits)
```

## Localización

Clase abstracta `AppStrings` con subclases concretas por idioma. Para añadir un string:
1. Añadir getter abstracto en `app_strings.dart`
2. Implementar en **todos** los archivos: `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`

Idiomas soportados: inglés (en, **fallback**), español (es), alemán (de), francés (fr), italiano (it).

Las notificaciones usan español fijo (`AppStrings.forLocale(const Locale('es'))`) por falta de contexto en background — pendiente de mejora.

## Estados de ánimo

5 moods definidos en `mood_definition.dart` con intensidades 1–5:
`happy(1) → calm(2) → neutral(3) → sad(4) → angry(5)`

Los assets SVG están en `assets/icon/`. El resolver está en `MoodDefinitionResolver`.

## Comandos útiles

```bash
flutter analyze                          # lint
flutter pub run build_runner build       # regenerar código freezed/hive
flutter run                              # correr en simulador
```

## Conventional Commits

Usar el formato `<tipo>(<scope>): <descripción>` en todos los commits:

| Tipo | Cuándo usarlo |
|------|--------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Cambio de código sin fix ni feature |
| `chore` | Tareas de mantenimiento (deps, config, build) |
| `style` | Cambios de formato/UI sin lógica |
| `docs` | Solo documentación |
| `test` | Tests |
| `perf` | Mejora de rendimiento |

Scopes sugeridos: `localization`, `mood`, `calendar`, `notifications`, `settings`, `ui`

Ejemplos:
```
feat(localization): add German, French, Italian support
fix(mood): correct streak calculation for partial months
refactor(localization): migrate AppStrings to per-language subclasses
chore: update flutter_local_notifications to 17.1.2
```

## Notas

- `fl_chart` está en `pubspec.yaml` pero ya no se usa (la gráfica mensual fue eliminada) — se puede remover en un cleanup futuro
- No hay tests actualmente
- No hay backend ni autenticación; todos los datos son locales (Hive)
