import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';

/// Lets the user jump to any month up to [today]'s. Returns the first day of
/// the chosen month, or null when the sheet is dismissed.
Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required DateTime visibleMonth,
  required DateTime today,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        _MonthPickerContent(visibleMonth: visibleMonth, today: today),
  );
}

class _MonthPickerContent extends StatefulWidget {
  const _MonthPickerContent({required this.visibleMonth, required this.today});

  final DateTime visibleMonth;
  final DateTime today;

  @override
  State<_MonthPickerContent> createState() => _MonthPickerContentState();
}

class _MonthPickerContentState extends State<_MonthPickerContent> {
  late int _year = widget.visibleMonth.year;

  bool _isFuture(int year, int month) =>
      year > widget.today.year ||
      (year == widget.today.year && month > widget.today.month);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final canGoNext = _year < widget.today.year;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                strings.chooseMonthYearLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.text,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: strings.previousYearTooltip,
                  icon: Icon(Icons.chevron_left_rounded, color: palette.text),
                  onPressed: () => setState(() => _year--),
                ),
                Text(
                  '$_year',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: palette.text,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  tooltip: strings.nextYearTooltip,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: canGoNext
                        ? palette.text
                        : palette.textSecondary.withValues(alpha: 0.5),
                  ),
                  onPressed: canGoNext ? () => setState(() => _year++) : null,
                ),
              ],
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (var month = 1; month <= 12; month++)
                  _MonthButton(
                    label: strings.monthNames[month - 1],
                    selected: _year == widget.visibleMonth.year &&
                        month == widget.visibleMonth.month,
                    enabled: !_isFuture(_year, month),
                    onTap: () =>
                        Navigator.of(context).pop(DateTime(_year, month)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? palette.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.glassBorder),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? palette.onInk
                      : enabled
                          ? palette.text
                          : palette.textSecondary.withValues(alpha: 0.5),
                ),
          ),
        ),
      ),
    );
  }
}
