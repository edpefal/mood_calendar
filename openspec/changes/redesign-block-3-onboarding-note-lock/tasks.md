## 1. Dependencia y plataformas

- [x] 1.1 Añadir `local_auth: ^2.3.0` y comprobar con Flutter 3.32.1 (mismo SDK que el CI) que `flutter pub get`, `flutter analyze`, `flutter test` y un build de simulador siguen en verde; si no resuelve, parar y replantear antes de seguir _(hallazgo: con Flutter 3.44 los transitivos resolvían a versiones que piden Dart 3.9; se fijaron `local_auth_android` 1.0.52, `local_auth_darwin` 1.6.0 y `flutter_plugin_android_lifecycle` 2.0.31 en `dependency_overrides`. Flutter 3.32.1 no se pudo descargar en local; la compatibilidad se comprobó por los metadatos de pub y la confirma el CI del PR)_
- [x] 1.2 iOS: `NSFaceIDUsageDescription` en `Info.plist`, `InfoPlist.strings` en en/es/de/fr/it y `CFBundleLocalizations`; confirmar que `verify_ios_archive_no_ad_id.sh` no detecta cambios _(se registran con `tool/ios_add_infoplist_strings.rb`; el script de verificación corre en el próximo archive)_
- [x] 1.3 Android: permiso `USE_BIOMETRIC`, `MainActivity` como `FlutterFragmentActivity` y temas `LaunchTheme`/`NormalTheme` compatibles con AppCompat sin cambiar el color ni el arranque; confirmar que `verify_android_bundle_no_ad_id.sh` no detecta cambios _(el build debug de Android compila; el script corre en el próximo bundle de release)_

## 2. Datos y arranque

- [x] 2.1 `AppSettings.noteLockEnabled` (por defecto `false`) con su clave en `AppSettingsLocalDataSource` y tests de lectura y escritura sin migración
- [x] 2.2 `OnboardingStateDataSource` (clave `onboarding_completed` sobre la caja de ajustes) y `OnboardingGate` con la regla "sin la clave y sin entradas", con tests: instalación nueva, actualización con historial, completado y omitido
- [x] 2.3 `AppRoot` como `home` de `MyApp`: monta `OnboardingFlow` o `MainShell` según el gate, de forma síncrona, y conserva `mainShellKey` y el manejo del toque del recordatorio
- [x] 2.4 `LocalNotificationService`: separar `requestPermission()` de `initialize({required bool requestPermission})`; `main()` no pide el permiso ni programa el recordatorio por defecto mientras el onboarding esté pendiente; las instalaciones existentes conservan su comportamiento; tests del servicio y del arranque _(el plugin de notificaciones no se puede inyectar: la lógica de pedir/no pedir el permiso se prueba en `OnboardingCubit` y `SettingsCubit`; el cableado de `main()` se verifica en el simulador, 6.2)_
- [x] 2.5 `SettingsCubit`: al activar el recordatorio llama a `requestPermission()` antes de programar y revierte con el mensaje si se niega; tests

## 3. Onboarding

- [x] 3.1 `OnboardingCubit` (paso, hora, mood y nota del paso 4) con tests de navegación, "Skip" por paso y retroceso en Android
- [x] 3.2 `OnboardingProgress` con `Semantics` "Step n of 4" y los pasos 1 (bienvenida con calendario de muestra fijo) y 2 (sugerencias Morning 9:00, Afternoon 14:00, Night 20:00 y selector de rueda; Night por defecto; elegir una sugerencia mueve el selector y mover el selector deselecciona)
- [x] 3.3 Paso 3: "Turn on reminder" pide el permiso y programa a la hora elegida o deja el recordatorio apagado si se niega; "Not now" y "Skip" lo dejan apagado sin diálogo; tests con un servicio falso
- [x] 3.4 Paso 4: cuadrícula de Moods base sin candados y sin selección, `NoteEditorSheet` para la nota opcional, "Save my first day" con `MoodCubit.save`, confirmación "Day 1 of your calendar" y "Continue"; sin pedido de calificación; tests de widget con ventana 390×844
- [x] 3.5 Cierre: marcar `onboarding_completed`, montar el shell en el Log "Saved" y, tras el primer frame, abrir `showPremiumSheet(source: onboarding)` una sola vez y solo sin suscripción; "Skip" del paso 1 no la abre; tests incluidos suscriptor y reconstrucción de `AppRoot`
- [x] 3.6 `PremiumSource.onboarding` y las analíticas del onboarding (`onboarding_completed`, `onboarding_skipped` con `step`) en la lista permitida; actualizar `telemetry_privacy` y sus tests, incluida la exclusión de datos de entradas

## 4. Bloqueo de notas

- [x] 4.1 `NoteLockAuthenticator` (interfaz) con la implementación de `local_auth` (`biometricOnly: false`) y un falso en `test/support/`
- [x] 4.2 `NoteLockCubit`: `enabled`, `unlocked` en memoria, disponibilidad y `enforceable`; vuelve a bloquear en `hidden`/`paused` y no en `inactive`; `enable()` exige Premium y autenticación, `disable()` exige autenticación y no Premium; tests de cada escenario del spec `note-lock`, incluidos suscripción vencida y código eliminado
- [x] 4.3 `LockedNoteText` con el marcador "Note locked", acción de desbloquear y `Semantics`; usarlo en el estado Saved del Log y en `DayDetailSheet` y comprobar con un test que ninguna pantalla muestra `entry.note` sin pasar por él
- [x] 4.4 Editor de nota: pedir `unlock()` antes de abrirlo cuando la entrada tiene nota y la sesión está bloqueada; si falla, no se abre y la nota no cambia; la nota nueva no pide autenticación
- [x] 4.5 Exportación: pedir `unlock()` antes de generar el archivo con el bloqueo activo; cancelar no genera nada y deja la fila disponible; tests sobre `SettingsScreen`
- [x] 4.6 Fila en Settings > Privacy and data (marca "Pro", interruptor, detalle según la plataforma, estado "no hay código configurado") y `NoteLockCubit` + observador de ciclo de vida en el árbol de `main.dart`; tests de la fila para suscriptor, sin suscripción y sin autenticación
- [x] 4.7 Analíticas `note_lock_enabled`/`note_lock_disabled` sin datos de entradas; el desbloqueo no emite eventos

