import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/monthly_mood_summary.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class MonthlyMoodSummaryCard extends StatelessWidget {
  final MonthlyMoodSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  const MonthlyMoodSummaryCard({
    super.key,
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
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
        _StatCard(
          title: strings.bestStreak,
          semanticsLabel: strings.bestStreakSemantics(summaryData.bestStreak),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 32,
                color: palette.text,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.streakText(summaryData.bestStreak),
                  style: Theme.of(context).textTheme.bodyMedium,
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
