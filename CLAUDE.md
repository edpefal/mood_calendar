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
- **Utilidades de plataforma**: in_app_review (pedir/abrir calificación), url_launcher (política de privacidad), package_info_plus (versión en Settings), share_plus (hoja de compartir al exportar el historial)
- **CI/CD**: `.github/workflows/ci.yml` corre `flutter analyze` + `flutter test` en cada push a `main` y en cada PR; `deploy_android.yml` publica a Google Play al empujar un tag `vX.Y.Z`

## Arquitectura

Clean Architecture con tres features (`mood`, `purchases` y `settings`):

```
lib/
├── core/
│   ├── localization/     # AppStrings (abstracta) + subclases por idioma
│   ├── logging/          # AppLogger
│   ├── notifications/    # LocalNotificationService
│   ├── rating/           # ReviewRequester (in_app_review)
│   ├── settings/         # AppSettings y estado del pedido de calificación (Hive)
│   ├── telemetry/        # AppTelemetry
│   ├── widgets/          # widgets compartidos (GradientPillButton, FloatingTabBar)
│   └── navigation/       # MainShell: raíz de la app con las 4 pestañas y el bottom bar
└── features/
    ├── mood/
    │   ├── data/         # datasources (Hive), models, repositories, services (export JSON, pedido de calificación)
    │   ├── domain/       # entities, usecases, repositories, services (resolver, streak calculator, orden del selector, política de calificación)
    │   └── presentation/ # screens, widgets, bloc (Cubits)
    ├── purchases/        # RevenueCat datasource, MoodEntitlementsRepository (+ Noop), PurchasesCubit, MoodStoreScreen, purchase sheets
    └── settings/         # solo presentation: SettingsScreen + SettingsCubit (recordatorio diario con autoguardado, exportar historial, calificar, privacidad, versión); la persistencia vive en core/settings/
```

`lib/features/ads/` y `lib/features/premium/` son carpetas vacías residuales (sin archivos `.dart`); la monetización vive en `purchases/`.

## Documentación de dominio y decisiones

- `CONTEXT.md` — glosario del dominio (Mood vs Mood Entry, Tier, Unlocked, Purchase, Pack, Intensity, Most Common Mood). Respetar sus términos y los "_Avoid_".
- `docs/adr/` — ADR 0001 (intensity no es valencia), ADR 0002 (composición de Pack congelada).
- `docs/risks.md` — riesgos aceptados de IAP (sin validación de recibos en backend, etc.).
- `docs/brainstorms/` y `docs/plans/` — requisitos y plan de las compras de moods (abril 2026); contexto histórico, no vigente.
- `backlog.md` — backlog activo.
- `openspec/` — workflow spec-driven: `openspec/specs/` contiene los specs vigentes (`branded-launch-screen`, `bottom-navigation`, `calendar-navigation`, `daily-note-capture`, `ios-simulator-ui-testing`, `localization-architecture`, `monthly-mood-summary`, `mood-history-export`, `mood-store`, `premium-moods`, `rating-prompt`, `settings-screen`) y `openspec/changes/archive/` el historial de changes con su proposal/design/tasks. Consultarlo antes de tocar un área con historia.

## Localización

Clase abstracta `AppStrings` con subclases concretas por idioma. Para añadir un string:
1. Añadir getter abstracto en `app_strings.dart`
2. Implementar en **todos** los archivos: `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`

Idiomas soportados: inglés (en, **fallback**), español (es), alemán (de), francés (fr), italiano (it). La UI usa el locale del dispositivo (no hay locale hardcodeado).

Las fechas completas (día, mes y año) se formatean con `AppStrings.formatFullDate(date)` (orden y capitalización por idioma: "October 10, 2026", "10 de octubre de 2026", "10. Oktober 2026"…); no armarlas a mano con `monthNames`, que va capitalizado para títulos.

Las notificaciones (`LocalNotificationService`) resuelven el idioma con `PlatformDispatcher.instance.locale` (inyectable vía `localeResolver`) cada vez que programan el recordatorio, y el `title` de `MaterialApp` usa `onGenerateTitle`. Un recordatorio ya programado cambia de idioma en el siguiente arranque. `AppStrings.forLocale` cae a inglés para locales no soportados.

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

## Comportamientos con spec

Cada uno tiene su spec en `openspec/specs/`; leerla antes de cambiarlo.

