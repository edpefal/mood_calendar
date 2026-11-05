import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../mood/domain/entities/mood_category.dart';
import '../../../mood/presentation/widgets/mood_category_grid.dart';

/// The four categories with their tint and their name, so the color of a
/// chart is never the only way to tell them apart.
class CategoryLegend extends StatelessWidget {
  const CategoryLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final category in MoodCategory.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: palette.tint(category.tone).ring,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                moodCategoryName(strings, category),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
