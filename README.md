# Mood Calendar

Mood Calendar es una app Flutter para registrar el estado de ánimo de cada día, añadir una nota y revisar el mes en un calendario de colores. Los datos viven solo en el dispositivo. Está disponible en iOS y Android (mismo identificador, `com.artlab.moodcalendar`) y en cinco idiomas: inglés, español, alemán, francés e italiano.

- Sitio: <https://moodcalendar.app> (política de privacidad, términos y soporte)
- Versión actual: `1.8.5+36` (ver `pubspec.yaml`)

## Qué hace

- **Registro diario**: carrusel de moods con flechas y una cuadrícula para saltar a uno concreto, y una nota opcional por día.
- **Catálogo de 19 moods**: 5 gratuitos y 14 premium de compra única, sueltos o en Packs (Confianza, Afecto, Cuerpo e Intenso). Las compras pasan por RevenueCat (App Store y Google Play).
- **Calendario mensual** con navegación entre meses y un resumen con el mood más frecuente y la mejor racha.
- **Recordatorio diario** local, con hora configurable y autoguardado.
- **Exportar el historial** en JSON y compartirlo con la hoja del sistema.
- **Calificar la app** de forma automática (en hitos de uso) y manual desde Ajustes.
- Cuatro pestañas en un bottom bar flotante: selector, calendario, tienda y ajustes.

El idioma sigue al del dispositivo (el inglés es el fallback).

## Privacidad

- No hay cuentas ni backend: las entradas (mood, nota, fecha) no salen del dispositivo.
- **Firebase Analytics** mide el uso de forma anónima (instalaciones activas, sesiones, versión y una lista cerrada de eventos), solo en builds de release. Se puede apagar en Ajustes → "Compartir datos de uso anónimos". No usa el ID de publicidad ni pide permiso de rastreo.
- **Firebase Crashlytics** reporta fallos de forma anónima, solo en release.
- **RevenueCat** gestiona las compras.