- **Selector de moods** (`premium-moods`): el carrusel muestra primero los moods desbloqueados ordenados por frecuencia de uso y después los premium bloqueados (`MoodPickerOrder`); el orden se calcula al abrir la pantalla y no cambia mientras está abierta. Si la fecha ya tiene entrada, el carrusel se posiciona en su mood. Tocar un mood premium bloqueado abre la compra en vez de guardar.
- **Bottom bar** (`bottom-navigation`): `MainShell` (`lib/core/navigation/`) es el `home` y tiene 4 pestañas en un `IndexedStack`: selector de moods (`sentiment_satisfied_outlined`), calendario, tienda y ajustes. El bar (`FloatingTabBar`) es una cápsula flotante translúcida, con ancho máximo en iPad y una píldora en la pestaña activa. Los modales (editor de nota, hojas de compra) lo cubren. Las pantallas reservan el espacio del bar a través del `padding.bottom` de `MediaQuery` que pone el shell: usar `SafeArea` o `MediaQuery.paddingOf(context).bottom` en pantallas nuevas. El shell posee la pestaña activa y la fecha del selector; guardar un mood cambia a la pestaña del calendario y el recordatorio llama a `MainShellState.showMoodPicker(hoy)` tras cerrar los modales (`handleReminderTap` en `main.dart`). No hay `Navigator.push` entre pestañas.
- **Fecha del selector** (`calendar-navigation`): las pestañas conservan su estado; la fecha del selector solo cambia al tocar un día del calendario (hoy al iniciar la app). Ya no existe el botón de volver del calendario.
- **Calificación** (`rating-prompt`): pedido automático tras guardar con el 3.er y el 7.º día con entradas (máx. 2 en la vida de la instalación, ≥30 días entre intentos), siempre desde el calendario y nunca tras un guardado fallido. La fila "Calificar" de Settings es manual y no cuenta como intento.
- **Settings** (`settings-screen`): recordatorio diario con **autoguardado** (sin botón Guardar; los cambios se encolan y, si fallan, se revierten con un mensaje), exportar historial, calificar, política de privacidad y versión. Es el único lugar donde se configura el recordatorio; el calendario ya no tiene la campana. Es la cuarta pestaña del bottom bar, no una pantalla apilada.
- **Exportar historial** (`mood-history-export`): Settings > "Tus datos" genera un JSON v1 (`formatVersion`, `generatedAt`, `entryCount`, `entries[{date, mood, note}]`) y abre la hoja de compartir (anclada a la fila en iPad). `mood` es el id estable (`calm`), nunca la ruta del asset ni `intensity`; un mood desconocido se exporta tal cual en vez de caer en *happy*. El archivo va al directorio temporal y solo se conserva el último.

## Compras in-app (RevenueCat)

- 6 productos no consumibles en App Store Connect: `mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`.
- Un entitlement por mood premium; un Pack otorga varios entitlements. Composición y precio de packs se configuran en RevenueCat, no en código, y un Pack publicado nunca cambia de composición (ADR 0002).
- `lib/main.dart` configura RevenueCat solo si recibe `REVENUECAT_IOS_API_KEY` vía `--dart-define`; si no, usa `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible"). No tocar `purchases_flutter` antes de `Purchases.configure()`.
- El MCP de RevenueCat (`mcp__revenuecat__*`) está disponible para consultar estado real de productos/entitlements — preferirlo a notas viejas en specs.

## Arranque de la app

`runApp()` se llama **antes** de inicializar notificaciones (que espera el diálogo nativo de permisos) y de tareas lentas. Nunca volver a hacer `await` de nada que dependa de interacción del usuario (diálogos del sistema, p. ej. el permiso de notificaciones) antes de `runApp()`: dejó la app congelada en el launch screen y causó un rechazo de Apple (Guideline 2.1(a)). Hive y `Purchases.configure()` sí se esperan antes de `runApp()` a propósito: no esperan al usuario y `configure()` debe terminar antes de construir `MoodEntitlementsRepositoryImpl` (ver `openspec/changes/archive/2026-09-29-fix-launch-blocked-on-notification-permission/`).

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

**La única forma soportada de generar un build para subir al App Store es `scripts/build_ios_release.sh`. No correr `flutter build ipa` a mano.**

```bash
REVENUECAT_IOS_API_KEY=<key> STORE_VERIFIED=1 scripts/build_ios_release.sh
```

El script se niega a correr sin la key, siempre pasa `--dart-define=REVENUECAT_IOS_API_KEY=<key>` y, al terminar (`scripts/verify_ios_archive_key.sh`), comprueba que la key quedó embebida en el binario compilado: falla si no está. Acepta flags extra de `flutter build ipa`.

Un hook de Claude Code (`.claude/settings.json` → `.claude/hooks/require-release-script.sh`) bloquea `flutter build ipa` y `flutter build ios` de release ejecutados directo en una sesión. Los builds de simulador, debug y profile no se bloquean. Si se archiva desde Xcode (no recomendado) hay que poner el mismo `--dart-define` en los Build Settings del scheme de Release y correr después `REVENUECAT_IOS_API_KEY=<key> scripts/verify_ios_archive_key.sh`.

**Pasos manuales previos — el script no puede hacerlos por vos:**

1. **Conseguir la API key pública (SDK key) de RevenueCat para iOS.** Vía MCP: `mcp__revenuecat__list-projects` → `mcp__revenuecat__list-apps` (proyecto "Mood Calendar", app `app_store`) → `mcp__revenuecat__list-app-public-api-keys`. No es secreta (va embebida en el cliente), pero nunca se hardcodea en el repo: siempre por variable de entorno.
2. **Probar en simulador con esa misma key** (`flutter run --dart-define=REVENUECAT_IOS_API_KEY=<key>`) y confirmar que `MoodStoreScreen` carga el catálogo de moods premium (no vacío, sin mensaje de error). Repetirlo en un simulador/dispositivo **iPad** (Apple revisa en iPad Air) y confirmar que la UI aparece antes del diálogo de permisos de notificaciones.
3. Solo después correr el script con `STORE_VERIFIED=1`, que afirma que el paso 2 está hecho.

**Simuladores compartidos**: las apps `com.artlab.*` (Mood Calendar, Photo Wardrobe, Reevo) comparten vendor. En un simulador que tenga otras de esas apps instaladas, el SDK de RevenueCat puede reutilizar el ID anónimo de otra app y mostrar productos ajenos o "no packages found". Si la tienda sale vacía o con productos que no son de Mood Calendar, repetir la prueba en un simulador limpio (`xcrun simctl create ...`) antes de sospechar de la configuración; la del dashboard se puede confirmar con el MCP de RevenueCat.

**Por qué es obligatorio**: si falta el `--dart-define`, la app cae a `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible" de inmediato). Eso ya causó un rechazo real de Apple (Guideline 2.1(b)) por un error visible en la pantalla de tienda durante la revisión; ver `openspec/changes/archive/2026-10-01-fix-app-review-iap-rejection/`. Olvidar el flag justo al archivar es fácil, y por eso el script y el hook existen.

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

