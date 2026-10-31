## 1. Prerrequisitos y rama

- [x] 1.1 Confirmar que `add-apple-watch-mood-picker` está mergeado a `main` y archivado (PR #113 y #116). La 1.9.0 sigue en revisión de Apple; se empieza igualmente por decisión del usuario, y si Apple pide cambios se corrigen con un change nuevo.
- [x] 1.2 Crear la rama `feat/premium-subscription` desde `main` actualizado y comprobar `flutter analyze` y `flutter test` en verde. Línea base: analyze sin incidencias y 289 tests en verde.
- [x] 1.3 Revisar en RevenueCat (gráficos de ventas no consumibles y de ingresos) si hubo compras reales del intervalo 1.8.x–1.9.0 y anotar el resultado en el PR. Resultado a 2026-10-31: 0 compras no consumibles y $0 de ingresos desde la creación del proyecto (2026-09-25).

## 2. Productos y configuración en las tiendas (cada paso se muestra al usuario antes de ejecutarlo)

- [x] 2.1 App Store Connect: crear el grupo "Mood Calendar Premium" y las suscripciones `premium_weekly`, `premium_monthly` y `premium_annual` (niveles anual > mensual > semanal, Compartir en Familia desactivado). Hecho el 2026-10-31 por API; antes de poner precios Apple exige crear la disponibilidad de cada suscripción (las 175 regiones de la app).
- [x] 2.2 App Store Connect: precio base USD $0.99 / $2.99 / $14.99 con equivalencias por territorio, oferta de introducción gratis de 3 días para clientes nuevos en los tres productos. Hecho: precio en 175 de 175 regiones y prueba gratis en 175 de 175 por suscripción (la oferta de introducción se crea región por región; unas 500 llamadas por cada una, a ~4 s cada una).
- [x] 2.3 App Store Connect: nombre y descripción de cada plan en inglés, español, alemán, francés e italiano. Hecho; las tres suscripciones siguen en `MISSING_METADATA` hasta subir la captura de revisión (2.7).
- [x] 2.4 Play Console / API de Play: crear la suscripción `premium` con los planes base `weekly`, `monthly` y `annual`, mismo precio base y oferta de prueba gratis de 3 días para clientes nuevos. Hecho por API con la cuenta de servicio `play-publisher` (la ruta la autorizó el usuario); planes y ofertas `trial` activos. Play exige un listado en el idioma por defecto de la app; el idioma por defecto pasó de `es-419` a `en-US` por decisión del usuario (se subió el ícono de 512×512 al listado en inglés).
- [x] 2.5 RevenueCat: importar los productos en las apps iOS y Android, crear el entitlement `premium`, adjuntarle los 6 productos y añadir los paquetes `$rc_weekly`, `$rc_monthly` y `$rc_annual` a la oferta `default` sin quitar los 18 paquetes viejos. Hecho: iOS `premium_weekly|monthly|annual`, Android `premium:weekly|monthly|annual`; la oferta `default` sigue siendo la actual.
- [x] 2.6 Comprobar que la 1.9.0 (TestFlight, build 37) sigue cargando su tienda sin errores con los paquetes nuevos en `default`. Confirmado por el usuario el 2026-10-31. Que la oferta devuelve los 3 paquetes nuevos se comprueba con la app de la 1.10.0 (grupo 4).
- [ ] 2.7 App Store Connect: subir la captura de revisión de la pantalla Premium a las tres suscripciones, cuando la pantalla exista (grupo 4)

## 3. Dominio y datos de compras

- [x] 3.1 Crear `SubscriptionPlan`, `SubscriptionPlanType` y `SubscriptionStatus` en `lib/features/purchases/domain/entities/`; borrar `MoodPack` y `MoodOffer` Hecho: `SubscriptionPlan`, `SubscriptionPlanType` y `SubscriptionStatus`; `MoodPack` y `MoodOffer` borrados.
- [x] 3.2 Reescribir `MoodEntitlementsRepository` (D2): `availablePlans`, `purchasePlan`, `subscriptionStatus`, `restorePurchases`, `unlockedPremiumMoodIds`, `isUnlocked` Hecho: `availablePlans`, `purchasePlan`, `subscriptionStatus`, `restorePurchases`, `unlockedPremiumMoodIds` e `isUnlocked`.
- [x] 3.3 Reescribir `MoodEntitlementsRepositoryImpl`: `premium` activo desbloquea todos los ids premium del catálogo; si no, se leen los `mood_*` heredados; paquetes por `PackageType`; `SubscriptionStatus` desde `CustomerInfo` Hecho; el plan se deduce del producto de iOS (`premium_weekly`) o del plan base de Android (`weekly`).
- [x] 3.4 Elegibilidad de la prueba: `checkTrialOrIntroductoryPriceEligibility` en iOS y opciones de suscripción en Android; cualquier error o estado desconocido ⇒ no elegible Hecho en el datasource: iOS con `checkTrialOrIntroductoryPriceEligibility` y Android con la fase gratis de la opción por defecto. La elegibilidad de Android se confirma en la pista interna (9.3).
- [x] 3.5 Cálculo del ahorro del plan anual con los precios numéricos de la tienda (sin porcentajes fijos); adaptar `NoopMoodEntitlementsRepository` y los fakes de `test/support/` Hecho (`annualSavingsPercent`, `NoopMoodEntitlementsRepository` y el fake de `test/support/`); el entrypoint de capturas también se adaptó.
- [x] 3.6 Tests de Dart del repositorio: `premium` desbloquea todo; `mood_*` heredados sin suscripción; suscripción más heredados; vencimiento; paquetes ausentes; elegibilidad; errores de compra; restaurar 27 tests del repositorio (incluye planes, elegibilidad, heredados, vencimiento, compra y restauración).

## 4. Cubit y pantalla Premium

- [x] 4.1 Reescribir `PurchasesCubit`/`PurchasesState` (planes, plan seleccionado, estado de suscripción, `actionStatus`, reintento de carga) con los parámetros `plan` y `source` en la telemetría Hecho: `selectPlan`, `purchaseSelectedPlan`, `trackPremiumOpened(PremiumSource)` y estado `restored` para distinguir una restauración.
- [x] 4.2 Crear `PremiumScreen` y `PremiumPlansView` (escaparate de caritas, tarjetas de plan con el anual preseleccionado y "Mejor valor", botón principal, texto legal con enlaces a Términos y Privacidad, "Restaurar compras") y el estado de suscrito con plan, fecha y "Gestionar suscripción" Hecho en `PremiumScreen` y `PremiumPlansView` (`premium_plans_view.dart`).
- [x] 4.3 Conservar la recuperación cuando los planes no cargan (error, reintentar, reintento al volver a la pestaña) y la accesibilidad (`Semantics` en todo control) Hecho: error con reintento, reintento al volver a la pestaña, `Semantics` en las tarjetas y botones.
- [x] 4.4 Crear `showPremiumSheet(context, source)`; borrar `MoodStoreScreen`, `mood_purchase_sheet.dart` y `pack_purchase_sheet.dart` Hecho: `showPremiumSheet`; `MoodStoreScreen` y las dos hojas de compra borradas.
- [x] 4.5 Pestaña "Premium": nombre, icono (estrella o diamante outlined) y etiqueta de accesibilidad en `MainShell`/`FloatingTabBar`; quitar el acceso a la tienda del header Hecho: pestaña `MainTab.premium` con el icono `diamond_outlined`; el header ya no tenía acceso a la tienda.
- [x] 4.6 Tests de widget: planes y selección, texto del botón según elegibilidad, estado de suscrito y en prueba, error con reintento, restaurar, iPad y texto al 200 % 30 tests de la pantalla (planes, texto del botón, suscrito, errores, restaurar, enlaces y 200 % de texto en los 5 idiomas a 390 pt). Falta revisar iPad a ojo en simulador (9.4).

## 5. Selector de moods

- [x] 5.1 Función `canSaveWithMood` (D5) con tests unitarios: mood desbloqueado, mismo mood de la entrada existente, mood distinto bloqueado, fecha sin entrada Hecho: `canSaveWithMood` con 5 tests.
- [x] 5.2 `MoodScreen`: abrir `showPremiumSheet(source: lockedMood)` al tocar el mood bloqueado seleccionado, en la hoja de cuadrícula y al guardar con un mood bloqueado distinto; permitir guardar la nota con el mismo mood caducado Hecho en `mood_screen.dart` (mood seleccionado, hoja de cuadrícula y Guardar).
- [x] 5.3 Actualizar los tests de `mood_screen_test.dart` y `mood_picker_order_test.dart` (suscripción reordena al volver, restaurar reordena al volver, conservar la selección sin guardar) Hecho; 3 tests nuevos de quien deja de pagar.
- [x] 5.4 Verificar que el calendario, el resumen mensual y la exportación siguen mostrando las entradas con moods premium cuando la suscripción vence Verificado por código y tests: el calendario, el resumen y la exportación no leen los entitlements, solo `MoodScreen`, `MoodPickerOrder` y el reloj.

## 6. Apple Watch

- [x] 6.1 `ProcessWatchInboxUseCase`: si procesa alguna elección descartada o aplicada, publicar el estado con `handledChoiceIds` (últimos 20); `PublishWatchStateUseCase` incluye el campo Hecho: `WatchInboxResult.handledIds` y el campo `handledChoiceIds` en el estado; el coordinador conserva los últimos 20 y republica aunque todas las elecciones se hayan descartado.
- [x] 6.2 Reloj (`WatchModels.swift`, `WatchModel.swift`): leer `handledChoiceIds` y quitar la marca pendiente cuando contiene el id de la elección; un estado que no la menciona conserva la marca Hecho: `WatchAppState.handledChoiceIds`, `PendingChoice.id` (opcional, para elecciones guardadas por la versión anterior) y la regla en `WatchModel`.
- [x] 6.3 Tests de Dart y XCTest para ambos lados; actualizar `docs/watch-sync-contract.md` y `docs/watch-testing.md` Hecho: 6 tests nuevos de Dart (33 en total en `test/features/watch`) y 6 de Swift (16 en `WatchModelTests`, todos pasan con `xcodebuild test`); contrato y guía de pruebas actualizados.

## 7. Analíticas y cadenas

- [x] 7.1 Añadir `plan` a `analyticsParameterAllowlist`; enviar `source` en `store_opened` y `plan` en `purchase_started`/`purchase_completed`; tests de `AnalyticsAppTelemetry` y del cubit (sin ids de moods) Hecho (`plan` en la lista de parámetros; tests de `AnalyticsAppTelemetry` y del cubit).
- [x] 7.2 Cadenas nuevas en `app_strings.dart` y en los 5 idiomas (nombre de la pestaña, planes, "Mejor valor", botones, texto legal, estado de suscrito, errores) y retirar las de Packs, compras sueltas y avisos de solape Hecho en los 5 idiomas; se borraron las cadenas de Packs, compras sueltas y avisos de solape.
- [x] 7.3 Revisar la fijación de idioma de los enlaces de Términos y Privacidad (`/terms/`, `/es/terms/`, etc.) Hecho: los enlaces usan `/terms/` y `/privacy/`, y las versiones `/es/` si el idioma del dispositivo es español.

## 8. Sitio, documentos y especificaciones

- [x] 8.1 Reescribir la sección 3 de `site/terms` y `site/es/terms` y la línea de RevenueCat de `site/privacy` y `site/es/privacy`; actualizar sus fechas Hecho el 2026-10-31. El texto cubre también las versiones anteriores que aún venden moods sueltos, porque el sitio se publica antes que la 1.10.0.
- [x] 8.2 Actualizar `PRODUCT.md` (moods premium por suscripción; la web sigue sin precios), `CONTEXT.md` (glosario), `docs/risks.md` (caducidad offline), marcar el ADR 0002 como "Reemplazado" y actualizar `CLAUDE.md` y `backlog.md` (lo que queda fuera de v1) Hecho (`PRODUCT.md`, `CONTEXT.md`, `docs/risks.md` con una sección nueva, ADR 0002 marcado como reemplazado, `CLAUDE.md` y `backlog.md`).
- [x] 8.3 Validar con `openspec validate replace-mood-purchases-with-subscription` y revisar que no queden referencias a Packs o compras sueltas en `lib/`, `test/` y `site/` (salvo la lectura de `mood_*`) `openspec validate --strict` pasa; solo queda la lectura de `mood_*` como referencia a Packs en `lib/`.

## 9. Pruebas en dispositivo y en tiendas

- [ ] 9.1 iOS con cuenta sandbox y TestFlight: comprar cada plan con prueba de 3 días, renovación acelerada, caducidad, restaurar tras reinstalar y una compra heredada con la suscripción vencida
- [ ] 9.2 Reloj con la suscripción activa y caducada: el estado se actualiza, la elección de un mood bloqueado se descarta y la marca pendiente desaparece
- [ ] 9.3 Android en la pista interna con una cuenta de prueba de licencias: los mismos casos que 9.1 y verificación de la elegibilidad de la prueba
- [ ] 9.4 Pantalla Premium y hoja en iPad y con texto al 200 %, en los 5 idiomas; confirmar que no aparece sin que el usuario la pida
- [ ] 9.5 `flutter analyze`, `flutter test` y `xcodebuild test` en verde; los scripts `verify_*` del archive de iOS y del bundle de Android pasan

## 10. Publicación

- [ ] 10.1 Subir la versión a 1.10.0 (+build) en un PR aparte y, ya en `main`, construir con `scripts/build_ios_release.sh` y `scripts/build_android_release.sh` (`STORE_VERIFIED=1` solo tras 9.1–9.4 y con confirmación del usuario)
- [ ] 10.2 App Store Connect: versión 1.10.0 con las notas de versión, el párrafo de suscripción en la descripción (5 idiomas), las suscripciones adjuntas a la versión, y las notas para el revisor con la ruta a la pantalla y la cuenta sandbox; enviar a revisión
- [ ] 10.3 Play Console: subir el `.aab`, añadir el párrafo de suscripción a la ficha y confirmar a mano la versión de producción
- [ ] 10.4 Con la 1.10.0 publicada: retirar de la venta los 18 productos de compras sueltas en las dos tiendas y quitar sus 18 paquetes de la oferta `default` en RevenueCat (conservar entitlements y productos para restaurar)
- [ ] 10.5 Actualizar la sección "Estado actual" de `CLAUDE.md`, marcar el backlog y archivar el change con `/opsx:archive`
