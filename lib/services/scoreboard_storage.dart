import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';

class SavedGame {
  final List<Player> players;
  final int nextId;

  SavedGame({required List<Player> players, required this.nextId})
      : players = List.unmodifiable(players);

  factory SavedGame.fromJson(Object? value) {
    if (value is! Map<String, dynamic> || value['version'] != 1) {
      throw const FormatException('Unsupported saved game.');
    }
    final entries = value['players'];
    final nextId = value['nextId'];
    if (entries is! List || nextId is! int || nextId < 1) {
      throw const FormatException('Invalid saved game.');
    }
    final players = entries.map(Player.fromJson).toList();
    final ids = players.map((player) => player.id).toSet();
    if (ids.length != players.length || ids.any((id) => id >= nextId)) {
      throw const FormatException('Invalid saved player IDs.');
    }
    return SavedGame(players: players, nextId: nextId);
  }

  Map<String, Object> toJson() => {
        'version': 1,
        'nextId': nextId,
        'players': players.map((player) => player.toJson()).toList(),
      };
}

class ScoreboardStorage {
  static const _key = 'scoreboard.saved_game';
  late final _preferences = SharedPreferencesAsync();

  Future<SavedGame?> load() async {
    final value = await _preferences.getString(_key);
    return value == null ? null : SavedGame.fromJson(jsonDecode(value));
  }

  Future<void> save(SavedGame game) async {
    await _preferences.setString(_key, jsonEncode(game.toJson()));
  }
}
