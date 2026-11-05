import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/services/trend_calculator.dart';
import '../../../mood/presentation/widgets/mood_category_grid.dart';
import 'category_legend.dart';
import 'not_enough_data.dart';

/// Mood level over the chosen range: one point per day (7 and 30 days) or per
/// week (90 and 365), tinted by category, with gaps where nothing was logged.
class TrendCard extends StatelessWidget {
  const TrendCard({
    super.key,
    required this.result,
    required this.range,
    required this.isPremium,
    required this.onRangeSelected,
  });

  final TrendResult result;
  final TrendRange range;
  final bool isPremium;

  /// Called with every tapped range, including the Premium ones; the screen
  /// decides whether to switch or to offer the subscription.
  final ValueChanged<TrendRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              strings.trendTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in TrendRange.values)
                _RangeChip(
                  range: value,
                  selected: value == range,
                  locked: value.requiresPremium && !isPremium,
                  onTap: () => onRangeSelected(value),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (result.isInsufficient)
            const NotEnoughData()
          else
            Semantics(
              image: true,
              label: strings.trendChartSemantics(
                range.days,
                result.entryCount,
                moodCategoryName(strings, result.dominantCategory!),
              ),
              excludeSemantics: true,
              child: SizedBox(
                height: 160,
                child: _TrendChart(result: result, range: range),
              ),
            ),
          if (!result.isInsufficient) ...[
            const SizedBox(height: 12),
            const CategoryLegend(),
          ],
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.range,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final TrendRange range;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: locked
          ? strings.lockedCardSemantics(strings.trendRangeLabel(range.days))
          : strings.trendRangeLabel(range.days),
      excludeSemantics: true,
      child: Material(
        color: selected ? palette.ink : Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: palette.glassBorder)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (locked) ...[
                    Icon(Icons.lock_rounded,
                        size: 12, color: palette.textSecondary),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    strings.trendRangeChip(range.days),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? palette.onInk : palette.text,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.result, required this.range});

  final TrendResult result;
  final TrendRange range;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final points = result.points;
    final spots = [
      for (var i = 0; i < points.length; i++)
        points[i].level == null
            ? FlSpot.nullSpot
            : FlSpot(i.toDouble(), points[i].level!),
    ];

    return LineChart(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      LineChartData(
        minX: -0.5,
        maxX: points.length - 0.5,
        minY: 0.5,
        maxY: 3.5,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: palette.glassBorder, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: points.length <= 30 ? 2 : 1.5,
            color: palette.textSecondary.withValues(alpha: 0.45),
            dotData: FlDotData(
              getDotPainter: (spot, percent, bar, index) {
                final category = points[index].category;
                return FlDotCirclePainter(
                  radius: points.length <= 30 ? 5 : 3.5,
                  color: category == null
                      ? palette.textSecondary
                      : palette.tint(category.tone).ring,
                  strokeWidth: 1.5,
                  strokeColor: palette.background,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
