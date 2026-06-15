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

- Los recordatorios diarios ya son configurables desde la UI.

- Ya existe exportación local del historial en JSON.

- La app ya incorpora moods adicionales en el selector principal.

## Alta prioridad

- Documentar mejor la arquitectura real del proyecto.
  El README debe describir con precisión `features/mood`, settings, notificaciones y telemetría. Hace falta una guía de onboarding que refleje el flujo real de dependencias, estado y persistencia.

- Añadir cobertura para recordatorios y navegación por notificación.
  Hay buena cobertura en repositorio, summary y `MoodScreen`, pero falta validar permisos, programación/cancelación de recordatorios, apertura desde payload y efectos de configuración guardada.

- Endurecer la UX de errores de plataforma.
  Conviene revisar mensajes, reintentos y comportamiento offline para que la UX sea clara cuando fallen notificaciones, exportación o persistencia local.

- Revisar checklist de release.
  Hace falta una checklist operativa compacta para permisos, notificaciones, exportación, validaciones manuales y pasos previos a publicar.

## Prioridad media

- Mejorar accesibilidad general.
  Conviene revisar labels semánticos, tamaños táctiles, contraste y comportamiento con text scaling en picker, calendario, sheet de compras y settings.

- Consolidar estrategia de localización.
  La base para `es` y `en` existe, pero la app arranca fija en español. Hace falta decidir si seguirá así o si se adoptará selección automática/manual de idioma.

- Añadir edición, borrado y consulta más cómoda de entradas.
  El flujo principal cubre registro y resumen, pero sigue faltando una experiencia explícita para editar, eliminar o revisar notas históricas con menos fricción.

- Diseñar una pantalla de historial.
  Un timeline o listado con filtros por mood, fecha y texto haría más útil el historial exportable que ya existe.

- Refinar observabilidad del producto.
  Ya hay telemetría básica, pero conviene decidir qué eventos de exportación, recordatorios y errores de plataforma son realmente útiles para producto.

## Prioridad baja

- Explorar tendencias e insights.
  Comparativas entre meses, patrones recurrentes y resúmenes semanales pueden aumentar el valor percibido sin cambiar el flujo principal.

- Añadir etiquetas o categorías a las notas.
  Tags como trabajo, sueño o ejercicio mejorarían análisis e historial.

- Evaluar nuevas taxonomías de moods.
  Vale la pena decidir si el selector crecerá con más moods, agrupaciones o categorías según el uso real.

## Orden sugerido de ejecución

1. Alinear documentación técnica y checklist de release con el estado real del proyecto.
2. Cubrir con pruebas el flujo de recordatorios y apertura desde notificaciones.
3. Mejorar UX y manejo de errores en plataforma y estados offline.
4. Iterar en producto: historial, edición/borrado, accesibilidad e insights.
