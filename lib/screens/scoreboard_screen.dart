import 'dart:math';

import 'package:flutter/material.dart';

import '../controllers/scoreboard_controller.dart';
import '../widgets/edit_player_dialog.dart';
import '../widgets/glass_dialog.dart';
import '../widgets/player_tile.dart';
import '../widgets/score_dialog.dart';
import '../widgets/score_history_dialog.dart';

class ScoreboardScreen extends StatefulWidget {
  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final _scoreboard = ScoreboardController();

  @override
  void initState() {
    super.initState();
    _scoreboard.initialize();
  }

  @override
  void dispose() {
    _scoreboard.dispose();
    super.dispose();
  }

  Future<void> _showScoreDialog(int playerId) async {
    final player = _scoreboard.playerById(playerId);
    if (player == null) return;

    final delta = await showGlassDialog<int>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: _scoreboard,
        builder: (context, child) {
          final current = _scoreboard.playerById(playerId) ?? player;
          return ScoreDialog(
            playerName: current.name,
            currentScore: current.score,
            playerColor: current.backgroundColor,
            onViewHistory: () => _showHistory(playerId),
          );
        },
      ),
    );
    if (!mounted || delta == null) return;

    _scoreboard.adjustScore(playerId, delta);
  }

  void _showHistory(int playerId) {
    final player = _scoreboard.playerById(playerId);
    if (player == null) return;

    showGlassDialog<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: _scoreboard,
        builder: (context, child) => ScoreHistoryDialog(
          player: _scoreboard.playerById(playerId) ?? player,
          onUndo: () => _scoreboard.undoScore(playerId),
        ),
      ),
    );
  }

  Future<void> _editPlayer(int playerId) async {
    final player = _scoreboard.playerById(playerId);
    if (player == null) return;

    final result = await showGlassDialog<PlayerEditResult>(
      context: context,
      builder: (context) => EditPlayerDialog(player: player),
    );
    if (!mounted || result == null) return;

    if (result.delete) {
      _scoreboard.removePlayer(playerId);
    } else {
      _scoreboard.editPlayer(
        playerId,
        name: result.name,
        backgroundColor: result.backgroundColor,
      );
    }
  }

  Future<void> _newGame() async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (context) => GlassDialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Start a new game?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text('All scores and history will be reset. Player names and colours will stay.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                child: const Text('Start new game'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                child: const Text('Keep playing'),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && confirmed == true) _scoreboard.newGame();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scoreboard,
      builder: (context, child) {
        if (_scoreboard.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(semanticsLabel: 'Restoring game')),
          );
        }
        final players = _scoreboard.players;
        final winner = _scoreboard.winner;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scoreboard',
                              style: TextStyle(
                                fontSize: 28,
                                letterSpacing: -0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              winner == null ? 'Ready for a game?' : '🏆 ${winner.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF526079), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        onPressed: _scoreboard.addPlayer,
                        tooltip: 'Add Player',
                        style: IconButton.styleFrom(
                          minimumSize: const Size(52, 52),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF192A45),
                          side: const BorderSide(color: Color(0xFFE1E7F0)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded),
                        tooltip: 'New game',
                        onPressed: _newGame,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                      ),
                    ],
                  ),
                ),
                if (_scoreboard.storageMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        _scoreboard.storageMessage!,
                        style: const TextStyle(color: Color(0xFFB83E55), fontSize: 13),
                      ),
                    ),
                  ),
                Expanded(
                  child: players.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sports_esports_outlined,
                                    size: 56, color: Color(0xFF526079)),
                                const SizedBox(height: 16),
                                const Text('Add a player to get started.'),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _scoreboard.addPlayer,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add player'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final tileHeight = max(
                              players.length > 5 ? 120.0 : 156.0,
                              constraints.maxHeight / players.length,
                            );

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: players.length,
                              findChildIndexCallback: (key) {
                                final index = players.indexWhere(
                                  (player) => ValueKey(player.id) == key,
                                );
                                return index == -1 ? null : index;
                              },
                              itemBuilder: (context, index) {
                                final player = players[index];
                                return SizedBox(
                                  key: ValueKey(player.id),
                                  height: tileHeight,
                                  child: PlayerTile(
                                    name: player.name,
                                    score: player.score,
                                    backgroundColor: player.backgroundColor,
                                    isWideLayout: players.length > 5,
                                    onAdd: () => _scoreboard.adjustScore(player.id, 1),
                                    onSubtract: () => _scoreboard.adjustScore(player.id, -1),
                                    onTap: () => _showScoreDialog(player.id),
                                    onSettings: () => _editPlayer(player.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                  child: Text(
                    players.isEmpty ? 'Your next game starts here' : 'Tap a score to add points',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF526079), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
