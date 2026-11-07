import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/note_lock/presentation/bloc/note_lock_cubit.dart';
import 'package:mood_calendar/features/note_lock/presentation/widgets/note_lock_host.dart';

import '../../support/app_harness.dart';
import '../../support/fake_note_lock_authenticator.dart';

void main() {
  late FakeNoteLockAuthenticator authenticator;
  late NoteLockCubit cubit;

  setUp(() {
    authenticator = FakeNoteLockAuthenticator();
    cubit = NoteLockCubit(
      authenticator: authenticator,
      telemetry: RecordingTelemetry(),
      isSubscribed: () => true,
      enabled: true,
    );
  });

  tearDown(() => cubit.close());

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const NoteLockHost(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(),
          ),
        ),
      ),
    );
  }

  void lifecycle(WidgetTester tester, AppLifecycleState state) =>
      tester.binding.handleAppLifecycleStateChanged(state);

  testWidgets('going to the background locks the notes again', (tester) async {
    await pumpHost(tester);
    await cubit.unlock('r');
    expect(cubit.state.unlocked, isTrue);

    lifecycle(tester, AppLifecycleState.inactive);
    lifecycle(tester, AppLifecycleState.hidden);
    lifecycle(tester, AppLifecycleState.paused);

    expect(cubit.state.unlocked, isFalse);
  });

  testWidgets('the system prompt (inactive) does not lock the session',
      (tester) async {
    await pumpHost(tester);
    await cubit.unlock('r');

    lifecycle(tester, AppLifecycleState.inactive);

    expect(cubit.state.unlocked, isTrue);
  });

  testWidgets('coming back re-checks that the device can authenticate',
      (tester) async {
    await pumpHost(tester);
    await tester.pump();
    authenticator.available = false;

    lifecycle(tester, AppLifecycleState.paused);
    lifecycle(tester, AppLifecycleState.resumed);
    await tester.pump();

    expect(cubit.state.available, isFalse);
    expect(cubit.state.conceals, isFalse);
  });
}
