import 'package:flutter/material.dart';

import 'browser_theme.dart';

class ModalThemeObserver extends NavigatorObserver {
  final Set<Route<dynamic>> _modals = {};

  void _update() => setBrowserModalOpen(_modals.isNotEmpty);

  void _removeModal(Route<dynamic>? route) {
    if (route is! PopupRoute) return;
    route.completed.then((_) {
      _modals.remove(route);
      _update();
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) _modals.add(route);
    _update();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _removeModal(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _removeModal(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _removeModal(oldRoute);
    if (newRoute is PopupRoute) _modals.add(newRoute);
    _update();
  }
}
