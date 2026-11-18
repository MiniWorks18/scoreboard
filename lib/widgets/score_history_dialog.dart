import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/player.dart';
import 'glass_dialog.dart';

class ScoreHistoryDialog extends StatelessWidget {
  final Player player;
  final VoidCallback onUndo;

  const ScoreHistoryDialog({
    required this.player,
    required this.onUndo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score history', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(player.name, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),
                Text(
                  '${player.score} points',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text('Latest changes first',
                    style: TextStyle(color: Color(0xFF526079))),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemCount: player.history.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final historyIndex = player.history.length - 1 - index;
                final score = player.history[historyIndex];
                final initial = historyIndex == 0;
                final previous = initial ? 0 : player.history[historyIndex - 1];
                final delta = score - previous;
                final color = initial
                    ? const Color(0xFF526079)
                    : delta > 0
                        ? const Color(0xFF186B54)
                        : const Color(0xFFB83E55);

                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.09),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        initial
                            ? Icons.flag_outlined
                            : delta > 0
                                ? Icons.north_east_rounded
                                : Icons.south_east_rounded,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(initial ? 'Starting score' : 'Adjustment $historyIndex',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(initial ? '0 points' : '$previous → $score points',
                              style: const TextStyle(color: Color(0xFF526079))),
                        ],
                      ),
                    ),
                    if (!initial)
                      Flexible(
                        child: Text(
                          '${delta > 0 ? '+' : '−'}${delta.abs()}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: player.history.length <= 1
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          onUndo();
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Undo last change'),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
