import 'package:flutter/material.dart';

import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/mood/presentation/screens/calendar_screen.dart';
import '../../features/mood/presentation/screens/log_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../localization/app_strings.dart';
import '../widgets/floating_tab_bar.dart';

/// Pestañas del bottom bar, en el orden en que se muestran.
enum MainTab { calendar, insights, log, settings }

/// Raíz de la app: cuatro pestañas que conservan su estado y un bar flotante.
///
/// Posee la pestaña activa y la fecha del Log, de modo que tocar un día del
/// calendario, abrir desde el recordatorio y el atajo "¿Olvidaste ayer?" sean
/// cambios de estado y no de rutas. La app abre en el Log con la fecha de hoy.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  MainTab _tab = MainTab.log;
  // Las pestañas se construyen la primera vez que se visitan y después se
  // conservan montadas.
  final Set<MainTab> _visited = {MainTab.log};
  DateTime _logDate = _dateOnly(DateTime.now());
  Key _logKey = UniqueKey();
  bool _logStartsEditing = false;
  Key _insightsKey = UniqueKey();
  bool _insightsScrollsToYear = false;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  MainTab get currentTab => _tab;

  /// Fecha que muestra el Log.
  DateTime get logDate => _logDate;

  /// Activa el Log con [date]. Recrea el Log (y con él la selección y la nota
  /// sin guardar), igual que cuando se abría una fecha nueva. Con [edit] abre
  /// la cuadrícula ya editando la entrada de esa fecha (el "Edit" del detalle
  /// del día).
  void showLog(DateTime date, {bool edit = false}) {
    setState(() {
      _logDate = _dateOnly(date);
      _logKey = UniqueKey();
      _logStartsEditing = edit;
      _selectTab(MainTab.log);
    });
  }

  /// Activa Insights y baja a la tarjeta Year in Pixels (el botón "ver año"
  /// del calendario).
  void showInsightsYear() {
    setState(() {
      _insightsKey = UniqueKey();
      _insightsScrollsToYear = true;
      _selectTab(MainTab.insights);
    });
  }

  /// Activa la pestaña de Ajustes (la campana del Log).
  void showSettings() {
    setState(() => _selectTab(MainTab.settings));
  }

  void _selectTab(MainTab tab) {
    _tab = tab;
    _visited.add(tab);
  }

  Widget _buildTab(MainTab tab) {
    if (!_visited.contains(tab)) {
      return const SizedBox.shrink();
    }
    switch (tab) {
      case MainTab.calendar:
        return CalendarScreen(
          onDaySelected: showLog,
          onEditEntry: (date) => showLog(date, edit: true),
          onViewYear: showInsightsYear,
        );
      case MainTab.insights:
        return InsightsScreen(
          key: _insightsKey,
          scrollToYear: _insightsScrollsToYear,
          onEditEntry: (date) => showLog(date, edit: true),
        );
      case MainTab.log:
        return LogScreen(
          key: _logKey,
          selectedDate: _logDate,
          startEditing: _logStartsEditing,
          isActive: _tab == MainTab.log,
          onOpenSettings: showSettings,
          onRequestDate: showLog,
        );
      case MainTab.settings:
        return SettingsScreen.forApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      // Las pestañas no tienen campos de texto (la nota se edita en un sheet
      // que maneja su propio inset), así que el teclado no debe encogerlas.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Las pantallas reservan el espacio del bar a través del padding
          // inferior de MediaQuery (lo usan SafeArea y las listas).
          MediaQuery(
            data: mediaQuery.copyWith(
              padding: mediaQuery.padding.copyWith(
                bottom:
                    mediaQuery.padding.bottom + FloatingTabBar.reservedHeight,
              ),
            ),
            child: IndexedStack(
              index: _tab.index,
              children: [
                for (final tab in MainTab.values) _buildTab(tab),
              ],
            ),
          ),
          FloatingTabBar(
            currentIndex: _tab.index,
            onTap: (index) => setState(() => _selectTab(MainTab.values[index])),
            items: [
              FloatingTabItem(
                icon: Icons.calendar_today_outlined,
                label: strings.tabCalendar,
              ),
              FloatingTabItem(
                icon: Icons.bar_chart_rounded,
                label: strings.tabInsights,
              ),
              FloatingTabItem(
                icon: Icons.add_rounded,
                label: strings.tabLog,
                highlighted: true,
              ),
              FloatingTabItem(
                icon: Icons.tune_rounded,
                label: strings.tabSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
