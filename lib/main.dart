// AstroCare - health monitoring for astronauts that works without any connection.
// Team Falcon Health, NASA Space Apps Challenge 2026.
 
import 'package:flutter/material.dart';
 
import 'app/app_state.dart';
import 'ui/home_shell.dart';
import 'ui/login_page.dart';
import 'ui/theme.dart';
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  appState.load();
  runApp(const AstroCareApp());
}
 
class AstroCareApp extends StatefulWidget {
  const AstroCareApp({super.key});
 
  @override
  State<AstroCareApp> createState() => _AstroCareAppState();
}
 
class _AstroCareAppState extends State<AstroCareApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
 
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  /// When the app comes back to the screen, a report whose time has passed is
  /// created at once.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) appState.checkReportDue();
  }
 
  @override
  Widget build(BuildContext context) {
    // The whole app is rebuilt when the language, the theme or the session changes.
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        Widget home;
        if (!appState.loaded) {
          home = const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (!appState.signedIn) {
          home = const LoginPage();
        } else {
          home = HomeShell(key: ValueKey('home-${appState.session!.uid}'));
        }
        return MaterialApp(
          title: 'AstroCare',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(false),
          darkTheme: buildTheme(true),
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: home,
        );
      },
    );
  }
}
