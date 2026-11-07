import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import 'onboarding_frame.dart';

/// Step 3: explains the daily reminder before the system asks for the
/// notification permission, which only happens on "Turn on reminder".
class ReminderPermissionStep extends StatelessWidget {
  const ReminderPermissionStep({
    super.key,
    required this.busy,
    required this.onTurnOn,
    required this.onNotNow,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback onTurnOn;
  final VoidCallback onNotNow;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return OnboardingFrame(
      step: 3,
      onSkip: busy ? null : onSkip,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingTitleCard(
            title: strings.onboardingReminderTitle,
            body: strings.onboardingReminderBody,
          ),
          const SizedBox(height: 32),
          ExcludeSemantics(
            child: Center(
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: palette.logLinearGradient,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 60,
                  color: palette.onLogGradient,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientPillButton(
            label: strings.onboardingTurnOnReminder,
            loading: busy,
            onPressed: onTurnOn,
          ),
          const SizedBox(height: 4),
          OnboardingTextButton(
            label: strings.onboardingNotNow,
            onPressed: busy ? null : onNotNow,
          ),
        ],
      ),
    );
  }
}
