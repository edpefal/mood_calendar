import 'package:mood_calendar/features/note_lock/domain/note_lock_authenticator.dart';

/// A [NoteLockAuthenticator] the test drives: [available] says whether the
/// device can authenticate, [succeeds] whether the person passes.
class FakeNoteLockAuthenticator implements NoteLockAuthenticator {
  FakeNoteLockAuthenticator({this.available = true, this.succeeds = true});

  bool available;
  bool succeeds;
  final List<String> reasons = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    reasons.add(reason);
    return succeeds;
  }
}
