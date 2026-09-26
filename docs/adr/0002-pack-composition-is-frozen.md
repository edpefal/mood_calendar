# Pack composition is frozen at creation

Un Pack es un Purchase no consumible que desbloquea varios Moods premium a la vez con descuento. Dado que el catálogo de Moods va a seguir creciendo indefinidamente, surgió la pregunta de qué pasa si un Mood nuevo encaja temáticamente con un Pack ya existente.

Se decidió que la composición de un Pack (qué Moods incluye) queda **congelada en el momento en que se publica** y nunca se modifica después. Si un Mood nuevo encaja con el tema de un Pack existente, se crea un Pack nuevo (con su propio precio y su propio identificador de producto); el Pack original no cambia.

La alternativa — permitir agregar Moods a un Pack ya existente — habría cambiado retroactivamente el contenido de un producto no consumible que usuarios ya compraron. Eso genera dos problemas: (1) no hay forma automática de "regalar" el mood nuevo a quienes ya compraron el pack sin lógica adicional de entitlements del lado de RevenueCat, y (2) el App Store espera que el contenido de un producto no consumible ya comprado sea estable — cambiarlo retroactivamente puede generar confusión o reclamos de soporte ("compré el pack y no tenía este mood, ¿por qué otros sí?").
