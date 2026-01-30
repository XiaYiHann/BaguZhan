import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// 路径进度横幅组件
///
/// 显示单元标题和副标题
/// Neo-Brutal风格横幅
class PathProgressBanner extends StatelessWidget {
  /// 单元标题
  final String title;

  /// 副标题
  final String subtitle;

  /// 背景色
  final Color backgroundColor;

  /// 文字颜色
  final Color textColor;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 外边距
  final EdgeInsetsGeometry margin;

  const PathProgressBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = NeoBrutalTheme.primary,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: NeoBrutalTheme.createBorder(),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMd),
        boxShadow: NeoBrutalTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: NeoBrutalTheme.styleHeadlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: NeoBrutalTheme.styleBodyLarge.copyWith(
              color: textColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 带图标的路径进度横幅
class PathProgressBannerWithIcon extends StatelessWidget {
  /// 单元标题
  final String title;

  /// 副标题
  final String subtitle;

  /// 图标
  final IconData icon;

  /// 背景色
  final Color backgroundColor;

  /// 文字颜色
  final Color textColor;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 外边距
  final EdgeInsetsGeometry margin;

  const PathProgressBannerWithIcon({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.backgroundColor = NeoBrutalTheme.primary,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: NeoBrutalTheme.createBorder(),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMd),
        boxShadow: NeoBrutalTheme.shadowMd,
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              border: Border.all(color: textColor, width: 2),
              borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSm),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // 文字区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: NeoBrutalTheme.styleBodyMedium.copyWith(
                    color: textColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
