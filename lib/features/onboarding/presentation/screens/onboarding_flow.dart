import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/settings/domain/repositories/app_settings_repository.dart';
import '../../../../core/telemetry/app_telemetry.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/presentation/bloc/mood_cubit.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/first_log_step.dart';
import '../widgets/reminder_permission_step.dart';
import '../widgets/reminder_time_step.dart';
import '../widgets/welcome_step.dart';

/// The four first-run steps (see the `onboarding` spec). Calls [onFinished]
/// once, when the user skips on the first step or confirms their first day.
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({
    super.key,
    required this.cubit,
    required this.onFinished,
  });

  final OnboardingCubit cubit;
  final ValueChanged<OnboardingOutcome> onFinished;

  /// Builds the flow wired to the app-wide services.
  static Widget forApp({
    required ValueChanged<OnboardingOutcome> onFinished,
    required Future<void> Function() markCompleted,
  }) {
    return Builder(
      builder: (context) {
        final settings = context.read<AppSettingsRepository>();
        final notifications = context.read<LocalNotificationService>();
        final moodCubit = context.read<MoodCubit>();
        final cubit = OnboardingCubit(
          saveReminderTime: (hour, minute) async {
            final current = await settings.getSettings();
            await settings.saveSettings(current.copyWith(
              dailyReminderHour: hour,
              dailyReminderMinute: minute,
            ));
          },
          requestNotificationPermission: notifications.requestPermission,
          setReminderEnabled: (enabled) async {
            final current = await settings.getSettings();
            await settings.saveSettings(
              current.copyWith(dailyReminderEnabled: enabled),
            );
            if (enabled) {
              await notifications.scheduleDailyReminder();
            } else {
              await notifications.cancelDailyReminder();
            }
          },
          saveFirstEntry: (MoodEntry entry) async {
            await moodCubit.save(entry);
            return !moodCubit.state
                .maybeWhen(error: (_) => true, orElse: () => false);
          },
          markCompleted: markCompleted,
          telemetry: context.read<AppTelemetry>(),
        );
        return OnboardingFlow(cubit: cubit, onFinished: onFinished);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: _OnboardingBody(onFinished: onFinished),
    );
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody({required this.onFinished});

  final ValueChanged<OnboardingOutcome> onFinished;

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  /// The permission step is waiting on the system dialog.
  bool _askingPermission = false;

  Future<void> _turnOnReminder(OnboardingCubit cubit) async {
    setState(() => _askingPermission = true);
    try {
      await cubit.turnOnReminder();
    } finally {
      if (mounted) setState(() => _askingPermission = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final strings = AppStrings.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Android back: one step back, and on the first step leave the app.
        if (!cubit.back()) unawaited(SystemNavigator.pop());
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<OnboardingCubit, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.outcome != current.outcome && current.outcome != null,
            listener: (context, state) => widget.onFinished(state.outcome!),
          ),
          BlocListener<OnboardingCubit, OnboardingState>(
            listenWhen: (previous, current) =>
                previous.saveFailureCount != current.saveFailureCount,
            listener: (context, state) => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(strings.saveMoodError))),
          ),
        ],
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              child: KeyedSubtree(
                key: ValueKey(state.step),
                child: _step(context, cubit, state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _step(
      BuildContext context, OnboardingCubit cubit, OnboardingState state) {
    switch (state.step) {
      case 1:
        return WelcomeStep(
          onGetStarted: cubit.getStarted,
          onSkip: () => unawaited(cubit.skip()),
        );
      case 2:
        return ReminderTimeStep(
          state: state,
          onSuggestion: cubit.selectSuggestion,
          onTimeChanged: cubit.setTime,
          onContinue: () => unawaited(cubit.continueFromTime()),
          onSkip: () => unawaited(cubit.skip()),
        );
      case 3:
        return ReminderPermissionStep(
          busy: _askingPermission,
          onTurnOn: () => unawaited(_turnOnReminder(cubit)),
          onNotNow: () => unawaited(cubit.notNow()),
          onSkip: () => unawaited(cubit.skip()),
        );
      default:
        return FirstLogStep(
          state: state,
          onMoodPicked: (mood) => cubit.selectMood(mood.id),
          onNoteChanged: cubit.setNote,
          onSave: (mood) => unawaited(
            cubit.saveFirstDay(
              assetPath: mood.assetPath,
              intensity: mood.intensity,
            ),
          ),
          onContinue: () => unawaited(cubit.finish()),
        );
    }
  }
}
