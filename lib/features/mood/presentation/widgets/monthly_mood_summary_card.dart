import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/monthly_mood_summary.dart';

class MonthlyMoodSummaryCard extends StatelessWidget {
  final MonthlyMoodSummary? summary;

  const MonthlyMoodSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final summaryData = summary;
    if (summaryData == null || summaryData.entries.isEmpty) {
      return _EmptyState(message: 'Aún no hay registros este mes. Empieza hoy ■');
    }

    final spots = summaryData.entries
        .map(
          (entry) => FlSpot(
            entry.date.day.toDouble(),
            entry.intensity.toDouble(),
          ),
        )
        .toList();

    final lastEntry = summaryData.lastEntry;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de ${_monthName(summaryData.month.month)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: _daysInMonth(summaryData.month).toDouble(),
                  minY: 1,
                  maxY: 5,
                  gridData: FlGridData(show: true, horizontalInterval: 1),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          const emojis = ['😞', '🙁', '😐', '🙂', '😄'];
                          if (value % 1 != 0 || value < 1 || value > 5) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            emojis[value.toInt() - 1],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 7,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineTouchData: LineTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final isLast = lastEntry != null &&
                              spot.x == lastEntry.date.day.toDouble() &&
                              spot.y == lastEntry.intensity.toDouble();
                          return FlDotCirclePainter(
                            radius: isLast ? 5 : 3,
                            color: isLast ? Colors.deepPurple : Colors.white,
                            strokeColor: Colors.deepPurple,
                            strokeWidth: isLast ? 3 : 1.5,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Promedio del mes',
              value:
                  '${_emojiForScore(summaryData.averageScore)} ${summaryData.averageScore.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Mejor racha',
              value:
                  '${summaryData.bestStreak} día${summaryData.bestStreak == 1 ? '' : 's'} seguidos registrando tu ánimo',
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month];
  }

  int _daysInMonth(DateTime month) {
    final beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1)).day;
  }

  String _emojiForScore(double score) {
    if (score >= 4.5) return '😄';
    if (score >= 3.5) return '🙂';
    if (score >= 2.5) return '😐';
    if (score >= 1.5) return '🙁';
    return '😞';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

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
            const Icon(Icons.insights, color: Colors.deepPurple),
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
