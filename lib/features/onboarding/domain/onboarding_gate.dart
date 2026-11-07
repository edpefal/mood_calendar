/// Decides, once and synchronously at startup, whether the app opens on the
/// onboarding. Only a brand-new install qualifies: the onboarding was never
/// finished AND there is no Mood Entry yet, so someone updating from an older
/// version with a full calendar never sees it.
class OnboardingGate {
  const OnboardingGate({
    required bool Function() isCompleted,
    required bool Function() hasEntries,
  })  : _isCompleted = isCompleted,
        _hasEntries = hasEntries;

  /// A gate that never shows the onboarding (tests, screenshot entrypoint).
  const OnboardingGate.skipped()
      : _isCompleted = _alwaysTrue,
        _hasEntries = _alwaysTrue;

  final bool Function() _isCompleted;
  final bool Function() _hasEntries;

  bool get shouldShow => !_isCompleted() && !_hasEntries();

  static bool _alwaysTrue() => true;
}
