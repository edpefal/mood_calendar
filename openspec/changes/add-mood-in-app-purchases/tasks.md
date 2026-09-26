## 1. Configuración de RevenueCat

> La configuración externa (cuenta de RevenueCat, App Store Connect, entitlements, pack de prueba) vive en el change `setup-revenuecat-store-config` — no se duplica aquí. Las tareas 1.4 y 1.5 dependen de que ese change esté avanzado (necesitan, respectivamente, un pack ya configurado para inspeccionar su metadata, y la API key pública de RevenueCat).

- [x] 1.4 Investigar y confirmar cómo `purchases_flutter` expone metadata custom de `Offering`/`Package` para describir la composición de un Pack (ver Open Question en design.md); si no es viable, documentar el fallback de lista mínima en código — **confirmado**: `purchases_flutter` 10.13.2 expone `Offering.metadata` (`Map<String, Object>`, verificado en el source oficial). `Package` no tiene metadata. Convención: clave `"{packageLookupKey}_moodIds"` en el metadata del Offering (ya configurado en RevenueCat como `pack_confianza_moodIds`). No se necesita el fallback de lista hardcodeada.
- [x] 1.5 Agregar `purchases_flutter` a `pubspec.yaml` y configurar la API key de RevenueCat (iOS, vía variable de entorno o `--dart-define`, nunca hardcodeada) en la inicialización de la app — `String.fromEnvironment('REVENUECAT_IOS_API_KEY')` en `main.dart`; correr con `flutter run --dart-define=REVENUECAT_IOS_API_KEY=appl_PqUaOfVljJyegpVDjMkhHroCQHf`

## 2. Catálogo de moods con tier

- [x] 2.1 Agregar `enum MoodTier { base, premium }` y campo `tier` a `MoodDefinition`
- [x] 2.2 Renombrar `freeMoodDefinitions` a `baseMoodDefinitions`; crear `premiumMoodDefinitions` con los moods premium (assets ya existentes: anxious, brave, confident, romantic, shy)
- [x] 2.3 Redefinir `allMoodDefinitions` como la unión real de `baseMoodDefinitions` + `premiumMoodDefinitions`
- [x] 2.4 Eliminar `MoodDefinitionResolver.moodPathForScore` (queda huérfano al remover `averageScore`)
- [x] 2.5 Revisar `backgroundGradientForMood`: confirmar que el caso `default` cubre los moods premium sin cambios adicionales — confirmado, no requirió cambios

## 3. Feature `purchases` — dominio

- [x] 3.1 Crear `lib/features/purchases/domain/entities/mood_offer.dart` (compra individual: moodId, precio mostrado, productId)
- [x] 3.2 Crear `lib/features/purchases/domain/entities/mood_pack.dart` (id, label, moodIds congelados, precio mostrado, productId)
- [x] 3.3 Crear `lib/features/purchases/domain/repositories/mood_entitlements_repository.dart` (interfaz: `isUnlocked`, `unlockedPremiumMoodIds` stream, `availableMoodOffers`, `availablePacks`, `purchaseMood`, `purchasePack`, `restorePurchases`) — se agregó también `domain/entities/purchase_failure.dart` (`PurchaseException`/`PurchaseFailureReason`) para el manejo de errores de la tarea 4.4

## 4. Feature `purchases` — datos (RevenueCat)

- [x] 4.1 Crear `lib/features/purchases/data/datasources/revenue_cat_datasource.dart` (wrapper sobre `purchases_flutter`: fetch de offerings/customer info, listener de cambios, purchase, restore)
- [x] 4.2 Implementar `MoodEntitlementsRepositoryImpl`: `isUnlocked` devuelve `true` inmediato para moods `base`; para `premium` consulta el cache en memoria alimentado por `customerInfo.entitlements.active` (vía listener, sin llamada de red por cada check)
  > **Bug encontrado en QA de dispositivo (9.3) y corregido**: los entitlements en RevenueCat tienen el identificador `mood_<moodId>` (ej. `mood_anxious`), no `<moodId>` crudo. El código comparaba directo contra `moodId` sin el prefijo, así que `isUnlocked` siempre daba `false` aunque la compra se hubiera completado (confirmado con un recibo JWS real de sandbox). Se corrigió despojando el prefijo `mood_` al mapear `customerInfo.entitlements.active` a `moodId`s dentro de `MoodEntitlementsRepositoryImpl`, para que el resto de la app siga trabajando solo con `moodId`s planos.
- [x] 4.3 Mapear la composición de cada Pack para la UI según lo resuelto en la tarea 1.4 — se lee `Offering.metadata['pack_${packId}_moodIds']`
  > **Bug encontrado en QA de dispositivo (9.3) y corregido**: el pack "Confidence Pack" mostraba "Includes:" vacío. La clave de metadata configurada en RevenueCat es `pack_confianza_moodIds` (con el prefijo `pack_`), pero el código buscaba `confianza_moodIds` (sin el prefijo, usando solo el `packId` derivado del `package.identifier`). Se corrigió la clave de búsqueda a `'pack_${packId}_moodIds'` para que coincida con lo configurado.
