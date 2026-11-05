import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// The app's pastel mesh: four soft blobs over the palette's base color,
/// with an optional [tint] pooled at the top (the Log tints it with the
/// selected mood's category). Sits behind every tab and fills the screen.
class MeshBackground extends StatelessWidget {
  const MeshBackground({super.key, this.tint, this.child});

  final Color? tint;
  final Widget? child;

  static const _blobs = <({Alignment center, double radius})>[
    (center: Alignment(-1, -0.84), radius: 0.9),
    (center: Alignment(1, -0.64), radius: 0.85),
    (center: Alignment(0.8, 0.9), radius: 0.95),
    (center: Alignment(-1, 0.5), radius: 0.9),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);

    return ColoredBox(
      color: palette.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                for (var i = 0; i < _blobs.length; i++)
                  _Blob(
                    color: palette.mesh[i],
                    center: _blobs[i].center,
                    radius: _blobs[i].radius,
                  ),
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: tint ?? const Color(0x00000000)),
                  duration: const Duration(milliseconds: 200),
                  builder: (context, color, _) => _Blob(
                    color: color ?? const Color(0x00000000),
                    center: Alignment.topCenter,
                    radius: 1.1,
                  ),
                ),
              ],
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.center,
    required this.radius,
  });

  final Color color;
  final Alignment center;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0, 0.7],
        ),
      ),
    );
  }
}
