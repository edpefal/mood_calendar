import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../mood/presentation/bloc/calendar_cubit.dart';
import '../../mood/presentation/bloc/mood_cubit.dart';
import '../domain/services/watch_sync_coordinator.dart';

/// Pone en marcha la sincronización con el Apple Watch y refresca la UI.
///
/// Va debajo de los cubits: arranca el coordinador, lo reactiva al volver a
/// primer plano o cambiar el idioma, y recarga el calendario y el selector
/// cuando llega una elección del reloj con la app abierta. Recargar usa
/// `fetchAll`/`refresh`, no `save`, así que no cambia de pestaña, no dispara
/// el pedido de calificación y no emite analíticas.
class WatchSyncHost extends StatefulWidget {
  const WatchSyncHost({super.key, required this.child});

  final Widget child;

  @override
  State<WatchSyncHost> createState() => _WatchSyncHostState();
}

class _WatchSyncHostState extends State<WatchSyncHost>
    with WidgetsBindingObserver {
  late final WatchSyncCoordinator _coordinator;
  StreamSubscription<int>? _applied;

  @override
  void initState() {
    super.initState();
    _coordinator = context.read<WatchSyncCoordinator>();
    WidgetsBinding.instance.addObserver(this);
    _applied = _coordinator.applied.listen((_) {
      if (!mounted) return;
      unawaited(context.read<MoodCubit>().fetchAll());
      unawaited(context.read<CalendarCubit>().refresh());
    });
    _coordinator.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_coordinator.sync());
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _coordinator.schedulePublish();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_applied?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
