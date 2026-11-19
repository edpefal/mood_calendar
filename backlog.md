# Backlog

Backlog activo del proyecto, actualizado contra el estado actual del repo.

## Completado recientemente

- La UI ya no accede directo a Hive.
  `LogScreen` y `CalendarScreen` dependen de cubits, repositorios y servicios.

- Se eliminó el código residual del template de Flutter.
  `MyHomePage` y el test de contador ya no forman parte de la app.

- Logging y telemetría ya están abstraídos.
  El proyecto usa `AppLogger` y `AppTelemetry` en lugar de `print` dispersos.

- El proyecto ya corre con CI.
  `.github/workflows/ci.yml` ejecuta `flutter analyze` y `flutter test`.

- El analizador y la suite principal de tests están en verde.

- Ya existe una capa de settings.
  La configuración de recordatorios vive en `core/settings/`.

- Los recordatorios diarios se configuran desde la pestaña Settings, con autoguardado; también están ahí calificar la app, la política de privacidad y la versión.

- El historial se exporta a JSON versionado (`formatVersion: 1`, sin `intensity`) y se comparte con la hoja del sistema desde Settings > Tus datos.

- La app ya incorpora moods adicionales en el selector principal (desde el Bloque 1, en la cuadrícula del Log por categorías).

- Ficha de App Store localizada a es/de/fr/it, subtitle y keywords nuevos, categoría primaria Lifestyle, aviso para calificar la app (versión 1.8.3) y script/hook que obligan a pasar por `scripts/build_ios_release.sh` al generar builds de iOS.

- Set nuevo de 6 screenshots por idioma (iPhone + iPad) generado con `tool/screenshots/` y subido a la versión 1.8.4 en App Store Connect.

- Notificaciones de recordatorio y `title` de la app ya siguen el idioma del dispositivo (fallback inglés).

- Los nombres de los moods se muestran en el idioma del dispositivo (`AppStrings.moodName`).

- Compras y moods: catálogo de 19 moods (en el Bloque 1: 11 gratis y 8 premium) con Packs heredados, Tienda con reintento del catálogo, y compras en iOS y Android con RevenueCat.

- Android publicado en Google Play junto al mismo identificador de iOS, con capturas, gráfico de funciones y notas generados desde `tool/screenshots/`.

- Firebase Analytics anónimo con interruptor en Settings, sin ID de publicidad, y declaraciones actualizadas (App Privacy, Data safety y política).

- Sitio web `moodcalendar.app` con política de privacidad, términos y soporte en inglés y español.

- Landing rediseñada (2026-10-24): la primera pantalla imita el selector de la app (caritas base sobre su pastel, "gratis para descargar" y badges oficiales), con captura del calendario, bloque de privacidad, Poppins autoalojada, tarjeta de compartir por idioma y Lighthouse 100 en las cuatro categorías. Contexto en `PRODUCT.md` y `DESIGN.md`; el change quedó archivado como `redesign-landing-site`.

- README y `CLAUDE.md` actualizados con el estado real del proyecto (2026-10-24); todos los cambios de OpenSpec están archivados.

## Alta prioridad

