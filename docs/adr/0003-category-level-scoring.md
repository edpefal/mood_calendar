# Category level is the score; intensity stays an identifier

**Estado: Reemplaza al [ADR 0001](0001-intensity-is-not-valence.md).** Lo que el 0001 prohibía (usar `intensity` como escala de valencia) sigue prohibido; lo que cambia es que ahora hay una forma legítima de obtener un valor numérico para los análisis.

El rediseño (Bloque 1) agrupa los Moods en cuatro **categorías**: Positive, Peaceful, Neutral y Hard. Insights (Bloque 2) necesita un valor numérico para dibujar tendencias, y el ADR 0001 lo había dejado sin respuesta al descartar toda escala.

Se decidió que el puntaje es **por categoría, de tres niveles**: Positive y Peaceful son alto, Neutral es medio y Hard es bajo. Todo Mood hereda el nivel de su categoría y nunca tiene un puntaje propio, así que un Mood nuevo solo necesita declarar su categoría (un test del catálogo falla si no lo hace). Esto evita lo que el 0001 quería evitar: asignar a mano un valor a cada Mood para siempre.

Reglas que se conservan:

- `intensity` es solo un identificador interno. No se usa para ordenar, comparar, puntuar ni promediar.
- El resumen mensual sigue mostrando el Mood más frecuente (moda), no un promedio.
- Ninguna pantalla presenta una categoría como "mejor" que otra: el nivel es un dato para los análisis, no un juicio. El color de una categoría no sustituye a su nombre.

Alternativa descartada: puntaje propio por Mood. Reabría el problema del 0001 (cada Mood nuevo exigiría decidir dónde cae en una escala) sin aportar más que la categoría.
