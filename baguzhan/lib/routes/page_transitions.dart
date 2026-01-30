import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class DuoPageTransition<T> extends PageRouteBuilder<T> {
  DuoPageTransition({required this.child})
      : super(
          pageBuilder: (context, animation, _) => child,
          transitionDuration: AppTheme.durationPanel,
          reverseTransitionDuration: AppTheme.durationPanel,
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppTheme.curvePanel,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );

  final Widget child;
}
