import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../../../mood/domain/entities/mood_category.dart';

/// Fixed illustrations for the locked cards. They hold sample data on purpose
/// and never read the user's entries.
class SamplePixelsPreview extends StatelessWidget {
  const SamplePixelsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    const categories = MoodCategory.values;
    return SizedBox(
      height: 120,
      child: Column(
        children: [
          for (var row = 0; row < 8; row++)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var col = 0; col < 24; col++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: (row * 7 + col * 3) % 5 == 0
                                ? palette.glassBorder
                                : palette
                                    .tint(categories[(row + col * 2) % 4].tone)
                                    .ring,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SampleBarsPreview extends StatelessWidget {
  const SampleBarsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    const heights = [0.5, 0.8, 0.6, 0.9, 0.7, 1.0, 0.75];
    const categories = [
      MoodCategory.peaceful,
      MoodCategory.positive,
      MoodCategory.neutral,
      MoodCategory.positive,
      MoodCategory.peaceful,
      MoodCategory.positive,
      MoodCategory.peaceful,
    ];
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FractionallySizedBox(
                  heightFactor: heights[i],
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.tint(categories[i].tone).ring,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SampleTrendPreview extends StatelessWidget {
  const SampleTrendPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    const levels = [0.4, 0.7, 0.55, 0.9, 0.65, 0.8, 0.5, 0.95, 0.7, 0.85];
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final level in levels)
            Expanded(
              child: Align(
                alignment: Alignment(0, 1 - level * 2),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: palette.tint(MoodTone.peaceful).ring,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
