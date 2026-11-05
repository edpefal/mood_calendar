import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/services/mood_definition_resolver.dart';
import '../../domain/services/year_pixels.dart';
import 'category_legend.dart';

/// One pixel per day of the year, 12 months across and up to 31 days down,
/// tinted by the day's category. Tapping a logged day opens its detail.
class YearPixelsCard extends StatelessWidget {
  const YearPixelsCard({
    super.key,
    required this.year,
    required this.years,
    required this.days,
    required this.onYearChanged,
    required this.onDayTap,
  });

  final int year;

  /// Years that can be shown (oldest first).
  final List<int> years;
  final List<PixelDay> days;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<MoodEntry> onDayTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final index = years.indexOf(year);
    final canGoPrevious = index > 0;
    final canGoNext = index >= 0 && index < years.length - 1;
    final logged = days.where((d) => d.entry != null).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  label: strings.yearInPixelsSemantics(year, logged),
                  excludeSemantics: true,
                  child: Text(
                    strings.yearInPixelsTitle(year),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: palette.text,
                        ),
                  ),
                ),
              ),
              IconButton(
                tooltip: strings.previousYearTooltip,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: canGoPrevious
                      ? palette.text
                      : palette.textSecondary.withValues(alpha: 0.4),
                ),
                onPressed: canGoPrevious
                    ? () => onYearChanged(years[index - 1])
                    : null,
              ),
              IconButton(
                tooltip: strings.nextYearTooltip,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: canGoNext
                      ? palette.text
                      : palette.textSecondary.withValues(alpha: 0.4),
                ),
                onPressed:
                    canGoNext ? () => onYearChanged(years[index + 1]) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Grid(year: year, days: days, onDayTap: onDayTap),
          const SizedBox(height: 12),
          const CategoryLegend(),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.year, required this.days, required this.onDayTap});

  final int year;
  final List<PixelDay> days;
  final ValueChanged<MoodEntry> onDayTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final byMonthDay = {
      for (final d in days) (d.date.month, d.date.day): d,
    };

    return Column(
      children: [
        Row(
          children: [
            for (var month = 1; month <= 12; month++)
              Expanded(
                child: Center(
                  child: Text(
                    strings.monthNames[month - 1].characters.first,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var day = 1; day <= 31; day++)
          SizedBox(
            height: 9,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var month = 1; month <= 12; month++)
                  Expanded(
                    child: _Pixel(
                      pixel: byMonthDay[(month, day)],
                      onTap: onDayTap,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Pixel extends StatelessWidget {
  const _Pixel({required this.pixel, required this.onTap});

  final PixelDay? pixel;
  final ValueChanged<MoodEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final day = pixel;
    if (day == null) return const SizedBox.shrink();

    final category = day.category;
    final entry = day.entry;
    final fill = category == null
        ? (day.isFuture
            ? Colors.transparent
            : palette.glassBorder.withValues(alpha: 0.5))
        : palette.tint(category.tone).ring;

    final cell = Padding(
      padding: const EdgeInsets.all(1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    if (entry == null) return ExcludeSemantics(child: cell);

    final strings = AppStrings.of(context);
    final moodName =
        strings.moodName(MoodDefinitionResolver.byAssetPath(entry.mood).id);
    return Semantics(
      button: true,
      label: '${strings.formatFullDate(day.date)}, $moodName',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(entry),
        child: cell,
      ),
    );
  }
}
