import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../domain/entities/mood_category.dart';
import '../../domain/entities/mood_definition.dart';
import '../../domain/services/mood_definition_resolver.dart';

/// Name of [category] in the device language.
String moodCategoryName(AppStrings strings, MoodCategory category) {
  switch (category) {
    case MoodCategory.positive:
      return strings.categoryPositive;
    case MoodCategory.peaceful:
      return strings.categoryPeaceful;
    case MoodCategory.neutral:
      return strings.categoryNeutral;
    case MoodCategory.hard:
      return strings.categoryHard;
  }
}

/// Every mood of the catalog grouped under its category, in the fixed order
/// (4 columns, 2 with large system text). Tapping a cell reports the mood;
/// the caller decides what a locked mood does.
class MoodCategoryGrid extends StatelessWidget {
  const MoodCategoryGrid({
    super.key,
    required this.selectedId,
    required this.isLocked,
    required this.onMoodTap,
    this.onlyTier,
  });

  /// Shows only the moods of this tier (the onboarding offers the base ones,
  /// with nothing to unlock yet). All of them when null.
  final MoodTier? onlyTier;

  final String? selectedId;
  final bool Function(MoodDefinition mood) isLocked;
  final ValueChanged<MoodDefinition> onMoodTap;

  static const double _spacing = 6;

  List<({MoodCategory category, List<MoodDefinition> moods})> _groups() => [
        for (final group in moodDefinitionsByCategory())
          (
            category: group.category,
            moods: [
              for (final mood in group.moods)
                if (onlyTier == null || mood.tier == onlyTier) mood,
            ],
          ),
      ].where((group) => group.moods.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final columns = largeText ? 2 : 4;

    // Rows of equal-width cells built by hand (no LayoutBuilder or Wrap): the
    // Log lays this out inside a sliver that asks for intrinsic heights.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in _groups()) ...[
          Semantics(
            header: true,
            label: strings.categorySectionSemantics(
              moodCategoryName(strings, group.category),
            ),
            excludeSemantics: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: Text(
                moodCategoryName(strings, group.category),
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: BrandPalette.of(context).textSecondary,
                ),
              ),
            ),
          ),
          for (var start = 0; start < group.moods.length; start += columns)
            Padding(
              padding: const EdgeInsets.only(bottom: _spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) const SizedBox(width: _spacing),
                    Expanded(
                      child: start + i < group.moods.length
                          ? MoodCell(
                              mood: group.moods[start + i],
                              selected: group.moods[start + i].id == selectedId,
                              locked: isLocked(group.moods[start + i]),
                              onTap: () => onMoodTap(group.moods[start + i]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// One mood of the grid: icon and name on the tint of its category, a ring
/// and a larger icon when selected, dimmed with a lock badge when locked.
class MoodCell extends StatelessWidget {
  const MoodCell({
    super.key,
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
    final palette = BrandPalette.of(context);
    final tint = MoodDefinitionResolver.tintFor(context, mood);
    final name = strings.moodName(mood.id);
    final category = moodCategoryName(strings, mood.category);
    final animate = !MediaQuery.disableAnimationsOf(context);
    final duration =
        animate ? const Duration(milliseconds: 200) : Duration.zero;

    return Semantics(
      button: true,
      selected: selected,
      label: locked
          ? strings.lockedMoodSemantics(name, category)
          : strings.moodCellSemantics(name, category),
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: AnimatedContainer(
            duration: duration,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              color: tint.fill,
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(color: tint.ring, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.2 : 1,
                      duration: duration,
                      child: Opacity(
                        opacity: locked ? 0.55 : 1,
                        child: SvgPicture.asset(
                          mood.assetPath,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w500,
                          color: locked ? palette.textSecondary : palette.text,
                        ),
                      ),
                    ),
                  ],
                ),
                if (locked)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: palette.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: palette.onInk,
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
