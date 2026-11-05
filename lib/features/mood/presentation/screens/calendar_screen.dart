import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/phone_column.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../bloc/calendar_cubit.dart';
import '../widgets/monthly_mood_summary_card.dart';

class CalendarScreen extends StatefulWidget {
  /// Se llama con el día que el usuario toca (nunca uno futuro).
  final ValueChanged<DateTime> onDaySelected;

  /// Hoy, inyectable para las pruebas.
  final DateTime Function()? clock;

  const CalendarScreen({super.key, required this.onDaySelected, this.clock});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;

  DateTime get _today => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _focusedDay = _today;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            strings.calendarTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<CalendarCubit, CalendarState>(
            builder: (context, state) {
              final now = _focusedDay;
              final today = _today;
              final canGoNext = now.year < today.year ||
                  (now.year == today.year && now.month < today.month);
              final firstDayOfMonth = DateTime(now.year, now.month, 1);
              final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
              final daysInMonth = lastDayOfMonth.day;
              // Sunday-indexed (0=Sunday..6=Saturday) to match the Sunday-first
              // week header; DateTime.weekday is Monday-indexed (1=Monday..7=Sunday).
              final firstWeekday = firstDayOfMonth.weekday % 7;

              final entries = state.summary?.entries ?? [];
              final moodMap = <String, String>{};
              for (final mood in entries) {
                moodMap[_dateKey(mood.date)] = mood.mood;
              }

              return PhoneColumn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        GlassCard(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _CalendarHeader(
                                month: now.month,
                                year: now.year,
                                onPreviousMonth: _onPreviousMonth,
                                onNextMonth: canGoNext ? _onNextMonth : null,
                              ),
                              if (state.isLoading)
                                const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: LinearProgressIndicator(minHeight: 3),
                                ),
                              if (state.error != null) ...[
                                const SizedBox(height: 12),
                                _CalendarFeedbackBanner(
                                  message: strings.loadingMonthError,
                                  actionLabel: strings.retry,
                                  onPressed: () {
                                    context.read<CalendarCubit>().refresh();
                                  },
                                ),
                              ],
                              const SizedBox(height: 12),
                              _WeekDaysRow(),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: daysInMonth + firstWeekday,
                                itemBuilder: (context, index) {
                                  if (index < firstWeekday) {
                                    return const SizedBox.shrink();
                                  }
                                  final day = index - firstWeekday + 1;
                                  final date =
                                      DateTime(now.year, now.month, day);
                                  final isFutureDate = date.isAfter(
                                    DateTime(
                                        today.year, today.month, today.day),
                                  );
                                  final moodPath = moodMap[_dateKey(date)];
                                  return _DayCell(
                                    day: day,
                                    date: date,
                                    isFutureDate: isFutureDate,
                                    moodPath: moodPath,
                                    onTap: () => widget.onDaySelected(date),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        MonthlyMoodSummaryCard(
                          summary: state.summary,
                          isLoading: state.isLoading,
                          errorMessage: state.error == null
                              ? null
                              : strings.summaryLoadError,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
    context.read<CalendarCubit>().loadMonth(_focusedDay);
  }

  void _onNextMonth() {
    final today = _today;
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);

    if (nextMonth.year > today.year ||
        (nextMonth.year == today.year && nextMonth.month > today.month)) {
      return;
    }
    setState(() {
      _focusedDay = nextMonth;
    });
    context.read<CalendarCubit>().loadMonth(_focusedDay);
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.isFutureDate,
    required this.moodPath,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final bool isFutureDate;
  final String? moodPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final path = moodPath;
    final tint = path == null
        ? null
        : MoodDefinitionResolver.tintForMoodPath(context, path);
    final moodLabel = path == null
        ? null
        : strings.moodName(MoodDefinitionResolver.byAssetPath(path).id);

    return Semantics(
      button: !isFutureDate,
      enabled: !isFutureDate,
      label: strings.calendarDayLabel(
        formattedDate: strings.formatFullDate(date),
        moodLabel: moodLabel,
        isFutureDate: isFutureDate,
      ),
      onTap: isFutureDate ? null : onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isFutureDate ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          decoration: BoxDecoration(
            color: isFutureDate
                ? Colors.transparent
                : tint?.fill ?? palette.text.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFutureDate
                  ? palette.glassBorder
                  : tint?.ring.withValues(alpha: 0.55) ?? Colors.transparent,
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isFutureDate
                          ? palette.textSecondary.withValues(alpha: 0.6)
                          : palette.text,
                    ),
                  ),
                  if (path != null)
                    SvgPicture.asset(
                      path,
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      semanticsLabel: moodLabel,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.error_outline,
                        size: 24,
                        color: palette.danger,
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

class _CalendarFeedbackBanner extends StatelessWidget {
  const _CalendarFeedbackBanner({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.positive.fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.positive.ring),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: palette.positive.ring),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(foregroundColor: palette.text),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPreviousMonth;
  final VoidCallback? onNextMonth;

  const _CalendarHeader({
    required this.month,
    required this.year,
    required this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final months = [''] + strings.monthNames;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: 36,
          tooltip: strings.previousMonthTooltip,
          icon: Icon(Icons.chevron_left_rounded, color: palette.text),
          onPressed: onPreviousMonth,
        ),
        Expanded(
          child: Text(
            '${months[month]} $year',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        IconButton(
          iconSize: 36,
          tooltip: strings.nextMonthTooltip,
          icon: Icon(
            Icons.chevron_right_rounded,
            color: onNextMonth == null
                ? palette.textSecondary.withValues(alpha: 0.5)
                : palette.text,
          ),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = AppStrings.of(context).weekdayInitials;
    final palette = BrandPalette.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: palette.textSecondary),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
