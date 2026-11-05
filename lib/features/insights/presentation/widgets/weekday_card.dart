import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../mood/presentation/widgets/mood_category_grid.dart';
import '../../domain/services/weekday_profile.dart';
import 'category_legend.dart';
import 'not_enough_data.dart';

/// Average mood level by day of the week, Monday first, one bar per day tinted
/// with that day's most frequent category.
class WeekdayCard extends StatelessWidget {
  const WeekdayCard({super.key, required this.profile});

  final WeekdayProfileResult profile;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final names = strings.weekdayLongNames;
    // weekdayInitials starts on Sunday; the card starts on Monday.
    final initials = [
      ...strings.weekdayInitials.skip(1),
      strings.weekdayInitials.first,
    ];

    final summary = [
      for (var i = 0; i < 7; i++)
        profile.days[i] == null
            ? strings.weekdayNoDataSemantics(names[i])
            : strings.weekdayBarSemantics(
                names[i],
                moodCategoryName(strings, profile.days[i]!.category),
              ),
    ].join(', ');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              strings.weekdayTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.text,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          if (profile.isInsufficient)
            const NotEnoughData()
          else
            Semantics(
              image: true,
              label: '${strings.weekdayTitle}: $summary',
              excludeSemantics: true,
              child: SizedBox(
                height: 160,
                child: BarChart(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 250),
                  BarChartData(
                    minY: 0,
                    maxY: 3,
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: const BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              initials[value.toInt()],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < 7; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: profile.days[i]?.level ?? 0,
                              width: 18,
                              borderRadius: BorderRadius.circular(8),
                              color: profile.days[i] == null
                                  ? Colors.transparent
                                  : palette
                                      .tint(profile.days[i]!.category.tone)
                                      .ring,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 3,
                                color: palette.glassBorder,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (!profile.isInsufficient) ...[
            const SizedBox(height: 12),
            const CategoryLegend(),
          ],
        ],
      ),
    );
  }
}
