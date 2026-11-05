import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';

/// Primary pill-shaped button: an ink pill with white text, used across
/// screens as the standard primary action. The name predates the visual
/// system (it used to be a gradient) and is kept so call sites don't change.
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    this.loading = false,
    this.enabled = true,
    this.minHeight = 52,
    this.fontSize = 17,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final bool loading;
  final bool enabled;
  final double minHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = BrandPalette.of(context);
    final isEnabled = enabled && !loading && onPressed != null;
    final foreground = isEnabled ? palette.onInk : palette.textSecondary;

    return AbsorbPointer(
      absorbing: !isEnabled,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: semanticsLabel ?? label,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isEnabled ? onPressed : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isEnabled ? palette.ink : palette.glassFill,
                border:
                    isEnabled ? null : Border.all(color: palette.glassBorder),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: palette.ink.withValues(alpha: 0.22),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: loading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            palette.onInk,
                          ),
                        ),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: foreground,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
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
