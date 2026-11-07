import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/phone_column.dart';
import '../cubit/onboarding_cubit.dart';

/// Shared chrome of the four steps: the mesh background, the progress bar with
/// "Skip", a scrollable body (so large system text never hides the buttons)
/// and the actions pinned at the bottom.
class OnboardingFrame extends StatelessWidget {
  const OnboardingFrame({
    super.key,
    required this.step,
    required this.body,
    required this.actions,
    this.onSkip,
    this.tint,
  });

  final int step;
  final Widget body;
  final Widget actions;

  /// Null on the last step, which has no "Skip".
  final VoidCallback? onSkip;

  /// Pooled at the top of the background (the first log tints it with the
  /// picked mood's category).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return MeshBackground(
      tint: tint,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: PhoneColumn(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: OnboardingProgress(step: step)),
                      const SizedBox(width: 16),
                      // Keeps the bar's width the same on the last step.
                      if (onSkip != null)
                        _SkipButton(onPressed: onSkip!)
                      else
                        const SizedBox(height: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: body,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Step n of 4" as four segments; announced as one element.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return Semantics(
      label: AppStrings.of(context).onboardingStepLabel(step),
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 1; i <= OnboardingCubit.stepCount; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: i == step ? palette.ink : palette.glassBorder,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = AppStrings.of(context).onboardingSkip;
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: GlassCard(
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The big title and supporting line of a step, on a glass card.
class OnboardingTitleCard extends StatelessWidget {
  const OnboardingTitleCard({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                height: 40 / 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              height: 22 / 15,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A secondary text-only action under the primary button ("Not now").
class OnboardingTextButton extends StatelessWidget {
  const OnboardingTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
