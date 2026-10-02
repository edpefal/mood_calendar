## 1. App Store Connect — confirmar productos IAP

- [x] 1.1 Confirmar el estado actual de los 6 productos del catálogo (`mood_anxious_unlock`, `mood_brave_unlock`, `mood_confident_unlock`, `mood_romantic_unlock`, `mood_shy_unlock`, `pack_confianza_unlock`) — verificado vía `mcp__revenuecat__get-product-store-state` el 2026-10-01: los 6 están en `raw_store_status: READY_TO_SUBMIT`, con screenshot, pricing (en-US + es-MX) y localizaciones completos. La nota de `MISSING_METADATA` en `openspec/changes/setup-revenuecat-store-config/tasks.md` está desactualizada — ya no aplica.
- [x] 1.2 ~~Subir el screenshot de Tienda~~ — no hace falta, los 6 productos ya tienen screenshot cargado (ver 1.1).
- [x] 1.3 ~~Verificar precio y localización~~ — ya completos en los 6 productos (ver 1.1), sin necesidad de cambios.
- [x] 1.4 Confirmar que los 6 productos quedan en estado `Ready to Submit` — confirmado en 1.1.
- [x] 1.5 Re-confirmar en la sección Business de App Store Connect que el Paid Apps Agreement sigue vigente — confirmado por el usuario el 2026-10-01: "Paid agreement completo".
- [x] 1.6 Re-confirmar el estado de los 6 productos inmediatamente antes de reenviar — repetido vía `get-product-store-state` el 2026-10-01 (incluyendo `mood_shy_unlock`, el único no chequeado en la verificación de 1.1): los 6 siguen en `READY_TO_SUBMIT`. Usuario también confirmó "el estado de los productos es correcto".

## 2. Proceso de build de iOS — asegurar la API key de RevenueCat

- [x] 2.1 Confirmar cómo se generó el build de iOS que se envió a la revisión rechazada — **no determinable retroactivamente**: no hay Xcode Archives en esta máquina (`~/Library/Developer/Xcode/Archives/` vacío) ni rastro de `flutter build ipa`/`xcodebuild archive` en el historial de shell, y el usuario confirmó que no recuerda cómo se generó. Probablemente se hizo desde otra máquina o vía Xcode Organizer sin dejar rastro aquí. Se abandona la investigación retroactiva — el foco pasa a garantizar que el *próximo* build sí incluya la key (tareas 2.2–2.4), independientemente de qué pasó con el build rechazado.
- [x] 2.2 Documentar explícitamente en `CLAUDE.md` (sección de comandos/build) el requisito de pasar `--dart-define=REVENUECAT_IOS_API_KEY=<key>` en todo build de archive/release de iOS, con el comando exacto a usar — ver nueva sección "Build de release de iOS (archive/IPA)" en `CLAUDE.md`.
- [x] 2.3 Decidir y dejar anotado dónde vive la API key pública de RevenueCat para quien genere el build — decisión: no requiere gestor de secretos dedicado porque es una SDK key pública (no secreta, pensada para ir embebida en el cliente, igual que ya se documentó en `setup-revenuecat-store-config` tarea 4.1); se pasa siempre vía `--dart-define` y se pide al responsable del proyecto en el dashboard de RevenueCat si no se tiene a mano. Anotado en `CLAUDE.md`.
- [x] 2.4 (Opcional, follow-up) Evaluar si conviene un script de build versionado — decisión (consistente con `design.md` Decision #2): no se implementa en este change, queda como nota de follow-up. Si el paso documentado en `CLAUDE.md` se vuelve a olvidar en un futuro build manual, ese sería el disparador para crear `scripts/build_release.sh` (o automatizar con Fastlane/CI) en un change aparte.

## 3. Verificación en sandbox antes de reenviar

- [x] 3.1 Generar un build de release real (archive/IPA) con `REVENUECAT_IOS_API_KEY` incluido — `flutter build ipa --dart-define=REVENUECAT_IOS_API_KEY=<key>` generado el 2026-10-01 (`build/ios/ipa/mood_calendar.ipa`, 29.9MB). Verificado con `strings` sobre `App.framework/App` dentro del IPA que la key quedó embebida en el binario AOT — este build no caería al `NoopMoodEntitlementsRepository`.
- [x] 3.2 Probar la compra individual de moods premium sobre el build subido a TestFlight (que usa automáticamente el entorno sandbox, sin necesidad de un tester sandbox manual) — **confirmado en iPhone** por el usuario el 2026-10-01 (catálogo carga sin error, compras completadas).
- [x] 3.3 Probar la compra del pack (`pack_confianza_unlock`) — confirmado en iPhone junto con 3.2.
- [x] 3.4 Probar "Restaurar compras" — confirmado en iPhone junto con 3.2.
- [x] 3.5 Confirmar que ningún paso de 3.2–3.4 muestra un error en la store page ni en la UI de la app — confirmado en iPhone (catálogo cargó, moods visibles, compras completadas sin el error `storeLoadError` ni el de `NoopMoodEntitlementsRepository`).
- [x] 3.6 **Repetir 3.2–3.5 en iPad** — **decisión explícita del usuario (2026-10-01): no se dispone de iPad (real ni simulador) por ahora, se reenvía habiendo probado solo en iPhone.** Riesgo aceptado conscientemente: la causa raíz corregida (dart-define faltante) es independiente del dispositivo — afecta a toda la app sin importar el form factor — así que no hay razón técnica para esperar un comportamiento distinto en iPad specficamente; el riesgo real es que exista un segundo bug no relacionado, específico de iPad, que no se puede descartar sin probar ahí. Si Apple vuelve a rechazar citando un iPad, ese sería el primer lugar a investigar.

## 4. Reenvío a revisión

- [x] 4.1 Preparar las notas de revisión para Apple (App Review notes) — borrador listo para pegar en App Store Connect al reenviar (sección "App Review Information" → "Notes"):

  > We addressed the in-app purchase error reported in the previous review. We confirmed all 6 non-consumable products (5 individual moods + 1 bundle) are correctly configured and Ready for Sale, and verified the full purchase flow (individual mood purchases, bundle purchase, and restore purchases) in the sandbox environment on iPhone, with no errors on the store screen.

  **Nota**: texto final — no se menciona iPad porque no se pudo probar ahí (ver 3.6, riesgo aceptado conscientemente por el usuario).
- [x] 4.2 Reenviar el build a revisión — confirmado por el usuario el 2026-10-01: build ya en revisión en App Store Connect.
