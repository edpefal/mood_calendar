import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../domain/entities/mood_definition.dart';
import '../../domain/services/mood_definition_resolver.dart';

const int _noteMaxLength = 500;

/// Opens the expanded note editor as a bottom sheet. Edits [controller]
/// live - there is no separate draft state, the same controller is read
/// back by the caller when the mood entry is saved. [mood] (if any) is shown
/// at the top and tints the sheet with its category.
Future<void> showNoteEditorSheet(
  BuildContext context, {
  required TextEditingController controller,
  MoodDefinition? mood,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _NoteEditorSheetContent(
      controller: controller,
      mood: mood,
    ),
  );
}

class _NoteEditorSheetContent extends StatelessWidget {
  const _NoteEditorSheetContent({
    required this.controller,
    required this.mood,
  });

  final TextEditingController controller;
  final MoodDefinition? mood;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    final tint =
        mood == null ? null : MoodDefinitionResolver.tintFor(context, mood!);
    final accent = tint?.ring ?? palette.ink;

    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        child: SizedBox(
          // Subtract the keyboard inset (rather than just padding it below)
          // so the sheet shrinks instead of being pushed up past the safe
          // area when the keyboard opens — otherwise the title row ends up
          // under the status bar/notch.
          height: mediaQuery.size.height * 0.85 - keyboardInset,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  decoration: BoxDecoration(
                    color: tint?.fill ?? palette.glassFill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (mood != null) ...[
                        SvgPicture.asset(
                          mood!.assetPath,
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          mood == null
                              ? strings.noteSheetTitle
                              : strings.moodName(mood!.id),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: palette.text,
                                  ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: strings.noteSheetDoneButton,
                        onTap: () => Navigator.of(context).pop(),
                        excludeSemantics: true,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(64, 44),
                            foregroundColor: palette.text,
                          ),
                          child: Text(
                            strings.noteSheetDoneButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Semantics(
                    textField: true,
                    label: strings.noteSheetTitle,
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      maxLength: _noteMaxLength,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(color: palette.text),
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return Text(
                          '$currentLength/$maxLength',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: palette.textSecondary),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: strings.noteSheetPlaceholder,
                        hintStyle: TextStyle(color: palette.textSecondary),
                        filled: true,
                        fillColor:
                            palette.isDark ? palette.glassFill : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
