import 'package:flutter/material.dart';

/// Primary pill-shaped button with the app's brand gradient
/// (`#5F3DC4` → `#6C63FF`), used across screens as the standard
/// primary action button.
class GradientPillButton extends StatelessWidget {
  const GradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticsLabel,
    this.loading = false,
    this.enabled = true,
    this.minHeight = 56,
    this.fontSize = 18,
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
    final isEnabled = enabled && !loading && onPressed != null;

    return AbsorbPointer(
      absorbing: !isEnabled,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: semanticsLabel ?? label,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: GestureDetector(
            onTap: isEnabled ? onPressed : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF5F3DC4),
                    Color(0xFF6C63FF),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
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
