import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Whether glass surfaces should drop their blur and use an opaque fill.
///
/// Flutter only exposes the iOS/Android "increase contrast" switch
/// ([MediaQueryData.highContrast]); the iOS "reduce transparency" switch has
/// no Flutter equivalent, so the opaque fallback follows high contrast and
/// accessibility inverted colors.
bool useOpaqueGlass(BuildContext context) {
  final media = MediaQuery.maybeOf(context);
  if (media == null) return false;
  return media.highContrast || media.invertColors;
}

/// A translucent card with a light border and rounded corners over the mesh.
/// Use it for top-level surfaces only: a blur per grid cell or list row costs
/// frames on older devices.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.fill,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Corner radius; use a large value (e.g. 999) for a pill.
  final double radius;

  /// Overrides the palette's glass fill (e.g. a mood tint).
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final opaque = useOpaqueGlass(context);
    final borderRadius = BorderRadius.circular(radius);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: fill ?? (opaque ? palette.glassOpaque : palette.glassFill),
        borderRadius: borderRadius,
        border: Border.all(color: palette.glassBorder),
      ),
      child: Padding(padding: padding, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: opaque
            ? content
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: content,
              ),
      ),
    );
  }
}
