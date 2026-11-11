import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// flutter_local_notifications v17 does not declare the receivers that show a
/// scheduled notification, so without them the daily reminder never appears
/// on Android even though it is scheduled without errors.
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('declares the receiver that shows scheduled notifications', () {
    expect(
      manifest,
      contains('com.dexterous.flutterlocalnotifications.'
          'ScheduledNotificationReceiver'),
    );
  });

  test('reschedules the reminder after a reboot or an update', () {
    expect(
      manifest,
      contains('com.dexterous.flutterlocalnotifications.'
          'ScheduledNotificationBootReceiver'),
    );
    expect(manifest, contains('android.permission.RECEIVE_BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
    expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
  });
}
