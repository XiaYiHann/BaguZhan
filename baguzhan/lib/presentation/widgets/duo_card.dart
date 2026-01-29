import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class DuoCard extends StatelessWidget {
  const DuoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderWidth = AppTheme.borderWidth,
    this.radius = AppTheme.radiusCard,
    this.boxShadow = const [AppTheme.shadowDown],
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final List<BoxShadow> boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppTheme.outlineStrong,
          width: borderWidth,
        ),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
