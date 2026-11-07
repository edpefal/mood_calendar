import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../domain/note_lock_authenticator.dart';

/// [NoteLockAuthenticator] over the `local_auth` plugin. Biometrics or the
/// device passcode both count, so a device without Face ID or a fingerprint
/// reader can still lock its notes.
class LocalAuthNoteLockAuthenticator implements NoteLockAuthenticator {
  LocalAuthNoteLockAuthenticator([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } on PlatformException {
      // Cancelled, locked out, or no authentication available: stay locked.
      return false;
    }
  }
}
