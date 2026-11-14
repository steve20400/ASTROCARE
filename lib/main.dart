// AstroCare - offline health monitoring for astronauts.
// Team Falcon Health, NASA Space Apps Challenge 2026.
 
import 'package:flutter/material.dart';
 
import 'app/app_state.dart';
import 'ui/home_shell.dart';
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
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'AstroCare',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(false),
          darkTheme: buildTheme(true),
          themeMode: appState.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: appState.loaded
              ? const HomeShell()
              : const Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
