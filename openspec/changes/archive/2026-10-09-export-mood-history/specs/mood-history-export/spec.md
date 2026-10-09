## Purpose

Permite al usuario sacar su historial de Mood Entries de la app como un archivo JSON portable, compartiéndolo con la hoja del sistema desde Settings, para que conserve o respalde sus datos.

## ADDED Requirements

### Requirement: Entrada para exportar el historial en Settings
Settings SHALL incluir una sección "Tus datos" con una fila "Exportar historial". Al tocarla, la app SHALL generar el archivo de exportación y abrir la hoja de compartir del sistema con ese archivo.

#### Scenario: Exportar con entradas guardadas
- **WHEN** el usuario tiene al menos una Mood Entry y toca "Exportar historial"
- **THEN** se genera el archivo y se abre la hoja de compartir con ese archivo

#### Scenario: La hoja se cierra sin compartir
- **WHEN** el usuario cierra la hoja de compartir sin elegir un destino
- **THEN** la app no muestra ningún error y permanece en Settings

#### Scenario: Hoja anclada en iPad
- **WHEN** el usuario exporta desde un iPad
- **THEN** la hoja de compartir se muestra anclada a la fila "Exportar historial"

### Requirement: Estados de la exportación
Mientras se genera el archivo, la fila SHALL mostrar que está exportando y SHALL estar deshabilitada, de modo que no se inicien exportaciones simultáneas. Si no existe ninguna Mood Entry, la app NO SHALL abrir la hoja de compartir y SHALL informar al usuario que aún no hay nada que exportar. Si la generación falla, la app SHALL mostrar un mensaje de error y NO SHALL abrir la hoja de compartir.

#### Scenario: Exportación en curso
- **WHEN** el usuario toca "Exportar historial" y el archivo aún se está generando
- **THEN** la fila muestra progreso y no responde a nuevos toques

#### Scenario: Historial vacío
- **WHEN** el usuario no tiene ninguna Mood Entry y toca "Exportar historial"
- **THEN** la app muestra un mensaje indicando que aún no hay historial para exportar y no abre la hoja de compartir

#### Scenario: Falla al generar el archivo
- **WHEN** la generación del archivo falla
- **THEN** la app muestra un mensaje de error, no abre la hoja de compartir y la fila vuelve a estar disponible

### Requirement: Contenido del archivo exportado
El archivo SHALL ser JSON codificado en UTF-8 y SHALL incluir en su raíz la versión del formato (`formatVersion`, valor 1), la fecha y hora de generación en UTC (`generatedAt`), la cantidad de entradas (`entryCount`) y la lista de entradas (`entries`) ordenada por fecha ascendente. Cada entrada SHALL contener únicamente la fecha (`date`, formato `YYYY-MM-DD`), el id estable del mood (`mood`, por ejemplo `calm`) y la nota (`note`, nula si no hay). El archivo NO SHALL incluir `intensity` ni rutas de assets.

#### Scenario: Estructura de una entrada
- **WHEN** se exporta una Mood Entry del 2026-04-02 con mood calm y nota "Quiet day"
- **THEN** la entrada exportada es `{"date": "2026-04-02", "mood": "calm", "note": "Quiet day"}`

#### Scenario: Entrada sin nota
- **WHEN** se exporta una Mood Entry sin nota
- **THEN** su campo `note` es nulo

#### Scenario: Orden de las entradas
- **WHEN** el usuario tiene entradas de varios días guardadas en cualquier orden
- **THEN** `entries` queda ordenada por `date` ascendente y `entryCount` coincide con su longitud

#### Scenario: Moods premium bloqueados
- **WHEN** el historial incluye una entrada de un mood premium que el usuario ya no tiene desbloqueado
- **THEN** la entrada se exporta igualmente con su mood

#### Scenario: Mood no reconocido
- **WHEN** una Mood Entry guardada tiene un mood que la app no reconoce
- **THEN** se exporta con el valor tal como estaba guardado, sin sustituirlo por otro mood

### Requirement: El archivo exportado es temporal
La app SHALL escribir el archivo de exportación en un almacenamiento temporal del sistema y NO SHALL conservarlo como parte permanente de los datos de la app, de modo que las copias del historial no se acumulen dentro de la app.

#### Scenario: Exportaciones repetidas
- **WHEN** el usuario exporta su historial varias veces
- **THEN** la app no deja archivos de exportación acumulados en el almacenamiento permanente de documentos de la app

### Requirement: Textos localizados y accesibles de la exportación
Los textos de la fila y de sus mensajes SHALL mostrarse en el idioma del dispositivo entre inglés, español, alemán, francés e italiano, con inglés como respaldo. La fila SHALL exponer una etiqueta de `Semantics` que describa su acción y su estado de exportando.

#### Scenario: Dispositivo en alemán
- **WHEN** el idioma del dispositivo es alemán y el usuario abre Settings
- **THEN** la sección y la fila de exportar se muestran en alemán

#### Scenario: Lector de pantalla
- **WHEN** un lector de pantalla recorre Settings
- **THEN** la fila "Exportar historial" se anuncia con una etiqueta que describe su acción

### Requirement: Telemetría de la exportación
La app SHALL registrar un evento de telemetría cuando la exportación termina con éxito, con la cantidad de entradas, y un error trazable cuando falla. La telemetría NO SHALL incluir el contenido de las notas.

#### Scenario: Exportación exitosa
- **WHEN** el archivo se genera con éxito
- **THEN** se registra el evento de exportación con la cantidad de entradas y sin el contenido de las notas

#### Scenario: Exportación fallida
- **WHEN** la generación del archivo falla
- **THEN** se registra un error trazable de exportación