- [x] 4.4 Manejar errores de compra/restore (cancelado, sin red, producto no disponible) sin dejar el estado de `unlocked` inconsistente — `PurchaseException`/`PurchaseFailureReason` mapeados desde `PurchasesErrorHelper.getErrorCode`; el estado `unlocked` solo cambia vía el listener de `CustomerInfo`, nunca de forma optimista
  > **Bug encontrado en QA de dispositivo (9.3) y corregido**: tras un restore exitoso, la Tienda seguía mostrando los moods como bloqueados. Causa: `purchaseMood`/`purchasePack`/`restorePurchases` descartaban el `CustomerInfo` que devuelve la llamada y dependían 100% de que el listener pasivo de RevenueCat (`addCustomerInfoUpdateListener`) se disparara de nuevo por su cuenta. Se corrigió para que el `CustomerInfo` devuelto directamente por esas 3 llamadas también alimente el mismo pipeline que actualiza `unlockedPremiumMoodIds` (método `_applyCustomerInfo` compartido), sin esperar al listener.
  >
  > **Nota aparte, no de código**: se detectaron 2 "customers" distintos en el dashboard de RevenueCat durante las pruebas — cada reinstalación completa de la app desde Xcode/VS Code (no un hot-restart) genera un `appUserID` anónimo nuevo, porque ese ID vive en `UserDefaults` y se borra al desinstalar. La compra queda asociada al `appUserID` anónimo original; "Restaurar compras" debe reasociarla al nuevo `appUserID` si se usa la **misma cuenta sandbox** de App Store. Si el restore ya no muestra error pero el mood sigue bloqueado tras relanzar, confirmar que sea la misma cuenta sandbox — si no, hay que volver a comprar (no cuesta nada en sandbox).
  >
  > **Bug raíz encontrado en QA de dispositivo (9.3) y corregido — race condition de arranque en dos niveles**: en `MoodEntitlementsRepositoryImpl`, `datasource.startListening()` se llamaba **antes** de suscribirse a `datasource.customerInfoUpdates`. `Purchases.addCustomerInfoUpdateListener` invoca el callback **de forma síncrona e inmediata** si el SDK nativo ya tiene `CustomerInfo` en caché (muy común en un arranque en frío, justo después de que `configure()` termina su fetch interno). Ese primer evento —el más importante, con las entitlements reales del customer— se perdía porque nada estaba escuchando el `StreamController` (broadcast, sin replay) todavía en ese instante. Confirmado con logs de diagnóstico: el listener nativo sí recibía las 5 entitlements correctas, pero nunca llegaban al repositorio. Se corrigió invirtiendo el orden: suscribirse al stream **antes** de llamar `startListening()`.
  >
  > Ese primer fix no bastó: el mismo patrón de carrera existía **un nivel más arriba**, entre `MoodEntitlementsRepositoryImpl` (construido en `main()`, antes de `runApp()`) y `PurchasesCubit` (construido después, al armar el árbol de widgets vía `BlocProvider`) — `unlockedPremiumMoodIds()` exponía el mismo tipo de `StreamController.broadcast()` sin replay, así que el Cubit se suscribía tarde y perdía el evento igual. Se corrigió haciendo que `unlockedPremiumMoodIds()` primero emita el valor conocido actual (`_unlockedMoodIds`) y luego continúe con el stream en vivo, para que cualquier suscriptor tardío reciba el estado correcto sin importar cuándo se suscriba. **Confirmado funcionando en dispositivo** tras ambos fixes.

## 5. Feature `purchases` — presentación

- [x] 5.1 Crear `PurchasesCubit` (estado: catálogo de offers/packs, set de moods unlocked, loading/error) alimentado por `MoodEntitlementsRepository`
- [x] 5.2 Crear `MoodStoreScreen`: lista de moods premium individuales con precio y estado de desbloqueo, lista de packs con su composición y precio
  > **Bug encontrado en QA de dispositivo (9.3) y corregido**: `_MoodPackTile` nunca revisaba el estado de desbloqueo (a diferencia de `_MoodOfferTile` para moods individuales) — tras comprar el pack, la Tienda lo seguía mostrando con botón de compra en vez de la chip "Desbloqueado". Se corrigió calculando `isUnlocked` para el pack como `pack.moodIds.every(state.isMoodUnlocked)` en `MoodStoreScreen` y mostrando la misma chip que usan los moods individuales.
- [x] 5.3 Implementar compra individual desde la Tienda con feedback de éxito/error — `mood_purchase_sheet.dart`, reutilizado también desde el carrusel (tarea 6.3)
- [x] 5.4 Implementar compra de pack con aviso previo (no bloqueante) si el usuario ya tiene desbloqueado alguno de sus moods — `pack_purchase_sheet.dart`
- [x] 5.5 Implementar botón "Restaurar compras"
- [x] 5.6 Agregar punto de entrada a la Tienda (ej. ícono en `mood_screen.dart` o en ajustes) — ícono `storefront_outlined` junto al de calendario en `mood_screen.dart`

