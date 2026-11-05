import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/monthly_mood_summary.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/services/category_distribution.dart';
import '../../domain/services/mood_definition_resolver.dart';
import 'mood_category_grid.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class MonthlyMoodSummaryCard extends StatelessWidget {
  final MonthlyMoodSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  /// The streak alive today. It does not depend on the month being viewed, so
  /// the caller computes it from every entry.
  final int currentStreak;

  const MonthlyMoodSummaryCard({
    super.key,
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
    this.currentStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final summaryData = summary;
    if (isLoading && (summaryData == null || summaryData.entries.isEmpty)) {
      return _EmptyState(
        message: strings.loadingSummary,
        icon: Icons.hourglass_top_rounded,
      );
    }
    if (errorMessage != null &&
        (summaryData == null || summaryData.entries.isEmpty)) {
      return _EmptyState(
        message: errorMessage!,
        icon: Icons.error_outline_rounded,
      );
    }
    if (summaryData == null || summaryData.entries.isEmpty) {
      return _EmptyState(
        message: strings.emptySummary,
      );
    }

    final mostCommonMoodPath = summaryData.mostCommonMoodEntry?.mood;
    if (mostCommonMoodPath == null) {
      return _EmptyState(message: strings.emptySummary);
    }

    final mostCommonMood = MoodDefinitionResolver.byAssetPath(
      mostCommonMoodPath,
    );
    final palette = BrandPalette.of(context);
    final moodTint = MoodDefinitionResolver.tintFor(context, mostCommonMood);
    final moodTextColor = palette.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatCard(
          title: strings.monthlyAverage,
          semanticsLabel: strings.monthlyAverageSemantics(
            _moodLabelFromPath(context, mostCommonMoodPath),
          ),
          fill: moodTint.fill,
          child: Row(
            children: [
              SvgPicture.asset(
                mostCommonMoodPath,
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                semanticsLabel: _moodLabelFromPath(context, mostCommonMoodPath),
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.mood, size: 32, color: moodTextColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.moodRepresentsMonth(
                    _monthName(context, summaryData.month.month),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: moodTextColor,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CategoryDistributionCard(entries: summaryData.entries),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StreakCard(
                  title: strings.currentStreakTitle,
                  semanticsLabel: strings.currentStreakSemantics(currentStreak),
                  days: currentStreak,
                  icon: Icons.local_fire_department_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StreakCard(
                  title: strings.bestStreak,
                  semanticsLabel:
                      strings.bestStreakSemantics(summaryData.bestStreak),
                  days: summaryData.bestStreak,
                  icon: Icons.star_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthName(BuildContext context, int month) {
    final months = AppStrings.of(context).monthNames;
    return months[month - 1];
  }

  String _moodLabelFromPath(BuildContext context, String path) {
    return AppStrings.of(context)
        .moodName(MoodDefinitionResolver.byAssetPath(path).id);
  }
}

/// Bar and legend of the share of each mood category in [entries].
class CategoryDistributionCard extends StatelessWidget {
  const CategoryDistributionCard({super.key, required this.entries});

  final List<MoodEntry> entries;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final shares = CategoryDistribution.compute(entries);
    if (shares.isEmpty) return const SizedBox.shrink();

    final labels = [
      for (final share in shares)
        strings.categoryShareLabel(
          moodCategoryName(strings, share.category),
          share.percent,
        ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              strings.monthSoFarTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            container: true,
            label: strings.categoryDistributionSemantics(labels.join(', ')),
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < shares.length; i++) ...[
                          if (i > 0) const SizedBox(width: 3),
                          Expanded(
                            flex: shares[i].percent,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    palette.tint(shares[i].category.tone).ring,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < shares.length; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: palette.tint(shares[i].category.tone).ring,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            labels[i],
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A glass card with a streak length in days.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.title,
    required this.semanticsLabel,
    required this.days,
    required this.icon,
  });

  final String title;
  final String semanticsLabel;
  final int days;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: palette.text),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textSecondary),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$days',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: palette.text,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    strings.streakDaysUnit(days),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: palette.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? semanticsLabel;

  /// Tint behind the card (the most common mood's category); glass if null.
  final Color? fill;

  const _StatCard({
    required this.title,
    required this.child,
    this.semanticsLabel,
    this.fill,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: GlassCard(
        fill: fill,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.message,
    this.icon = Icons.insights,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, color: palette.text),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
