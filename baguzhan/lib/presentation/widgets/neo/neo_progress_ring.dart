/// Neo-Brutal 风格环形进度条组件
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';

/// Neo-Brutal 环形进度条
class NeoProgressRing extends StatefulWidget {
  const NeoProgressRing({
    super.key,
    required this.progress,
    this.size = 144,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.child,
    this.showPercentage = false,
  });

  /// 进度值 (0.0 - 1.0)
  final double progress;

  /// 圆环尺寸
  final double size;

  /// 线条宽度
  final double strokeWidth;

  /// 背景圆环颜色
  final Color? backgroundColor;

  /// 进度圆环颜色
  final Color? progressColor;

  /// 中心内容
  final Widget? child;

  /// 是否显示百分比文字
  final bool showPercentage;

  @override
  State<NeoProgressRing> createState() => _NeoProgressRingState();
}

class _NeoProgressRingState extends State<NeoProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: NeoBrutalTheme.durationProgress,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: NeoBrutalTheme.curveProgress),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(NeoProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: NeoBrutalTheme.curveProgress,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.backgroundColor ?? NeoBrutalTheme.pathLine;
    final progressColor =
        widget.progressColor ?? NeoBrutalTheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: _animation.value.clamp(0.0, 1.0),
              strokeWidth: widget.strokeWidth,
              backgroundColor: bgColor,
              progressColor: progressColor,
            ),
            child: widget.child ??
                (widget.showPercentage
                    ? Center(
                        child: Text(
                          '${(_animation.value * 100).toInt()}%',
                          style: NeoBrutalTheme.styleHeadlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : child),
          );
        },
      ),
    );
  }
}

/// 环形进度条画笔
class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);

    // 进度圆弧
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // 从顶部开始
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 带中央按钮的进度环（用于学习仪表板）
class NeoProgressButton extends StatelessWidget {
  const NeoProgressButton({
    super.key,
    required this.progress,
    required this.onPressed,
    this.size = 144,
    this.buttonIcon,
    this.buttonLabel,
    this.strokeWidth = 8,
  });

  final double progress;
  final VoidCallback? onPressed;
  final double size;
  final IconData? buttonIcon;
  final String? buttonLabel;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 32, // 为阴影留空间
      height: size + 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 进度环
          NeoProgressRing(
            progress: progress,
            size: size,
            strokeWidth: strokeWidth,
          ),
          // 中央按钮
          Positioned(
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NeoBrutalTheme.borderColor,
                    width: NeoBrutalTheme.borderWidth,
                  ),
                  boxShadow: NeoBrutalTheme.shadowLg,
                ),
                child: Center(
                  child: buttonIcon != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              buttonIcon,
                              color: Colors.white,
                              size: size * 0.25,
                            ),
                            if (buttonLabel != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                buttonLabel!,
                                style: const TextStyle(
                                  color: NeoBrutalTheme.charcoal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ],
                        )
                      : const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 36,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
