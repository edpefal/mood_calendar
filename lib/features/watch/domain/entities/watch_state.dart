/// Un mood que el reloj puede ofrecer, con su nombre ya localizado.
class WatchMoodOption {
  const WatchMoodOption({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, Object?> toMap() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      other is WatchMoodOption && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Estado que el iPhone publica al reloj (`docs/watch-sync-contract.md`).
class WatchState {
  const WatchState({
    required this.locale,
    required this.today,
    required this.moods,
    this.handledChoiceIds = const [],
  });

  static const int version = 1;

  /// Código de idioma de los nombres (`en`, `es`, `de`, `fr`, `it`).
  final String locale;

  /// Id del mood de hoy, o null si hoy no tiene entrada.
  final String? today;

  /// Solo los moods desbloqueados, en el orden de uso del selector.
  final List<WatchMoodOption> moods;

  /// Ids de las últimas elecciones del reloj que el iPhone ya procesó, ya fueran
  /// aplicadas o descartadas (p. ej. un mood que dejó de estar desbloqueado).
  /// Así el reloj sabe que puede quitar su marca "pendiente".
  final List<String> handledChoiceIds;

  Map<String, Object?> toMap() => {
        'version': version,
        'locale': locale,
        'today': today,
        'moods': [for (final mood in moods) mood.toMap()],
        'handledChoiceIds': handledChoiceIds,
      };
}
