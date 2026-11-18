import 'dart:math';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/scoreboard_storage.dart';

const _animalNames = [
  'Koala', 'Pademelon', 'Wombat', 'Quokka', 'Platypus', 'Bandicoot',
  'Wallaby', 'Froglet', 'Possum', 'Sugar Glider', 'Echidna', 'Kangaroo',
  'Numbat', 'Quoll', 'Dingo', 'Tasmanian Devil', 'Frog', 'Kookaburra',
  'Frogmouth',
];

class ScoreboardController extends ChangeNotifier {
  final Random _random = Random();
  final List<Player> _players = [];
  final ScoreboardStorage _storage = ScoreboardStorage();
  late final Future<void> _initialization = _restore();
  Future<void> _saveQueue = Future.value();
  int _nextId = 1;
  bool _isLoading = true;
  bool _canSave = true;
  bool _disposed = false;
  String? _storageMessage;

  bool get isLoading => _isLoading;
  String? get storageMessage => _storageMessage;

  Future<void> initialize() => _initialization;

  Future<void> _restore() async {
    try {
      final game = await _storage.load();
      if (game == null) {
        for (int i = 0; i < 4; i++) {
          addPlayer();
        }
      } else {
        _players.addAll(game.players);
        _nextId = game.nextId;
      }
    } catch (_) {
      // Keep the saved copy untouched until the user chooses a new game.
      _canSave = false;
      _storageMessage = 'Couldn’t restore your saved game. Start a new game to enable saving.';
      for (int i = 0; i < 4; i++) {
        addPlayer();
      }
    }
    _isLoading = false;
    _changed();
  }

  void _changed() {
    if (_isLoading || _disposed) return;
    notifyListeners();
    if (!_canSave) return;

    final snapshot = SavedGame(players: _players, nextId: _nextId);
    // Write snapshots in order so quick taps cannot save an older score last.
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _storage.save(snapshot);
        _storageMessage = null;
      } catch (_) {
        _storageMessage = 'Couldn’t save this game. Keep this page open to avoid losing your scores.';
      }
      if (!_disposed) notifyListeners();
    });
  }

  void newGame() {
    if (_isLoading) return;
    for (int i = 0; i < _players.length; i++) {
      final player = _players[i];
      _players[i] = Player(
        id: player.id,
        name: player.name,
        backgroundColor: player.backgroundColor,
      );
    }
    _canSave = true;
    _storageMessage = null;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<Player> get players => List.unmodifiable(_players);

  Player? get winner => _players.isEmpty
      ? null
      : _players.reduce((a, b) => a.score > b.score ? a : b);

  Player? playerById(int id) {
    for (final player in _players) {
      if (player.id == id) return player;
    }
    return null;
  }

  void addPlayer() {
    final id = _nextId++;
    final names = _animalNames
        .where((name) => !_players.any((player) => player.name == name))
        .toList();
    final colours = Colors.primaries
        .where((colour) =>
            !_players.any((player) => player.backgroundColor == colour))
        .toList();
    final palette = colours.isEmpty ? Colors.primaries : colours;

    _players.add(Player(
      id: id,
      name: names.isEmpty ? 'Player $id' : names[_random.nextInt(names.length)],
      backgroundColor: palette[_random.nextInt(palette.length)],
    ));
    _changed();
  }

  void editPlayer(int id, {required String name, required Color backgroundColor}) {
    final index = _players.indexWhere((player) => player.id == id);
    final trimmedName = name.trim();
    if (index == -1 || trimmedName.isEmpty) return;

    _players[index] = _players[index].edit(
      name: trimmedName,
      backgroundColor: backgroundColor,
    );
    _changed();
  }

  void adjustScore(int id, int delta) {
    final index = _players.indexWhere((player) => player.id == id);
    if (index == -1 || delta == 0) return;

    _players[index] = _players[index].adjustScore(delta);
    _changed();
  }

  void removePlayer(int id) {
    final index = _players.indexWhere((player) => player.id == id);
    if (index == -1) return;

    _players.removeAt(index);
    _changed();
  }

  void undoScore(int id) {
    final index = _players.indexWhere((player) => player.id == id);
    if (index == -1 || _players[index].history.length <= 1) return;

    _players[index] = _players[index].undoScore();
    _changed();
  }
}
