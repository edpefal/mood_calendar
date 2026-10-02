## Why

El change `add-mood-in-app-purchases` implementa la lógica de código para moods premium y compras, pero necesita que exista primero infraestructura externa real: un proyecto de RevenueCat, productos en App Store Connect, y el mapeo de entitlements/packs configurado del lado de RevenueCat. Esto no es código — son acciones en dashboards externos que requieren la cuenta del dueño del proyecto, así que se separan en su propio change para no bloquear ni mezclarse con el trabajo de implementación.

## What Changes

- Crear el proyecto de la app en RevenueCat y vincularlo a App Store Connect.
- Dar de alta los productos no consumibles en App Store Connect: uno por cada Mood premium individual, y al menos un Pack de prueba.
- Definir en RevenueCat un entitlement por Mood premium y mapear cada producto individual a su entitlement correspondiente.
- Configurar el Pack de prueba para que su producto otorgue varios entitlements a la vez (los de sus moods miembro).
- Obtener la API key pública de RevenueCat para iOS, necesaria para inicializar `purchases_flutter` en el código (tarea 1.5 de `add-mood-in-app-purchases`).

No hay cambios de comportamiento observable en la app como resultado directo de este change — es prerequisito operativo del change de implementación. Por eso no declara capabilities (`skip_specs: true`).

## Impact

- Cuenta de RevenueCat (nuevo proyecto).
- App Store Connect: nuevos productos no consumibles (uno por mood premium + al menos un pack de prueba).
- Ninguna dependencia de código en este change; desbloquea las tareas 1.1–1.3 (y provee el insumo para 1.4–1.5) de `openspec/changes/add-mood-in-app-purchases/tasks.md`.
