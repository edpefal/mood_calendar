import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/phone_column.dart';
import '../../../mood/domain/entities/monthly_mood_summary.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/services/mood_streak_calculator.dart';
import '../../../mood/presentation/bloc/mood_cubit.dart';
import '../../../mood/presentation/widgets/day_detail_sheet.dart';
import '../../../mood/presentation/widgets/monthly_mood_summary_card.dart';
import '../../../purchases/presentation/bloc/purchases_cubit.dart';
import '../../../purchases/presentation/widgets/premium_sheet.dart';
import '../../domain/services/trend_calculator.dart';
import '../../domain/services/weekday_profile.dart';
import '../../domain/services/year_pixels.dart';
import '../widgets/insight_previews.dart';
import '../widgets/locked_insight_card.dart';
import '../widgets/trend_card.dart';
import '../widgets/weekday_card.dart';
import '../widgets/year_pixels_card.dart';

/// The Insights tab: the month so far, the streaks, the trend, the mood by
/// day of the week and Year in Pixels. Everything is computed here from the
/// entries the [MoodCubit] already holds; nothing leaves the device.
///
/// The summary, the streaks and the 7 and 30 day trend are free; the longer
/// trends, the weekday card and Year in Pixels need the subscription. A user
/// without it sees those cards blurred with "See with Premium".
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({
    super.key,
    this.scrollToYear = false,
    this.onEditEntry,
    this.clock,
  });

  /// Scrolls to Year in Pixels once built (the calendar's "view year").
  final bool scrollToYear;

  /// "Edit" of a day opened from Year in Pixels: sends the user to the Log.
  final ValueChanged<DateTime>? onEditEntry;

  /// Today, injectable for tests.
  final DateTime Function()? clock;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final GlobalKey _yearKey = GlobalKey();

  List<MoodEntry> _entries = const [];
  bool _hydrated = false;
  TrendRange _range = TrendRange.days7;
  late int _year = _today.year;

  DateTime get _today => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToYear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _yearKey.currentContext;
        if (context != null && context.mounted) {
          Scrollable.ensureVisible(
            context,
            duration: Duration.zero,
            alignment: 0.05,
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _onMoodState(context.read<MoodCubit>().state);
    _hydrated = true;
  }

  void _onMoodState(MoodState state) {
    state.maybeWhen(
      loaded: (entries) {
        if (_hydrated) {
          setState(() => _entries = entries);
        } else {
          _entries = entries;
        }
      },
      orElse: () {},
    );
  }

  void _openPremium() {
    showPremiumSheet(context, source: PremiumSource.insights);
  }

  void _onRangeSelected(TrendRange range, bool isPremium) {
    if (range.requiresPremium && !isPremium) {
      _openPremium();
      return;
    }
    setState(() => _range = range);
  }

  void _openDay(MoodEntry entry) {
    showDayDetailSheet(
      context,
      entry: entry,
      onEdit: () => widget.onEditEntry?.call(entry.date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final isPremium = context.select<PurchasesCubit, bool>(
      (cubit) => cubit.state.subscription.isActive,
    );

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            strings.tabInsights,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        body: SafeArea(
          child: BlocListener<MoodCubit, MoodState>(
            listener: (context, state) => _onMoodState(state),
            child: PhoneColumn(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _entries.isEmpty
                    ? const _EmptyInsights()
                    : _content(context, strings, palette, isPremium),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    AppStrings strings,
    BrandPalette palette,
    bool isPremium,
  ) {
    final today = _today;
    final monthEntries = [
      for (final e in _entries)
        if (e.date.year == today.year && e.date.month == today.month) e,
    ];
    final summary = MonthlyMoodSummary.fromEntries(today, monthEntries);
    final dates = [for (final e in _entries) e.date];
    final years = YearPixels.yearsWithEntries(_entries, today);
    final year = years.contains(_year) ? _year : today.year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  strings
                      .insightsMonthTitle(strings.monthNames[today.month - 1]),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.text,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
            Text(
              strings.insightsEntriesCount(monthEntries.length),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MonthlyMoodSummaryCard(
          summary: summary,
          currentStreak: MoodStreakCalculator.currentStreakAsOf(dates, today),
        ),
        const SizedBox(height: 16),
        TrendCard(
          result: TrendCalculator.compute(_entries, _range, today),
          range: _range,
          isPremium: isPremium,
          onRangeSelected: (range) => _onRangeSelected(range, isPremium),
        ),
        const SizedBox(height: 16),
        if (isPremium)
          WeekdayCard(profile: WeekdayProfile.compute(_entries))
        else
          LockedInsightCard(
            title: strings.weekdayTitle,
            preview: const SampleBarsPreview(),
            onUnlock: _openPremium,
          ),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: _yearKey,
          child: isPremium
              ? YearPixelsCard(
                  year: year,
                  years: years,
                  days: YearPixels.compute(_entries, year, today),
                  onYearChanged: (value) => setState(() => _year = value),
                  onDayTap: _openDay,
                )
              : LockedInsightCard(
                  title: strings.yearInPixelsTitle(today.year),
                  preview: const SamplePixelsPreview(),
                  onUnlock: _openPremium,
                ),
        ),
      ],
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  const _EmptyInsights();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: palette.textSecondary),
          const SizedBox(height: 16),
          Text(
            strings.insightsEmptyTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.insightsEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
