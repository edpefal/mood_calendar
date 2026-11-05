import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';

/// A Premium card shown to someone without the subscription: a blurred fixed
/// illustration and "See with Premium".
///
/// [preview] is an illustration with sample data. It must never be built from
/// the user's entries: the card promises what Premium shows, not their data.
/// One blur per card keeps the cost of the glass low.
class LockedInsightCard extends StatelessWidget {
  const LockedInsightCard({
    super.key,
    required this.title,
    required this.preview,
    required this.onUnlock,
  });

  final String title;
  final Widget preview;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return Semantics(
      container: true,
      label: strings.lockedCardSemantics(title),
      button: true,
      onTap: onUnlock,
      excludeSemantics: true,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: preview,
                  ),
                  Material(
                    color: palette.ink,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: onUnlock,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_rounded,
                                  size: 16, color: palette.onInk),
                              const SizedBox(width: 8),
                              Text(
                                strings.seeWithPremium,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: palette.onInk,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
