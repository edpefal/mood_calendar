# Mood Calendar

App para registrar y revisar estados de ánimo diarios. El catálogo de estados de ánimo (moods) combina un núcleo gratuito permanente con moods adicionales que se desbloquean con una suscripción y que se siguen ampliando con el tiempo.

## Language

**Mood**:
Definición/tipo de estado de ánimo en el catálogo (id, etiqueta, ícono). Es la plantilla, no un registro de un día concreto.
_Avoid_: Mood entry (eso es un concepto distinto, ver más abajo)

**Mood Entry**:
Registro histórico de qué Mood eligió el usuario en una fecha concreta. Una vez guardado, es inmutable frente a cambios futuros del catálogo o del estado de `unlocked`: si el Mood usado ese día pierde `unlocked` después (ej. reembolso), la entrada sigue mostrándose tal cual — `unlocked` solo controla si se puede crear/editar una entrada *nueva*, nunca reescribe el pasado.
_Avoid_: Mood (ver arriba — es la plantilla, no el registro)

**Tier** (`base` | `premium`):
Propiedad fija del Mood en el catálogo: si es gratis para siempre (`base`) o requiere una suscripción (`premium`). No depende del usuario — es la misma para todos.
_Avoid_: Free, gratis (como nombre del campo — se confunde con el estado de desbloqueo del usuario)

**Unlocked**:
Estado por usuario: si ese usuario tiene acceso para usar un Mood concreto. Todo Mood `base` está unlocked trivialmente para cualquiera; un Mood `premium` está unlocked solo si el usuario tiene una **Subscription** activa o si compró ese Mood en una versión anterior (directo o vía Pack).
_Avoid_: Owned, purchased (como sinónimo genérico — "unlocked" es el estado resultante; "purchased" o "subscribed" es cómo se llegó a él, ver Subscription y Purchase)

**Subscription**:
Suscripción de renovación automática (semanal, mensual o anual) que mantiene `unlocked` **todos** los Moods premium mientras esté activa, incluidos los que se añadan después. Los tres planes dan el mismo acceso y solo cambian el ciclo y el precio, que siempre vienen de la tienda del sistema. Si termina, los Moods premium vuelven a estar bloqueados para entradas nuevas, pero ninguna Mood Entry se oculta ni se modifica. Un usuario que dejó de pagar sigue pudiendo editar la nota de una entrada que ya tiene ese Mood.
_Avoid_: Plan Premium, membresía, VIP

**Purchase** (heredado):
Compra no consumible de un solo pago que otorgaba `unlocked` a uno o más Moods premium: individual (un Mood) o un Pack. Dejó de venderse con la suscripción, pero las compras ya hechas se siguen reconociendo y se pueden restaurar.
_Avoid_: Product, SKU (vocabulario de tienda/RevenueCat, no del dominio)

**Most Common Mood**:
El Mood que más días se registró dentro de un mes — reemplaza al antiguo promedio numérico mensual, ya que el identificador de un Mood ya no representa valencia (ver Intensity). En caso de empate, gana el Mood cuyo último registro del mes sea más reciente.
_Avoid_: Average mood, representative mood, promedio (conceptos del modelo anterior — ya no existen)

**Intensity**:
Identificador numérico interno por Mood, sin relación con qué tan "bueno" o "malo" es. No se debe usar para ordenar, comparar ni promediar Moods entre sí — su único rol histórico es distinguir un Mood de otro dentro de un `Mood Entry` guardado.
_Avoid_: Score, valencia, valor emocional (implican una escala de mejor/peor que ya no existe)

**Pack** (heredado):
Un Purchase que desbloquea varios Moods premium a la vez, con descuento frente a comprarlos sueltos. Su composición (qué Moods incluye) es una **lista congelada en el momento en que se crea** — nunca se le agregan ni quitan Moods después de publicado. Si un Mood nuevo encaja temáticamente con un Pack existente, se crea un Pack nuevo; el original no cambia. Tiene precio fijo único: no se ajusta si el usuario ya tiene desbloqueados algunos de sus Moods (la Tienda puede advertir el solape antes de confirmar, pero no bloquea ni recalcula precio).
_Avoid_: Bundle, paquete (como sinónimo — usar siempre "Pack")

El Pack ya no se vende (ver `docs/adr/0002-pack-composition-is-frozen.md`, reemplazado por la suscripción); la definición se conserva para entender los entitlements `mood_*` que siguen vigentes.
