import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerTile extends StatefulWidget {
  final String name;
  final int score;
  final Color backgroundColor;
  final bool isWideLayout;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;
  final VoidCallback onTap;
  final VoidCallback onSettings;

  const PlayerTile({
    Key? key,
    required this.name,
    required this.score,
    required this.backgroundColor,
    required this.isWideLayout,
    required this.onAdd,
    required this.onSubtract,
    required this.onTap,
    required this.onSettings,
  }) : super(key: key);

  @override
  State<PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<PlayerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _impact;
  bool _reduceMotion = false;
  int _lastDelta = 0;

  @override
  void initState() {
    super.initState();
    _impact = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) _impact.value = 1;
  }

  @override
  void didUpdateWidget(covariant PlayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.score != oldWidget.score) {
      _lastDelta = widget.score - oldWidget.score;
      if (!_reduceMotion) _impact.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _impact.dispose();
    super.dispose();
  }

  Widget _stepButton({required bool add}) {
    return IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        if (add) {
          widget.onAdd();
        } else {
          widget.onSubtract();
        }
      },
      tooltip: add ? 'Add one point' : 'Subtract one point',
      constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
      padding: const EdgeInsets.all(12),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.14),
        foregroundColor: Colors.white,
      ),
      icon: Icon(add ? Icons.add_rounded : Icons.remove_rounded, size: 28),
    );
  }

  Widget _scoreControls() {
    return Row(
      children: [
        _stepButton(add: false),
        Expanded(
          child: Semantics(
            button: true,
            liveRegion: true,
            label: '${widget.name}, ${widget.score} points. Adjust score',
            excludeSemantics: true,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: _reduceMotion ? 0 : 220),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Text(
                        '${widget.score}',
                        key: ValueKey(widget.score),
                        style: const TextStyle(
                          fontSize: 80,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -3,
                          fontFeatures: [FontFeature.tabularFigures()],
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _stepButton(add: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(widget.backgroundColor, const Color(0xFF15233D), 0.38)!;
    final nameButton = TextButton(
      onPressed: widget.onSettings,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        alignment: Alignment.centerLeft,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.tune_rounded, size: 16, color: Colors.white70),
        ],
      ),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _impact,
        builder: (context, child) {
          final progress = _impact.value;
          final bounce = math.sin(progress * math.pi * 4) *
              math.pow(1 - progress, 2) * 0.035;
          return Transform.scale(
            scale: 1 + bounce,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: base.withOpacity(0.14),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color.lerp(base, Colors.white, 0.12)!, base],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ScoreRipplePainter(
                          animation: _impact,
                          wide: widget.isWideLayout,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: widget.isWideLayout
                        ? Row(
                            children: [
                              Flexible(flex: 2, child: nameButton),
                              const SizedBox(width: 8),
                              Expanded(flex: 3, child: _scoreControls()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              nameButton,
                              Expanded(child: _scoreControls()),
                            ],
                          ),
                  ),
                  Positioned(
                    top: 14,
                    right: 20,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _impact,
                        builder: (context, child) {
                          final progress = _impact.value;
                          return Opacity(
                            opacity: _lastDelta == 0 ? 0 : 1 - progress,
                            child: Transform.translate(
                              offset: Offset(0, -12 * progress),
                              child: Text(
                                '${_lastDelta > 0 ? '+' : '−'}${_lastDelta.abs()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreRipplePainter extends CustomPainter {
  final Animation<double> animation;
  final bool wide;

  _ScoreRipplePainter({required this.animation, required this.wide})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    if (progress == 0 || progress == 1) return;

    final origin = Offset(size.width * (wide ? 0.7 : 0.5), size.height * (wide ? 0.5 : 0.65));
    final radius = size.longestSide * 0.7;
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int ring = 0; ring < 3; ring++) {
      final wave = (progress - ring * 0.12) / (1 - ring * 0.12);
      if (wave <= 0 || wave >= 1) continue;
      paint
        ..color = Colors.white.withOpacity((1 - wave) * 0.24)
        ..strokeWidth = (1 - wave) * 3 + 0.5;
      canvas.drawCircle(origin, radius * Curves.easeOutCubic.transform(wave), paint);
    }

    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final angle = i * math.pi * 2 / 10;
      final distance = (18 + i % 3 * 12) + radius * 0.45 * progress;
      final offset = Offset(
        math.cos(angle) * distance,
        math.sin(angle) * distance * 0.55 + progress * progress * 24,
      );
      paint.color = Colors.white.withOpacity((1 - progress) * 0.65);
      canvas.drawCircle(origin + offset, (1 - progress) * (2 + i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRipplePainter oldDelegate) =>
      oldDelegate.wide != wide || oldDelegate.animation != animation;
}
