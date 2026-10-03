# Mood Calendar

Flutter app para registrar y revisar estados de ánimo diarios, con un catálogo de moods gratuitos + moods premium de pago (RevenueCat). iOS como plataforma principal (deployment target **iOS 15.0**).

## Stack

- **Flutter** 3.x (CI usa 3.32.1), Dart SDK `>=3.4.4 <4.0.0`
- **Estado**: flutter_bloc + Cubit
- **Persistencia**: Hive (local, sin backend)
- **Compras in-app**: purchases_flutter (RevenueCat), solo iOS por ahora
- **Generación de código**: freezed, json_serializable, hive_generator → correr con `flutter pub run build_runner build`
- **Notificaciones**: flutter_local_notifications + timezone
- **UI**: flutter_svg (emojis SVG), google_fonts (Poppins), lottie

## Arquitectura

Clean Architecture con dos features (`mood` y `purchases`):

```
lib/
├── core/
│   ├── localization/     # AppStrings (abstracta) + subclases por idioma
│   ├── logging/          # AppLogger
│   ├── notifications/    # LocalNotificationService
│   ├── settings/         # AppSettings (Hive)
│   ├── telemetry/        # AppTelemetry
│   ├── widgets/          # widgets compartidos (GradientPillButton)
│   └── navigation/
└── features/
    ├── mood/
    │   ├── data/         # datasources (Hive), models, repositories, services (export JSON)
    │   ├── domain/       # entities, usecases, repositories, services (resolver, streak calculator)
    │   └── presentation/ # screens, widgets, bloc (Cubits)
    └── purchases/        # RevenueCat datasource, MoodEntitlementsRepository (+ Noop), PurchasesCubit, MoodStoreScreen, purchase sheets
```

`lib/features/ads/` y `lib/features/premium/` son carpetas vacías residuales (sin archivos `.dart`); la monetización vive en `purchases/`.

## Documentación de dominio y decisiones

- `CONTEXT.md` — glosario del dominio (Mood vs Mood Entry, Tier, Unlocked, Purchase, Pack, Intensity, Most Common Mood). Respetar sus términos y los "_Avoid_".
- `docs/adr/` — ADR 0001 (intensity no es valencia), ADR 0002 (composición de Pack congelada).
- `docs/risks.md` — riesgos aceptados de IAP (sin validación de recibos en backend, etc.).
- `backlog.md` — backlog activo.
- `openspec/` — workflow spec-driven: `openspec/specs/` contiene los specs vigentes (`branded-launch-screen`, `ios-simulator-ui-testing`, `localization-architecture`, `monthly-mood-summary`, `mood-store`, `premium-moods`) y `openspec/changes/archive/` el historial de changes con su proposal/design/tasks. Consultarlo antes de tocar un área con historia.

## Localización

Clase abstracta `AppStrings` con subclases concretas por idioma. Para añadir un string:
1. Añadir getter abstracto en `app_strings.dart`
2. Implementar en **todos** los archivos: `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`

Idiomas soportados: inglés (en, **fallback**), español (es), alemán (de), francés (fr), italiano (it). La UI usa el locale del dispositivo (no hay locale hardcodeado).

Las notificaciones (`LocalNotificationService`) y el `title` de `MaterialApp` usan español fijo (`AppStrings.forLocale(const Locale('es'))`) por falta de contexto en background — pendiente de mejora.

## Estados de ánimo

10 moods en `mood_definition.dart`, cada uno con `tier` (`MoodTier.base` | `MoodTier.premium`):

- **Base** (gratis): `happy(1)`, `calm(2)`, `neutral(3)`, `sad(4)`, `angry(5)`
- **Premium** (compra individual o vía Pack): `anxious(6)`, `brave(7)`, `confident(8)`, `romantic(9)`, `shy(10)`

Reglas importantes:
- **`intensity` es solo un identificador interno, NO una escala de valencia** (ADR 0001). No ordenar, comparar ni promediar moods por intensity.
- El resumen mensual muestra el **mood más frecuente** (moda, desempate por registro más reciente) y la **mejor racha**; no hay promedio ni gráfica.
- Racha: días consecutivos = diferencia de exactamente 1 día calendario, aunque cruce mes/año (`MoodStreakCalculator`).
- `unlocked` solo controla crear/editar entradas nuevas; nunca reescribe `Mood Entry` históricas.
- `MoodDefinition.color` **debe ser un `MaterialColor`** (`Colors.green`, etc.): `MoodDefinitionResolver.backgroundGradientForMood` deriva el gradiente pastel con `.shade50`/`.shade200`.

Los assets SVG están en `assets/icon/` (`brave.svg` es un outlier pesado pendiente de regenerar, ver `backlog.md`). El resolver está en `MoodDefinitionResolver`.

## Compras in-app (RevenueCat)

