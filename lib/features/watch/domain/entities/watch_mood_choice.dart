/// Un mood elegido en el Apple Watch, pendiente de aplicar en el iPhone.
///
/// Contrato en `docs/watch-sync-contract.md`: solo la fecha local del reloj
/// (`YYYY-MM-DD`) y el id estable del mood; nunca `intensity` (ADR 0001).
class WatchMoodChoice {
  const WatchMoodChoice({
    required this.id,
    required this.date,
    required this.mood,
    required this.chosenAt,
  });

  /// UUID de la elección; el lado nativo deduplica por él.
  final String id;

  /// Fecha local del reloj al elegir, `YYYY-MM-DD`.
  final String date;

  /// Id estable del mood, por ejemplo `calm`.
  final String mood;

  /// Milisegundos desde epoch en el reloj; ordena las elecciones del mismo día.
  final int chosenAt;

  /// Devuelve null si el mapa no cumple el contrato.
  static WatchMoodChoice? tryParse(Map<Object?, Object?> map) {
    final id = map['id'];
    final date = map['date'];
    final mood = map['mood'];
    final chosenAt = map['chosenAt'];
    if (id is! String || id.isEmpty) return null;
    if (date is! String || mood is! String || mood.isEmpty) return null;
    if (chosenAt is! num) return null;
    return WatchMoodChoice(
      id: id,
      date: date,
      mood: mood,
      chosenAt: chosenAt.toInt(),
    );
  }
}
