# User Stories

Historias de usuario derivadas de [backlog.md](/Users/eder/Development/Flutter/ai_projects/mood_calendar/mood_calendar/backlog.md), agrupadas por épicas según prioridad.

## Épica 1: Estabilidad técnica y arquitectura

### US-01: Desacoplar la UI de Hive
Como desarrollador  
Quiero que la UI no lea ni escriba directamente en Hive  
Para mantener una arquitectura limpia y facilitar pruebas, mantenimiento y cambios futuros de almacenamiento.

Criterios de aceptación:
- Ninguna pantalla en `presentation` accede directamente a `Hive.box()` o `Hive.openBox()`.
- La carga y guardado de moods se hace a través de casos de uso, repositorios o cubits.
- El comportamiento actual de lectura y guardado se mantiene sin regresiones visibles.

### US-02: Eliminar código residual del template
Como desarrollador  
Quiero remover widgets y pruebas heredadas del template de Flutter  
Para que el código refleje únicamente el comportamiento real de la aplicación.

Criterios de aceptación:
- `MyHomePage` y cualquier referencia asociada al contador dejan de existir si no forman parte de la app.
- El test de contador se elimina o se reemplaza por uno alineado con la app real.
- El proyecto sigue compilando y ejecutándose correctamente tras la limpieza.

### US-03: Reemplazar `print` por logging controlado
Como desarrollador  
Quiero usar un sistema de logging consistente  
Para depurar mejor en desarrollo sin contaminar la app en producción.

Criterios de aceptación:
- Los `print` en código productivo se sustituyen por un mecanismo de logging definido por el proyecto.
- Los logs verbosos no se emiten en release salvo errores relevantes.
- `flutter analyze` deja de reportar advertencias de `avoid_print` en los archivos corregidos.

### US-04: Mantener `flutter analyze` limpio
Como desarrollador  
Quiero corregir los warnings actuales del analizador  
Para reducir deuda técnica y detectar regresiones con mayor claridad.

Criterios de aceptación:
- Los warnings actuales priorizados quedan resueltos o documentados con una razón válida.
- `flutter analyze` puede ejecutarse sin errores ni warnings no justificados.
- No se introducen ignores innecesarios para ocultar problemas reales.

### US-05: Cubrir la lógica crítica con pruebas
Como desarrollador  
Quiero tener pruebas unitarias y de widgets para la lógica principal  
Para asegurar que guardado de moods, resumen mensual y rachas funcionen correctamente.

Criterios de aceptación:
- Existen tests unitarios para repositorio o casos de uso de moods.
- Existen tests para el cálculo de resumen mensual, promedio y `bestStreak`.
- El comando `flutter test` pasa con la nueva cobertura añadida.

## Épica 2: Robustez de plataforma y mantenibilidad

### US-06: Crear una capa de settings de aplicación
Como desarrollador  
Quiero encapsular preferencias de aplicación en una capa específica de settings  
Para evitar claves sueltas en Hive y preparar futuras configuraciones de usuario.

Criterios de aceptación:
- Las preferencias y flags de configuración se gestionan desde una clase o datasource de settings.
- Las claves de almacenamiento quedan centralizadas y tipadas.
- La solución es extensible para soportar nuevas preferencias sin duplicar lógica.

### US-07: Unificar idioma y preparar localización
Como usuario  
Quiero una experiencia consistente en un solo idioma o con soporte de localización  
Para entender la app de forma clara y coherente.

Criterios de aceptación:
- Los textos visibles de la app siguen una convención de idioma definida.
- No hay mezcla arbitraria de español e inglés en la UI final.
- Si se introduce localización, existe una estructura base para añadir nuevos idiomas.

### US-08: Mejorar feedback de carga y errores
Como usuario  
Quiero recibir mensajes claros cuando algo falle o esté cargando  
Para entender el estado de la app y saber qué hacer a continuación.

Criterios de aceptación:
- Los flujos de guardado, carga y error muestran feedback claro y consistente.
- Los mensajes de error son comprensibles para usuario final.
- Los estados vacíos y de carga no bloquean innecesariamente la interacción.

### US-09: Poder editar, borrar y revisar entradas
Como usuario  
Quiero modificar o eliminar registros anteriores y consultar sus notas  
Para mantener mi historial actualizado y útil.

Criterios de aceptación:
- El usuario puede abrir un registro existente y editarlo.
- El usuario puede eliminar un registro con confirmación adecuada.
- Las notas históricas pueden consultarse desde la interfaz sin recurrir a almacenamiento interno.

### US-10: Ordenar la navegación de la app
Como desarrollador  
Quiero centralizar o normalizar la navegación  
Para evitar lógica duplicada y reducir errores entre pantallas.

