# Contrato de sincronización iPhone ↔ Apple Watch

Fuente de verdad: el iPhone (Hive). El reloj no guarda historial. Spec: `openspec/specs/watch-mood-picker/` (o el change `add-apple-watch-mood-picker` mientras esté activo) y `design.md` del change.

Transporte: WatchConnectivity.

## iPhone → reloj: estado (`updateApplicationContext`)

Último valor gana; se entrega aunque la app del reloj esté cerrada.

```json
{
  "version": 1,
  "locale": "es",
  "today": "calm",
  "moods": [
    { "id": "calm", "name": "Tranquilo" },
    { "id": "happy", "name": "Feliz" }
  ]
}
```

- `version`: versión del contrato (hoy `1`). El reloj ignora estados con una versión mayor que la que entiende.
- `locale`: código de idioma de los nombres (`en`, `es`, `de`, `fr`, `it`); solo informativo.
- `today`: id del mood de hoy, o `null` si hoy no tiene Mood Entry.
- `moods`: solo los desbloqueados, ya en el orden de uso del selector del iPhone, con el nombre localizado por `AppStrings`.

## Reloj → iPhone: elección (`transferUserInfo`)

Cola persistente: sobrevive a que el iPhone esté lejos o la app cerrada.

```json
{ "id": "5c1b8f3e-0a7e-4a52-9d5f-3b7a9c0e41d2", "date": "2026-11-02", "mood": "calm", "chosenAt": 1793617800000 }
```

- `id`: UUID de la elección; el iPhone deduplica por él.
- `date`: fecha **local** del reloj al elegir (`YYYY-MM-DD`). Solo se acepta la de hoy.
- `mood`: id estable del mood (`calm`). Nunca `intensity` ni rutas de assets (ADR 0001).
- `chosenAt`: milisegundos desde epoch en el reloj; ordena elecciones del mismo día (gana la última).

No hay notas ni otro campo. Un `mood` desconocido o bloqueado se ignora en el iPhone sin error.

## Buzón del iPhone (puente nativo ↔ Dart)

Swift guarda cada elección recibida en un buzón persistente (`UserDefaults`, clave `watch.inbox.v1`) y recuerda los últimos ids vistos para no reaplicar una elección que el sistema reentregue. Dart es el único que escribe en Hive:

| Método (`com.artlab.moodcalendar/watch`) | Dirección | Efecto |
|---|---|---|
| `readInbox` | Dart → Swift | Devuelve la lista de elecciones pendientes |
| `ackInbox({ids})` | Dart → Swift | Quita del buzón solo esas elecciones, después de aplicarlas |
| `publishState(estado)` | Dart → Swift | Guarda y envía el estado al reloj |
| `inboxChanged` | Swift → Dart | Avisa de que llegó una elección nueva |

Aplicar = leer, guardar en Hive, y solo después confirmar (`ackInbox`), para no perder datos si la app muere en medio.
