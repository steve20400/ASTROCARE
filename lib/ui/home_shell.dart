// Main frame of the app: five tabs in a bottom navigation bar.
 
import 'package:flutter/material.dart';
 
import '../app/app_state.dart';
import 'add_measurement_sheet.dart';
import 'alerts_page.dart';
import 'body_page.dart';
import 'dashboard_page.dart';
import 'more_page.dart';
import 'synergy_page.dart';
 
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
 
  @override
  State<HomeShell> createState() => _HomeShellState();
}
 
class _HomeShellState extends State<HomeShell> {
  int _index = 0;
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final openCount = appState.openAlerts(appState.currentMemberId).length;
        final pages = <Widget>[
          const DashboardPage(),
          const BodyPage(),
          const SynergyPage(),
          const AlertsPage(),
          const MorePage(),
        ];
        final titles = [
          t('nav.dashboard'),
          t('nav.body'),
          t('nav.synergies'),
          t('nav.alerts'),
          t('nav.more'),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text('AstroCare · ${titles[_index]}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Tooltip(
                  message: t('dash.autonomous'),
                  child: const Icon(Icons.cloud_off),
                ),
              ),
            ],
          ),
          body: SafeArea(child: pages[_index]),
          floatingActionButton: _index <= 1
              ? FloatingActionButton.extended(
                  onPressed: () => showAddMeasurement(context),
                  icon: const Icon(Icons.add),
                  label: Text(t('dash.add')),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                label: t('nav.dashboard'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.accessibility_new),
                label: t('nav.body'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.hub_outlined),
                label: t('nav.synergies'),

              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: openCount > 0,
                  label: Text('$openCount'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                label: t('nav.alerts'),
              ),
              NavigationDestination(icon: const Icon(Icons.more_horiz), label: t('nav.more')),
            ],
          ),
        );
      },
    );
  }
}
