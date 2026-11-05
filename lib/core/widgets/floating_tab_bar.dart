import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

class FloatingTabItem {
  const FloatingTabItem({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;

  /// The central action tab: a round button over the brand gradient.
  final bool highlighted;
}

/// Floating capsule of ink with the tabs' icons and visible names. The active
/// tab is drawn in full white and a heavier weight; the others are dimmed.
/// A [FloatingTabItem.highlighted] tab (Log) is a round gradient button.
///
/// The bar is a solid fill, so it needs no separate fallback when the system
/// asks to reduce transparency.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const double height = 68;
  static const double bottomMargin = 12;
  static const double maxWidth = 420;
  static const double _horizontalMargin = 20;

  /// Espacio vertical que las pantallas deben reservar para que el bar no
  /// tape su contenido (sin contar el inset del safe area).
  static const double reservedHeight = height + bottomMargin;

  final List<FloatingTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final palette = BrandPalette.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _horizontalMargin,
          0,
          _horizontalMargin,
          bottomInset + bottomMargin,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: palette.tabBar,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: palette.tabBarBorder),
              boxShadow: [
                BoxShadow(
                  color: palette.isDark
                      ? palette.shadow
                      : palette.tabBar.withValues(alpha: 0.28),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _TabButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FloatingTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final color = selected ? palette.onTabBar : palette.onTabBarMuted;
    final label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2),
      style: TextStyle(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: color,
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: Tooltip(
        message: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.highlighted)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: palette.logLinearGradient,
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0xE6FFFFFF),
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: palette.onLogGradient,
                    ),
                  )
                else
                  Icon(item.icon, color: color, size: 22),
                const SizedBox(height: 3),
                label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
