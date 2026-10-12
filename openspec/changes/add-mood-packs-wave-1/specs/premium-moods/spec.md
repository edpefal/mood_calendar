## ADDED Requirements

### Requirement: Moods premium de la primera ola de packs
El catálogo SHALL incluir, además de los moods existentes, 9 Moods premium con ids estables: `affectionate`, `hugging`, `laughing`, `sleepy`, `sick`, `hurt`, `crying`, `scared` y `stressed`. Los 9 SHALL tener tier `premium`, un ícono propio, un nombre localizado en inglés, español, alemán, francés e italiano, y SHALL ordenarse en el catálogo después de los moods premium existentes, agrupados por Pack (Afecto, Cuerpo, Intenso) en el orden en que se listan aquí. El catálogo resultante SHALL tener 5 Moods `base` y 14 `premium`. Los ids SHALL NOT cambiar una vez publicados, porque son el identificador estable de las Mood Entry guardadas y de la exportación.

#### Scenario: El catálogo incluye los moods nuevos
- **WHEN** se consulta el catálogo completo de moods
- **THEN** contiene 19 Moods, de los cuales 5 son `base` y 14 son `premium`, y los 9 nuevos son `premium`

#### Scenario: Cada mood nuevo tiene nombre en todos los idiomas
- **WHEN** el idioma del dispositivo es cualquiera de los 5 soportados
- **THEN** cada uno de los 9 moods nuevos muestra su nombre localizado y no cae al id ni a otro idioma

#### Scenario: Los moods nuevos aparecen bloqueados sin compra
- **WHEN** un usuario sin compras abre el selector
- **THEN** los 9 moods nuevos aparecen después de los moods `unlocked`, marcados como no `unlocked`, en el orden del catálogo

#### Scenario: Un usuario existente conserva sus datos
- **WHEN** un usuario con Mood Entry previas actualiza a la versión que incluye los moods nuevos
- **THEN** sus entradas y sus moods `unlocked` no cambian

#### Scenario: Los moods nuevos se exportan con su id
- **WHEN** el usuario exporta su historial y tiene una entrada con `sleepy`
- **THEN** el JSON contiene `sleepy` como `mood`, no la ruta del asset ni `intensity`
