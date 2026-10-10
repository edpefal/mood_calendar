import 'package:flutter/material.dart';

import '../../features/mood/presentation/screens/calendar_screen.dart';
import '../../features/mood/presentation/screens/mood_screen.dart';
import '../../features/purchases/presentation/screens/mood_store_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../localization/app_strings.dart';
import '../widgets/floating_tab_bar.dart';

/// Pestañas del bottom bar, en el orden en que se muestran.
enum MainTab { moodPicker, calendar, store, settings }

/// Raíz de la app: cuatro pestañas que conservan su estado y un bar flotante.
///
/// Posee la pestaña activa y la fecha del selector de moods, de modo que
/// guardar, tocar un día del calendario y abrir desde el recordatorio sean
/// cambios de estado y no de rutas.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  MainTab _tab = MainTab.moodPicker;
  // Las pestañas se construyen la primera vez que se visitan y después se
  // conservan montadas.
  final Set<MainTab> _visited = {MainTab.moodPicker};
  DateTime _pickerDate = _dateOnly(DateTime.now());
  Key _pickerKey = UniqueKey();
  DateTime? _recentlySavedDate;
  int _saveToken = 0;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  MainTab get currentTab => _tab;

  /// Fecha que muestra el selector de moods.
  DateTime get pickerDate => _pickerDate;

  /// Activa el selector de moods con [date]. Recrea el selector (y con él el
  /// orden del carrusel), igual que cuando se abría una fecha nueva.
  void showMoodPicker(DateTime date) {
    setState(() {
      _pickerDate = _dateOnly(date);
      _pickerKey = UniqueKey();
      _selectTab(MainTab.moodPicker);
    });
  }

  void _onMoodSaved(DateTime date) {
    setState(() {
      _recentlySavedDate = _dateOnly(date);
      _saveToken++;
      _selectTab(MainTab.calendar);
    });
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
      case MainTab.moodPicker:
        return MoodScreen(
          key: _pickerKey,
          selectedDate: _pickerDate,
          onSaved: _onMoodSaved,
        );
      case MainTab.calendar:
        return CalendarScreen(
          isActive: _tab == MainTab.calendar,
          recentlySavedDate: _recentlySavedDate,
          saveToken: _saveToken,
          onDaySelected: showMoodPicker,
        );
      case MainTab.store:
        return const MoodStoreScreen();
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
                bottom: mediaQuery.padding.bottom + FloatingTabBar.reservedHeight,
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
                icon: Icons.sentiment_satisfied_outlined,
                label: strings.openMoodPickerTooltip,
              ),
              FloatingTabItem(
                icon: Icons.calendar_today,
                label: strings.openCalendarTooltip,
              ),
              FloatingTabItem(
                icon: Icons.storefront_outlined,
                label: strings.openStoreTooltip,
              ),
              FloatingTabItem(
                icon: Icons.settings_outlined,
                label: strings.openSettingsTooltip,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
