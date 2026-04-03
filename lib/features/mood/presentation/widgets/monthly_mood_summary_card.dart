import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/monthly_mood_summary.dart';
import '../../domain/services/mood_definition_resolver.dart';

class MonthlyMoodSummaryCard extends StatefulWidget {
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
  State<MonthlyMoodSummaryCard> createState() => _MonthlyMoodSummaryCardState();
}

class _MonthlyMoodSummaryCardState extends State<MonthlyMoodSummaryCard> {
  Offset? _tooltipLocalOffset;
  String? _tooltipMoodPath;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final summaryData = widget.summary;
    if (widget.isLoading &&
        (summaryData == null || summaryData.entries.isEmpty)) {
      return _EmptyState(
        message: strings.loadingSummary,
        icon: Icons.hourglass_top_rounded,
      );
    }
    if (widget.errorMessage != null &&
        (summaryData == null || summaryData.entries.isEmpty)) {
      return _EmptyState(
        message: widget.errorMessage!,
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
        _buildChartCard(context, summaryData),
        const SizedBox(height: 16),
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

  Widget _buildChartCard(BuildContext context, MonthlyMoodSummary summaryData) {
    final strings = AppStrings.of(context);
    final spots = summaryData.entries
        .map(
          (entry) => FlSpot(
            entry.date.day.toDouble(),
            (6 - entry.intensity).toDouble(),
          ),
        )
        .toList();
    final lastEntry = summaryData.lastEntry;
    final entriesByDay = {
      for (final entry in summaryData.entries) entry.date.day: entry,
    };

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5F3DC4),
              Color(0xFF6C63FF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.summaryTitle(
                  _monthName(context, summaryData.month.month),
                ),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: Semantics(
                  label: strings.monthlyChartSemantics,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ExcludeSemantics(
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            maxX: _daysInMonth(summaryData.month).toDouble(),
                            minY: 1,
                            maxY: 5,
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => const FlLine(
                                color: Colors.white24,
                                strokeWidth: 1,
                              ),
                              drawVerticalLine: false,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final y = value.round();
                                    if (y < 1 || y > 5) {
                                      return const SizedBox.shrink();
                                    }
                                    final path =
                                        MoodDefinitionResolver.byIntensity(
                                                6 - y)
                                            .assetPath;
                                    return SvgPicture.asset(
                                      path,
                                      height: 22,
                                      width: 22,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) =>
                                          const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.mood, size: 22),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 7,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 != 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (event, response) {
                                if (response?.lineBarSpots != null &&
                                    response!.lineBarSpots!.isNotEmpty) {
                                  final spot = response.lineBarSpots!.first;
                                  setState(() {
                                    _tooltipLocalOffset = event.localPosition;
                                    _tooltipMoodPath =
                                        entriesByDay[spot.x.toInt()]?.mood;
                                  });
                                } else {
                                  setState(() {
                                    _tooltipLocalOffset = null;
                                    _tooltipMoodPath = null;
                                  });
                                }
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Colors.white,
                                barWidth: 3,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    final isLast = lastEntry != null &&
                                        spot.x ==
                                            lastEntry.date.day.toDouble() &&
                                        spot.y ==
                                            (6 - lastEntry.intensity)
                                                .toDouble();
                                    return FlDotCirclePainter(
                                      radius: isLast ? 5 : 3,
                                      color: Colors.white,
                                      strokeColor: isLast
                                          ? Colors.white
                                          : Colors.white70,
                                      strokeWidth: isLast ? 3 : 1.5,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_tooltipLocalOffset != null &&
                          _tooltipMoodPath != null)
                        _MoodTooltipOverlay(
                          localOffset: _tooltipLocalOffset!,
                          moodPath: _tooltipMoodPath!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(BuildContext context, int month) {
    final months = AppStrings.of(context).monthNames;
    return months[month - 1];
  }

  int _daysInMonth(DateTime month) {
    final beginningNextMonth = month.month < 12
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  String _moodLabelFromPath(BuildContext context, String path) {
    return MoodDefinitionResolver.byAssetPath(path).label;
  }
}

class _MoodTooltipOverlay extends StatelessWidget {
  final Offset localOffset;
  final String moodPath;

  const _MoodTooltipOverlay({
    required this.localOffset,
    required this.moodPath,
  });

  @override
  Widget build(BuildContext context) {
    const tooltipSize = 44.0;
    const iconSize = 36.0;
    return Positioned(
      left: localOffset.dx - tooltipSize / 2,
      top: localOffset.dy - tooltipSize - 12,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(tooltipSize / 2),
        color: Colors.grey.shade800,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SvgPicture.asset(
            moodPath,
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.mood, size: iconSize, color: Colors.white),
          ),
        ),
      ),
    );
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