Los detalles están en la [política de privacidad](https://moodcalendar.app/privacy/) y, para quien mantiene el proyecto, en las secciones de privacidad de `CLAUDE.md`.

## Stack

- Flutter 3.x (el CI usa 3.32.1), Dart `>=3.6.0 <4.0.0`. iOS 15.0 como mínimo.
- Estado con `flutter_bloc` (Cubit); persistencia local con `hive`.
- Compras con `purchases_flutter` (RevenueCat).
- Firebase: `firebase_core`, `firebase_crashlytics` y `firebase_analytics`.
- Notificaciones locales con `flutter_local_notifications` y `timezone`.
- UI con `flutter_svg`, `google_fonts` (Poppins) y `lottie`.
- Plataforma: `in_app_review`, `url_launcher`, `package_info_plus`, `share_plus`, `path_provider`.
- Código generado con `freezed`, `json_serializable` y `hive_generator`.

## Arquitectura

Clean Architecture con tres features (`mood`, `purchases`, `settings`) y un `core/` compartido:

```text
lib/
  core/
    localization/   # AppStrings (abstracta) + una subclase por idioma
    logging/        # AppLogger (package:logger)
    navigation/     # MainShell: pestañas y bottom bar
    notifications/  # LocalNotificationService
    rating/         # Pedido de calificación (in_app_review)
    settings/       # Preferencias en Hive (recordatorio, datos de uso, calificación)
    telemetry/      # AppTelemetry; reporte de fallos (Crashlytics) y analíticas (Firebase)
    widgets/        # Widgets compartidos
  features/
    mood/           # data / domain / presentation: registro, calendario, resumen, exportación
    purchases/      # RevenueCat, entitlements, Tienda y hojas de compra
    settings/       # Pantalla de Ajustes y su cubit
  main.dart
```

Reglas:

- La capa `presentation` no accede a Hive: pasa por cubits, casos de uso y repositorios.
- La persistencia de ajustes pasa por `AppSettingsRepository` (`core/settings/`).
- Logging y telemetría van por abstracciones (`AppLogger`, `AppTelemetry`), nunca por los paquetes directos.
- La telemetría se compone en `main.dart` como Logger → Crashlytics → Analytics. `AnalyticsAppTelemetry` solo reenvía una lista cerrada de eventos y parámetros, sin datos de las entradas.
- Todo control interactivo lleva `Semantics`.

El resto de carpetas del repo:

| Carpeta | Contenido |
|---|---|
| `scripts/` | Builds de release de iOS y Android y sus verificaciones |
| `site/` | Sitio web estático de `moodcalendar.app` (Vercel) |
| `aso/` | Material de las fichas de las tiendas |
| `tool/screenshots/` | Generadores de capturas y arte de App Store y Google Play |
| `openspec/` | Specs vigentes (`specs/`) e historial de cambios (`changes/archive/`) |
| `docs/` | ADRs, riesgos aceptados y notas históricas |

## Puesta en marcha

```sh
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # solo si cambias modelos freezed/json/hive
flutter run
```

Los archivos generados (`*.g.dart`, `*.freezed.dart`) se versionan.

Sin la llave de RevenueCat la app arranca igual, pero todas las compras fallan con "producto no disponible". Para probar la tienda con el catálogo real:

```sh
flutter run --dart-define=REVENUECAT_IOS_API_KEY=<key appl_...>        # iOS
flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=<key goog_...>    # Android
```

Firebase (Crashlytics y Analytics) solo se activa en builds de release; en debug, en los tests y en el entrypoint de capturas no sale nada del dispositivo.

## Comandos de desarrollo

```sh
flutter analyze        # lint; debe estar limpio para hacer merge
flutter test           # suite completa
dart format lib test   # formato
```

## Builds de release

Los builds de las tiendas **solo** se generan con los scripts de `scripts/`; no se corre `flutter build ipa` ni `flutter build appbundle` a mano (un hook de Claude Code lo bloquea en sesiones del agente):

```sh
REVENUECAT_IOS_API_KEY=<key> STORE_VERIFIED=1 scripts/build_ios_release.sh
REVENUECAT_ANDROID_API_KEY=<key> STORE_VERIFIED=1 scripts/build_android_release.sh
```

Los scripts exigen la llave de RevenueCat, la pasan con `--dart-define` y comprueban que quedó dentro del binario, que Crashlytics tiene su configuración y que el build no enlaza el ID de publicidad. El detalle (qué significan `STORE_VERIFIED` e `INTERNAL_TEST_BUILD`, cómo se sube cada build y qué se hace en App Store Connect y Play Console) está en `CLAUDE.md`, secciones "Build de release" y "Flujo de release".

## Pruebas y CI

Hay 262 pruebas unitarias y de widget en `test/`: repositorios, resolver y orden del selector, resumen y rachas, calificación, exportación, cubits de moods, compras y ajustes, pantallas principales y la telemetría (analíticas y reporte de fallos). Los fakes viven en `test/support/`.

`.github/workflows/ci.yml` corre `flutter pub get`, `flutter analyze` y `flutter test` en cada push a `main`, en cada pull request y a mano. El repo protege `main`: los PR necesitan que pase el check "Analyze and Test".

## Flujo de trabajo

- Siempre en ramas y con PR; nada de push directo a `main`. Se borra la rama una vez mergeada.
- Commits con [Conventional Commits](https://www.conventionalcommits.org/) (`feat(settings): ...`, `fix(mood): ...`, `docs(openspec): ...`).
- Los cambios no triviales siguen el flujo de OpenSpec (proponer, implementar, archivar); los specs vigentes están en `openspec/specs/`.

## Documentación

- `CLAUDE.md` — guía de trabajo del proyecto: estado actual, reglas de arquitectura, compras, releases, privacidad y sitio web.
- `CONTEXT.md` — glosario del dominio (Mood vs Mood Entry, Tier, Unlocked, Pack, Intensity...).
- `openspec/specs/` — comportamiento vigente de cada área; `openspec/changes/archive/` — el historial.
- `docs/adr/` — decisiones de arquitectura; `docs/risks.md` — riesgos aceptados de las compras.
- `backlog.md` — trabajo pendiente.