- 6 productos no consumibles en App Store Connect: `mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`.
- Un entitlement por mood premium; un Pack otorga varios entitlements. Composición y precio de packs se configuran en RevenueCat, no en código, y un Pack publicado nunca cambia de composición (ADR 0002).
- `lib/main.dart` configura RevenueCat solo si recibe `REVENUECAT_IOS_API_KEY` vía `--dart-define`; si no, usa `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible"). No tocar `purchases_flutter` antes de `Purchases.configure()`.
- El MCP de RevenueCat (`mcp__revenuecat__*`) está disponible para consultar estado real de productos/entitlements — preferirlo a notas viejas en specs.

## Arranque de la app

`runApp()` se llama **antes** de inicializar notificaciones (que espera el diálogo nativo de permisos) y de tareas lentas. Nunca volver a hacer `await` de diálogos del sistema o SDKs de terceros antes de `runApp()`: dejó la app congelada en el launch screen y causó un rechazo de Apple (Guideline 2.1(a)).

## Sistema de diseño

- Color de marca: púrpura `#5F3DC4` → `#6C63FF` (gradiente); launch screen con fondo `#8C52FF` coincidiendo con el ícono.
- Botón primario estándar: `GradientPillButton` (`lib/core/widgets/`) — usarlo en vez de `FilledButton`/`OutlinedButton` de Material.
- Fondos/cards ligados a un mood usan `MoodDefinitionResolver.backgroundGradientForMood(mood)`.
- Títulos de AppBar en bold + color de marca; headers de sección en bold sin color de marca. Íconos de navegación con tinte púrpura.
- Todo control interactivo debe tener label de `Semantics`.

## Comandos útiles

```bash
flutter analyze                          # lint
flutter test                             # tests unitarios/widget
flutter pub run build_runner build       # regenerar código freezed/hive
flutter run --dart-define=REVENUECAT_IOS_API_KEY=<key>   # correr en simulador con compras reales (sandbox)
```

## Build de release de iOS (archive/IPA)

**⚠️ Checklist obligatorio cada vez que se genera una nueva versión/build de release — no saltear ningún paso:**

1. **Conseguir la API key pública (SDK key) de RevenueCat para iOS** antes de buildear. Vía MCP: `mcp__revenuecat__list-projects` → `mcp__revenuecat__list-apps` (proyecto "Mood Calendar", app `app_store`) → `mcp__revenuecat__list-app-public-api-keys`. No es secreta (va embebida en el cliente), pero igual nunca se hardcodea en el repo — siempre vía `--dart-define`/variable de entorno.
2. **Incluir `--dart-define=REVENUECAT_IOS_API_KEY=<key>` en el build de archive**, sin excepción:
   ```bash
   flutter build ipa --dart-define=REVENUECAT_IOS_API_KEY=<key>
   ```
   Si se archiva desde Xcode en vez de `flutter build ipa`, agregar el mismo `--dart-define` en los Build Settings del scheme de Release (`Other Flutter Build Flags` / "Additional Run Args" según la versión de Xcode) antes de archivar.
3. **Antes de archivar, probar en simulador con esa misma key** (`flutter run --dart-define=REVENUECAT_IOS_API_KEY=<key>`) y confirmar visualmente que `MoodStoreScreen` carga el catálogo de moods premium normalmente — no vacío, no con mensaje de error.
4. **Repetir la verificación en un simulador/dispositivo iPad**, no solo iPhone (Apple revisa en iPad Air), y confirmar que la UI aparece antes del diálogo de permisos de notificaciones.
5. Solo después de 3 y 4 generar el archive final y subirlo.

**Por qué es obligatorio**: si falta el `--dart-define`, la app cae a `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible" de inmediato) — esto ya causó un rechazo real de Apple (Guideline 2.1(b)) por un error visible en la pantalla de tienda durante la revisión. Ver `openspec/changes/archive/2026-10-01-fix-app-review-iap-rejection/` para el contexto completo del incidente. El build de archive/release **nunca** pasó por `flutter run` normal (que si pedís la key manualmente sí la lleva) — es fácil olvidar el flag justo en el paso de archivar, que es exactamente lo que pasó la vez anterior.

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

Scopes sugeridos: `localization`, `mood`, `calendar`, `notifications`, `settings`, `ui`, `purchases`, `ios`

Ejemplos:
```
feat(localization): add German, French, Italian support
fix(mood): correct streak calculation for partial months
refactor(localization): migrate AppStrings to per-language subclasses
chore: update flutter_local_notifications to 17.1.2
```

## Workflow de desarrollo

Siempre trabajar en ramas y abrir PR — nunca push directo a `main`:

```bash
git checkout -b feat/nombre-del-cambio
# ... implementar ...
git push -u origin feat/nombre-del-cambio
gh pr create
```

El repo tiene branch protection: los PRs requieren que pase el check "Analyze and Test" (`.github/workflows/ci.yml`: `flutter analyze` + `flutter test`) antes de hacer merge.

Cambios no triviales siguen el flujo OpenSpec: proponer (`/opsx:propose`) → implementar (`/opsx:apply`) → archivar (`/opsx:archive`), sincronizando los specs de `openspec/specs/` cuando cambian requisitos de comportamiento. Changes puramente operativos/visuales declaran `skip_specs: true`.

## Testing

- Tests unitarios y de widget en `test/` (repositorio, resolver, streak calculator, summary usecase, `MoodCubit`, `MoodScreen`, settings, exportador JSON). `test/support/fake_mood_entitlements_repository.dart` es el fake de compras para tests.
- No hay tests de notificaciones/recordatorios ni de navegación por notificación (pendiente en `backlog.md`).

### Testing de UI/UX en el simulador de iOS

El agente puede validar cambios de UI/UX de forma ad-hoc en el simulador (screenshots, taps, árbol de accesibilidad, diálogos nativos del sistema) usando `idb`. Ver `docs/ios-simulator-ui-testing.md` para el workflow completo. No es una suite de tests ni corre en CI.

## Notas

- No hay backend ni autenticación; todos los datos son locales (Hive). Los unlocks de compras se cachean localmente; no hay validación de recibos en servidor (ver `docs/risks.md`).
