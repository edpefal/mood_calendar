# crash-reporting Specification

## Purpose

Define cómo Mood Calendar detecta y reporta crashes y errores no fatales en producción, de forma anónima y sin bloquear el arranque, para que el desarrollador pueda diagnosticar fallos de usuarios reales.

## Requirements
### Requirement: Captura de crashes en builds de release
La app SHALL reportar a un servicio externo de crashes los errores fatales no manejados (errores de Flutter, errores asíncronos fuera de zona y crashes nativos) cuando se ejecuta como build de release en iOS o Android. Los reportes SHALL incluir stack trace simbolicado, versión de la app y versión del sistema operativo.

#### Scenario: Error de Flutter no manejado en release
- **WHEN** ocurre una excepción no capturada en el framework de Flutter en un build de release
- **THEN** la excepción se reporta como fatal y la app sigue el comportamiento normal del framework

#### Scenario: Error asíncrono no manejado en release
- **WHEN** ocurre un error asíncrono que ningún `catch` maneja en un build de release
- **THEN** el error se reporta como fatal

#### Scenario: Crash nativo en release
- **WHEN** la app termina por un crash nativo en iOS o Android en un build de release
- **THEN** el reporte se envía en el siguiente arranque de la app

### Requirement: Errores no fatales registrados por la app
Los errores que la app ya registra como `recordError` SHALL reportarse como errores no fatales en release, con su nombre, motivo y contexto, sin cambiar el comportamiento visible para el usuario.

#### Scenario: Error registrado manualmente
- **WHEN** un componente de la app registra un error mediante la telemetría
- **THEN** el error se envía como no fatal con su nombre y contexto, y el flujo de la app continúa igual

### Requirement: Sin reporte fuera de release
La app NO SHALL enviar reportes de crashes en builds de debug, en builds de profile, bajo `flutter test` ni desde el entrypoint de capturas de App Store. En esos casos los errores SHALL seguir escribiéndose únicamente en el log local.

#### Scenario: Build de debug
- **WHEN** la app corre en modo debug y ocurre un error
- **THEN** no se envía ningún reporte y el error aparece en el log local

#### Scenario: Entrypoint de capturas
- **WHEN** la app arranca desde el entrypoint de capturas de App Store
- **THEN** no se inicializa el servicio de crashes ni se envía ningún reporte

### Requirement: Arranque no bloqueado por el reporte de crashes
La inicialización del reporte de crashes SHALL NOT depender de interacción del usuario ni de diálogos del sistema, y SHALL completarse antes de `runApp()` sin impedir que la interfaz se muestre. Si la inicialización falla, la app SHALL arrancar con normalidad sin reporte de crashes.

#### Scenario: Inicialización exitosa
- **WHEN** la app arranca en release
- **THEN** el reporte de crashes queda activo antes de mostrar la primera pantalla y la interfaz aparece sin esperar al usuario

#### Scenario: Fallo de inicialización
- **WHEN** la inicialización del servicio de crashes lanza un error
- **THEN** la app se muestra con normalidad y el fallo se escribe en el log local

### Requirement: Reportes anónimos y sin contenido del usuario
Los reportes SHALL ser anónimos y NO SHALL incluir notas diarias, moods registrados, fechas de entradas ni identificadores personales (nombre, correo, ID de cuenta). El contexto adjunto a los errores SHALL limitarse a datos técnicos.

#### Scenario: Contexto de un error
- **WHEN** se reporta un error cuyo contexto incluye datos de la app
- **THEN** el reporte no contiene el texto de ninguna nota ni el mood o la fecha de una entrada

### Requirement: Reporte activo por defecto sin ajuste en Settings
El reporte de crashes en release SHALL estar activo por defecto y NO SHALL ofrecer un control en Settings para desactivarlo. La declaración de privacidad de la app SHALL indicar que se recopilan datos de diagnóstico anónimos.

#### Scenario: Primera instalación
- **WHEN** el usuario instala y abre la app por primera vez en un build de release
- **THEN** el reporte de crashes está activo sin mostrar diálogos ni pedir permiso

#### Scenario: Settings no ofrece el control
- **WHEN** el usuario abre Settings
- **THEN** no existe ninguna fila ni switch para activar o desactivar el reporte de crashes
