import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// 三角形绘制器
///
/// 用于绘制对话框下方的小三角指针
class TrianglePainter extends CustomPainter {
  final Color color;
  final double size;

  TrianglePainter({
    this.color = NeoBrutalTheme.charcoal,
    this.size = 16.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size, 0);
    path.lineTo(size / 2, size * 0.866); // 等边三角形高度
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 角色对话框组件
///
/// 漫画风格对话框，包含：
/// - 对话框主体（带边框和圆角）
/// - 下方小三角指针
/// - 角色头像（带硬阴影）
/// - 消息文本
class CharacterDialogWidget extends StatelessWidget {
  /// 对话框消息文本
  final String message;

  /// 角色图标/表情符号
  final String characterIcon;

  /// 对话框背景色
  final Color backgroundColor;

  /// 头像背景色
  final Color avatarBackgroundColor;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 最大宽度
  final double maxWidth;

  const CharacterDialogWidget({
    super.key,
    required this.message,
    required this.characterIcon,
    this.backgroundColor = Colors.white,
    this.avatarBackgroundColor = NeoBrutalTheme.secondary,
    this.padding = const EdgeInsets.all(16.0),
    this.maxWidth = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 对话框主体
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: NeoBrutalTheme.createBorder(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: NeoBrutalTheme.shadowMd,
          ),
          child: Text(
            message,
            style: NeoBrutalTheme.styleBodyLarge.copyWith(
              color: NeoBrutalTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 小三角指针
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: CustomPaint(
            size: const Size(16, 14),
            painter: TrianglePainter(
              color: NeoBrutalTheme.charcoal,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 角色头像
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: avatarBackgroundColor,
            shape: BoxShape.circle,
            border: NeoBrutalTheme.createBorder(),
            boxShadow: NeoBrutalTheme.shadowMd,
          ),
          child: Center(
            child: Text(
              characterIcon,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }
}

/// 简化版角色对话框（仅对话框，无头像）
class CharacterDialogOnly extends StatelessWidget {
  /// 对话框消息文本
  final String message;

  /// 对话框背景色
  final Color backgroundColor;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 最大宽度
  final double maxWidth;

  /// 是否显示下方三角
  final bool showTriangle;

  const CharacterDialogOnly({
    super.key,
    required this.message,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16.0),
    this.maxWidth = 280.0,
    this.showTriangle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 对话框主体
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: NeoBrutalTheme.createBorder(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: NeoBrutalTheme.shadowMd,
          ),
          child: Text(
            message,
            style: NeoBrutalTheme.styleBodyLarge.copyWith(
              color: NeoBrutalTheme.charcoal,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // 小三角指针
        if (showTriangle)
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: CustomPaint(
              size: const Size(16, 14),
              painter: TrianglePainter(
                color: NeoBrutalTheme.charcoal,
              ),
            ),
          ),
      ],
    );
  }
}
