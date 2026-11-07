import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../bloc/note_lock_cubit.dart';
import '../bloc/note_lock_state.dart';

/// The text of a saved note, or a "Note locked" marker while the note lock is
/// on and the session is not unlocked. Every screen that shows note text goes
/// through here, so none decides on its own whether the text may be seen.
class NoteText extends StatelessWidget {
  const NoteText(this.text, {super.key, this.style, this.maxLines});

  final String text;
  final TextStyle? style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteLockCubit, NoteLockState>(
      buildWhen: (previous, current) => previous.conceals != current.conceals,
      builder: (context, state) {
        if (!state.conceals) {
          return Text(
            text,
            style: style,
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
          );
        }
        return const LockedNoteMarker();
      },
    );
  }
}

/// "Note locked · Unlock": tapping it asks the system to authenticate.
class LockedNoteMarker extends StatelessWidget {
  const LockedNoteMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final palette = BrandPalette.of(context);
    void unlock() =>
        context.read<NoteLockCubit>().unlock(strings.noteLockReasonUnlock);

    return Semantics(
      button: true,
      label: strings.noteLockedSemantics,
      onTap: unlock,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: unlock,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 18, color: palette.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.noteLockedLabel,
                  style: TextStyle(
                    fontSize: 15,
                    height: 22 / 15,
                    color: palette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.noteLockedUnlockAction,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
