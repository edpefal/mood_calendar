# Backlog

Backlog activo del proyecto, actualizado contra el estado actual del repo (2026-11-21).

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

- Rediseño completo (Bloques 1 a 3) publicado en la **1.10.1** en las dos tiendas (comprobado por API el 2026-11-16): App Store build 49 (`READY_FOR_SALE`) y Google Play build 50 en producción (el 49 de la pista interna era un `INTERNAL_TEST_BUILD`, no promovible). Incluye ícono nuevo, capturas y fichas en 5 idiomas, política de privacidad con el bloqueo de notas y el respaldo de Android, y el sitio con la marca nueva.

- Suscripción Premium (1.10.0, 2026-11-03) con la **primera compra real el 2026-11-19**: plan mensual por Google Play, producción, $2,99 brutos y $2,54 netos (RevenueCat).

- ASO con Applyra (2026-11-17 y 18): alta de 12 fichas (iOS y Play en EE. UU., México, España, Alemania, Francia e Italia), simulaciones de metadata, descripción larga de Play reescrita en 5 idiomas y título de Alemania en Play; detalle y seguimiento en "ASO pendiente".

- README, `CLAUDE.md` y el CV actualizados con el estado real (2026-11-16 a 2026-11-19).

## Alta prioridad

- Conseguir reseñas y calificaciones (es el límite de todo el ASO).
  La ficha de EE. UU. tiene 1 calificación (1,0) frente a 30 000 a 70 000 de Daylio, How We Feel, EMMO y DailyBean, y la auditoría de Applyra la marca como lo más pesado del atractivo de la ficha. Revisar el momento del pedido de calificación (hoy sale con el 3.er y el 7.º día con entradas, máx. 2 en la vida de la instalación) y responder las reseñas que lleguen. Ningún cambio de textos de las fichas compensa esto.

- Terminar las pruebas del rediseño en dispositivos reales.
  Falta ver el **texto grande** del paso 2 del onboarding en un Android real (el ajuste #141 solo se verificó en simulador iOS) y la barra de estado oscura en tema claro (#144) en un iPhone real. Probado en dispositivos reales: onboarding, bloqueo de notas con Face ID y con huella o código, aviso del recordatorio y su toque (en Android no llegaba por faltar los receivers, #139), restaurar compras, el caso "ya estás suscrito" (#138) y el vencimiento de una compra de prueba. Mejoras futuras del bloqueo de notas: cifrar la caja de notas y proteger la miniatura del selector de apps (`FLAG_SECURE`/privacy screen); subir `local_auth` a la 3.x cuando el CI suba a Flutter 3.35 o más, quitando los `dependency_overrides` de `pubspec.yaml`.

- Vigilar la suscripción y los ingresos.
  Hay una suscripción real (Play, mensual, desde 2026-11-19, se renueva el 2026-12-19). RevenueCat muestra además 1 "prueba activa" que no se identificó (el plan mensual no tiene prueba). Seguir Crashlytics y RevenueCat. Fuera de la primera versión: plan vitalicio, ofertas promocionales o de reconquista, Compartir en Familia, paywalls y experimentos de RevenueCat, y avisos dentro de la app por vencimiento o reintento de cobro.

- Palabras frecuentes de las notas y "tu mes en una imagen" (Insights).
  Marcadas Pro en el diseño de referencia (`b968c1cf-8592-4534-8a8c-db17961bb6fc`), quedaron fuera del Bloque 2. Las palabras frecuentes necesitan leer el texto de las notas, que con el bloqueo del Bloque 3 puede estar oculto: hay que decidir si se calculan solo con la sesión desbloqueada y qué se muestra si no (privacidad); la imagen del mes necesita hoja de compartir. Cada una es un change aparte.

- Comprobar que el reloj aparece en la ficha pública de la 1.9.0 y revisar el modo oscuro del sitio (`moodcalendar.app`).
  La 1.9.0 está publicada (`READY_FOR_SALE`). Mejoras del reloj para más adelante: complicación en la esfera, notas por dictado, colores pastel por mood, acciones en la notificación del recordatorio y app independiente.

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

- Poder medir las descargas reales.
  La llave de App Store Connect responde 403 en los informes de ventas (hace falta un rol de Ventas o Finanzas, o una llave nueva) y Play no expone sus estadísticas a la cuenta de servicio. Hoy solo hay la señal de RevenueCat (clientes que abrieron la app, con instalaciones de prueba).

- Detalles pendientes de la marca nueva.
  El anillo de selección del reloj sigue en cian (`ios/WatchApp/MoodGridView.swift`); el hook de diseño marca 4 avisos de contraste en `site/index.html` y `site/es/index.html` (sin revisar) y un falso positivo probable de "side-tab" en `.private::before` de `site/style.css`.

- Pagos: añadir un método de pago a RevenueCat y revisar el perfil de pagos de Google Play.
  RevenueCat no tiene método de pago registrado (plan "pro", facturas en $0) y cobra al pasar su umbral de ingresos; en Play hay que comprobar el perfil de pagos, el umbral de pago y el formulario fiscal de EE. UU. (W-8BEN) para no sufrir retenciones.

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
- Seguir el volumen de calificaciones (meta del reporte: 25+ con 4.5 o más; al 2026-11-17 siguen US 1×1★, MX 1×5★ y ES, DE, FR e IT sin ninguna) y responder las reseñas nuevas. Ver también "Conseguir reseñas" en alta prioridad.
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

1. Conseguir las primeras reseñas (pedido de calificación y respuestas) y vigilar la suscripción real y RevenueCat.
2. Cerrar las pruebas del rediseño en dispositivos reales (texto grande en Android, barra de estado en iPhone).
3. Añadir el método de pago a RevenueCat, revisar el perfil de pagos y la información fiscal de Play, y conectar las notificaciones RTDN de Google Play; respaldar `~/my-release-key.jks`.
4. Con la próxima versión de iOS: título y subtítulo de Alemania, 10 capturas y el anillo del reloj en la nueva marca; revisar las posiciones de las palabras en Applyra (2 a 3 semanas tras 2026-11-18).
5. Cubrir con pruebas los recordatorios y la apertura desde notificaciones; mejorar UX y manejo de errores en plataforma y estados offline.
6. Iterar en producto: historial, edición/borrado, accesibilidad e insights.
