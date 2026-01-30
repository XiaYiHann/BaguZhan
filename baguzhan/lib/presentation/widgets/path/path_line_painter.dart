import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// 路径连线绘制器
///
/// 绘制垂直虚线连接各个节点
/// 支持高亮已完成的路段
class PathLinePainter extends CustomPainter {
  /// 已完成的路段数量
  final int completedSegments;

  /// 总路段数量
  final int totalSegments;

  /// 虚线段长度
  final double dashLength;

  /// 虚线间隔
  final double dashGap;

  /// 线宽
  final double lineWidth;

  PathLinePainter({
    required this.completedSegments,
    required this.totalSegments,
    this.dashLength = 8.0,
    this.dashGap = 4.0,
    this.lineWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalSegments <= 0) return;

    final paint = Paint()
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    final segmentHeight = size.height / totalSegments;
    final centerX = size.width / 2;

    for (int i = 0; i < totalSegments; i++) {
      final startY = i * segmentHeight;
      final endY = (i + 1) * segmentHeight;
      final isCompleted = i < completedSegments;

      // 设置颜色：已完成用主色，未完成用灰色
      paint.color =
          isCompleted ? NeoBrutalTheme.primary : NeoBrutalTheme.pathLine;

      // 绘制虚线
      _drawDashedLine(
        canvas,
        Offset(centerX, startY),
        Offset(centerX, endY),
        paint,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final totalDistance = (end - start).distance;
    final direction = (end - start) / totalDistance;

    double currentDistance = 0;
    bool isDrawing = true;

    while (currentDistance < totalDistance) {
      final segmentLength = isDrawing ? dashLength : dashGap;

      if (isDrawing) {
        final segmentStart = start + direction * currentDistance;
        final segmentEnd = start +
            direction *
                (currentDistance + segmentLength).clamp(0, totalDistance);
        canvas.drawLine(segmentStart, segmentEnd, paint);
      }

      currentDistance += segmentLength;
      isDrawing = !isDrawing;
    }
  }

  @override
  bool shouldRepaint(covariant PathLinePainter oldDelegate) {
    return oldDelegate.completedSegments != completedSegments ||
        oldDelegate.totalSegments != totalSegments ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.lineWidth != lineWidth;
  }
}

/// 路径连线组件
///
/// 使用CustomPaint绘制垂直虚线连接节点
class PathLineWidget extends StatelessWidget {
  /// 已完成的路段数量
  final int completedSegments;

  /// 总路段数量
  final int totalSegments;

  /// 线宽
  final double width;

  /// 高度
  final double height;

  const PathLineWidget({
    super.key,
    required this.completedSegments,
    required this.totalSegments,
    this.width = 14.0,
    this.height = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: PathLinePainter(
        completedSegments: completedSegments,
        totalSegments: totalSegments,
      ),
    );
  }
}
