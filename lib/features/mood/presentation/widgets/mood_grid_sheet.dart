import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../domain/entities/mood_definition.dart';

/// Abre la hoja con todos los moods en la cuadrícula y devuelve el mood
/// tocado (o `null` si se cierra sin elegir). [moods] ya viene en el orden
/// vigente del carrusel: la hoja nunca lo recalcula.
Future<MoodDefinition?> showMoodGridSheet(
  BuildContext context, {
  required List<MoodDefinition> moods,
  required String selectedId,
  required bool Function(MoodDefinition mood) isLocked,
}) {
  return showModalBottomSheet<MoodDefinition>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MoodGridSheet(
      moods: moods,
      selectedId: selectedId,
      isLocked: isLocked,
    ),
  );
}

class MoodGridSheet extends StatelessWidget {
  const MoodGridSheet({
    super.key,
    required this.moods,
    required this.selectedId,
    required this.isLocked,
  });

  final List<MoodDefinition> moods;
  final String selectedId;
  final bool Function(MoodDefinition mood) isLocked;

  static const _brand = Color(0xFF5F3DC4);
  static const _spacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final columns = largeText ? 2 : 4;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.moodGridTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth =
                      (constraints.maxWidth - _spacing * (columns - 1)) /
                          columns;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: _spacing,
                      runSpacing: _spacing,
                      children: [
                        for (final mood in moods)
                          SizedBox(
                            width: cellWidth,
                            child: _MoodCell(
                              mood: mood,
                              selected: mood.id == selectedId,
                              locked: isLocked(mood),
                              onTap: () => Navigator.of(context).pop(mood),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodCell extends StatelessWidget {
  const _MoodCell({
    required this.mood,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final MoodDefinition mood;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final name = strings.moodName(mood.id);

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color:
                selected ? MoodGridSheet._brand.withValues(alpha: 0.10) : null,
            border: Border.all(
              color: selected ? MoodGridSheet._brand : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: locked ? 0.4 : 1,
                    child: SvgPicture.asset(
                      mood.assetPath,
                      height: 56,
                      width: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (locked)
                    const Icon(
                      Icons.lock_rounded,
                      size: 24,
                      color: MoodGridSheet._brand,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Una sola línea que se reduce si hace falta: partir un nombre
              // a media palabra ("Affectionat/e") se lee peor que una letra
              // más pequeña.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