## 6. Integración con el carrusel diario

- [x] 6.1 En `mood_screen.dart`, iterar sobre `allMoodDefinitions` (base + premium) en vez de solo los gratuitos — ya lo hacía; automático tras la tarea 2.3 (`allMoodDefinitions` pasó a ser la unión real)
- [x] 6.2 Mostrar candado visual sobre los moods premium no `unlocked` (consultando `PurchasesCubit`/`MoodEntitlementsRepository`) — ícono de candado + opacidad reducida, reactivo vía `BlocBuilder<PurchasesCubit, PurchasesState>`
- [x] 6.3 Al tocar un mood bloqueado, impedir seleccionarlo para guardar la entrada del día y abrir el flujo de compra de ese mood específico en su lugar — tap directo en el mood bloqueado y también al presionar "Guardar" con un mood bloqueado seleccionado, ambos abren `showMoodPurchaseSheet`
- [x] 6.4 Verificar que un mood ya `unlocked` (o `base`) se selecciona y guarda con el comportamiento actual sin cambios — cubierto por tests en `mood_screen_test.dart` ("saving a base mood...", "saving an unlocked premium mood...", "tapping a locked premium mood...")

## 7. Resumen mensual: moda en vez de promedio

- [x] 7.1 Actualizar `MonthlyMoodSummary`: remover `averageScore` y `representativeAverageEntry`, agregar `mostCommonMoodEntry`
- [x] 7.2 Actualizar `GetMonthlyMoodSummaryUseCase`: agrupar entradas por mood, elegir el más frecuente, desempatar por fecha de registro más reciente
- [x] 7.3 Actualizar `MonthlyMoodSummaryCard` para consumir `mostCommonMoodEntry` en vez de `representativeAverageEntry`/`averageScore`
- [x] 7.4 Actualizar/agregar tests de `GetMonthlyMoodSummaryUseCase` cubriendo el caso de empate (mismo criterio de desempate que el código anterior) — 4 tests: sin empate real (todos count=1), mayoría clara, empate entre 2 moods con igual conteo, mes vacío

## 8. Localización

- [x] 8.1 Agregar strings de Tienda (título, precio, botón comprar, botón restaurar, aviso de solape, estados de éxito/error) en `app_strings.dart` (abstracta)
- [x] 8.2 Implementar los nuevos strings en `app_strings_en.dart`, `app_strings_es.dart`, `app_strings_de.dart`, `app_strings_fr.dart`, `app_strings_it.dart`
- [x] 8.3 Actualizar el string de "promedio mensual" existente (`monthlyAverage`/`moodRepresentsMonth`/`monthlyAverageSemantics`) por el nuevo texto de "mood más frecuente" en los 5 idiomas

## 9. Verificación

- [x] 9.1 `flutter analyze` sin errores — "No issues found!"; `flutter test` completo: 22/22 tests pasan
- [x] 9.2 Confirmar que las entradas históricas (`MoodEntry`) con moods que luego pierdan `unlocked` (simulando un caso de prueba) se siguen mostrando sin cambios en calendario/historial — confirmado por diseño: `calendar_screen.dart`, `calendar_cubit.dart` y `get_moods_for_month_usecase.dart` no consultan `MoodEntitlementsRepository`/`PurchasesCubit` en ningún punto; el estado `unlocked` solo se consulta al crear/editar una entrada nueva en `mood_screen.dart`, nunca al leer historial
- [x] 9.3 Probar en simulador/dispositivo iOS con productos sandbox: compra individual, compra de pack con solape, cancelación, y restaurar compras — probado en dispositivo físico por el usuario (incluyendo un segundo tester sandbox para el solape), todo funciona correctamente. Se encontraron y corrigieron 4 bugs reales durante esta prueba (ver notas en 4.2, 4.3, 4.4 y 5.2 arriba): mismatch de prefijo `mood_` en entitlements, mismatch de prefijo `pack_` en metadata de composición de packs, `MoodPackTile` sin indicador de desbloqueo, y una race condition en dos niveles (`RevenueCatDatasource`→`Repository`→`PurchasesCubit`) que perdía el primer evento de `CustomerInfo` en frío
- [x] 9.4 Verificar visualmente el carrusel (candados) y la nueva card de resumen mensual — probado en dispositivo físico por el usuario, funciona bien. Se encontraron y arreglaron 2 overflows de `RenderFlex` **preexistentes** en `calendar_screen.dart` (no relacionados a este change): header del mes (`_CalendarHeader`) desbordaba con nombres de mes largos + los 3 íconos, y la celda de día en la grilla del calendario desbordaba verticalmente con el ícono de mood animado
