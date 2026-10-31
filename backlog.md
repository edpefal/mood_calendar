# Backlog

Backlog activo del proyecto, actualizado contra el estado actual del repo.

## Completado recientemente

- La UI ya no accede directo a Hive.
  `MoodScreen` y `CalendarScreen` dependen de cubits, repositorios y servicios.

- Se eliminó el código residual del template de Flutter.
  `MyHomePage` y el test de contador ya no forman parte de la app.

- Logging y telemetría ya están abstraídos.
  El proyecto usa `AppLogger` y `AppTelemetry` en lugar de `print` dispersos.

- El proyecto ya corre con CI.
  `.github/workflows/ci.yml` ejecuta `flutter analyze` y `flutter test`.

- El analizador y la suite principal de tests están en verde.

- Ya existe una capa de settings.
  La configuración de recordatorios vive en `core/settings/`.

- Los recordatorios diarios se configuran desde la pantalla de Settings (engrane en la pantalla principal), con autoguardado; también están ahí calificar la app, la política de privacidad y la versión.

- El historial se exporta a JSON versionado (`formatVersion: 1`, sin `intensity`) y se comparte con la hoja del sistema desde Settings > Tus datos.

- La app ya incorpora moods adicionales en el selector principal.

- Ficha de App Store localizada a es/de/fr/it, subtitle y keywords nuevos, categoría primaria Lifestyle, aviso para calificar la app (versión 1.8.3) y script/hook que obligan a pasar por `scripts/build_ios_release.sh` al generar builds de iOS.

- Set nuevo de 6 screenshots por idioma (iPhone + iPad) generado con `tool/screenshots/` y subido a la versión 1.8.4 en App Store Connect.

- Notificaciones de recordatorio y `title` de la app ya siguen el idioma del dispositivo (fallback inglés).

- Los nombres de los moods se muestran en el idioma del dispositivo (`AppStrings.moodName`).

- Compras y moods: catálogo de 19 moods (14 premium) con Packs, Tienda con reintento del catálogo, y compras en iOS y Android con RevenueCat.

- Android publicado en Google Play junto al mismo identificador de iOS, con capturas, gráfico de funciones y notas generados desde `tool/screenshots/`.

- Firebase Analytics anónimo con interruptor en Settings, sin ID de publicidad, y declaraciones actualizadas (App Privacy, Data safety y política).

- Sitio web `moodcalendar.app` con política de privacidad, términos y soporte en inglés y español.

- Landing rediseñada (2026-10-24): la primera pantalla imita el selector de la app (caritas base sobre su pastel, "gratis para descargar" y badges oficiales), con captura del calendario, bloque de privacidad, Poppins autoalojada, tarjeta de compartir por idioma y Lighthouse 100 en las cuatro categorías. Contexto en `PRODUCT.md` y `DESIGN.md`; el change quedó archivado como `redesign-landing-site`.

- README y `CLAUDE.md` actualizados con el estado real del proyecto (2026-10-24); todos los cambios de OpenSpec están archivados.

## Alta prioridad

- Publicar la app de Apple Watch (≈1.9.0).
  Implementada en el change `add-apple-watch-mood-picker`. Falta: probar la sincronización en un iPhone y un Apple Watch reales (TestFlight): entrega en cola, idioma, varias elecciones del mismo día y compra de un mood; capturas de Watch (`tool/screenshots/capture_watch.py`) y la ficha de App Store Connect; subir la versión, construir con `scripts/build_ios_release.sh` y enviar a revisión. Mejoras posteriores: complicación en la esfera, notas por dictado, colores pastel por mood, acciones en la notificación del recordatorio y app independiente.

- Cerrar el lanzamiento de la 1.8.5 (iOS y Android).
  Android ya está publicado en Google Play (confirmado el 2026-10-24); falta verificar qué `versionCode` sirve en producción. En iOS, comprobar el estado de la 1.8.5 (build 36) en App Store Connect: estaba en revisión. Al aprobarse: comprobar en Firebase → Analytics que llegan usuarios reales y anotar el estado en `CLAUDE.md` ("Estado actual"). Opcional: recapturar los slides en español, que muestran los textos anteriores a la corrección de acentos; al regenerarlos, revisar en `compose.py` que el slide 5 (recordatorios) enmarque bien la captura de Settings a pantalla completa.

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

1. Cerrar el lanzamiento de la 1.8.5 y mantener `CLAUDE.md` al día con cada release.
2. Cubrir con pruebas el flujo de recordatorios y apertura desde notificaciones.
3. Mejorar UX y manejo de errores en plataforma y estados offline.
4. Iterar en producto: historial, edición/borrado, accesibilidad e insights.
