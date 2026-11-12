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
  Los tres bloques están en `main` y archivados (2026-11-11); el build 1.10.1 (47) está en la pista interna de Play y listo para subir a TestFlight. Probados en dispositivos reales: onboarding, bloqueo de notas con Face ID y con huella o código, aviso del recordatorio (en Android no llegaba nunca por faltar los receivers del plugin, #139) y su toque, restaurar compras y el caso "ya estás suscrito" (#138). Falta antes de publicar: (1) **quitar la prueba gratis del mensual y el semanal** en App Store Connect y Play, rehacer capturas y fichas en los 5 idiomas y enviar a revisión (toca las tiendas: pedir permiso); (2) ver el **texto grande** del paso 2 del onboarding en un Android real tras el #141 (necesita un build 48); el vencimiento de una compra de prueba ya salió bien en un Android real (2026-11-11); (3) decidir si la política de privacidad y las fichas mencionan el bloqueo de notas, sin decir "cifrado" (las notas no están cifradas en reposo, ver `docs/risks.md`); (4) decidir **a propósito el respaldo automático de Android**: el manifiesto no declara `allowBackup`, así que al reinstalar Android restaura las cajas de Hive (entradas, notas, bloqueo activo y que el onboarding ya está hecho); es útil para quien cambia de teléfono, pero las notas sin cifrar viajan al Drive del usuario y la política de privacidad dice que todo es local; (5) mejora futura: cifrar la caja de notas y proteger la miniatura del selector de apps (`FLAG_SECURE`/privacy screen); y subir `local_auth` a la 3.x cuando el CI suba a Flutter 3.35 o más, quitando los `dependency_overrides` de `pubspec.yaml`.

- Palabras frecuentes de las notas y "tu mes en una imagen" (Insights).
  Marcadas Pro en el diseño de referencia (`b968c1cf-8592-4534-8a8c-db17961bb6fc`), quedaron fuera del Bloque 2. Las palabras frecuentes necesitan leer el texto de las notas, que con el bloqueo del Bloque 3 puede estar oculto: hay que decidir si se calculan solo con la sesión desbloqueada y qué se muestra si no (privacidad); la imagen del mes necesita hoja de compartir. Cada una es un change aparte.

- Cerrar el rediseño (Bloques 2 y 3) antes de publicar el Bloque 1.
  El Bloque 1 (sistema visual, Log por categorías, 4 pestañas, paywall como hoja y Ajustes) está implementado en `feat/redesign-block-1`, pero **no puede publicarse solo**: el paywall anuncia notas protegidas con biometría (Bloque 3) y Insights es un estado vacío (Bloque 2). Requisito previo a publicar, que hay que pedir aparte porque toca las tiendas: quitar la prueba gratis del plan mensual y del semanal en App Store Connect y Google Play (la app solo la ofrece en el anual). Pendiente también: medir la fluidez del vidrio en un iPhone real (iOS 15) y, si se pide, un build de TestFlight; el texto de las fichas de las tiendas (6 moods pasan a gratis) y las capturas se rehacen en el paso de marketing.

- Siguiente change visual y publicación de la versión con la nueva marca (1.10.1 o posterior).
  El recolor Ocean Cyan está en `main` y el build 1.10.1 (42) está en TestFlight desde el 2026-11-04, probado por el usuario. No se publica todavía: se agruparán más cambios visuales en un change nuevo y entonces se sube la versión a Play, se recapturan las capturas de tienda en los 5 idiomas (`capture.py`, `capture_android.py`, `compose.py`, `header.py`), se suben el ícono, las capturas y los gráficos a App Store Connect y Play, y se envía a revisión. Pendiente también de ese cierre: revisar el modo oscuro y los 390 pt del sitio, y el arranque con el ícono nuevo en Android.

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

## Orden sugerido de ejecución

1. Hacer el siguiente change visual y publicar la versión con la nueva marca, mantener `CLAUDE.md` al día con cada release y vigilar la suscripción (1.10.0).
2. Conectar las notificaciones RTDN de Google Play hacia RevenueCat y respaldar `~/my-release-key.jks`.
3. Cubrir con pruebas el flujo de recordatorios y apertura desde notificaciones.
4. Mejorar UX y manejo de errores en plataforma y estados offline.
5. Iterar en producto: historial, edición/borrado, accesibilidad e insights.
