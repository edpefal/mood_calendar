import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mood_calendar/features/onboarding/data/onboarding_state_data_source.dart';
import 'package:mood_calendar/features/onboarding/domain/onboarding_gate.dart';

void main() {
  group('OnboardingGate', () {
    test('shows on a new install: not completed and no entries', () {
      final gate = OnboardingGate(
        isCompleted: () => false,
        hasEntries: () => false,
      );

      expect(gate.shouldShow, isTrue);
    });

    test('never shows to someone updating with a history', () {
      final gate = OnboardingGate(
        isCompleted: () => false,
        hasEntries: () => true,
      );

      expect(gate.shouldShow, isFalse);
    });

    test('does not show again once completed or skipped', () {
      final gate = OnboardingGate(
        isCompleted: () => true,
        hasEntries: () => false,
      );

      expect(gate.shouldShow, isFalse);
    });

    test('the skipped gate never shows', () {
      expect(const OnboardingGate.skipped().shouldShow, isFalse);
    });
  });

  group('OnboardingStateDataSource', () {
    late Directory tempDir;
    late Box<dynamic> box;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('onboarding_state_');
      Hive.init(tempDir.path);
      box = await Hive.openBox<dynamic>('app_settings');
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('is not completed when the key is missing', () {
      expect(OnboardingStateDataSource(box).isCompleted, isFalse);
    });

    test('remembers completion across reopens', () async {
      await OnboardingStateDataSource(box).markCompleted();
      await box.close();
      box = await Hive.openBox<dynamic>('app_settings');

      expect(OnboardingStateDataSource(box).isCompleted, isTrue);
    });
  });
}
