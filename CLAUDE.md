# Mood Calendar

Flutter app para registrar y revisar estados de ánimo diarios, con un catálogo de moods gratuitos + moods premium de pago (RevenueCat). Se publica en iOS (plataforma principal, deployment target **iOS 15.0**) y en Android, con el mismo identificador `com.artlab.moodcalendar`.

## Estado actual (2026-11-04)

- **Versión**: `pubspec.yaml` está en `1.10.1+42`. La **1.10.0 (la suscripción Premium) está publicada en App Store y en Google Play** (comprobado el 2026-11-03), igual que la 1.9.0 (reloj). El build **1.10.1 (42), con el recolor Ocean Cyan y el ícono nuevo del iPhone y del reloj, está en TestFlight** (probado por el usuario el 2026-11-04) pero **no se ha enviado a revisión ni subido a Play**, ni se han recapturado las capturas de tienda: se hará junto con los siguientes cambios visuales, en un change nuevo, para no sacar dos versiones. Hasta entonces las tiendas muestran la marca morada y el sitio ya está en cian.
- **Analíticas medidas**: Firebase Analytics funciona (eventos vistos en Analytics → Realtime desde builds de TestFlight y de la pista interna). Los `GoogleService-Info.plist` y `google-services.json` siguen trayendo Analytics como deshabilitado aunque la propiedad de GA (`mood-calendar-fee5c`) está vinculada, y aun así funciona: no hace falta regenerarlos.
- **Declaraciones de privacidad al día**: App Privacy de Apple (Device ID, Purchase History, Product Interaction y Crash Data; no vinculados, sin rastreo) y Data safety de Play (interacciones en la app, ID de dispositivo, historial de compras y registros de fallos). Ver "Privacidad y declaraciones de las tiendas".
- **Sitio** `https://moodcalendar.app` activo (política de privacidad, términos y soporte en inglés y español). Ver "Sitio web".
- **Rediseño en curso (Bloques 1 y 2 de 3)**: el Bloque 1 (`redesign-block-1-visual-system-home-navigation`) está **mergeado en `main`** (PR #129, 2026-11-05) pero sigue activo porque le falta la tarea 9.3: sistema visual nuevo (tinta `#1D1D22`, malla pastel, vidrio, tema Sistema/Claro/Oscuro), Log con cuadrícula por categorías, 4 pestañas (Calendar, Insights, Log, Settings), paywall como hoja y Ajustes reorganizados. **No es publicable solo**: el paywall anuncia notas con biometría (Bloque 3) y la prueba gratis sigue activa en el mensual y el semanal de las tiendas (hay que quitarla en App Store Connect y Play antes de publicar, ver `backlog.md`). Pendiente del change: medir la fluidez del vidrio en un iPhone real (9.3), y hay que archivarlo antes que el Bloque 2 (sus deltas parten de los suyos). El build 1.10.1 (43) está en TestFlight desde el 2026-11-05 y `pubspec.yaml` está en `1.10.1+43`. El **Bloque 2** (`redesign-block-2-calendar-insights-log-time`: calendario nuevo con detalle del día, hora de registro e Insights real) está propuesto (PR #130, mergeado) e implementado en la rama `feat/redesign-block-2` (sin commitear); le faltan la revisión en simulador y la medición de fluidez (7.2 y 7.3). El Bloque 3 (onboarding y biometría) no existe todavía.
- **OpenSpec**: 16 specs vigentes (la suscripción añadió `premium-subscription`); el único change activo es el del Bloque 1. Archivados el 2026-11-04: `replace-mood-purchases-with-subscription` y `recolor-brand-to-ocean-cyan` (este con las capturas de tienda, el modo oscuro del sitio y el arranque en Android diferidos u omitidos por decisión del usuario).
- **Apple Watch**: implementada en el change `add-apple-watch-mood-picker` (elegir el mood de hoy desde el reloj), mergeada en `main` (PR #113), probada en un iPhone y un Apple Watch reales con TestFlight (2026-10-30) y **publicada en la 1.9.0**. Ver "Apple Watch".
- **Marca**: lo publicado y el sitio usan Ocean Cyan (`#00727D → #00838F`), pero la app en `main` migra con el Bloque 1 a la tinta `#1D1D22` con fondo de malla pastel (Ocean Cyan nunca se publicó en la app). Las fichas de las tiendas siguen con la marca morada. Ver "Sistema de diseño".
- **Compras heredadas retiradas (2026-11-04)**: no había ninguna compra real de los 18 productos de pago único (135 clientes de RevenueCat revisados). Se quitaron sus paquetes de la oferta `default`, quedaron inactivos en Play y fuera de venta en App Store Connect. Quien aún use una versión anterior a la 1.10.0 ve la tienda vacía hasta actualizar.
- **Pendiente**: notificaciones RTDN de Google Play hacia RevenueCat, respaldo de `~/my-release-key.jks` fuera del equipo y el toggle de Crashlytics (ver `backlog.md`).

## Stack

- **Flutter** 3.x (CI usa 3.32.1), Dart SDK `>=3.6.0 <4.0.0`
- **Estado**: flutter_bloc + Cubit
- **Persistencia**: Hive (local, sin backend)
- **Analíticas de uso**: Firebase Analytics (`firebase_analytics`), anónimas, solo en release en iOS/Android y con interruptor en Settings; sin ID de publicidad (ver "Arranque de la app")
- **Crashes**: Firebase Crashlytics (`firebase_core` + `firebase_crashlytics`, proyecto Firebase `mood-calendar-fee5c`, apps iOS y Android con el mismo identificador `com.artlab.moodcalendar`; Android ya está publicado en Google Play), solo en release en iOS/Android
- **Compras in-app**: purchases_flutter (RevenueCat) en iOS y Android (Android ya publicado en Google Play)
- **Generación de código**: freezed, json_serializable, hive_generator → correr con `flutter pub run build_runner build`
- **Notificaciones**: flutter_local_notifications + timezone
- **UI**: flutter_svg (emojis SVG), google_fonts (Poppins), lottie, fl_chart (gráficas de Insights; fijado en 1.1.0 porque el CI usa Flutter 3.32.1, que fija `vector_math` 2.1.4 y desde la 1.1.1 `fl_chart` pide ^2.2.0)
- **Utilidades de plataforma**: in_app_review (pedir/abrir calificación), url_launcher (política de privacidad), package_info_plus (versión en Settings), share_plus (hoja de compartir al exportar el historial)
- **CI/CD**: `.github/workflows/ci.yml` corre `flutter analyze` + `flutter test` en cada push a `main` y en cada PR. No hay despliegue automático: los builds de iOS y Android se generan con los scripts de `scripts/` y se suben a mano (el workflow de despliegue de Android por tag se eliminó: nunca llegó a funcionar de punta a punta y los tags ya no publican nada)

## Arquitectura

Clean Architecture con cuatro features (`mood`, `purchases`, `settings` y `watch`):

```
lib/
├── core/
│   ├── localization/     # AppStrings (abstracta) + subclases por idioma
│   ├── logging/          # AppLogger
│   ├── notifications/    # LocalNotificationService
│   ├── rating/           # ReviewRequester (in_app_review)
│   ├── settings/         # AppSettings y estado del pedido de calificación (Hive)
│   ├── telemetry/        # AppTelemetry, CrashReporter/Crashlytics (crash reporting) y AnalyticsReporter/Analytics (uso anónimo)
│   ├── theme/            # brand_colors.dart (BrandPalette: ThemeExtension clara/oscura, único lugar con colores), app_theme.dart (ThemeData por brillo), theme_cubit.dart (tema en la raíz)
│   ├── widgets/          # widgets compartidos (GradientPillButton = píldora de tinta, FloatingTabBar, GlassCard, MeshBackground, PhoneColumn)
│   └── navigation/       # MainShell: raíz de la app con las 4 pestañas (Calendar, Insights, Log, Settings) y el bottom bar
└── features/
    ├── mood/
    │   ├── data/         # datasources (Hive), models, repositories, services (export JSON, pedido de calificación)
    │   ├── domain/       # entities (MoodDefinition, MoodCategory), usecases, repositories, services (resolver, streak calculator, política de calificación)
    │   └── presentation/ # screens, widgets, bloc (Cubits)
    ├── watch/            # Apple Watch (solo iOS): canal de plataforma, casos de uso que aplican las elecciones del reloj y publican el estado, coordinador y WatchSyncHost
    ├── insights/         # pestaña Insights: servicios puros en domain (tendencia, día de la semana, Year in Pixels) y tarjetas con `fl_chart` en presentation
    ├── purchases/        # RevenueCat datasource, MoodEntitlementsRepository (+ Noop), PurchasesCubit, PremiumPlansView y la hoja de suscripción (showPremiumSheet)
    └── settings/         # solo presentation: SettingsScreen + SettingsCubit (recordatorio diario con autoguardado, exportar historial, calificar, privacidad, versión); la persistencia vive en core/settings/
```

`lib/firebase_options.dart` lo genera FlutterFire. `lib/features/ads/` y `lib/features/premium/` son carpetas vacías residuales (sin archivos `.dart`); la monetización vive en `purchases/`.

Fuera de `lib/`:

- `scripts/` — builds de release y verificaciones de los artefactos (llave de RevenueCat, Crashlytics, sin ID de publicidad, también sobre la app del reloj).
- `ios/WatchApp/` — app de Apple Watch (SwiftUI) y `ios/Runner/Watch/` (puente WatchConnectivity del iPhone). Ver "Apple Watch".
- `tool/watch/` — scripts del target del reloj (`add_watch_target.rb`) y de sus íconos (`export_mood_icons.sh`).
- `site/` — sitio web estático de `moodcalendar.app` (ver "Sitio web").
- `aso/` — material de la ficha de las tiendas (reporte ASO, headers de App Store, gráficos de funciones de Play).
- `tool/screenshots/` — generadores de capturas y arte de las tiendas (ver las secciones de screenshots).
- `openspec/`, `docs/` — specs, historial de cambios, ADRs y riesgos.
- `.github/workflows/ci.yml` — CI.

## Documentación de dominio y decisiones

- `PRODUCT.md` — contexto de producto del sitio y la marca (público, posicionamiento, restricciones y pruebas disponibles). Leerlo antes de tocar el copy o el diseño de `site/`.
- `DESIGN.md` (+ `.impeccable/design.json`) — sistema visual del sitio web: tokens, tipografía, componentes y reglas con nombre. Lo usan los comandos de `/impeccable`; actualizarlo si cambia `site/style.css`.
- `CONTEXT.md` — glosario del dominio (Mood vs Mood Entry, Tier, Unlocked, Subscription, Intensity, Most Common Mood, y los Purchase y Pack heredados). Respetar sus términos y los "_Avoid_".
- `docs/adr/` — ADR 0001 (intensity no es valencia), ADR 0002 (composición de Pack congelada; reemplazado por la suscripción).
- `docs/risks.md` — riesgos aceptados de IAP (sin validación de recibos en backend, etc.).
- `docs/brainstorms/` y `docs/plans/` — requisitos y plan de las compras de moods (abril 2026); contexto histórico, no vigente.
- `backlog.md` — backlog activo.
- `openspec/` — workflow spec-driven: `openspec/specs/` contiene los specs vigentes (`branded-launch-screen`, `bottom-navigation`, `calendar-navigation`, `daily-note-capture`, `ios-simulator-ui-testing`, `localization-architecture`, `monthly-mood-summary`, `mood-history-export`, `mood-store`, `premium-moods`, `rating-prompt`, `settings-screen`, `usage-analytics`, `crash-reporting`, `watch-mood-picker`, `premium-subscription`) y `openspec/changes/archive/` el historial de changes con su proposal/design/tasks. Consultarlo antes de tocar un área con historia.

## Localización

Clase abstracta `AppStrings` con subclases concretas por idioma. Para añadir un string:
1. Añadir getter abstracto en `app_strings.dart`
2. Implementar en **todos** los archivos: `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`

Idiomas soportados: inglés (en, **fallback**), español (es), alemán (de), francés (fr), italiano (it). La UI usa el locale del dispositivo (no hay locale hardcodeado).

Las fechas completas (día, mes y año) se formatean con `AppStrings.formatFullDate(date)` (orden y capitalización por idioma: "October 10, 2026", "10 de octubre de 2026", "10. Oktober 2026"…); no armarlas a mano con `monthNames`, que va capitalizado para títulos.

Las notificaciones (`LocalNotificationService`) resuelven el idioma con `PlatformDispatcher.instance.locale` (inyectable vía `localeResolver`) cada vez que programan el recordatorio, y el `title` de `MaterialApp` usa `onGenerateTitle`. Un recordatorio ya programado cambia de idioma en el siguiente arranque. `AppStrings.forLocale` cae a inglés para locales no soportados.

## Estados de ánimo

19 moods en `mood_definition.dart` (una sola lista, `allMoodDefinitions`, en el orden de pantalla), cada uno con `tier` (`MoodTier.base` | `MoodTier.premium`) y `category` (`MoodCategory`, obligatoria):

- **Base** (gratis, 11): `happy`, `calm`, `neutral`, `sleepy`, `sad`, `angry`, `anxious`, `stressed`, `scared`, `crying`, `sick`
- **Premium** (8; se desbloquean con la suscripción, y los que se compraron sueltos o en Pack en versiones anteriores siguen desbloqueados): `laughing`, `confident`, `brave`, `affectionate`, `hugging`, `romantic`, `shy`, `hurt`
- **Categorías** y orden fijo (nunca por uso, por `unlocked` ni por `intensity`): Positive (`happy`, `laughing`, `confident`, `brave`), Peaceful (`calm`, `affectionate`, `hugging`, `romantic`), Neutral (`neutral`, `sleepy`, `shy`) y Hard (`sad`, `angry`, `anxious`, `stressed`, `scared`, `crying`, `sick`, `hurt`). Cada categoría tiene un nivel (alto, alto, medio, bajo; ADR 0003) y un tinte; `angry` usa el rojo. `intensity` conserva los valores de siempre (1-19).

Reglas importantes:
- **`intensity` es solo un identificador interno, NO una escala de valencia** (ADR 0001, reemplazado por el ADR 0003: el puntaje para los análisis sale de la categoría). No ordenar, comparar, puntuar ni promediar moods por intensity.
- El resumen mensual muestra el **mood más frecuente** (moda, desempate por registro más reciente) y la **mejor racha**; no hay promedio ni gráfica.
- Racha: días consecutivos = diferencia de exactamente 1 día calendario, aunque cruce mes/año (`MoodStreakCalculator`).
- `unlocked` solo controla crear/editar entradas nuevas; nunca reescribe `Mood Entry` históricas.
- `MoodDefinition` ya no tiene `color`: el tinte sale de la categoría (`MoodDefinition.tone` → `BrandPalette.tint`) y se pide con `MoodDefinitionResolver.tintFor(context, mood)`; un mood nuevo debe declarar su categoría.

Los assets SVG están en `assets/icon/` (`brave.svg` es un outlier pesado pendiente de regenerar, ver `backlog.md`). El resolver está en `MoodDefinitionResolver`.

## Comportamientos con spec

Cada uno tiene su spec en `openspec/specs/`; leerla antes de cambiarlo.

- **Log** (`home-mood-log`, `premium-moods`, `mood-categories`): la pestaña central (`LogScreen`, `features/mood/presentation/screens/log_screen.dart`) muestra todos los moods en una cuadrícula de 4 columnas (2 con texto grande) agrupada por categoría y en orden fijo; no hay carrusel, contador, flechas ni hoja "todos los moods" ni orden por frecuencia (se borraron `MoodPickerOrder` y `MoodGridSheet`). No hay mood preseleccionado: Guardar se habilita al elegir uno. Tocar un mood premium bloqueado abre la hoja de suscripción (`showPremiumSheet`) sin cambiar la selección, la fecha ni la nota; guardar con un mood bloqueado la abre también, **salvo** que la entrada de esa fecha ya tenga ese mismo mood (`canSaveWithMood`): así quien dejó de pagar sigue pudiendo editar la nota de un día antiguo. Guardar ya no cambia de pestaña: el Log pasa al estado **Saved** (racha actual con `MoodStreakCalculator.currentStreak`, tarjeta con mood, categoría y nota, botón Edit y, solo hoy y si ayer no tiene entrada, "Forgot yesterday? Log it"). Abrir una fecha con entrada también muestra Saved. La nota se abre desde una píldora sobre Guardar (pregunta según la categoría); Guardar y la píldora quedan fijos sobre el bar y la cuadrícula se desplaza. El pedido de calificación sale del Log tras el primer frame de Saved (si la pestaña sigue activa).
- **Bottom bar** (`bottom-navigation`): `MainShell` (`lib/core/navigation/`) es el `home` y tiene 4 pestañas en un `IndexedStack`: Calendar, Insights, Log (botón central con degradado, pestaña inicial) y Settings. El bar (`FloatingTabBar`) es una cápsula de tinta con nombres visibles (su texto no pasa de 1.2×) y ancho máximo en iPad. Los modales (editor de nota, hoja de suscripción) lo cubren. Las pantallas reservan el espacio del bar a través del `padding.bottom` de `MediaQuery` que pone el shell: usar `SafeArea` o `MediaQuery.paddingOf(context).bottom` en pantallas nuevas. El shell posee la pestaña activa y la fecha del Log (`showLog(date, edit:)`, `showInsightsYear()`, `showSettings()`); tocar un día **sin entrada** del calendario, el "Edit" del detalle de un día (con `edit: true`: abre la cuadrícula ya editando), el recordatorio (`handleReminderTap`) y "Forgot yesterday?" llaman a `showLog`; el botón "ver año" del calendario llama a `showInsightsYear` (Insights con scroll a Year in Pixels). La campana del Log abre Settings. No hay `Navigator.push` entre pestañas ni pestaña Premium.
- **Calendario y detalle del día** (`calendar-navigation`, `monthly-mood-summary`): celdas teñidas por categoría con la carita, borde punteado y "+" en días pasados sin entrada, aro de tinta en hoy y futuros inertes; el título del mes abre un selector de mes y año (hoja; sin meses futuros). Tocar un día **con entrada** abre `DayDetailSheet` (mood, categoría, hora de registro, nota y Edit); un día pasado sin entrada va directo al Log. Debajo, el resumen: mood más frecuente, barra de distribución por categoría con nombres visibles y racha actual (de hoy o de ayer, independiente del mes visible) y mejor racha.
- **Hora de registro** (`entry-log-time`): `MoodEntry.loggedAt` (`HiveField(4)`, opcional; las entradas anteriores quedan en nulo, sin migración). La estampa `MoodCubit` (con un reloj inyectable) y la elección del reloj usa su `chosenAt`; `MoodRepositoryImpl.saveMood` la conserva si la entrada del día ya existe con el mismo mood y la reemplaza si el mood cambió. Solo se muestra en el detalle del día y solo si cae el mismo día calendario que la entrada (`loggedTimeFor`), con el formato de hora del dispositivo. No va al export ni a analíticas.
- **Insights** (`insights-screen`): resumen del mes, rachas, tendencia (7/30 días por día; 90/365 por semana), mood por día de la semana y Year in Pixels, calculados en el dispositivo desde `MoodCubit` con servicios puros (`TrendCalculator`, `WeekdayProfile`, `YearPixels`, `CategoryDistribution`) que sacan el valor numérico **del nivel de la categoría** (ADR 0003), nunca de `intensity`; un test falla si lo leen. Umbrales de datos insuficientes en `InsightsThresholds` (2 por rango, 2 por día de la semana, 14 en total). Gratis: resumen, rachas y tendencia de 7 y 30 días; Premium: 90 y 365 días, día de la semana y Year in Pixels, que quien no está suscrito ve difuminados (`LockedInsightCard`, con una ilustración fija, nunca sus datos) y "Ver con Premium" abre la hoja con `source` = `insights`. Las gráficas de línea y de barras usan `fl_chart` (solo Dart, sin red); cada una lleva `Semantics` y una leyenda con los nombres de las categorías porque `fl_chart` no tiene árbol de accesibilidad.
- **Fecha del Log** (`calendar-navigation`): las pestañas conservan su estado; la fecha del Log solo cambia al tocar un día del calendario (nunca uno futuro), por el atajo de ayer o por el recordatorio (hoy al iniciar la app).
- **Calificación** (`rating-prompt`): pedido automático tras guardar con el 3.er y el 7.º día con entradas (máx. 2 en la vida de la instalación, ≥30 días entre intentos), siempre desde el calendario y nunca tras un guardado fallido. La fila "Calificar" de Settings es manual y no cuenta como intento.
- **Settings** (`settings-screen`): cinco secciones — Premium ("Get Premium" abre la hoja; con suscripción, "Premium · Active" con plan y fecha abre la gestión de la tienda; "Restaurar compras" siempre), Reminders (recordatorio diario con **autoguardado**: los cambios se encolan y, si fallan, se revierten con un mensaje), Privacy and data (exportar historial y datos de uso), Appearance (tema Sistema/Claro/Oscuro) y Help (calificar, enviar comentarios a `support@moodcalendar.app`, política, términos y versión). El tema vive en `ThemeCubit` (raíz) pero se guarda con `SettingsCubit` para que ninguna escritura pise a otra. Es la cuarta pestaña del bottom bar.
- **Exportar historial** (`mood-history-export`): Settings > "Tus datos" genera un JSON v1 (`formatVersion`, `generatedAt`, `entryCount`, `entries[{date, mood, note}]`) y abre la hoja de compartir (anclada a la fila en iPad). `mood` es el id estable (`calm`), nunca la ruta del asset ni `intensity`; un mood desconocido se exporta tal cual en vez de caer en *happy*. El archivo va al directorio temporal y solo se conserva el último.

## Apple Watch

El reloj (solo iOS) permite elegir el mood de **hoy** con un toque. Spec en `openspec/specs/watch-mood-picker/` (historial en `openspec/changes/archive/*-add-apple-watch-mood-picker/`); contrato de sincronización en `docs/watch-sync-contract.md` y pruebas en `docs/watch-testing.md`.

- **El iPhone es la única fuente de verdad (Hive).** El reloj no guarda historial: muestra el último estado que publicó el iPhone (moods **desbloqueados** en el orden del selector, nombres ya localizados por `AppStrings` y el mood de hoy) y manda solo `{id, fecha local, mood, chosenAt}`, nunca `intensity` (ADR 0001). No hay compras en el reloj.
- **Transporte**: `updateApplicationContext` hacia el reloj y `transferUserInfo` (cola persistente) hacia el iPhone. Swift (`WatchBridge`, `WatchInboxStore`) guarda las elecciones en un buzón en `UserDefaults` porque Hive solo es accesible desde Dart; Dart (`ProcessWatchInboxUseCase`) las aplica conservando la nota del día y **solo después** las confirma (`ackInbox`). `WCSession` se activa en `AppDelegate` al arrancar, antes de Dart.
- **Cableado** (`lib/main.dart`): solo en iOS; `WatchSyncHost` arranca el coordinador, lo reactiva al volver a primer plano o cambiar el idioma y recarga `MoodCubit`/`CalendarCubit` con `fetchAll`/`refresh` (no con `save`, para no disparar el cambio de pestaña, el pedido de calificación ni analíticas). El reloj no emite eventos de analíticas.
- **Validación**: `MoodEntitlementsRepository.isUnlocked` devuelve `true` para ids desconocidos, así que el id se valida contra el catálogo antes de preguntar si está desbloqueado. `MoodEntry.mood` guarda la **ruta del asset**, no el id.
- **Target** (`ios/WatchApp/`, bundle `com.artlab.moodcalendar.watchkitapp`, watchOS 9.0): se crea y se mantiene con `ruby tool/watch/add_watch_target.rb` (gema `xcodeproj` de CocoaPods; idempotente; correrlo al añadir archivos). Tiene `SUPPORTED_PLATFORMS = "watchos watchsimulator"`: sin eso el archive compila el reloj con el SDK de iPhone y falla. La versión del reloj sale de `FLUTTER_BUILD_NAME`/`FLUTTER_BUILD_NUMBER` y debe coincidir con la del iPhone.
- **Íconos**: `tool/watch/export_mood_icons.sh` rasteriza `assets/icon/*.svg` a PNG @2x/@3x (`brew install librsvg`); incluye `brave`, que así pesa 14 KB.
- **Requisitos de desarrollo**: el runtime de watchOS (`xcodebuild -downloadPlatform watchOS`, varios GB) es obligatorio hasta para compilar `Runner` en simulador, y `flutter build ios --simulator`/`flutter run` piden `-d <udid>`. En simuladores WatchConnectivity no es fiable (el iPhone ve `appInstalled: NO`); la sincronización de punta a punta se prueba en dispositivos reales.
- **Release**: el archive incluye `Runner.app/Watch/WatchApp.app` y `verify_ios_archive_no_ad_id.sh` también revisa su binario y su `Info.plist`. Todo `main` que contenga el target lo publica en el siguiente IPA: no mergear cambios del reloj a medias.
- **Ficha de App Store Connect**: las capturas del reloj van en el conjunto `APP_WATCH_SERIES_10` (416×496, las que genera `tool/screenshots/capture_watch.py`); Apple no admite transparencia, así que las PNG RGBA se aplanan a RGB antes de subirlas.
- **Privacidad**: sin cambios. El reloj no usa la red ni lleva Firebase, RevenueCat ni `AdSupport`.
- **Fuera de la primera versión**: complicación en la esfera, app independiente, notas, días pasados, colores pastel por mood y acciones en la notificación del recordatorio (ver `backlog.md`).

## Compras in-app (RevenueCat)

- **Suscripción Premium** (vigente desde la 1.10.0): tres planes de una sola suscripción, con 3 días de prueba para clientes nuevos y precio base USD $0.99 semanal / $2.99 mensual / $14.99 anual (los precios viven en las tiendas, nunca en el código). iOS: grupo "Mood Calendar Premium" con `premium_weekly`, `premium_monthly` y `premium_annual`. Android: suscripción `premium` con los planes base `weekly`, `monthly` y `annual` y la oferta `trial` (en RevenueCat se registran como `premium:weekly`, etc.). Idioma por defecto de la ficha de Play: inglés. En RevenueCat los productos de las dos apps cuelgan del entitlement `premium` y de los paquetes estándar `$rc_weekly`, `$rc_monthly` y `$rc_annual` de la oferta `default`.
- **Compras sueltas heredadas** (versiones 1.8.x y 1.9.0): 18 productos no consumibles, 14 moods (`mood_<id>_unlock`) y 4 Packs (`pack_<id>_unlock`), en iOS y Android con los mismos identificadores. **Se retiraron el 2026-11-04**, una vez publicada la 1.10.0 en las dos tiendas: sus 18 paquetes ya no están en la oferta `default` (solo `$rc_weekly`, `$rc_monthly` y `$rc_annual`), están inactivos en Play y fuera de venta en App Store Connect (disponibilidad en cero territorios). Los productos y los entitlements `mood_<id>` se conservan en RevenueCat para poder restaurar compras antiguas. Las versiones anteriores a la 1.10.0 leen solo los paquetes `$rc_custom_*`, así que ven la tienda vacía hasta actualizar.
- El entitlement `premium` lo activa cualquier plan y desbloquea **todos** los moods premium (también los futuros). Los entitlements `mood_<id>` heredados se siguen leyendo en `MoodEntitlementsRepositoryImpl`, así que quien compró un mood o un Pack lo conserva aunque no se suscriba. `unlockedPremiumMoodIds()` e `isUnlocked()` son lo único que consumen el selector, el orden y el reloj. La prueba gratis (solo en el plan anual) se ofrece solo si la tienda confirma la elegibilidad (`checkTrialOrIntroductoryPriceEligibility` en iOS; la fase gratis de la opción por defecto en Android); ante cualquier duda, el botón dice "Suscribirme".
- `lib/main.dart` configura RevenueCat solo si recibe la llave de la plataforma vía `--dart-define` (`REVENUECAT_IOS_API_KEY` en iOS, `REVENUECAT_ANDROID_API_KEY` en Android; `revenueCatApiKeyFor` en `lib/features/purchases/data/revenue_cat_config.dart` elige la que toca); si no, usa `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible"). No tocar `purchases_flutter` antes de `Purchases.configure()`.
- Los nombres de los planes salen de `AppStrings` (`weeklyPlanLabel`, `monthlyPlanLabel`, `annualPlanLabel`), no de `storeProduct.title`: Google Play añade "(… (unreviewed))" a los títulos mientras la app no está revisada. El texto legal (precio, renovación automática, cancelación) y los enlaces a Términos y Privacidad (`/terms/` y `/privacy/`, con las versiones `/es/` si el dispositivo está en español) van en la pantalla Premium: Apple los exige.
- La oferta es **solo una hoja** (`showPremiumSheet`, ya no hay pestaña ni pantalla Premium) y solo se abre cuando el usuario la pide: tocar un mood bloqueado (`source` = `locked_mood`, con una cápsula del mood como contexto) "Get Premium" en Settings (`source` = `settings`) o una tarjeta o rango bloqueado de Insights (`source` = `insights`); nunca al abrir la app, tras guardar ni en un onboarding, y nunca a un suscriptor. Lleva el título "Understand how you feel", tres beneficios (Insights y Year in Pixels, notas con biometría, moods expresivos), las tarjetas de los tres planes con el anual preseleccionado y "Mejor valor", y el texto legal con los enlaces. **La prueba gratis solo se ofrece con el anual seleccionado y elegible** (con la línea de tiempo "Hoy" / fecha del primer cobro y sin promesa de recordatorio); con el mensual o el semanal el botón dice "Suscribirme". Al completar una compra la hoja se cierra y el Log conserva fecha, selección y nota.
- El MCP de RevenueCat (`mcp__revenuecat__*`) está disponible para consultar estado real de productos/entitlements — preferirlo a notas viejas en specs.

## Arranque de la app

`runApp()` se llama **antes** de inicializar notificaciones (que espera el diálogo nativo de permisos) y de tareas lentas. Nunca volver a hacer `await` de nada que dependa de interacción del usuario (diálogos del sistema, p. ej. el permiso de notificaciones) antes de `runApp()`: dejó la app congelada en el launch screen y causó un rechazo de Apple (Guideline 2.1(a)). Hive y `Purchases.configure()` sí se esperan antes de `runApp()` a propósito: no esperan al usuario y `configure()` debe terminar antes de construir `MoodEntitlementsRepositoryImpl` (ver `openspec/changes/archive/2026-09-29-fix-launch-blocked-on-notification-permission/`).

`initializeCrashReporting()` (`lib/core/telemetry/crash_reporting_bootstrap.dart`) es lo primero que corre en `main()` tras `ensureInitialized()`, para capturar también crashes de arranque; tampoco espera al usuario. Solo se activa con `kReleaseMode`, en iOS/Android y con `errorsEnabled` (`ENABLE_ERROR_TELEMETRY`); en debug, tests y `tool/screenshots/main.dart` queda `LoggerAppTelemetry` y nada sale del dispositivo. Si falla, la app arranca igual sin reporte. `CrashlyticsAppTelemetry` envuelve al logger y reenvía `recordError` como no fatal, **sin** las claves de contexto `date`, `mood`, `intensity` y `note` (`blockedContextKeys`): al añadir contexto a un `recordError`, no meter datos de entradas del usuario. El reporte es opt-out y no hay toggle en Settings (pendiente en `backlog.md`).

**Analytics** (`openspec/specs/usage-analytics/`): `initializeAnalytics()` (`analytics_bootstrap.dart`) corre tras abrir Hive y solo se activa con `kReleaseMode`, iOS/Android, Firebase ya inicializado y la preferencia `usageAnalyticsEnabled` (Hive, `true` por defecto, interruptor "Compartir datos de uso anónimos" en Settings); aplica `setCollectionEnabled(preferencia)` antes de componer la telemetría. La recolección nace apagada en `Info.plist` y el manifiesto y se enciende en código. La cadena es `Logger → Crashlytics → Analytics`: `AnalyticsAppTelemetry` solo reenvía los eventos de `AppTelemetryEvents.analyticsAllowlist` y los parámetros de `analyticsParameterAllowlist` (`has_note`, `source`, `plan`); `blockedContextKeys` (`telemetry_privacy.dart`) se comparte con Crashlytics. **Al añadir un evento, ponerlo en la allowlist solo si no lleva datos de entradas ni ids de moods.** `store_opened` lleva `source` (`locked_mood` o `settings`; el valor `tab` ya no existe) y `purchase_started`/`purchase_completed` llevan `plan` (`weekly`, `monthly`, `annual`). Sin ID de publicidad: el `Podfile` fija `$FirebaseAnalyticsWithoutAdIdSupport = true` (no enlaza IdentitySupport/AdSupport), no hay ATT, y el manifiesto quita `AD_ID` y `ACCESS_ADSERVICES_*`; los scripts `verify_android_bundle_no_ad_id.sh` y `verify_ios_archive_no_ad_id.sh` lo comprueban en cada release. `tool/screenshots/main.dart` provee `NoopAnalyticsReporter`.

## Sistema de diseño

- Todos los colores salen de `BrandPalette` (`lib/core/theme/brand_colors.dart`, un `ThemeExtension` con variante clara y oscura; `BrandPalette.of(context)`): nunca un literal de color en un widget. Tinta `#1D1D22` (clara) / `#F4F3F7` (oscura) para las acciones principales, fondo de malla pastel (`MeshBackground`), tarjetas de vidrio (`GlassCard`, con relleno opaco cuando el sistema pide contraste alto), tintes por categoría de mood (amarillo Positive, verde Peaceful, lavanda Neutral, violeta Hard, rojo `angry`) y el degradado `#B9A6FF → #F7B2D9 → #FFD3B6` del botón Log y del check de Saved. `test/core/theme/brand_colors_test.dart` recorre cada par texto/fondo en ambos brillos y falla bajo 4.5:1; si un tinte no da, se oscurece el texto, no el tinte.
- Tema Sistema (por defecto) / Claro / Oscuro: `ThemeCubit` en la raíz y `buildAppTheme(Brightness)` en `core/theme/app_theme.dart` (Poppins). Flutter no expone "reducir transparencia" de iOS: el relleno opaco sigue a contraste alto / colores invertidos.
- El color significa algo en esta app: el tinte de cada mood sale de su categoría y el nombre de la categoría siempre se puede leer (el color no la sustituye).
- Botón primario estándar: `GradientPillButton` (`lib/core/widgets/`, ahora una píldora de tinta; conserva el nombre) — usarlo en vez de `FilledButton`/`OutlinedButton` de Material.
- Fondos/cards ligados a un mood usan `MoodDefinitionResolver.tintFor(context, mood)`; las pantallas de pestaña van sobre `MeshBackground` y centradas con `PhoneColumn` (ancho máximo 520 pt en iPad).
- Títulos de AppBar en peso medio y color de texto; headers de sección en peso medio y color secundario.
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

El script se niega a correr sin la key, siempre pasa `--dart-define=REVENUECAT_IOS_API_KEY=<key>` y, al terminar (`scripts/verify_ios_archive_key.sh`), comprueba que la key quedó embebida en el binario compilado: falla si no está. Acepta flags extra de `flutter build ipa`. Después corre `scripts/verify_ios_archive_crash_reporting.sh`, que falla si el archive no trae `GoogleService-Info.plist` o los dSYMs de `Runner.app` y `App.framework` (sin ellos Crashlytics no inicializa o los traces no se simbolican). Por último corre `scripts/verify_ios_archive_no_ad_id.sh`, que falla si algún binario enlaza `AdSupport`, si el `Info.plist` declara `NSUserTrackingUsageDescription` o si las claves de Analytics (`FIREBASE_ANALYTICS_COLLECTION_ENABLED`, personalización y almacenamiento de anuncios) no están en `false`. El IPA se sube con `xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey <key id> --apiIssuer <issuer id>` (la `.p8` va en `~/.appstoreconnect/private_keys/`). A diferencia de Android, el script de iOS no tiene `INTERNAL_TEST_BUILD`: para un build de TestFlight hay que usar `STORE_VERIFIED=1`. Si el archive se compila pero la exportación falla (p. ej. `No Accounts` o falta el certificado de distribución, porque `xcodebuild` no alcanza la sesión de Xcode del usuario), el script termina con error y sin `.ipa`: el archive queda en `build/ios/archive/Runner.xcarchive` y hay que exportarlo desde Xcode Organizer o con `xcodebuild -exportArchive ... -allowProvisioningUpdates` en la terminal del usuario. La build phase "FlutterFire: upload-crashlytics-symbols" del target Runner sube los símbolos al archivar y necesita `flutterfire` instalado (`dart pub global activate flutterfire_cli`, en `~/.pub-cache/bin`).

`ios/Runner/Info.plist` declara `ITSAppUsesNonExemptEncryption=false` (la app solo usa HTTPS y el cifrado del sistema, exentos), así que App Store Connect ya no pide el cuestionario de cumplimiento de exportación en cada build; si algún día se añade cifrado propio, hay que revisarlo.

Un hook de Claude Code (`.claude/settings.json` → `.claude/hooks/require-release-script.sh`) bloquea `flutter build ipa`, `flutter build ios`, `flutter build appbundle` y `flutter build apk` de release ejecutados directo en una sesión. Los builds de simulador, debug y profile no se bloquean. Si se archiva desde Xcode (no recomendado) hay que poner el mismo `--dart-define` en los Build Settings del scheme de Release y correr después `REVENUECAT_IOS_API_KEY=<key> scripts/verify_ios_archive_key.sh`.

**Pasos manuales previos — el script no puede hacerlos por vos:**

1. **Conseguir la API key pública (SDK key) de RevenueCat para iOS.** Vía MCP: `mcp__revenuecat__list-projects` → `mcp__revenuecat__list-apps` (proyecto "Mood Calendar", app `app_store`) → `mcp__revenuecat__list-app-public-api-keys`. No es secreta (va embebida en el cliente), pero nunca se hardcodea en el repo: siempre por variable de entorno.
2. **Probar en simulador con esa misma key** (`flutter run --dart-define=REVENUECAT_IOS_API_KEY=<key>`) y confirmar que la pestaña Premium carga los tres planes con su precio (no vacía, sin mensaje de error). Repetirlo en un simulador/dispositivo **iPad** (Apple revisa en iPad Air) y confirmar que la UI aparece antes del diálogo de permisos de notificaciones.
3. Solo después correr el script con `STORE_VERIFIED=1`, que afirma que el paso 2 está hecho.

**Simuladores compartidos**: las apps `com.artlab.*` (Mood Calendar, Photo Wardrobe, Reevo) comparten vendor. En un simulador que tenga otras de esas apps instaladas, el SDK de RevenueCat puede reutilizar el ID anónimo de otra app y mostrar productos ajenos o "no packages found". Si la tienda sale vacía o con productos que no son de Mood Calendar, repetir la prueba en un simulador limpio (`xcrun simctl create ...`) antes de sospechar de la configuración; la del dashboard se puede confirmar con el MCP de RevenueCat.

**Por qué es obligatorio**: si falta el `--dart-define`, la app cae a `NoopMoodEntitlementsRepository` (todas las compras fallan con "producto no disponible" de inmediato). Eso ya causó un rechazo real de Apple (Guideline 2.1(b)) por un error visible en la pantalla de tienda durante la revisión; ver `openspec/changes/archive/2026-10-01-fix-app-review-iap-rejection/`. Olvidar el flag justo al archivar es fácil, y por eso el script y el hook existen.

## Build de release de Android (App Bundle)

**La única forma soportada de generar un `.aab` para Google Play es `scripts/build_android_release.sh`. No correr `flutter build appbundle` a mano** (sin la llave, las compras de Android fallan; el hook lo bloquea).

```bash
REVENUECAT_ANDROID_API_KEY=<key goog_...> STORE_VERIFIED=1 scripts/build_android_release.sh
```

Igual que el de iOS: se niega a correr sin la llave (debe empezar con `goog_`), la pasa por `--dart-define=REVENUECAT_ANDROID_API_KEY=<key>`, comprueba con `scripts/verify_android_bundle_key.sh` que está dentro del `libapp.so` de cada ABI del bundle y falla si no se generó el `.aab` (`build/app/outputs/bundle/release/app-release.aab`). La llave pública sale del MCP de RevenueCat: `list-projects` → `list-apps` (app "Mood Calendar Android", tipo `play_store`) → `list-app-public-api-keys`. Es pública, pero no se hardcodea: siempre por variable de entorno.

- `STORE_VERIFIED=1` afirma que la pantalla Premium se probó (compra de un plan con una cuenta de prueba) en un dispositivo Android con esa llave. Para el build que se sube a la pista interna justamente para hacer esa prueba, usar `INTERNAL_TEST_BUILD=1` en su lugar (la llave se exige y se verifica igual); ese bundle no debe promoverse a producción sin reconstruirlo con `STORE_VERIFIED=1`. Play exige que `targetSdk` sea el nivel actual (hoy 36) y que el código de versión no se repita entre subidas. Para que los planes carguen, la suscripción `premium` debe existir y estar activa en Google Play Console, RevenueCat necesita las credenciales de servicio de Play y el build tiene que estar subido a una pista de pruebas.
- El paquete de Android es `com.artlab.moodcalendar` (igual que el bundle ID de iOS). Se firma con el keystore de `android/key.properties`; el `.aab` resultante se sube a mano a Google Play Console (primero a la pista interna). Poner un tag `v*.*.*` ya no dispara ningún despliegue.
- Tras construir, `scripts/verify_android_bundle_no_ad_id.sh` falla si el manifiesto del `.aab` declara `com.google.android.gms.permission.AD_ID` o `ACCESS_ADSERVICES_*` (el manifiesto fuente los quita con `tools:node="remove"` porque el SDK de Analytics los añade). Estos dos scripts usan `grep -c` y no `grep -q`: con `pipefail`, `grep -q` cierra la tubería antes y da resultados falsos.
- R8 está activo en release: `android/app/proguard-rules.pro` (conectado en `buildTypes.release`) conserva las firmas genéricas de Gson que necesita `flutter_local_notifications` v17. Sin él, programar y cancelar el recordatorio fallaba con `TypeToken must be created with a type argument` en producción (1.8.4 a 1.10.0). Al subir el plugin a la v19 o posterior las reglas dejan de ser necesarias; mientras tanto, no quitarlas.
- Play no acepta repetir un `versionCode`: si un bundle `INTERNAL_TEST_BUILD` ya ocupó el número, el bundle de producción (con `STORE_VERIFIED=1`) necesita subir el build en `pubspec.yaml` (+1) en un PR aparte.
- Si se publica con Play App Signing, añadir el SHA-1 de la clave de firma de Play a la API key de Firebase de Android (restringida por paquete y SHA-1).

## Flujo de release

1. **Bump**: rama `chore/bump-...` y PR con la versión en `pubspec.yaml` (`<nombre>+<build>`); tras el merge, trabajar desde `main` limpio.
2. **Builds**: `scripts/build_ios_release.sh` y `scripts/build_android_release.sh` (secciones anteriores). Las llaves públicas de RevenueCat salen del MCP (`list-projects` → `list-apps` → `list-app-public-api-keys`).
3. **iOS**: subir el IPA con `altool` y esperar a que el build quede `VALID`. La versión de App Store Connect se crea por la API (`appStoreVersions`, `releaseType: AFTER_APPROVAL`, copyright `Mood Calendar`): hay que fijar `whatsNew`, el texto promocional (no se hereda), `supportUrl` y, en el `appInfo` nuevo, `privacyPolicyUrl` (solo editable con una versión en preparación; en la publicada da 409). Las capturas, descripción y palabras clave sí se heredan. Adjuntar el build y enviar a revisión. Si App Store Connect responde "You must respond to the required age ratings questions", se contesta la `ageRatingDeclaration` del `appInfo` en preparación (por API o en App Information > Age Rating); la declaración vigente es: sin redes sociales, sin anuncios, temas de salud o bienestar sí, clasificación 4+. Un envío a revisión pedido desde una sesión de Claude Code puede bloquearlo el clasificador de permisos: en ese caso se envía a mano en App Store Connect ("Add for Review").
4. **Android**: subir el `.aab` a la pista interna con la API de Play (edit → `bundles` → `tracks/internal` → `validate` → `commit`). La cuenta de servicio **no puede** confirmar una versión de producción (403 en `validate`): la versión de producción, con las notas por idioma, se crea a mano en Play Console con el bundle ya subido.
5. **Declaraciones**: si cambia qué datos recoge la app, actualizar antes App Privacy, Data safety y la política (ver la sección siguiente).

## Privacidad y declaraciones de las tiendas

La app solo envía datos anónimos de analíticas (Firebase Analytics, con interruptor en Settings) y de fallos (Crashlytics, sin interruptor), más las compras vía RevenueCat. Nada de las entradas (mood, nota, fecha, intensidad) sale del dispositivo. Esto está declarado en cuatro sitios que deben decir lo mismo:

- **App Privacy** (App Store Connect → App Privacy; solo web, la API no lo expone): Device ID (analíticas y funciones de la app), Purchase History (funciones de la app), Product Interaction (analíticas) y Crash Data (funciones de la app); todos no vinculados y sin rastreo.
- **Data safety** (Play Console → Contenido de la app): interacciones en la app (recopiladas, opcionales, estadísticas), ID de dispositivo (necesario, funciones de la app y estadísticas), historial de compras y registros de fallos/diagnóstico; sin datos compartidos con terceros.
- **Política de privacidad**: `site/privacy/` y `site/es/privacy/`; la URL se configura en la app (`privacyPolicyUrl` en `settings_screen.dart`), en Play Console y en cada versión de App Store Connect.
- **Specs**: `usage-analytics` y `crash-reporting`.

Cualquier SDK o evento nuevo que recoja datos obliga a actualizar los cuatro antes de publicar. Mantener la verificación de "sin ID de publicidad" (sin AdSupport, sin ATT, sin `AD_ID`).

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

- Tests unitarios y de widget en `test/` (hoy 488 en 44 archivos): repositorio, catálogo y categorías, resolver, streak calculator (mejor y actual), summary usecase, política y servicio de calificación, exportador JSON, `MoodCubit`, `LogScreen`, `MainShell` (pestañas, calendario y toque del recordatorio), contraste de la paleta en ambos brillos, `GlassCard`, `ThemeCubit`, `PurchasesCubit`, la hoja de suscripción (incluye los eventos de compras), `SettingsCubit` y `SettingsScreen` (incluye el interruptor de datos de uso), y la telemetría (`AnalyticsAppTelemetry`, `initializeAnalytics`, `initializeCrashReporting`). Los fakes están en `test/support/`: `fake_mood_entitlements_repository.dart` (compras), `fake_crash_reporter.dart` (fallos y `RecordingLogger`) y `fake_analytics_reporter.dart` (analíticas), `fake_watch_channel.dart` (buzón del reloj), `in_memory_mood_repository.dart` y `app_harness.dart` (`buildTestApp`/`buildTestProviders`: los proveedores de `main()` con fakes, `RecordingTelemetry`, `FakeSettingsRepository` y `FakeRatingPromptService`). La lógica de Swift se prueba con XCTest en `ios/RunnerTests/` (buzón del iPhone y modelo del reloj). Las pantallas que usan `SettingsScreen.forApp()` necesitan un `RepositoryProvider<AnalyticsReporter>` y un `ThemeCubit` (el harness los pone). Los tests de widget usan una ventana de teléfono (390×844): la de prueba por defecto (800×600) deja el botón Guardar fuera de pantalla.
- Las pantallas con efectos de plataforma reciben esos efectos inyectados para poder probarlos sin plugins: `SettingsScreen` toma `openUrl` y `shareFile`, `SettingsCubit` toma `scheduleReminder`/`cancelReminder`/`loadAppVersion`, el exportador toma `directoryProvider`.
- Siguen sin cubrirse la programación real de notificaciones (`LocalNotificationService` solo prueba el idioma) ni la navegación por notificación (pendiente en `backlog.md`).

### Testing de UI/UX en el simulador de iOS

El agente puede validar cambios de UI/UX de forma ad-hoc en el simulador (screenshots, taps, árbol de accesibilidad, diálogos nativos del sistema) usando `idb`. Ver `docs/ios-simulator-ui-testing.md` para el workflow completo. No es una suite de tests ni corre en CI. Notas verificadas:

- La navegación se prueba con `MainShell` como `home` (`test/core/navigation/main_shell_test.dart`, con los grupos `tabs`, `calendar` y `reminder tap`); `LogScreen` suelto funciona sin shell (sus callbacks son opcionales). El toque real de la notificación no se pudo reproducir con `simctl push` + `idb` (queda en la pantalla de bloqueo), por eso el manejador `handleReminderTap` se prueba con un widget test.
- Para probar pantallas angostas usar un simulador **iPhone 16e** (390 pt): dos simuladores iPhone SE (3.ª gen) recién creados sobre iOS 26.2 dejaron `simctl launch`/`terminate` colgados sin error.
- Con el simulador de iPad en horizontal, `simctl io screenshot` sale girado 90° (`sips -r 270` lo endereza) y `idb ui tap` usa las coordenadas del panel vertical: toma las de `idb ui describe-all` tal cual si ya vienen en vertical, o conviértelas `(x, y) → (1024 − y, x)` si vienen en horizontal.
- Al vigilar `flutter run` en segundo plano, cubrir también las señales de fallo (`No supported devices`, `Error:`, `Exception`); un filtro que solo espera el éxito expira en silencio.

### Screenshots de App Store

`tool/screenshots/main.dart` es un entrypoint **solo para capturas** (no se envía en la app): en cada arranque borra los datos locales y siembra el mes anterior completo (racha de 14 días) más una nota en el día de hoy (así el Log abre en su estado Saved; `capture.py` y `capture_android.py` pulsan Edit para llegar a la cuadrícula y usan las pestañas [calendario, insights, log, ajustes]; el arte de tienda no se ha recapturado con el rediseño), deja todos los moods premium desbloqueados y no inicializa notificaciones (evita el diálogo de permisos). Con `--dart-define=REVENUECAT_IOS_API_KEY=<key>` usa el catálogo real de RevenueCat en vez del repositorio "todo desbloqueado" (necesario para la pantalla Premium).

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
- `capture.py` necesita un `idb_companion` conectado al simulador (`idb_companion --udid <udid> &` y `idb connect <udid>`). Encuentra los botones por posición con `idb ui describe-all` porque las etiquetas cambian por idioma: las 4 pestañas del bottom bar son la fila de botones más baja, [selector, calendario, Premium, ajustes]; en el calendario, la fila de botones más alta (sin contar el bar) es [mes anterior, mes siguiente]. El calendario con datos es el del mes anterior.
- Flujo con los scripts de `tool/screenshots/` (requieren `idb`, Pillow y Google Chrome en macOS):

  ```bash
  python3 tool/screenshots/capture.py <udid> <iphone|ipad> <en|es|de|fr|it>   # picker, note, calendar, settings (reminders) -> build/screenshots/shots/
  python3 tool/screenshots/compose.py <iphone|ipad> [idiomas]                  # 6 slides por idioma -> build/screenshots/slides/
  ```

  `compose.py` arma cada slide en HTML (fondo pastel, titular traducido, marco de dispositivo sobre la captura) y lo exporta a PNG con Chrome headless en el tamaño exacto (iPhone 1320×2868, iPad 2064×2752). Los titulares están en el diccionario `TEXT` del script y la fuente Poppins va incluida en `tool/screenshots/fonts/` (licencia OFL). Los slides 1, 3 y 6 reutilizan la captura del calendario con distinto encuadre.
- El set publicado no incluye la pantalla Premium a propósito: muestra precios en dólares en todos los idiomas y los nombres de los moods premium, que cambiarán al añadir más. `build/` está en `.gitignore`, así que las capturas y los slides generados no entran al repo.

### Header y Search Results de App Store

App Store Connect > Product Page Information > "Header and Search Results" acepta un arte opcional por idioma (distinto de las capturas). `tool/screenshots/header.py` lo genera con Chrome headless y Pillow (sin simulador):

```bash
python3 tool/screenshots/header.py [en es de fr it]   # -> aso/header/<locale>/header_search_5244x2950.png
```

- Una sola imagen **16:9 de 5244×2950, PNG sin alfa** sirve para los dos slots. Specs de Apple: Header 21:9 (3840×1646), Search Results 3:2 (1920×1280 a 3840×2560); videos opcionales de 5–30 s.
- Apple recorta la imagen según el slot, así que el contenido debe quedar dentro de los 4425×2247 px centrales (cubre ambos recortes). Si se cambia el layout, mantenerlo ahí.
- Muestra ícono (`AppIcon 1024`), nombre, lema y una fila de caritas de `assets/icon/` (sin `brave.svg`, que es muy pesado). Los lemas por idioma están en el diccionario `TAGLINE` del script.
- Se sube a mano, un archivo por idioma, con el selector de idioma de la esquina: la misma imagen en **Header** y en **Search Results**, y revisar con **Preview**.

### Capturas y gráfico de funciones de Google Play

Play pide capturas de teléfono con proporción de hasta 2:1 (las de App Store, 1320×2868, no sirven) y un **gráfico de funciones de 1024×500**. Se generan igual que las de iOS, pero desde un emulador de Android:

```bash
# emulador sin datos que importen (el entrypoint BORRA los datos locales) y barra de estado en modo demo (9:41)
flutter run -t tool/screenshots/main.dart -d <serial>
python3 tool/screenshots/capture_android.py <serial> <en|es|de|fr|it>   # picker, note, calendar, reminders -> build/screenshots/shots/android/
python3 tool/screenshots/compose.py android [idiomas]                    # 6 slides de 1080×1920 -> build/screenshots/slides/android/
python3 tool/screenshots/header.py --play [idiomas]                      # -> aso/play/<locale>/feature_1024x500.png
```

- `capture_android.py` usa `adb` y `uiautomator dump` (botones por posición, igual que `capture.py`), cambia el idioma con `cmd locale set-app-locales` y lanza la app con `am start` (`monkey` no la abre). Pinta de blanco el gotero del cursor que Android deja en la nota.
- Imagen de emulador: Pixel 8, Android 15 `google_apis` arm64 con el disco de datos limitado a 3 GB; son varios GB, así que borrar el AVD y la imagen al terminar (`avdmanager delete avd`, `sdkmanager --uninstall`).
- Si Chrome ya está abierto, `header.py` usa un perfil temporal propio; sin él, el modo headless puede colgarse.
- El ícono de 512×512 sale de `AppIcon 1024` (opaco). Las imágenes se subieron a Play con la API (`edits.listings/<idioma>/<phoneScreenshots|featureGraphic|icon>`); la cuenta de servicio no puede validar ni confirmar una versión de producción, así que las versiones se crean a mano en Play Console.

## Sitio web (`site/`)

Sitio estático bilingüe para `https://moodcalendar.app`: inglés en `/` y español en `/es/`, cada uno con inicio, `/privacy/`, `/terms/` y `/support/`. Son archivos HTML escritos a mano más `style.css`, `icon.png`, `fonts/` e `img/`; **hay que editar siempre las dos versiones** y la fecha de "última actualización" de la política cuando cambie. No hay paso de build. Contexto de producto en `PRODUCT.md`; el change `redesign-landing-site` (OpenSpec) documenta las decisiones del rediseño.

- **Inicio** (`index.html`, `es/index.html`): la primera pantalla imita el selector de moods de la app (carrusel de las 5 caritas base con el degradado pastel de cada una, contador y botones de tienda), y debajo van la captura del calendario, el bloque de privacidad y una descarga final. Funciona sin JavaScript (las caritas se deslizan con scroll-snap; el script solo cambia fondo, nombre y contador) y respeta `prefers-reduced-motion`. Se publica como "gratis para descargar y usar": no afirma que todos los moods sean gratis ni menciona precios, la suscripción ni la tienda de moods (los Términos y la política sí describen la suscripción). Lo que dice de privacidad debe coincidir con `site/privacy/` y con las declaraciones de las tiendas.
- **Activos**: Poppins autoalojada en `fonts/` (OFL; sin fuentes ni scripts de terceros) y caritas base en `img/moods/` (copiadas de `assets/icon/`; actualizarlas si cambia el arte). La captura `img/calendar-<idioma>-{390,780}.webp` sale del calendario de `capture.py` (ver "Screenshots de App Store") y se regenera si cambia la UI; `img/og-<idioma>.jpg` (1200×630) se recorta de `aso/header/<idioma>/header_search_5244x2950.png`; los badges oficiales de App Store y Google Play están en `img/badges/` y no se modifican.

- **Hosting**: proyecto Vercel `mood-calendar-web` (equipo `artlabstudio`), con `site/` como directorio raíz y conectado al repo: despliega en cada push a `main` que cambie `site/` (un paso de "build ignorado" cancela los demás). Los comentarios de Vercel en los PR están desactivados en el panel.
- **Dominio y DNS**: comprado en Cloudflare; registro `A` `@` → `76.76.21.21` y `CNAME` `www` → `cname.vercel-dns.com`, ambos en "solo DNS" (con el proxy de Cloudflare, Vercel no puede emitir el certificado).
- **Correo**: `support@moodcalendar.app` es un reenvío de Cloudflare Email Routing hacia un Gmail; es el contacto de la política, los términos y el soporte.
- **URLs en las tiendas**: privacidad `https://moodcalendar.app/privacy/` (`/es/privacy/` para español) y soporte `https://moodcalendar.app/support/` (`/es/support/`).
- **Editor y copyright**: el sitio, la política y el copyright de App Store Connect usan "Mood Calendar". **Reevo no tiene nada que ver con Mood Calendar**: no usarlo como editor, titular ni copyright.

## Notas

- No hay backend ni autenticación; todos los datos son locales (Hive). Los unlocks de compras se cachean localmente; no hay validación de recibos en servidor (ver `docs/risks.md`).
