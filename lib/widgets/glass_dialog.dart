import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final reduceMotion = MediaQuery.of(context).disableAnimations;
  final route = RawDialogRoute<T>(
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x660F172A),
    transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 280),
    pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
      child: builder(context),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
  final result = await Navigator.of(context, rootNavigator: true).push<T>(route);
  // Let the dialog settle back before the scorecard reacts.
  await route.completed;
  return result;
}

class GlassDialog extends StatelessWidget {
  final Widget child;

  const GlassDialog({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.85)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.97),
                    const Color(0xFFF1F5FC).withOpacity(0.90),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
