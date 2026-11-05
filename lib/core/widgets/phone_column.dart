import 'package:flutter/material.dart';

/// Widest the content of a tab gets. On a phone it is the full width; on an
/// iPad the phone layout stays centered at this width.
const double kPhoneContentMaxWidth = 520;

/// Centers [child] and limits it to [kPhoneContentMaxWidth].
class PhoneColumn extends StatelessWidget {
  const PhoneColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kPhoneContentMaxWidth),
        child: child,
      ),
    );
  }
}
