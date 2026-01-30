import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// 路径分类数据模型
class PathCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int order;
  final int totalNodes;
  final int completedNodes;

  const PathCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    required this.totalNodes,
    required this.completedNodes,
  });

  /// 是否已锁定
  bool get isLocked => completedNodes == 0 && order > 1;

  /// 进度百分比
  double get progressPercent =>
      totalNodes > 0 ? completedNodes / totalNodes : 0.0;
}

/// 路径分类卡片组件
///
/// 显示分类信息：图标、名称、进度
/// Neo-Brutal风格卡片
class PathCategoryCard extends StatefulWidget {
  final PathCategoryModel category;
  final VoidCallback? onTap;

  const PathCategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  State<PathCategoryCard> createState() => _PathCategoryCardState();
}

class _PathCategoryCardState extends State<PathCategoryCard> {
  bool _isPressed = false;

  Color _getCategoryColor() {
    if (widget.category.isLocked) {
      return NeoBrutalTheme.lockedGray;
    }

    switch (widget.category.color) {
      case 'primary':
      case '#58CC02':
        return NeoBrutalTheme.primary;
      case 'secondary':
      case '#1CB0F6':
        return NeoBrutalTheme.secondary;
      case 'accent':
      case '#FFC800':
        return NeoBrutalTheme.accent;
      case 'error':
      case '#FF4B4B':
        return NeoBrutalTheme.error;
      default:
        // 尝试解析十六进制颜色
        try {
          return Color(
              int.parse(widget.category.color.replaceFirst('#', '0xFF')));
        } catch (_) {
          return NeoBrutalTheme.primary;
        }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.category.isLocked) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final isLocked = widget.category.isLocked;
    final progressText =
        '${widget.category.completedNodes}/${widget.category.totalNodes}';
    final statusText = isLocked ? ' (锁定)' : '';

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: NeoBrutalTheme.durationPress,
        curve: NeoBrutalTheme.curvePress,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: NeoBrutalTheme.createBorder(),
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMd),
          boxShadow: _isPressed
              ? NeoBrutalTheme.shadowPressed
              : NeoBrutalTheme.shadowMd,
        ),
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.identity(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  border: NeoBrutalTheme.createBorder(),
                  borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    widget.category.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: NeoBrutalTheme.styleHeadlineSmall.copyWith(
                        color: isLocked
                            ? Colors.grey.shade600
                            : NeoBrutalTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$progressText 个关卡 • 进度 $statusText',
                      style: NeoBrutalTheme.styleBodyMedium.copyWith(
                        color: isLocked
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 进度条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: widget.category.progressPercent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLocked ? Colors.grey.shade400 : color,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // 锁定图标或箭头
              if (isLocked)
                Icon(
                  Icons.lock,
                  color: Colors.grey.shade400,
                  size: 24,
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: NeoBrutalTheme.charcoal,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
