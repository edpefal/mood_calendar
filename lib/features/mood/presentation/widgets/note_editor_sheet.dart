import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';

const int _noteMaxLength = 500;

/// Opens the expanded note editor as a bottom sheet. Edits [controller]
/// live - there is no separate draft state, the same controller is read
/// back by the caller when the mood entry is saved.
Future<void> showNoteEditorSheet(
  BuildContext context, {
  required TextEditingController controller,
  required Color accentColor,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _NoteEditorSheetContent(
      controller: controller,
      accentColor: accentColor,
    ),
  );
}

class _NoteEditorSheetContent extends StatelessWidget {
  const _NoteEditorSheetContent({
    required this.controller,
    required this.accentColor,
  });

  final TextEditingController controller;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        strings.noteSheetTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: strings.noteSheetDoneButton,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          strings.noteSheetDoneButton,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        return Text(
                          '$currentLength/$maxLength',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: strings.noteSheetPlaceholder,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: accentColor,
                            width: 2,
                          ),
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
