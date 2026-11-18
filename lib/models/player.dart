import 'package:flutter/material.dart';

class Player {
  final int id;
  final String name;
  final Color backgroundColor;
  final List<int> history;

  Player({
    required this.id,
    required this.name,
    required this.backgroundColor,
  }) : history = const [0];

  Player._({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required List<int> history,
  }) : history = List.unmodifiable(history);

  int get score => history.last;

  factory Player.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid saved player.');
    }
    final id = value['id'];
    final name = value['name'];
    final color = value['backgroundColor'];
    final history = value['history'];
    if (id is! int || id < 1 ||
        name is! String || name.trim().isEmpty ||
        color is! int || color < 0 || color > 0xFFFFFFFF ||
        history is! List || history.isEmpty || history.first != 0 ||
        history.any((score) => score is! int)) {
      throw const FormatException('Invalid saved player.');
    }
    return Player._(
      id: id,
      name: name,
      backgroundColor: Color(color),
      history: history.cast<int>(),
    );
  }

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'backgroundColor': backgroundColor.toARGB32(),
        'history': history,
      };

  Player edit({required String name, required Color backgroundColor}) {
    return Player._(
      id: id,
      name: name,
      backgroundColor: backgroundColor,
      history: history,
    );
  }

  Player adjustScore(int delta) {
    return Player._(
      id: id,
      name: name,
      backgroundColor: backgroundColor,
      history: [...history, score + delta],
    );
  }

  Player undoScore() {
    if (history.length <= 1) return this;

    return Player._(
      id: id,
      name: name,
      backgroundColor: backgroundColor,
      history: history.sublist(0, history.length - 1),
    );
  }
}
