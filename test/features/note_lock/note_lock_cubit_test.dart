import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/note_lock/presentation/bloc/note_lock_cubit.dart';

import '../../support/app_harness.dart';
import '../../support/fake_note_lock_authenticator.dart';

void main() {
  late FakeNoteLockAuthenticator authenticator;
  late RecordingTelemetry telemetry;
  late bool subscribed;

  NoteLockCubit build({bool enabled = false}) => NoteLockCubit(
        authenticator: authenticator,
        telemetry: telemetry,
        isSubscribed: () => subscribed,
        enabled: enabled,
      );

  setUp(() {
    authenticator = FakeNoteLockAuthenticator();
    telemetry = RecordingTelemetry();
    subscribed = true;
  });

  group('turning the lock on', () {
    test('needs Premium and does not even ask the system', () async {
      subscribed = false;
      final cubit = build();

      final result = await cubit.requestChange(enable: true, reason: 'r');

      expect(result, NoteLockChange.needsPremium);
      expect(cubit.state.enabled, isFalse);
      expect(authenticator.reasons, isEmpty);
    });

    test('a subscriber who authenticates gets the lock', () async {
      final cubit = build();

      final result = await cubit.requestChange(enable: true, reason: 'r');

      expect(result, NoteLockChange.enabled);
      expect(cubit.state.enabled, isTrue);
      expect(telemetry.events.map((e) => e.name), ['note_lock_enabled']);
      expect(telemetry.events.single.properties, isEmpty);
    });

    test('cancelling the authentication leaves it off', () async {
      authenticator.succeeds = false;
      final cubit = build();

      final result = await cubit.requestChange(enable: true, reason: 'r');

      expect(result, NoteLockChange.cancelled);
      expect(cubit.state.enabled, isFalse);
      expect(telemetry.events, isEmpty);
    });

    test('a device without biometrics or passcode cannot use it', () async {
      authenticator.available = false;
      final cubit = build();

      final result = await cubit.requestChange(enable: true, reason: 'r');

      expect(result, NoteLockChange.unavailable);
      expect(cubit.state.enabled, isFalse);
      expect(authenticator.reasons, isEmpty);
    });
  });

  group('turning the lock off', () {
    test('needs authentication but not Premium', () async {
      subscribed = false; // the subscription lapsed
      final cubit = build(enabled: true);

      final result = await cubit.requestChange(enable: false, reason: 'r');

      expect(result, NoteLockChange.disabled);
      expect(cubit.state.enabled, isFalse);
      expect(authenticator.reasons, ['r']);
      expect(telemetry.events.map((e) => e.name), ['note_lock_disabled']);
    });

    test('cancelling the authentication keeps it on', () async {
      authenticator.succeeds = false;
      final cubit = build(enabled: true);

      final result = await cubit.requestChange(enable: false, reason: 'r');

      expect(result, NoteLockChange.cancelled);
      expect(cubit.state.enabled, isTrue);
    });

    test('an unlocked session does not ask again', () async {
      final cubit = build(enabled: true);
      await cubit.unlock('r');
      authenticator.reasons.clear();

      final result = await cubit.requestChange(enable: false, reason: 'r');

      expect(result, NoteLockChange.disabled);
      expect(authenticator.reasons, isEmpty);
    });
  });

  group('session', () {
    test('conceals notes only while enabled and locked', () async {
      expect(build().state.conceals, isFalse);
      final cubit = build(enabled: true);
      expect(cubit.state.conceals, isTrue);

      await cubit.unlock('r');

      expect(cubit.state.conceals, isFalse);
    });

    test('unlock does not ask when the lock is off', () async {
      final cubit = build();

      expect(await cubit.unlock('r'), isTrue);
      expect(authenticator.reasons, isEmpty);
    });

    test('lock goes back to concealing', () async {
      final cubit = build(enabled: true);
      await cubit.unlock('r');

      cubit.lock();

      expect(cubit.state.conceals, isTrue);
    });

    test('a failed authentication stays locked', () async {
      authenticator.succeeds = false;
      final cubit = build(enabled: true);

      expect(await cubit.unlock('r'), isFalse);
      expect(cubit.state.conceals, isTrue);
    });

    test('concurrent unlocks share one system prompt', () async {
      final cubit = build(enabled: true);

      final results = await Future.wait([cubit.unlock('r'), cubit.unlock('r')]);

      expect(results, [true, true]);
      expect(authenticator.reasons, hasLength(1));
    });

    test(
        'an authentication that ends after the app was backgrounded does not '
        'unlock', () async {
      final cubit = build(enabled: true);

      final pending = cubit.unlock('r');
      cubit.lock(); // the app went to the background mid-prompt
      final result = await pending;

      expect(result, isFalse);
      expect(cubit.state.conceals, isTrue);
    });
  });

  group('no authentication available', () {
    test(
        'the notes are shown instead of lost, and the lock returns with '
        'the passcode', () async {
      final cubit = build(enabled: true);
      authenticator.available = false;

      await cubit.refreshAvailability();

      expect(cubit.state.conceals, isFalse);
      expect(cubit.state.enabledButUnenforceable, isTrue);

      authenticator.available = true;
      await cubit.refreshAvailability();

      expect(cubit.state.conceals, isTrue);
      expect(cubit.state.enabledButUnenforceable, isFalse);
    });
  });

  test('setEnabled follows the saved value', () {
    final cubit = build();

    cubit.setEnabled(true);
    expect(cubit.state.enabled, isTrue);

    cubit.setEnabled(false);
    expect(cubit.state.enabled, isFalse);
  });
}
