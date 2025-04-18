import 'package:flutter/material.dart';
import 'screens/scoreboard_screen.dart';

void main() => runApp(ScoreboardApp());

class ScoreboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoreboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScoreboardScreen(),
    );
  }
}
