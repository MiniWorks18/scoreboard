import 'package:flutter/material.dart';
import 'screens/scoreboard_screen.dart';
import 'services/modal_theme_observer.dart';

void main() => runApp(ScoreboardApp());

class ScoreboardApp extends StatelessWidget {
  final _modalThemeObserver = ModalThemeObserver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoreboard',
      navigatorObservers: [_modalThemeObserver],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF192A45)),
        scaffoldBackgroundColor: const Color(0xFFF2F4F9),
      ),
      home: ScoreboardScreen(),
    );
  }
}
