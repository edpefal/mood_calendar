import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../cubit/onboarding_state.dart';
import 'onboarding_frame.dart';

/// Step 2: when to check in. Three suggested times and a wheel; picking a
/// suggestion moves the wheel and moving the wheel clears the suggestion.
class ReminderTimeStep extends StatefulWidget {
  const ReminderTimeStep({
    super.key,
    required this.state,
    required this.onSuggestion,
    required this.onTimeChanged,
    required this.onContinue,
    required this.onSkip,
  });

  final OnboardingState state;
  final ValueChanged<ReminderSuggestion> onSuggestion;
  final void Function(int hour, int minute) onTimeChanged;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  State<ReminderTimeStep> createState() => _ReminderTimeStepState();
}

class _ReminderTimeStepState extends State<ReminderTimeStep> {
  /// Changes only when a suggestion is tapped, to rebuild the wheel at its
  /// time; moving the wheel by hand must not rebuild it mid-scroll.
  int _wheelEpoch = 0;

  String _suggestionName(AppStrings strings, ReminderSuggestion suggestion) {
    switch (suggestion) {
      case ReminderSuggestion.morning:
        return strings.onboardingMorning;
      case ReminderSuggestion.afternoon:
        return strings.onboardingAfternoon;
      case ReminderSuggestion.night:
        return strings.onboardingNight;
    }
  }

  /// Three pills side by side only while the names fit: with large system
  /// text each one is a third of the width and its name ("Afternoon") is cut,
  /// so they stack at full width instead.
  Widget _suggestionPills(
    BuildContext context,
    AppStrings strings,
    OnboardingState state,
  ) {
    final stacked = MediaQuery.textScalerOf(context).scale(14) / 14 > 1.3;
    final pills = [
      for (final suggestion in ReminderSuggestion.values)
        _SuggestionPill(
          name: _suggestionName(strings, suggestion),
          time: TimeOfDay(hour: suggestion.hour, minute: suggestion.minute)
              .format(context),
          selected: state.suggestion == suggestion,
          onTap: () {
            setState(() => _wheelEpoch++);
            widget.onSuggestion(suggestion);
          },
        ),
    ];
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final pill in pills) ...[
            if (pill != pills.first) const SizedBox(height: 8),
            pill,
          ],
        ],
      );
    }
    return Row(
      children: [
        for (final pill in pills) ...[
          if (pill != pills.first) const SizedBox(width: 8),
          Expanded(child: pill),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final state = widget.state;
    final selectedTime = TimeOfDay(hour: state.hour, minute: state.minute);

    return OnboardingFrame(
      step: 2,
      onSkip: widget.onSkip,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingTitleCard(
            title: strings.onboardingTimeTitle,
            body: strings.onboardingTimeBody,
          ),
          const SizedBox(height: 16),
          _suggestionPills(context, strings, state),
          const SizedBox(height: 16),
          Semantics(
            label: strings
                .onboardingTimePickerSemantics(selectedTime.format(context)),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: palette.brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle:
                          TextStyle(fontSize: 22, color: palette.text),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    key: ValueKey(_wheelEpoch),
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
                    initialDateTime:
                        DateTime(2000, 1, 1, state.hour, state.minute),
                    onDateTimeChanged: (value) =>
                        widget.onTimeChanged(value.hour, value.minute),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: GradientPillButton(
        label: strings.continueLabel,
        onPressed: widget.onContinue,
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({
    required this.name,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String time;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final strings = AppStrings.of(context);
    final foreground = selected ? palette.onInk : palette.text;
    return Semantics(
      button: true,
      selected: selected,
      label: strings.onboardingTimeSuggestionSemantics(name, time),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? palette.ink : palette.glassFill,
            border: selected ? null : Border.all(color: palette.glassBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 12, height: 16 / 12, color: foreground),
              ),
              Text(
                time,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
