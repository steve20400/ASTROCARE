// Main frame of the app: four tabs. Each tab is rebuilt whenever the state changes.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import 'add_measurement_sheet.dart';
import 'alerts_page.dart';
import 'body_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'transmission_page.dart';
 
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
 
  @override
  State<HomeShell> createState() => _HomeShellState();
}
 
class _HomeShellState extends State<HomeShell> {
  int _index = 0;
 
  Widget _page() {
    switch (_index) {
      case 1:
        return const BodyPage();
      case 2:
        return buildAlertsPage(context);
      case 3:
        return buildSettingsPage(context);
      default:
        return buildHomePage(context);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final openCount = appState.openAlertCount;
        final titles = [t('nav.home'), t('nav.body'), t('nav.alerts'), t('nav.settings')];
        return Scaffold(
          appBar: AppBar(
            title: Text(_index == 0 ? 'AstroCare' : titles[_index]),
            actions: [
              // Link with the ground, with the number of reports waiting on board.
              IconButton(
                tooltip: t('tx.title'),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => const TransmissionPage())),
                icon: Badge(
                  isLabelVisible: appState.queuedReports > 0,
                  label: Text('${appState.queuedReports}'),
                  child: const Icon(Icons.satellite_alt),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(child: _page()),
          floatingActionButton: _index == 0
              ? FloatingActionButton.extended(
                  onPressed: () => showAddMeasurement(context),
                  icon: const Icon(Icons.add),
                  label: Text(t('home.add')),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), label: titles[0]),
              NavigationDestination(
                icon: const Icon(Icons.accessibility_new),
                label: titles[1],
              ),

              NavigationDestination(
                icon: Badge(
                  isLabelVisible: openCount > 0,
                  label: Text('$openCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                label: titles[2],
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                label: titles[3],
              ),
            ],
          ),
        );
      },
    );
  }
}