Scopes sugeridos: `localization`, `mood`, `calendar`, `notifications`, `settings`, `ui`, `purchases`, `ios`, `openspec` (archivado y sync de specs)

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

**Una vez mergeada una rama, hay que borrarla**, tanto en el remoto como en local (el repo no borra las ramas solo al mergear):

```bash
git push origin --delete feat/nombre-del-cambio   # o `gh pr merge --delete-branch`
git branch -d feat/nombre-del-cambio
```

En PRs apilados (un PR cuya base es la rama de otro PR), primero se mergea el padre, luego se reajusta el hijo con `gh pr edit <n> --base main` y solo después se borra la rama del padre; si no, el hijo pierde su base.

Cambios no triviales siguen el flujo OpenSpec: proponer (`/opsx:propose`) → implementar (`/opsx:apply`) → archivar (`/opsx:archive`), sincronizando los specs de `openspec/specs/` cuando cambian requisitos de comportamiento. Changes puramente operativos/visuales declaran `skip_specs: true`.

## Testing

- Tests unitarios y de widget en `test/` (repositorio, resolver, streak calculator, orden del selector, summary usecase, política y servicio de calificación, exportador JSON, `MoodCubit`, `MoodScreen`, `SettingsCubit` y `SettingsScreen`). `test/support/fake_mood_entitlements_repository.dart` es el fake de compras para tests.
- Las pantallas con efectos de plataforma reciben esos efectos inyectados para poder probarlos sin plugins: `SettingsScreen` toma `openUrl` y `shareFile`, `SettingsCubit` toma `scheduleReminder`/`cancelReminder`/`loadAppVersion`, el exportador toma `directoryProvider`.
- Siguen sin cubrirse la programación real de notificaciones (`LocalNotificationService` solo prueba el idioma) ni la navegación por notificación (pendiente en `backlog.md`).

### Testing de UI/UX en el simulador de iOS

El agente puede validar cambios de UI/UX de forma ad-hoc en el simulador (screenshots, taps, árbol de accesibilidad, diálogos nativos del sistema) usando `idb`. Ver `docs/ios-simulator-ui-testing.md` para el workflow completo. No es una suite de tests ni corre en CI. Notas verificadas:

- La navegación se prueba con `MainShell` como `home` (ver el grupo `bottom navigation` y `reminder tap` en `mood_screen_test.dart`); `MoodScreen` suelto sigue funcionando sin shell (`onSaved` es opcional). El toque real de la notificación no se pudo reproducir con `simctl push` + `idb` (queda en la pantalla de bloqueo), por eso el manejador `handleReminderTap` se prueba con un widget test.
- Para probar pantallas angostas usar un simulador **iPhone 16e** (390 pt): dos simuladores iPhone SE (3.ª gen) recién creados sobre iOS 26.2 dejaron `simctl launch`/`terminate` colgados sin error.
- Con el simulador de iPad en horizontal, `simctl io screenshot` sale girado 90° (`sips -r 270` lo endereza) y `idb ui tap` usa las coordenadas del panel vertical: toma las de `idb ui describe-all` tal cual si ya vienen en vertical, o conviértelas `(x, y) → (1024 − y, x)` si vienen en horizontal.
- Al vigilar `flutter run` en segundo plano, cubrir también las señales de fallo (`No supported devices`, `Error:`, `Exception`); un filtro que solo espera el éxito expira en silencio.

