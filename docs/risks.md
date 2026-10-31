# In-App Purchase Risks

Riesgos identificados en la implementación actual de compras in-app del proyecto.

## Riesgos aceptables para v1

### 1. Sin validación de recibos en backend

La app no valida recibos fuera del dispositivo. La implementación actual confía
en `purchaseStream` y luego cachea los unlocks localmente en Hive.

Por qué puede aceptarse en v1:
- La app es local-first.
- No existe sistema de cuentas propio.
- El catálogo inicial es pequeño y sólo usa no consumibles.

Tradeoff:
- Menor defensa ante manipulación local o estados inconsistentes de tienda.

## 2. Caché local de entitlements en Hive

Los moods comprados se guardan en Hive para permitir arranque offline con el
último estado conocido.

Por qué puede aceptarse en v1:
- Mejora el tiempo de arranque.
- Evita depender del store en cada apertura.
- Hace que el producto se sienta más estable cuando la tienda no responde.

Tradeoff:
- Puede existir drift temporal entre el caché local y el estado real de la
  cuenta de tienda.

### 3. Mensajes premium todavía poco refinados

Los mensajes de error y estados premium funcionan, pero todavía son básicos y
no están muy diferenciados por tipo de fallo.

Por qué puede aceptarse en v1:
- No bloquea el flujo principal.
- Puede mejorarse después del primer release si el comportamiento base es
  correcto.

Tradeoff:
- La UX se siente menos pulida en errores, restore y estados intermedios.

### 4. Packs modelados pero no expuestos en UI

El modelo de moods premium ya contempla `packIds`, pero el flujo visible sigue
siendo de compras individuales.

Por qué puede aceptarse en v1:
- No introduce complejidad extra en producto.
- Mantiene el alcance de monetización acotado.

Tradeoff:
- La base técnica sugiere una expansión futura que todavía no está cerrada en
  roadmap ni UX.

## Riesgos que conviene corregir antes de publicar

### 1. Restore con feedback ambiguo

`restorePurchases()` dispara la restauración, pero el resultado real depende de
lo que llegue después por `purchaseStream`. Si no llega nada útil, la UX puede
quedar ambigua.

Riesgo:
- El usuario no sabe si no había compras para restaurar, si la tienda falló o
  si el proceso sigue pendiente.

Conviene corregir:
- Mostrar resultado explícito de restore.
- Diferenciar restore exitoso, sin compras previas y error.

### 2. Cierre prematuro del modal de compra

El sheet de compra se cierra cuando `buyMood()` retorna, no cuando la compra ya
fue confirmada por el stream de compras.

Riesgo:
- La UI puede dar una sensación falsa de éxito.
- En compras pendientes o canceladas el usuario pierde contexto.

Conviene corregir:
- Mantener el modal abierto o mostrar un estado intermedio hasta tener un
  resultado concluyente.

### 3. Estado `pending` sin UX específica

La lógica evita desbloquear incorrectamente hasta recibir `purchased` o
`restored`, lo cual está bien. Pero no hay una experiencia clara para compras
pendientes.

Riesgo:
- El usuario no entiende si debe esperar, reintentar o cerrar la app.
- Esto es especialmente delicado en Google Play.

Conviene corregir:
- Modelar y mostrar explícitamente el estado pendiente.

### 4. Productos faltantes degradados con defaults silenciosos

Al consultar productos del store, si alguno no está disponible se usan
fallbacks de `title`, `description` y `price` en vez de fallar con una señal
visible.

Riesgo:
- Un error de configuración en App Store Connect o Play Console puede pasar
  desapercibido.
- La UI puede mostrar un producto que en realidad no está disponible.

Conviene corregir:
- Detectar y registrar productos faltantes con más dureza.
- Mostrar señales de no disponibilidad si un SKU no está bien configurado.

### 5. Checklist de release todavía insuficiente

La app ya implementa compras, pero el proceso operativo de publicación necesita
más disciplina.

Riesgo:
- Errores de configuración entre código, App Store Connect y Play Console.
- Falsos positivos en QA si no se prueban cuentas sandbox y restore.

Conviene corregir:
- Mantener una checklist de release que cubra:
  compra exitosa
  restore tras reinstalar
  tienda no disponible
  validación de productos activos
  cuentas sandbox/test en iOS y Android

### 6. Cobertura de pruebas aún incompleta para escenarios de plataforma

Ya existe una base razonable de pruebas para premium, pero todavía faltan casos
operativos importantes.

Riesgo:
- Regresiones en restore, estados de tienda, errores de producto y flujos
  pendientes.

Conviene corregir:
- Reforzar pruebas de restore.
- Cubrir estados de store no disponible.
- Validar mejor errores y transiciones del flujo premium.

## Priorización recomendada antes de release

Si sólo se atienden dos riesgos antes de publicar, la mejor relación
impacto/esfuerzo parece ser:

1. Dar resultado claro al flujo de restore.
2. Evitar cerrar el modal de compra antes de confirmación real.

## Suscripción Premium (1.10.0)

Riesgos aceptados al pasar de compras sueltas a una suscripción semanal, mensual y anual (change `replace-mood-purchases-with-subscription`). El documento anterior de esta página describe una implementación previa de compras; para la vigente, ver `CLAUDE.md` ("Compras in-app").

### Sin validación de recibos propia
RevenueCat es la fuente de verdad y el cliente confía en su `CustomerInfo`. Sigue valiendo el riesgo de la sección 1 de arriba: no hay backend propio que valide recibos.

### Caducidad sin conexión
RevenueCat cachea el último `CustomerInfo` y evalúa la caducidad con fechas firmadas, pero sin red el estado puede ser el último conocido. Una suscripción vencida puede seguir desbloqueando moods hasta la siguiente conexión y, al revés, una renovada puede tardar en reflejarse.
- Se acepta: lo único que está en juego es poder crear entradas nuevas con moods premium; el historial nunca se toca.

### Reembolsos y fallos de pago en Android
Las notificaciones en tiempo real de Google Play hacia RevenueCat (RTDN) siguen pendientes (`backlog.md`). Sin ellas, un reembolso o una cancelación puede tardar en llegar a RevenueCat.

### El reloj puede mostrar moods que ya no están desbloqueados
El reloj muestra el último estado que publicó el iPhone. Si la suscripción vence con la app cerrada, el reloj puede ofrecer un mood premium hasta que el iPhone se abra. El iPhone descarta esa elección sin cambiar ninguna entrada y el siguiente estado la da por procesada (`handledChoiceIds`); ver `docs/watch-sync-contract.md`.

### La prueba gratis y los usuarios de versiones anteriores
Quien se suscribe desde la 1.10.0 no ve sus moods desbloqueados en un dispositivo con la 1.8.x o la 1.9.0 (solo leen los entitlements `mood_*`). Se acepta: la suscripción se compra y se usa en la versión nueva.

### Precio frente a las compras sueltas
Un mensual de $2.99 supera el coste de comprar todo suelto (≈ $8 con los Packs) en pocos meses. Sin compras reales hasta octubre de 2026 no hay compradores con los que comparar; los precios viven en las tiendas y se pueden cambiar sin tocar la app.
