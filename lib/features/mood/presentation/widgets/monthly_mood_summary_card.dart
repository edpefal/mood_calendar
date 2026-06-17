import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/monthly_mood_summary.dart';
import '../../domain/services/mood_definition_resolver.dart';

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

    final representativeMoodPath =
        summaryData.representativeAverageEntry?.mood ??
            MoodDefinitionResolver.moodPathForScore(summaryData.averageScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatCard(
          title: strings.monthlyAverage,
          semanticsLabel: strings.monthlyAverageSemantics(
            _moodLabelFromPath(context, representativeMoodPath),
          ),
          highlight: true,
          child: Row(
            children: [
              SvgPicture.asset(
                representativeMoodPath,
                height: 32,
                width: 32,
                fit: BoxFit.contain,
                semanticsLabel:
                    _moodLabelFromPath(context, representativeMoodPath),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.mood, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.moodRepresentsMonth(
                    _monthName(context, summaryData.month.month),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
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
          highlight: true,
          child: Text(
            strings.streakText(summaryData.bestStreak),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
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
    return MoodDefinitionResolver.byAssetPath(path).label;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool highlight;
  final String? semanticsLabel;

  const _StatCard({
    required this.title,
    required this.child,
    this.highlight = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: highlight ? Colors.white : null,
        );

    return Semantics(
      label: semanticsLabel,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        color: highlight ? Colors.transparent : null,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: Container(
          decoration: highlight
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5F3DC4),
                      Color(0xFF6C63FF),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
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
    return Card(
      elevation: 0,
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
