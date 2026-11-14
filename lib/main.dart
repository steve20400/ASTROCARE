import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/astrocare_provider.dart';
import 'ui/theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/body_twin_screen.dart';
import 'ui/screens/synergies_screen.dart';
import 'ui/screens/protocols_screen.dart';
import 'ui/screens/mission_sync_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final astroCareProvider = AstroCareProvider();
  await astroCareProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: astroCareProvider,
      child: const AstroCareApp(),
    ),
  );
}

class AstroCareApp extends StatelessWidget {
  const AstroCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroCare',
      debugShowCheckedModeBanner: false,
      theme: AstroTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    BodyTwinScreen(),
    SynergiesScreen(),
    ProtocolsScreen(),
    MissionSyncScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AstroCareProvider>();
    final queuedCount = provider.queuedOfflinePacketsCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AstroTheme.borderCard, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart_outlined, size: 20),
              activeIcon: Icon(Icons.monitor_heart, size: 20),
              label: 'VITALS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new_outlined, size: 20),
              activeIcon: Icon(Icons.accessibility_new, size: 20),
              label: 'TWIN',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.hub_outlined, size: 20),
              activeIcon: Icon(Icons.hub, size: 20),
              label: 'SYNERGIES',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rtl_outlined, size: 20),
              activeIcon: Icon(Icons.checklist_rtl, size: 20),
              label: 'PROTOCOLS',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: queuedCount > 0,
                label: Text('$queuedCount'),
                backgroundColor: AstroTheme.cautionAmber,
                textColor: Colors.black,
                child: const Icon(Icons.sync_alt, size: 20),
              ),
              label: 'EARTH SYNC',
            ),
          ],
        ),
      ),
    );
  }
}
