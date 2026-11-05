import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/widgets/gradient_pill_button.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/services/logged_time.dart';
import '../../domain/services/mood_definition_resolver.dart';
import 'logged_time_text.dart';
import 'mood_category_grid.dart';

/// Opens the detail of a day that has an entry: its mood, category, the time
/// it was logged (only when it was logged that same day), the note and Edit.
///
/// [onEdit] runs after the sheet closes; the caller sends the user to the Log
/// with the grid already editing that entry.
Future<void> showDayDetailSheet(
  BuildContext context, {
  required MoodEntry entry,
  required VoidCallback onEdit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => DayDetailSheet(
      entry: entry,
      onEdit: () {
        Navigator.of(sheetContext).pop();
        onEdit();
      },
    ),
  );
}

class DayDetailSheet extends StatelessWidget {
  const DayDetailSheet({super.key, required this.entry, required this.onEdit});

  final MoodEntry entry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final mood = MoodDefinitionResolver.byAssetPath(entry.mood);
    final tint = MoodDefinitionResolver.tintFor(context, mood);
    final moodName = strings.moodName(mood.id);
    final category = moodCategoryName(strings, mood.category);
    final time = loggedTimeFor(entry);
    final note = entry.note?.trim() ?? '';
    final date = strings.formatFullDate(entry.date);

    return Semantics(
      container: true,
      label: strings.dayDetailSemantics(date),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      date,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: palette.text,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.closeLabel,
                    icon: Icon(Icons.close_rounded, color: palette.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tint.fill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        entry.mood,
                        width: 46,
                        height: 46,
                        semanticsLabel: moodName,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            moodName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: palette.text,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            time == null
                                ? category
                                : strings.dayDetailCategoryAndTime(
                                    category,
                                    formatLoggedTime(context, time),
                                  ),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: palette.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.dayDetailNoteTitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                note.isEmpty ? strings.noNoteYet : note,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          note.isEmpty ? palette.textSecondary : palette.text,
                    ),
              ),
              const SizedBox(height: 20),
              GradientPillButton(
                label: strings.editEntryButton,
                semanticsLabel: strings.editEntryButton,
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
