# usage-analytics Specification

## Purpose

Define cómo Mood Calendar mide el uso de la app de forma anónima (usuarios activos, sesiones, versión y un conjunto cerrado de eventos) para que el desarrollador entienda cuántas personas la usan, sin recoger datos de las entradas ni identificadores publicitarios.

## Requirements
### Requirement: Medición anónima de uso en builds de release
La app SHALL enviar a un servicio externo de analíticas la actividad de uso (apertura de sesión, versión de la app, versión del sistema operativo y país) cuando se ejecuta como build de release en iOS o Android y el usuario no ha desactivado la medición. La medición SHALL identificar la instalación, no a la persona: la app NO SHALL asociarla a una cuenta, correo, nombre ni a ningún dato de las entradas.

#### Scenario: Primera apertura en release
- **WHEN** el usuario abre por primera vez un build de release en iOS o Android con la medición activa
- **THEN** se registra una sesión de una instalación nueva sin ningún dato personal

#### Scenario: Aperturas posteriores
- **WHEN** el usuario vuelve a abrir la app en otro día
- **THEN** se registra la sesión asociada a la misma instalación

### Requirement: Sin medición fuera de release
La app NO SHALL enviar analíticas en builds de debug, en builds de profile, bajo `flutter test` ni desde el entrypoint de capturas de App Store. En esos casos los eventos SHALL seguir escribiéndose únicamente en el log local.

#### Scenario: Build de debug
- **WHEN** la app corre en modo debug y el usuario guarda un mood
- **THEN** no se envía ningún evento y el evento aparece en el log local

#### Scenario: Entrypoint de capturas
- **WHEN** la app arranca desde el entrypoint de capturas de App Store
- **THEN** no se inicializa el servicio de analíticas ni se envía nada

### Requirement: Lista cerrada de eventos sin datos de entradas
La app SHALL enviar únicamente los eventos de una lista cerrada: guardar un mood, abrir la app desde el recordatorio, programar o cancelar el recordatorio, pedir la calificación (automática o manual), abrir la tienda y el resultado de una compra (iniciada, completada, cancelada o fallida, y restaurada). Ningún evento NO SHALL incluir el mood elegido, la nota, la fecha de la entrada, la intensidad ni el identificador de un mood o Pack comprado.

#### Scenario: Guardar un mood
- **WHEN** el usuario guarda un mood con una nota
- **THEN** se envía el evento de mood guardado sin el mood, la nota, la fecha ni la intensidad

#### Scenario: Evento con parámetros prohibidos
- **WHEN** un componente intenta enviar un evento con una clave de contexto que contiene datos de entradas (`date`, `mood`, `intensity` o `note`)
- **THEN** esas claves se descartan antes de enviarse y el resto del evento se envía

#### Scenario: Evento fuera de la lista
- **WHEN** un componente intenta enviar un evento que no está en la lista cerrada
- **THEN** el evento no se envía y solo se escribe en el log local

### Requirement: Sin identificadores publicitarios ni seguimiento
La app NO SHALL recolectar el identificador de publicidad del dispositivo, NO SHALL compartir datos de analíticas con servicios de publicidad y NO SHALL mostrar el aviso de seguimiento de transparencia de apps (App Tracking Transparency). El build de Android NO SHALL declarar el permiso de identificador de publicidad.

#### Scenario: Instalación nueva en iOS
- **WHEN** el usuario abre la app por primera vez en iOS
- **THEN** no aparece ningún aviso de seguimiento y no se lee el identificador de publicidad

#### Scenario: Manifiesto de Android
- **WHEN** se genera el bundle de release de Android
- **THEN** el manifiesto final no incluye el permiso de identificador de publicidad

### Requirement: Interruptor para dejar de compartir datos de uso
El usuario SHALL poder desactivar la medición en cualquier momento desde Settings. La preferencia SHALL guardarse localmente, estar activada por defecto y aplicarse de inmediato y en los siguientes arranques: con la medición desactivada la app NO SHALL enviar ningún evento. El interruptor NO SHALL afectar al reporte de crashes.

#### Scenario: Desactivar la medición
- **WHEN** el usuario desactiva el interruptor y luego guarda un mood
- **THEN** no se envía ningún evento y la preferencia queda guardada

#### Scenario: Preferencia conservada al reiniciar
- **WHEN** el usuario desactivó la medición y reinicia la app
- **THEN** la app arranca con la medición desactivada desde el primer evento

#### Scenario: Reactivar la medición
- **WHEN** el usuario vuelve a activar el interruptor
- **THEN** los eventos posteriores se envían de nuevo, sin reenviar los que ocurrieron mientras estuvo desactivado

### Requirement: Arranque no bloqueado por las analíticas
La inicialización de las analíticas NO SHALL esperar nada que dependa del usuario ni retrasar `runApp()` más que la inicialización de Firebase ya existente. Si la inicialización falla, la app SHALL arrancar igual, sin medición y sin mostrar errores al usuario.

#### Scenario: Fallo al inicializar
- **WHEN** el servicio de analíticas falla al inicializarse en un build de release
- **THEN** la app arranca con normalidad, el error se escribe en el log local y no se envía ningún evento