### Screenshots de App Store

`tool/screenshots/main.dart` es un entrypoint **solo para capturas** (no se envía en la app): en cada arranque borra los datos locales y siembra el mes anterior completo (racha de 14 días) más una nota en el día de hoy, deja todos los moods premium desbloqueados y no inicializa notificaciones (evita el diálogo de permisos). Con `--dart-define=REVENUECAT_IOS_API_KEY=<key>` usa el catálogo real de RevenueCat en vez del repositorio "todo desbloqueado" (necesario para la pantalla de la tienda).

**Siempre en simuladores propios y limpios**, nunca en los del día a día: el entrypoint **borra** los moods y ajustes de la app instalada, y compartir simulador con otras apps `com.artlab.*` contamina el catálogo de RevenueCat (ver "Simuladores compartidos"). Para recrearlos:

```bash
RT=$(xcrun simctl list runtimes | grep -o 'com.apple.CoreSimulator.SimRuntime.iOS-[0-9-]*' | tail -1)
IPHONE=$(xcrun simctl create "MC Shots iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max $RT)  # 1320×2868
IPAD=$(xcrun simctl create "MC Shots iPad" com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-16GB $RT)  # 2064×2752
for d in $IPHONE $IPAD; do xcrun simctl boot $d; done
xcrun simctl status_bar $IPHONE override --time 9:41 --batteryState charged --batteryLevel 100 --cellularMode active --cellularBars 4 --wifiBars 3
xcrun simctl status_bar $IPAD override --time 9:41 --batteryState charged --batteryLevel 100 --cellularMode notSupported --wifiBars 3
flutter run -t tool/screenshots/main.dart -d $IPHONE   # idem con -d $IPAD
```

Esas resoluciones corresponden a los tamaños de 6.9" y 13" que Apple lista para screenshots (confirmarlo en App Store Connect al subirlos); `xcrun simctl delete <udid>` borra los simuladores al terminar. Notas del flujo de captura:

- Tras compilar, `flutter run` puede quedarse esperando en un simulador recién creado (indexa atajos del sistema en el primer arranque). Si la app no abre sola: `xcrun simctl launch <udid> com.artlab.moodcalendar`.
- Para cambiar de idioma: `xcrun simctl terminate` y `xcrun simctl launch <udid> com.artlab.moodcalendar -AppleLanguages "(es)" -AppleLocale es_ES`. Los textos de la app (ya con acentos), el calendario y los nombres de los moods (`AppStrings.moodName`) siguen ese idioma.
- `capture.py` necesita un `idb_companion` conectado al simulador (`idb_companion --udid <udid> &` y `idb connect <udid>`). Encuentra los botones por posición con `idb ui describe-all` porque las etiquetas cambian por idioma: las 4 pestañas del bottom bar son la fila de botones más baja, [selector, calendario, tienda, ajustes]; en el calendario, la fila de botones más alta (sin contar el bar) es [mes anterior, mes siguiente]. El calendario con datos es el del mes anterior.
- Flujo con los scripts de `tool/screenshots/` (requieren `idb`, Pillow y Google Chrome en macOS):

  ```bash
  python3 tool/screenshots/capture.py <udid> <iphone|ipad> <en|es|de|fr|it>   # picker, note, calendar, settings (reminders) -> build/screenshots/shots/
  python3 tool/screenshots/compose.py <iphone|ipad> [idiomas]                  # 6 slides por idioma -> build/screenshots/slides/
  ```

  `compose.py` arma cada slide en HTML (fondo pastel, titular traducido, marco de dispositivo sobre la captura) y lo exporta a PNG con Chrome headless en el tamaño exacto (iPhone 1320×2868, iPad 2064×2752). Los titulares están en el diccionario `TEXT` del script y la fuente Poppins va incluida en `tool/screenshots/fonts/` (licencia OFL). Los slides 1, 3 y 6 reutilizan la captura del calendario con distinto encuadre.
- El set publicado no incluye la pantalla de la tienda a propósito: mostraba precios en dólares en todos los idiomas y los nombres de los moods premium, que cambiarán al añadir más. `build/` está en `.gitignore`, así que las capturas y los slides generados no entran al repo.

## Notas

- No hay backend ni autenticación; todos los datos son locales (Hive). Los unlocks de compras se cachean localmente; no hay validación de recibos en servidor (ver `docs/risks.md`).
