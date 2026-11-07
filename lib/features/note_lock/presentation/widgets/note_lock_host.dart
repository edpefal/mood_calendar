import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/note_lock_cubit.dart';

/// Locks the notes again when the app leaves the foreground, and re-checks
/// that the device can still authenticate when it comes back.
///
/// `inactive` is ignored on purpose: the system's own Face ID prompt makes the
/// app inactive, and reacting to it would cancel the unlock in progress.
class NoteLockHost extends StatefulWidget {
  const NoteLockHost({super.key, required this.child});

  final Widget child;

  @override
  State<NoteLockHost> createState() => _NoteLockHostState();
}

class _NoteLockHostState extends State<NoteLockHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<NoteLockCubit>().refreshAvailability();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<NoteLockCubit>();
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        cubit.lock();
      case AppLifecycleState.resumed:
        cubit.refreshAvailability();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
