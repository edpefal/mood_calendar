/// Claves de contexto que nunca salen del dispositivo: describen una entrada
/// del usuario (fecha, mood, nota). Siguen escribiéndose en el log local.
/// Las comparten Crashlytics y Analytics.
const blockedContextKeys = {'date', 'mood', 'intensity', 'note'};
