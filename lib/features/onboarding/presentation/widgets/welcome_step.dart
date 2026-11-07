import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/dashed_border_painter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import 'onboarding_frame.dart';

/// Step 1: what the app is for, with an illustrative calendar (fixed sample
/// moods, never the user's data).
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.onGetStarted,
    required this.onSkip,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return OnboardingFrame(
      step: 1,
      onSkip: onSkip,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingTitleCard(
            title: strings.onboardingWelcomeTitle,
            body: strings.onboardingWelcomeBody,
          ),
          const SizedBox(height: 16),
          Semantics(
            image: true,
            label: strings.onboardingCalendarPreviewSemantics,
            excludeSemantics: true,
            child: const _CalendarPreview(),
          ),
        ],
      ),
      actions: GradientPillButton(
        label: strings.onboardingGetStarted,
        onPressed: onGetStarted,
      ),
    );
  }
}

const _sampleMoods = [
  'happy', 'calm', 'happy', 'neutral', 'sad', 'calm', 'happy', //
  'sleepy', 'calm', 'anxious', 'happy', 'happy', 'calm', 'neutral', //
  'stressed', 'happy', 'calm', 'happy', 'sad', 'calm', 'angry', //
];

class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview();

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    const gap = 6.0;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var row = 0; row < 4; row++) ...[
            if (row > 0) const SizedBox(height: gap),
            Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) const SizedBox(width: gap),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: row * 7 + col < _sampleMoods.length
                          ? _SampleCell(id: _sampleMoods[row * 7 + col])
                          : CustomPaint(
                              painter: DashedBorderPainter(
                                color: palette.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SampleCell extends StatelessWidget {
  const _SampleCell({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final mood = MoodDefinitionResolver.byId(id);
    final tint = MoodDefinitionResolver.tintFor(context, mood);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.fill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SvgPicture.asset(mood.assetPath),
      ),
    );
  }
}
