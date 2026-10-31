import '../../../../core/localization/app_strings.dart';
import '../../../mood/domain/entities/mood_definition.dart';
import '../../../mood/domain/repositories/mood_repository.dart';
import '../../../mood/domain/services/mood_picker_order.dart';
import '../entities/watch_state.dart';
import '../repositories/watch_channel.dart';

/// Publica al reloj los moods desbloqueados (en el orden del selector), sus
/// nombres localizados y el mood de hoy.
class PublishWatchStateUseCase {
  PublishWatchStateUseCase({
    required this.repository,
    required this.channel,
    required this.isUnlocked,
    required this.strings,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MoodRepository repository;
  final WatchChannel channel;
  final bool Function(String moodId) isUnlocked;

  /// Idioma activo de la app, resuelto en el momento de publicar.
  final AppStrings Function() strings;
  final DateTime Function() _now;

  Future<void> call({List<String> handledChoiceIds = const []}) async {
    final entries = await repository.getMoods();
    final localized = strings();

    final ordered = MoodPickerOrder.sort(entries, isUnlocked: isUnlocked)
        .where((mood) => isUnlocked(mood.id));

    final now = _now();
    String? today;
    for (final entry in entries) {
      final isToday = entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day;
      if (!isToday) continue;
      for (final definition in allMoodDefinitions) {
        if (definition.assetPath == entry.mood) today = definition.id;
      }
    }

    await channel.publishState(
      WatchState(
        locale: localized.locale.languageCode,
        today: today,
        moods: [
          for (final mood in ordered)
            WatchMoodOption(id: mood.id, name: localized.moodName(mood.id)),
        ],
        handledChoiceIds: handledChoiceIds,
      ),
    );
  }
}