Criterios de aceptación:
- La navegación principal sigue una estrategia consistente definida por el proyecto.
- Se reduce la duplicación de `push`, `pushReplacement` y lógica condicional inline.
- Los flujos actuales entre calendario, detalle y recordatorios siguen funcionando.

### US-11: Normalizar el guardado por fecha
Como desarrollador  
Quiero guardar los moods con una clave diaria consistente  
Para evitar inconsistencias por horas o zonas horarias.

Criterios de aceptación:
- La clave de persistencia representa el día de forma consistente y sin depender de la hora exacta.
- Los registros existentes siguen siendo legibles o migrables.
- No se crean duplicados para un mismo día por diferencias de timestamp.

## Épica 3: Experiencia de usuario y evolución del producto

### US-12: Mejorar accesibilidad general
Como usuario  
Quiero que la app sea accesible con lector de pantalla, buen contraste y tamaños adecuados  
Para poder usarla cómodamente en distintas condiciones.

Criterios de aceptación:
- Los elementos interactivos tienen tamaños táctiles razonables.
- Los componentes clave exponen semántica útil para accesibilidad.
- Los contrastes y textos principales son legibles en condiciones comunes de uso.

### US-13: Configurar recordatorios diarios
Como usuario  
Quiero elegir la hora o activar/desactivar mis recordatorios  
Para adaptar la app a mi rutina.

Criterios de aceptación:
- Existe una opción visible para activar o desactivar recordatorios.
- El usuario puede seleccionar al menos una hora personalizada.
- La programación de notificaciones respeta la configuración guardada.

### US-14: Exportar o respaldar mi historial
Como usuario  
Quiero poder exportar mis datos o hacer backup  
Para no perder mi historial y poder reutilizarlo fuera de la app.

Criterios de aceptación:
- El usuario puede generar una exportación de su historial en un formato útil.
- La exportación incluye fecha, mood, nota e intensidad cuando existan.
- El flujo informa claramente si la exportación fue exitosa o falló.

### US-15: Medir eventos clave de la aplicación
Como responsable de producto  
Quiero registrar métricas y errores importantes  
Para entender uso real, detectar fallos y priorizar mejoras.

Criterios de aceptación:
- Se registran eventos clave como guardado de mood y apertura desde notificación.
- Los errores relevantes quedan trazables con contexto mínimo útil.
- La solución respeta la configuración de entorno y evita exponer datos sensibles innecesarios.

### US-16: Mejorar documentación de desarrollo
Como desarrollador  
Quiero contar con documentación más completa de arquitectura y flujo de trabajo  
Para incorporarme rápido al proyecto y mantener consistencia en cambios futuros.

Criterios de aceptación:
- La documentación explica estructura general, flujo de datos y convenciones principales.
- Existe una guía básica para correr, probar y generar código.
- La documentación refleja el estado real del proyecto y no referencias obsoletas.

### US-17: Ejecutar validaciones automáticas en CI
Como desarrollador  
Quiero que el repositorio ejecute análisis y pruebas automáticamente  
Para detectar problemas antes de integrar cambios.

Criterios de aceptación:
- Existe un workflow de CI que corre al menos `flutter analyze` y `flutter test`.
- El pipeline falla cuando hay errores o regresiones.
- La configuración de CI está documentada de forma mínima para el equipo.

## Épica 4: Funcionalidades de valor adicional

### US-18: Visualizar tendencias y patrones
Como usuario  
Quiero ver tendencias de mi estado de ánimo y comparativas por periodos  
Para entender mejor mis patrones emocionales.

Criterios de aceptación:
- La app muestra al menos una vista comparativa o tendencia más allá del mes actual.
- La información presentada es comprensible y accionable para el usuario.
- Los cálculos usan correctamente el historial disponible.

### US-19: Añadir etiquetas a las notas
Como usuario  
Quiero clasificar mis registros con tags como trabajo, sueño o ejercicio  
Para encontrar mejor las causas o contextos de mis moods.

Criterios de aceptación:
- El usuario puede asociar una o más etiquetas a un registro.
- Las etiquetas quedan guardadas y visibles al consultar el historial.
- Las etiquetas pueden usarse como filtro o criterio de búsqueda.

### US-20: Consultar un historial tipo timeline
Como usuario  
Quiero una pantalla de historial con búsqueda y filtros  
Para revisar fácilmente mis registros pasados.

Criterios de aceptación:
- Existe una pantalla dedicada al historial de registros.
- El historial permite buscar por texto o filtrar por mood, fecha o etiqueta.
- Desde el historial se puede abrir el detalle de una entrada existente.

## Mapeo rápido con prioridades

- Alta prioridad:
  US-01, US-02, US-03, US-04, US-05
- Prioridad media:
  US-06, US-07, US-08, US-09, US-10, US-11
- Prioridad baja:
  US-12, US-13, US-14, US-15, US-16, US-17
- Oportunidades de producto:
  US-18, US-19, US-20
