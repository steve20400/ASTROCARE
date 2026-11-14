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
 
class AstroCareApp extends StatelessWidget {
  const AstroCareApp({super.key});
 
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
