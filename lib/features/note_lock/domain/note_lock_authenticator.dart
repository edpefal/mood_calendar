/// Asks the operating system to verify the person holding the device
/// (biometrics or the device passcode). The app only ever learns whether it
/// succeeded; it never sees or stores biometric data.
abstract class NoteLockAuthenticator {
  /// Whether the device has biometrics or a passcode set up.
  Future<bool> isAvailable();

  /// Shows the system prompt with [reason]; false when it was cancelled,
  /// failed or could not be shown.
  Future<bool> authenticate(String reason);
}
