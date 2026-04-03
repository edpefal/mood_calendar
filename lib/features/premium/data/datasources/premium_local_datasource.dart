import 'package:hive/hive.dart';

class PremiumLocalDataSource {
  PremiumLocalDataSource(this._box);

  static const _ownedMoodIdsKey = 'owned_mood_ids';

  final Box<dynamic> _box;

  Future<Set<String>> getOwnedMoodIds() async {
    final rawValue = _box.get(_ownedMoodIdsKey);
    if (rawValue is List) {
      return rawValue.map((item) => item.toString()).toSet();
    }
    return <String>{};
  }

  Future<void> saveOwnedMoodIds(Set<String> ownedMoodIds) async {
    await _box.put(_ownedMoodIdsKey, ownedMoodIds.toList()..sort());
  }
}
