import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/settings/domain/entities/app_settings.dart';
import '../../../../core/settings/domain/repositories/app_settings_repository.dart';
import '../../domain/services/mood_definition_resolver.dart';
import '../bloc/calendar_cubit.dart';
import '../widgets/monthly_mood_summary_card.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? recentlySavedDate;

  const CalendarScreen({super.key, this.recentlySavedDate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late AnimationController _animationController;
  DateTime? _recentlySavedDate;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _recentlySavedDate = widget.recentlySavedDate;
    if (_recentlySavedDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!mounted) return;
    _animationController.repeat(reverse: true);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          _recentlySavedDate = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, state) {
            final now = _focusedDay;
            final today = DateTime.now();
            final canGoNext = now.year < today.year ||
                (now.year == today.year && now.month < today.month);
            final firstDayOfMonth = DateTime(now.year, now.month, 1);
            final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
            final daysInMonth = lastDayOfMonth.day;
            final firstWeekday = firstDayOfMonth.weekday;

            final entries = state.summary?.entries ?? [];
            final moodMap = <String, String>{};
            for (final mood in entries) {
              moodMap[_dateKey(mood.date)] = mood.mood;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CalendarHeader(
                              month: now.month,
                              year: now.year,
                              onPreviousMonth: _onPreviousMonth,
                              onNextMonth: canGoNext ? _onNextMonth : null,
                              onOpenReminderSettings:
                                  _openReminderSettingsSheet,
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
                              itemCount: daysInMonth + (firstWeekday - 1),
                              itemBuilder: (context, index) {
                                if (index < firstWeekday - 1) {
                                  return const SizedBox.shrink();
                                }
                                final day = index - (firstWeekday - 2);
                                final date = DateTime(now.year, now.month, day);
                                final isFutureDate = date.year > today.year ||
                                    (date.year == today.year &&
                                        date.month > today.month) ||
                                    (date.year == today.year &&
                                        date.month == today.month &&
                                        date.day > today.day);
                                final key = _dateKey(date);
                                final moodPath = moodMap[key];
                                final moodColor = moodPath != null
                                    ? _colorForMoodPath(moodPath)
                                    : null;
                                final moodLabel = moodPath == null
                                    ? null
                                    : _moodLabelForPath(context, moodPath);
                                final isRecentlySaved =
                                    _recentlySavedDate != null &&
                                        _dateKey(_recentlySavedDate!) == key;

                                return Semantics(
                                  button: !isFutureDate,
                                  enabled: !isFutureDate,
                                  label: strings.calendarDayLabel(
                                    formattedDate: _formatCalendarDate(
                                      context,
                                      date,
                                    ),
                                    moodLabel: moodLabel,
                                    isFutureDate: isFutureDate,
                                  ),
                                  child: GestureDetector(
                                    onTap: isFutureDate
                                        ? null
                                        : () async {
                                            final calendarCubit =
                                                context.read<CalendarCubit>();
                                            final result = await AppNavigator
                                                .pushMoodScreen(
                                              context,
                                              selectedDate: date,
                                            );
                                            if (!mounted) {
                                              return;
                                            }
                                            await calendarCubit.refreshForDate(
                                              result ?? date,
                                            );
                                            if (result != null) {
                                              setState(() {
                                                _recentlySavedDate = result;
                                              });
                                              _startAnimation();
                                            }
                                          },
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 44,
                                        minWidth: 44,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isFutureDate
                                            ? Colors.grey[100]
                                            : moodColor?.withValues(
                                                    alpha: 0.15) ??
                                                Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isFutureDate
                                              ? Colors.grey[200]!
                                              : moodColor ?? Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$day',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isFutureDate
                                                    ? Colors.grey[500]
                                                    : moodColor,
                                              ),
                                            ),
                                            if (moodPath != null)
                                              _AnimatedMoodIcon(
                                                animation: _animationController,
                                                isAnimated: isRecentlySaved,
                                                emojiPath: moodPath,
                                                semanticsLabel: moodLabel!,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    MonthlyMoodSummaryCard(
                      summary: state.summary,
                      isLoading: state.isLoading,
                      errorMessage:
                          state.error == null ? null : strings.summaryLoadError,
                    ),
                  ],
                ),
              ),
            );
          },
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
    final today = DateTime.now();
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

  Future<void> _openReminderSettingsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _ReminderSettingsSheet(),
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatCalendarDate(BuildContext context, DateTime date) {
    final strings = AppStrings.of(context);
    return '${date.day} ${strings.monthNames[date.month - 1]} ${date.year}';
  }

  String _moodLabelForPath(BuildContext context, String path) {
    return MoodDefinitionResolver.byAssetPath(path).label;
  }

  Color? _colorForMoodPath(String path) {
    return MoodDefinitionResolver.colorForMoodPath(path);
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF2C46D)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF9A6700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A4D00),
                  ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
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
  final VoidCallback onOpenReminderSettings;

  const _CalendarHeader({
    required this.month,
    required this.year,
    required this.onPreviousMonth,
    required this.onOpenReminderSettings,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final months = [''] + strings.monthNames;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: 36,
          tooltip: strings.previousMonthTooltip,
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF5F3DC4),
          ),
          onPressed: onPreviousMonth,
        ),
        Text(
          '${months[month]} $year',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF5F3DC4),
                fontWeight: FontWeight.w700,
              ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: strings.reminderSettingsTooltip,
              icon: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFF5F3DC4),
              ),
              onPressed: onOpenReminderSettings,
            ),
            IconButton(
              iconSize: 36,
              tooltip: strings.nextMonthTooltip,
              icon: Icon(
                Icons.chevron_right_rounded,
                color: onNextMonth == null
                    ? Colors.grey[400]
                    : const Color(0xFF5F3DC4),
              ),
              onPressed: onNextMonth,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReminderSettingsSheet extends StatefulWidget {
  const _ReminderSettingsSheet();

  @override
  State<_ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends State<_ReminderSettingsSheet> {
  bool _isLoading = true;
  bool _isSaving = false;
  late bool _remindersEnabled;
  late TimeOfDay _selectedTime;

  AppSettingsRepository get _settingsRepository =>
      context.read<AppSettingsRepository>();

  LocalNotificationService get _notificationService =>
      context.read<LocalNotificationService>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.getSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _remindersEnabled = settings.dailyReminderEnabled;
      _selectedTime = TimeOfDay(
        hour: settings.dailyReminderHour,
        minute: settings.dailyReminderMinute,
      );
      _isLoading = false;
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime == null || !mounted) {
      return;
    }
    setState(() {
      _selectedTime = pickedTime;
    });
  }

  Future<void> _saveSettings() async {
    final strings = AppStrings.of(context);
    setState(() {
      _isSaving = true;
    });

    final updatedSettings = AppSettings(
      dailyReminderEnabled: _remindersEnabled,
      dailyReminderHour: _selectedTime.hour,
      dailyReminderMinute: _selectedTime.minute,
    );

    await _settingsRepository.saveSettings(updatedSettings);
    if (updatedSettings.dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelDailyReminder();
    }

    if (!mounted) {
      return;
    }

    final timeText = _selectedTime.format(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedSettings.dailyReminderEnabled
              ? strings.reminderSavedAt(timeText)
              : strings.remindersTurnedOff,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.reminderSheetTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.reminderSheetDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _remindersEnabled,
                    title: Text(strings.reminderEnabledTitle),
                    subtitle: Text(strings.reminderEnabledSubtitle),
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _remindersEnabled = value;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.reminderTimeTitle),
                    subtitle: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time_rounded),
                    onTap: _isSaving || !_remindersEnabled ? null : _pickTime,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    child: Text(strings.saveReminderSettings),
                  ),
                ],
              ),
      ),
    );
  }
}

class _WeekDaysRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final days = AppStrings.of(context).weekdayInitials;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AnimatedMoodIcon extends StatelessWidget {
  final Animation<double> animation;
  final bool isAnimated;
  final String emojiPath;
  final String semanticsLabel;

  const _AnimatedMoodIcon({
    required this.animation,
    required this.isAnimated,
    required this.emojiPath,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = isAnimated ? 1.0 + (animation.value * 0.9) : 1.0;
        final rotation = isAnimated ? (animation.value * 0.2) : 0.0;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: SvgPicture.asset(
              emojiPath,
              height: 22,
              width: 22,
              fit: BoxFit.contain,
              semanticsLabel: semanticsLabel,
              placeholderBuilder: (context) => const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error_outline,
                  size: 24,
                  color: Colors.red,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
