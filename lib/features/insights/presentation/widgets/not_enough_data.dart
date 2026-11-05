import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';

/// What a card shows instead of a chart when it has too little data.
class NotEnoughData extends StatelessWidget {
  const NotEnoughData({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 32, color: palette.textSecondary),
          const SizedBox(height: 8),
          Text(
            strings.insightsNotEnoughTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.insightsNotEnoughBody,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
