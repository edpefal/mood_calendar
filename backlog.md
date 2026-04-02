# Backlog

Lista de mejoras sugeridas tras una revisión general del proyecto.

## Alta prioridad

- Reemplazar el acceso directo a Hive desde la UI.
  Actualmente `MoodScreen` consulta `Hive.box()` directamente para cargar el mood del día, lo que rompe la separación entre `presentation` y `data`. Conviene mover esa lectura a repositorio/caso de uso y dejar la pantalla dependiendo solo de cubits o use cases.

- Eliminar código residual del template de Flutter.
  `MyHomePage` en `lib/main.dart` y el test de contador en `test/widget_test.dart` ya no representan la app real. Mantenerlos genera ruido, falsa cobertura y confusión para nuevos cambios.

- Sustituir `print` por logging controlado.
  Hay bastante logging de depuración en `mood_repository_impl.dart`, `mood_cubit.dart` y `mood_screen.dart`. Conviene usar `debugPrint`, `dart:developer` o un logger centralizado, y desactivar logs verbosos en release.

- Corregir warnings del analizador y dejar el proyecto en verde.
  La base actual tiene warnings de `avoid_print`, `use_build_context_synchronously`, `deprecated_member_use`, `prefer_const_constructors` y `depend_on_referenced_packages`. Vale la pena dejar `flutter analyze` limpio para evitar que la deuda siga creciendo.

- Crear pruebas reales para la lógica principal.
  Faltan tests unitarios para repositorio, cubits y resumen mensual; también faltan pruebas del flujo de recordatorios. La prioridad es cubrir guardado de moods, cálculo de `bestStreak`, promedio mensual y navegación principal.

## Prioridad media

- Añadir una capa de settings/preferencias.
  Sería mejor encapsular settings de app en un servicio o datasource propio con claves tipadas. Eso prepara el terreno para futuras preferencias: hora de recordatorio, idioma y otras configuraciones persistentes.

- Unificar idioma y tono de la app.
  El proyecto mezcla español en documentación/comentarios con inglés en la UI. Conviene definir una estrategia clara y preparar localización (`intl`) si se piensa soportar más de un idioma.

- Mejorar el manejo de estados y errores en pantalla.
  Hay cargas y guardados que podrían mostrar mejor feedback: errores persistentes, estados vacíos, reintentos, loaders menos intrusivos y mensajes más claros cuando fallan notificaciones o persistencia.

- Añadir edición, borrado y consulta detallada de entradas.
  A nivel producto, el usuario puede guardar moods, pero falta un flujo claro para editar, borrar o revisar notas históricas de forma cómoda.

- Extraer navegación a una estrategia más consistente.
  La navegación actual usa `MaterialPageRoute` y varias decisiones inline (`pushReplacement`, `canPop`, etc.). Un router central o al menos helpers de navegación reducirían acoplamiento y errores de flujo.

- Revisar persistencia por fecha.
  Las claves se guardan con `toIso8601String()`. Conviene normalizar explícitamente a fecha local sin hora cuando el registro es diario, para evitar futuros problemas por zonas horarias o registros creados con timestamps distintos.

## Prioridad baja

- Mejorar accesibilidad y UX.
  Revisar tamaños táctiles, contraste, labels semánticos, soporte para lectores de pantalla y comportamiento con fuentes grandes.

- Permitir configuración del recordatorio diario.
  Hoy la notificación está fija a las 6:00 pm. Sería mejor que el usuario pudiera elegir hora, activar/desactivar recordatorios y quizá días específicos.

- Añadir exportación o respaldo de datos.
  Exportar moods a CSV/JSON o permitir backup facilitaría retención y portabilidad del historial.

- Añadir métricas y observabilidad básica.
  Registrar eventos clave como guardados, aperturas desde notificación y errores de persistencia ayudaría a tomar decisiones de producto.

- Mejorar documentación de desarrollo.
  El README está bien orientado, pero podría sumar una sección de arquitectura, convenciones de carpetas, estrategia de testing y checklist de release.

- Crear CI para análisis, tests y validación básica.
  Una acción de GitHub que corra `flutter analyze`, `flutter test` y validaciones mínimas ayudaría a detectar regresiones antes de mezclar cambios.

## Oportunidades de producto

- Agregar filtros y tendencias.
  Por ejemplo: ver semanas difíciles, comparar meses, detectar moods predominantes o mostrar insights simples.

- Incorporar tags o categorías a las notas.
  Etiquetas como trabajo, sueño, ejercicio o familia harían más útil el historial sin complicar demasiado la experiencia.

- Diseñar una pantalla de historial.
  Un listado o timeline con búsqueda por texto y filtro por mood mejoraría bastante la utilidad diaria de la app.

## Orden sugerido de ejecución

1. Limpiar analyzer warnings, eliminar código/template obsoleto y reemplazar `print`.
2. Añadir pruebas unitarias y widget tests alineados con la app real.
3. Refactorizar acceso a Hive para que la UI no dependa de almacenamiento.
4. Endurecer la capa de settings y normalizar configuración persistente.
5. Iterar en mejoras de producto: edición/borrado, configuración de recordatorios e historial.