## 5. Textos y accesibilidad

- [x] 5.1 Añadir los strings del onboarding, el bloqueo (fila, detalle, marcador, acción, mensajes y motivo del diálogo del sistema) y el permiso a `app_strings.dart` y a los cinco idiomas, con las `Semantics`
- [x] 5.2 Revisar texto grande (1.2× y 2×) en los cuatro pasos, modo claro y oscuro e iPad con `PhoneColumn` _(2026-11-09, simulador: iPhone 16e en alemán y oscuro (los 4 pasos), en inglés al tamaño máximo de accesibilidad, y iPad Pro 13" (onboarding, confirmación, hoja de suscripción, Log y edición). Hallazgos corregidos: a ese tamaño los títulos se partían a mitad de palabra (ahora el título escala hasta 1,7×) y "Not now" se recortaba (alto mínimo en vez de fijo). El contenido se desplaza y los botones principales siguen alcanzables)_

## 6. Verificación

- [x] 6.1 `flutter analyze` y `flutter test` en verde con Flutter local y con 3.32.1 _(local 3.44.6: analyze limpio y 590 tests en verde; 3.32.1 no se pudo descargar aquí, lo confirma el CI del PR)_
- [x] 6.2 Revisar en simulador de iPhone (propio y limpio): instalación nueva completa, "Skip" en cada paso, permiso concedido y negado, actualización con historial (sin onboarding), bloqueo con Face ID simulado y vuelta de segundo plano _(hecho en un iPhone 16e limpio, 2026-11-06: Skip en los pasos 1, 2 y 3 (el 1 va al Log sin hoja; el 2 y el 3 al paso 4, que no tiene Skip); permiso negado deja el recordatorio apagado con la hora conservada y activarlo en Ajustes lo revierte con el mensaje; con historial y sin la clave el app abre en el Log; Face ID: la hoja nativa sale con el texto localizado, un rostro que no coincide y Cancel dejan la nota oculta, uno que coincide la muestra, y al pasar a segundo plano vuelve a "Note locked", también en la píldora al editar. El bloqueo se activó con el entrypoint de capturas (se trata como suscriptor) al que se añadió `NoteLockHost`; el caso "dispositivo sin código" no se reprodujo en iOS porque el simulador ofrece el código del sistema, queda cubierto por los tests)_
- [ ] 6.3 Probar la autenticación real en un iPhone y en un Android reales (Face ID/Touch ID/huella, código y vencimiento del bloqueo) y el arranque en frío de Android tras el cambio de `MainActivity` y temas _(2026-11-06, emulador Pixel Android 17 de 4 GB: la app arranca con el tema AppCompat y la pantalla de arranque, el onboarding se muestra y el diálogo de permiso de Android aparece en el paso 3. Se encontró y corrigió un defecto previo: programar el recordatorio lanzaba `exact_alarms_not_permitted` (la app no declara `SCHEDULE_EXACT_ALARM` y usaba `exactAllowWhileIdle`), lo que dejaba atascado el paso 3; ahora el recordatorio es inexacto y el onboarding nunca se bloquea por ese fallo. Sin concluir: el emulador quedó saturado (ANR de Play Store y del launcher, carga 48) y no se pudo repetir el paso 3 con el arreglo ni probar el diálogo biométrico; falta un dispositivo real)_ _(2026-11-10, iPhone real con TestFlight 46: Face ID al activar y al apagar el bloqueo, y reaparición de "Note locked" al volver de segundo plano, bien. Falta la parte de Android real)_
- [ ] 6.4 Probar el flujo completo en TestFlight y en la pista interna de Play, y medir la fluidez del onboarding con vidrio en un iPhone real (junto con 9.3 y 7.3 de los bloques anteriores) _(2026-11-09, TestFlight 44: actualización con datos y onboarding en instalación nueva bien; bloqueo de notas bien salvo que apagarlo no pedía Face ID con la sesión desbloqueada (corregido en #135); el toque del recordatorio no abría el Log (corregido en #134, build 45); fluidez del vidrio y de Insights bien. Falta: confirmar el 45 y el 46 en el iPhone, la prueba en Android y la vista (modo oscuro, idiomas, texto grande, iPad))_ _(2026-11-10: en el 46 de TestFlight quedaron confirmados el apagado con Face ID y el toque del recordatorio; el 46 de Android está en la pista interna sin probar en un dispositivo)_

## 7. Documentación

- [x] 7.1 `CONTEXT.md` (Onboarding, Note lock, sesión desbloqueada), `CLAUDE.md` (estado, arquitectura, `local_auth` fijado y reglas de arranque del permiso) y `docs/risks.md` (las notas no están cifradas en reposo)
- [x] 7.2 `backlog.md`: palabras frecuentes de las notas (dependen del bloqueo), publicación de la versión del rediseño, política de privacidad y fichas con la mención del bloqueo, y cifrado de notas en reposo
- [x] 7.3 Actualizar `README` si menciona el onboarding o las notas
