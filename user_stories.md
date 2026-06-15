# User Stories

Historias de usuario activas derivadas del backlog vigente, agrupadas por épicas.

## Épica 1: Confiabilidad de plataforma y release

### US-01: Validar recordatorios de extremo a extremo
Como desarrollador  
Quiero cubrir con pruebas y validaciones el flujo de recordatorios  
Para evitar regresiones en permisos, programación, cancelación y navegación desde notificaciones.

Criterios de aceptación:
- Existen pruebas para la programación y cancelación de recordatorios.
- Existen pruebas o validaciones para apertura desde payload/notificación.
- Cambios en settings de recordatorio se reflejan correctamente en la programación local.

### US-02: Endurecer errores y estados de plataforma
Como usuario  
Quiero entender claramente qué pasó cuando una operación clave falla  
Para saber si debo reintentar, esperar o ajustar alguna configuración.

Criterios de aceptación:
- Los errores de notificaciones, exportación o persistencia muestran feedback claro.
- Los estados de carga no aparentan éxito inmediato incorrecto.
- El flujo mantiene una experiencia funcional cuando hay fallos temporales de plataforma.

### US-03: Tener un checklist de release
Como desarrollador  
Quiero un checklist claro para publicar la app  
Para reducir errores de configuración y validación antes del release.

Criterios de aceptación:
- La documentación enumera permisos, validaciones manuales y pasos mínimos antes de release.
- El checklist cubre iOS y Android.
- El equipo puede ejecutar el release checklist sin depender de conocimiento tácito.

## Épica 2: Mantenibilidad y documentación

### US-04: Mantener documentación alineada con la arquitectura real
Como desarrollador  
Quiero que la documentación describa el proyecto actual  
Para incorporarme rápido y tomar decisiones sin apoyarme en supuestos obsoletos.

Criterios de aceptación:
- El README refleja la arquitectura actual de `features/mood` y `core/`.
- La documentación describe bootstrap, settings, notificaciones y telemetría de forma consistente.
- Backlog y user stories no listan trabajo ya completado como si siguiera pendiente.

### US-05: Definir la estrategia de localización
Como responsable de producto  
Quiero decidir cómo se manejarán español e inglés  
Para evitar una base técnica bilingüe con comportamiento de producto ambiguo.

Criterios de aceptación:
- Existe una decisión explícita sobre idioma inicial y expansión futura.
- La documentación explica esa decisión.
- La app no mezcla una estrategia técnica y de producto contradictoria.

## Épica 3: Evolución del producto

### US-06: Poder editar, borrar y revisar entradas
Como usuario  
Quiero modificar o eliminar registros anteriores y consultar sus notas  
Para mantener mi historial útil y corregir errores de captura.

Criterios de aceptación:
- El usuario puede abrir un registro existente y editarlo.
- El usuario puede eliminar un registro con confirmación adecuada.
- Las notas históricas pueden consultarse desde la interfaz con un flujo claro.

### US-07: Consultar un historial tipo timeline
Como usuario  
Quiero una pantalla de historial con búsqueda y filtros  
Para revisar fácilmente mis registros pasados.

Criterios de aceptación:
- Existe una pantalla dedicada al historial.
- El historial permite buscar o filtrar por mood, fecha o texto.
- Desde el historial se puede abrir el detalle de una entrada existente.

### US-08: Mejorar accesibilidad general
Como usuario  
Quiero que la app sea accesible con lector de pantalla, buen contraste y tamaños adecuados  
Para poder usarla cómodamente en distintas condiciones.

Criterios de aceptación:
- Los elementos interactivos tienen tamaños táctiles razonables.
- Los componentes clave exponen semántica útil para accesibilidad.
- La UI mantiene legibilidad con text scaling común.

### US-09: Visualizar tendencias y patrones
Como usuario  
Quiero ver tendencias de mi estado de ánimo y comparativas por periodos  
Para entender mejor mis patrones emocionales.

Criterios de aceptación:
- La app muestra al menos una vista comparativa o tendencia más allá del mes actual.
- La información presentada es comprensible y accionable.
- Los cálculos usan correctamente el historial disponible.

### US-10: Añadir etiquetas a las notas
Como usuario  
Quiero clasificar mis registros con tags como trabajo, sueño o ejercicio  
Para encontrar mejor las causas o contextos de mis moods.

Criterios de aceptación:
- El usuario puede asociar una o más etiquetas a un registro.
- Las etiquetas quedan guardadas y visibles al consultar el historial.
- Las etiquetas pueden usarse como filtro o criterio de búsqueda.

### US-11: Evaluar expansión del catálogo de moods
Como responsable de producto  
Quiero decidir si el selector crecerá con más moods o agrupaciones  
Para priorizar mejor la evolución del producto después del lanzamiento inicial.

Criterios de aceptación:
- Existe una decisión documentada sobre si conviene añadir más moods o categorías.
- La decisión considera complejidad de UX, mantenimiento y utilidad real.
- El roadmap no trata esa expansión como implícita sin definición de alcance.

## Mapeo rápido con prioridades

- Alta prioridad:
  US-01, US-02, US-03, US-04
- Prioridad media:
  US-05, US-06, US-07
- Prioridad baja:
  US-08, US-09, US-10, US-11
