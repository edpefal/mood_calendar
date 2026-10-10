import 'dart:ui';

import 'package:flutter/material.dart';

const Color _brandColor = Color(0xFF5F3DC4);

class FloatingTabItem {
  const FloatingTabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Cápsula flotante y translúcida con pestañas de solo icono. La pestaña activa
/// se marca con una píldora translúcida detrás de su icono.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const double height = 64;
  static const double bottomMargin = 12;
  static const double maxWidth = 420;
  static const double _horizontalMargin = 24;

  /// Espacio vertical que las pantallas deben reservar para que el bar no
  /// tape su contenido (sin contar el inset del safe area).
  static const double reservedHeight = height + bottomMargin;

  final List<FloatingTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
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
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 60,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? _brandColor.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(item.icon, color: _brandColor, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
