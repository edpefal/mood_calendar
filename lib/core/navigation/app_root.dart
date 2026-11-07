import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../features/onboarding/domain/onboarding_gate.dart';
import '../../features/onboarding/presentation/cubit/onboarding_state.dart';
import '../../features/purchases/presentation/bloc/purchases_cubit.dart';
import '../../features/purchases/presentation/widgets/premium_sheet.dart';

/// What the app opens on: the first-run onboarding on a brand-new install
/// (decided once, synchronously, by [gate]) and [shell] otherwise.
///
/// When the onboarding ends after the first day was logged, the subscription
/// sheet is offered once on top of the shell (`source` = `onboarding`); it
/// never opens for a subscriber (the sheet checks that) nor after "Skip".
class AppRoot extends StatefulWidget {
  const AppRoot({
    super.key,
    required this.gate,
    required this.shell,
    required this.onboardingBuilder,
  });

  final OnboardingGate gate;
  final Widget shell;
  final Widget Function(ValueChanged<OnboardingOutcome> onFinished)
      onboardingBuilder;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late bool _showOnboarding = widget.gate.shouldShow;
  bool _offeredPremium = false;

  void _onFinished(OnboardingOutcome outcome) {
    if (!_showOnboarding) return;
    setState(() => _showOnboarding = false);
    if (outcome != OnboardingOutcome.completed || _offeredPremium) return;
    _offeredPremium = true;
    // After the shell's first frame, so the Log is already underneath.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(showPremiumSheet(context, source: PremiumSource.onboarding));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) return widget.onboardingBuilder(_onFinished);
    return widget.shell;
  }
}