- Publicar la versión del rediseño (Bloques 1 a 3) y cerrar lo que el Bloque 3 deja pendiente.
  Los tres bloques están en `main` y archivados (2026-11-11); el build 1.10.1 (47) está en la pista interna de Play y listo para subir a TestFlight. Probados en dispositivos reales: onboarding, bloqueo de notas con Face ID y con huella o código, aviso del recordatorio (en Android no llegaba nunca por faltar los receivers del plugin, #139) y su toque, restaurar compras y el caso "ya estás suscrito" (#138). Falta antes de publicar: (1) rehacer capturas y fichas en los 5 idiomas y enviar a revisión (toca las tiendas: pedir permiso); la prueba gratis del mensual y el semanal ya se quitó en App Store Connect y Play el 2026-11-12 (solo el anual la conserva); (2) ver el **texto grande** del paso 2 del onboarding en un Android real tras el #141 (necesita un build 48); el vencimiento de una compra de prueba ya salió bien en un Android real (2026-11-11); (3) la política de privacidad y las fichas ya mencionan el bloqueo de notas, sin decir "cifrado" (2026-11-12); (4) el respaldo automático de Android se dejó activo a propósito y la política de privacidad lo explica (2026-11-12; ver `docs/risks.md`); (5) mejora futura: cifrar la caja de notas y proteger la miniatura del selector de apps (`FLAG_SECURE`/privacy screen); y subir `local_auth` a la 3.x cuando el CI suba a Flutter 3.35 o más, quitando los `dependency_overrides` de `pubspec.yaml`.

- Palabras frecuentes de las notas y "tu mes en una imagen" (Insights).
  Marcadas Pro en el diseño de referencia (`b968c1cf-8592-4534-8a8c-db17961bb6fc`), quedaron fuera del Bloque 2. Las palabras frecuentes necesitan leer el texto de las notas, que con el bloqueo del Bloque 3 puede estar oculto: hay que decidir si se calculan solo con la sesión desbloqueada y qué se muestra si no (privacidad); la imagen del mes necesita hoja de compartir. Cada una es un change aparte.

- Cerrar el rediseño (Bloques 2 y 3) antes de publicar el Bloque 1.
  El Bloque 1 (sistema visual, Log por categorías, 4 pestañas, paywall como hoja y Ajustes) está implementado en `feat/redesign-block-1`, pero **no puede publicarse solo**: el paywall anuncia notas protegidas con biometría (Bloque 3) y Insights es un estado vacío (Bloque 2). Requisito previo a publicar, que hay que pedir aparte porque toca las tiendas: quitar la prueba gratis del plan mensual y del semanal en App Store Connect y Google Play (la app solo la ofrece en el anual). Pendiente también: medir la fluidez del vidrio en un iPhone real (iOS 15) y, si se pide, un build de TestFlight; el texto de las fichas de las tiendas (6 moods pasan a gratis) y las capturas se rehacen en el paso de marketing.

- Publicación de la nueva marca en las tiendas (1.10.1 o posterior).
  iOS: la 1.10.1 (49) está en revisión de Apple desde el 2026-11-12, con el ícono nuevo, las capturas y la ficha. Falta Play: subir el build 49 a producción, el ícono de 512 px, las capturas (hay que actualizar `capture_android.py` al set nuevo) y el gráfico de funciones, ya generado en `aso/play/`. El sitio usa la marca nueva desde el 2026-11-12 (PR de rediseño del sitio); el anillo de selección del reloj sigue en cian.

- Comprobar que el reloj aparece en la ficha pública de la 1.9.0 y revisar el modo oscuro del sitio (`moodcalendar.app`).
  La 1.9.0 está publicada (`READY_FOR_SALE`). Mejoras del reloj para más adelante: complicación en la esfera, notas por dictado, colores pastel por mood, acciones en la notificación del recordatorio y app independiente.

- Vigilar la suscripción publicada (1.10.0).
  Publicada en las dos tiendas desde el 2026-11-03; los 18 productos de compras sueltas se retiraron el 2026-11-04 (ninguna compra real). Seguir Crashlytics y RevenueCat unos días: que desaparezca el `TypeToken` y que no haya errores nuevos de la tienda. Fuera de la primera versión: plan vitalicio, ofertas promocionales o de reconquista, Compartir en Familia, paywalls y experimentos de RevenueCat, y avisos dentro de la app por vencimiento o reintento de cobro.

- Cerrar el lanzamiento de la 1.8.5 (iOS y Android).
  Android ya está publicado en Google Play (confirmado el 2026-10-24); falta verificar qué `versionCode` sirve en producción. iOS 1.8.5 (build 36) ya está publicada (`READY_FOR_SALE`, comprobado el 2026-10-31). Falta comprobar en Firebase → Analytics que llegan usuarios reales. Opcional: recapturar los slides en español, que muestran los textos anteriores a la corrección de acentos; al regenerarlos, revisar en `compose.py` que el slide 5 (recordatorios) enmarque bien la captura de Settings a pantalla completa.

- Configurar las notificaciones en tiempo real (RTDN) de Google Play hacia RevenueCat.
  Elegir el tema `play-notifications` en RevenueCat, pegarlo en Play Console → Monetización y enviar una notificación de prueba. No bloquea nada: hace que reembolsos y cancelaciones lleguen más rápido.

- Respaldar `~/my-release-key.jks` fuera del equipo y borrar la clave local antigua de la cuenta de servicio de Play (no la que está subida a RevenueCat).

- Añadir cobertura para recordatorios y navegación por notificación.
  `SettingsCubit` y `SettingsScreen` ya tienen tests, con la programación simulada.
  Hay buena cobertura en repositorio, summary y `MoodScreen`, pero falta validar permisos, programación/cancelación de recordatorios, apertura desde payload y efectos de configuración guardada.

- Cerrar la verificación pendiente de `export-mood-history`.
  Probar en el simulador el historial vacío y el error de generación (hoy solo cubiertos por tests de widget) y confirmar que la política de privacidad y las respuestas de App Store Connect no contradicen una exportación manual del historial.

- Avisar cuando el permiso de notificaciones está denegado en el sistema.
  Activar el recordatorio en Settings guarda el ajuste pero iOS no entrega la notificación; conviene mostrar un aviso con acceso a Ajustes del sistema.

- Endurecer la UX de errores de plataforma.
  Conviene revisar mensajes, reintentos y comportamiento offline para que la UX sea clara cuando fallen notificaciones, exportación o persistencia local.

- Revisar checklist de release.
  Hace falta una checklist operativa compacta para permisos, notificaciones, exportación, validaciones manuales y pasos previos a publicar.

## Prioridad media

- Mejorar accesibilidad general.
  Conviene revisar labels semánticos, tamaños táctiles, contraste y comportamiento con text scaling en picker, calendario, sheet de compras y settings. (El botón de volver de `CalendarScreen` ya tiene label vía `tooltip` desde `unify-mood-color-design-system`.)

- Regenerar `assets/icon/brave.svg`.
  Es un outlier: 1MB, 787 paths, 2048×2048 sin el `viewBox="0 0 512 512"` del resto del set — generado con VTracer (auto-trazado) a partir de una imagen de Gemini, a diferencia de los demás íconos (~3KB, vector limpio). Pesado de renderizar y visualmente inconsistente con el resto del set. Regenerar con el mismo proceso que produjo los otros 9 íconos.

- Fijar un `appUserID` explícito en `Purchases.configure()` (sin decidir).
  Las apps `com.artlab.*` comparten vendor y, en un mismo simulador, RevenueCat puede reutilizar el ID anónimo de otra app y mostrar productos ajenos. Un ID propio evitaría esa contaminación.

- Añadir edición, borrado y consulta más cómoda de entradas.
  El flujo principal cubre registro y resumen, pero sigue faltando una experiencia explícita para editar, eliminar o revisar notas históricas con menos fricción.

- Diseñar una pantalla de historial.
  Un timeline o listado con filtros por mood, fecha y texto haría más útil el historial exportable que ya existe.

- Refinar observabilidad del producto.
  Ya hay telemetría básica, pero conviene decidir qué eventos de exportación, recordatorios y errores de plataforma son realmente útiles para producto.

- Añadir un toggle en Settings para desactivar el reporte de crashes.
  Hoy el reporte a Crashlytics (change `add-crash-reporting`) es opt-out sin control en la app (el interruptor "Compartir datos de uso anónimos" de `add-firebase-analytics` solo gobierna Analytics, no Crashlytics); los datos son anónimos y se declaran en App Privacy. Agregar el toggle refuerza la postura de privacidad si llega un reclamo (requiere persistir el valor en Hive y leerlo antes de inicializar Firebase).

## Prioridad baja

- Explorar tendencias e insights.
  Comparativas entre meses, patrones recurrentes y resúmenes semanales pueden aumentar el valor percibido sin cambiar el flujo principal.

- Añadir etiquetas o categorías a las notas.
  Tags como trabajo, sueño o ejercicio mejorarían análisis e historial.

- Evaluar nuevas taxonomías de moods.
  Vale la pena decidir si el selector crecerá con más moods, agrupaciones o categorías según el uso real.

## ASO pendiente

Sale de `aso/aso_report.md` (auditoría del 2026-10-02). Lo ya hecho está en "Completado recientemente".

- Medir el efecto del cambio de categoría a Lifestyle: comparar impresiones y descargas durante 2 a 4 semanas.
- Seguir el volumen de calificaciones tras la 1.8.3 (meta del reporte: 25+ con 4.5 o más; al 2026-10-07 seguían US 1×1★, MX 1×5★, ES ninguna) y revisar si llegan reseñas nuevas para responderlas.
- App Preview de 15 a 25 s sin depender del sonido: registrar un mood, el calendario llenándose y la racha.
- Product Page Optimization: pruebas A/B de orden de screenshots e ícono.
- Custom Product Pages por audiencia, junto con Apple Search Ads para términos de nicho.
- In-App Events de temporada (por ejemplo un check-in de Año Nuevo o la semana de salud mental).
- **Alemania (de-DE): el cambio con más efecto simulado (2026-11-18).** La palabra "Stimmungen" del título casi no se busca en Alemania (Applyra marca `TITLE_WEAK`). Simulado con el campo de palabras clave real: título "Mood Calendar: Tagebuch", subtítulo "Stimmungstagebuch & Gefühle" y campo `stimmungskalender,stimmung,tracker,gefuehle,wohlbefinden,mental,gesundheit,gewohnheit,serie,check-in,angst` sube la ficha de 56 a 65 (cobertura de 51 a 80). "Stimmungstagebuch" tiene tráfico 46 y dificultad 52. Cambiar solo el campo de palabras clave da +1. Mezcla tres cambios y cambia el título en Alemania: decidirlo con el usuario y aplicarlo con la próxima versión de iOS. Es el modelo de Applyra, no posiciones reales.
- **Francia, Italia, España y México: sin cambio que justifique una versión.** Con el campo de palabras clave real de cada ficha como línea base (Applyra no lo conoce de las fichas que no son en-US: hay que pasárselo con `kw_field`, si no la comparación sale inflada), las mejores variantes quedan en +2 en Francia (subtítulo "Suivi quotidien et bien-être"), +2 en México (campo `bitacora,sentimientos,emocional,animo,estado,bienestar,mental,salud,habito,racha,ansiedad`), 0 en España y -1 en Italia. Línea base: ES 68, MX 76, DE 56, FR 59, IT 64.
- **Google Play (2026-11-18): subido solo el cambio de Alemania.** Play no tiene campo oculto de palabras clave (se indexan título, descripción corta y larga) y sus cambios de ficha no necesitan versión. Alta en Applyra de Play en México (641100), España (641112), Alemania (641131), Francia (641149) e Italia (641166), más EE. UU. (639838). Simulado: Alemania con título "Mood Calendar: Stimmung" + descripción que usa "Stimmungstagebuch" y "Monatskalender" sube de 58 a 65 y **se subió a Play el 2026-11-18** (el título de iOS sigue siendo "Stimmungen"; Google puede tardar unos días en revisar el título). Resto de mercados: descripción corta nueva sin repetir el título da +2 en Francia, +1 en Italia y México y 0 en España, así que no se tocó. Puntuaciones de Play antes del cambio: MX 61, ES 64, DE 58, FR 64, IT 65, US 54. Pendiente: llegar a más capturas (6 de 18) y reseñas.
  Seguimiento en Play (2026-11-18): Alemania (641131) con stimmungstagebuch, stimmungskalender, stimmung tracker, stimmungstracker y tagebuch gefühle, todas fuera del top 100, y "mood calendar" 8.º; EE. UU. (639838) con "mood calendar" 22.º, "daily mood" 45.º y mood tracker, mood journal, mood check in y emotion tracker fuera del top 100. Revisar en 2 a 3 semanas, sobre todo Alemania tras el cambio de título.
- **Inglés (en-US): no cambiar título ni subtítulo por ahora.** Seis variantes simuladas con Applyra el 2026-11-17 quedaron entre 1 y 3 puntos por debajo de la ficha actual (42). El límite es la calificación (1,0 con 1 reseña frente a 30 000 a 70 000 de Daylio, How We Feel, EMMO y DailyBean), no los textos. Revisar cuando haya reseñas.
- **Llegar a 10 capturas en la ficha de iOS** (hoy 6; Applyra lo marca en EE. UU., México y España, y Play tiene 6 de 18).
- **Seguimiento en Applyra** (alta el 2026-11-17): app de iOS en EE. UU. (id 618076), de Play en EE. UU. (639838), México (639862) y España (639871), 10 palabras en seguimiento en EE. UU. y 4 competidores (Daylio, How We Feel, EMMO, DailyBean). Línea base en EE. UU.: "mood streak" 5.º, "mood calendar" 8.º, "daily mood" 27.º, "mood tracker" 64.º, el resto fuera del top 100. Revisar en 2 a 3 semanas con `list_keywords` y `list_competitors`. En español (2026-11-18, 8 palabras en España y 8 en México: diario emocional, estado de ánimo, registro de ánimo, calendario emociones/emocional, diario de emociones, mood calendar, bitácora emocional, calendario de ánimo): línea base "mood calendar" 2.º en México y 6.º en España, "diario de emociones" 30.º en México y el resto fuera del top 100. Tras aplicar el campo de palabras clave nuevo, ver si "diario emocional" o "estado de ánimo" entran.
  Alemania, Francia e Italia (2026-11-18, 6 palabras cada una; ids Applyra 641077, 641082 y 641090). Línea base: DE "mood calendar" 6.º y todas las demás fuera del top 100 (stimmungstagebuch, stimmungskalender, stimmung tracker, tagebuch gefühle, stimmungstracker); FR "mood calendar" 2.º, "journal humeur" 59.º, "suivi émotions" 51.º y fuera suivi humeur, calendrier humeur y journal émotions; IT "monitoraggio emozioni" 7.º, "mood calendar" 29.º, "calendario umore" 69.º y fuera diario umore, diario emozioni y diario dell'umore. Si se aplica el cambio de título y subtítulo de Alemania, comparar estas posiciones tras 2 a 3 semanas.

## Orden sugerido de ejecución

1. Hacer el siguiente change visual y publicar la versión con la nueva marca, mantener `CLAUDE.md` al día con cada release y vigilar la suscripción (1.10.0).
2. Conectar las notificaciones RTDN de Google Play hacia RevenueCat y respaldar `~/my-release-key.jks`.
3. Cubrir con pruebas el flujo de recordatorios y apertura desde notificaciones.
4. Mejorar UX y manejo de errores en plataforma y estados offline.
5. Iterar en producto: historial, edición/borrado, accesibilidad e insights.
