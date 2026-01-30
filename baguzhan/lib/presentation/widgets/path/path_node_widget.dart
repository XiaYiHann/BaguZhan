import 'package:flutter/material.dart';
import '../../../core/theme/neo_brutal_theme.dart';

/// 路径节点状态
enum NodeStatus { locked, unlocked, completed, current }

/// 路径节点数据模型
class PathNodeModel {
  final String id;
  final String title;
  final String icon;
  final String color;
  final int order;
  final NodeStatus status;
  final List<String> questionIds;
  final String? prerequisiteNodeId;
  final int estimatedMinutes;

  const PathNodeModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.order,
    required this.status,
    required this.questionIds,
    this.prerequisiteNodeId,
    this.estimatedMinutes = 10,
  });
}

/// 路径节点组件
///
/// 支持4种状态：locked, unlocked, completed, current
/// Neo-Brutal风格，带有硬阴影和按压动画
class PathNodeWidget extends StatefulWidget {
  final PathNodeModel node;
  final Alignment alignment;
  final VoidCallback? onTap;
  final double size;

  const PathNodeWidget({
    super.key,
    required this.node,
    this.alignment = Alignment.center,
    this.onTap,
    this.size = 64.0,
  });

  @override
  State<PathNodeWidget> createState() => _PathNodeWidgetState();
}

class _PathNodeWidgetState extends State<PathNodeWidget>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.node.status == NodeStatus.current) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PathNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.node.status == NodeStatus.current) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getNodeColor() {
    switch (widget.node.color) {
      case 'primary':
        return NeoBrutalTheme.primary;
      case 'secondary':
        return NeoBrutalTheme.secondary;
      case 'accent':
        return NeoBrutalTheme.accent;
      case 'error':
        return NeoBrutalTheme.error;
      case 'diamond':
        return NeoBrutalTheme.diamond;
      default:
        return NeoBrutalTheme.primary;
    }
  }

  BoxDecoration _getDecoration() {
    final baseColor = _getNodeColor();

    switch (widget.node.status) {
      case NodeStatus.completed:
        return BoxDecoration(
          color: baseColor,
          border: NeoBrutalTheme.createBorder(),
          borderRadius: BorderRadius.circular(999),
          boxShadow: _isPressed
              ? NeoBrutalTheme.shadowPressed
              : NeoBrutalTheme.shadowNodeActive,
        );
      case NodeStatus.unlocked:
        return BoxDecoration(
          color: baseColor,
          border: NeoBrutalTheme.createBorder(),
          borderRadius: BorderRadius.circular(999),
          boxShadow: _isPressed
              ? NeoBrutalTheme.shadowPressed
              : NeoBrutalTheme.shadowNodeActive,
        );
      case NodeStatus.current:
        return BoxDecoration(
          color: const Color(0xFFFF69B4), // 粉色高亮
          border: NeoBrutalTheme.createBorder(),
          borderRadius: BorderRadius.circular(999),
          boxShadow: _isPressed
              ? NeoBrutalTheme.shadowPressed
              : NeoBrutalTheme.shadowNodeActive,
        );
      case NodeStatus.locked:
        return BoxDecoration(
          color: NeoBrutalTheme.lockedGray,
          border: Border.all(color: Colors.grey.shade400, width: 3),
          borderRadius: BorderRadius.circular(999),
          boxShadow: NeoBrutalTheme.shadowNodeLocked,
        );
    }
  }

  Widget _buildIcon() {
    final iconSize = widget.size * 0.5;

    switch (widget.node.status) {
      case NodeStatus.locked:
        return Icon(
          Icons.lock,
          size: iconSize,
          color: Colors.grey.shade600,
        );
      case NodeStatus.completed:
        return Icon(
          Icons.check,
          size: iconSize,
          color: Colors.white,
        );
      case NodeStatus.current:
      case NodeStatus.unlocked:
        return Text(
          widget.node.icon,
          style: TextStyle(fontSize: iconSize),
        );
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.node.status != NodeStatus.locked) {
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
    Widget nodeContent = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: NeoBrutalTheme.durationPress,
        curve: NeoBrutalTheme.curvePress,
        width: widget.size,
        height: widget.size,
        decoration: _getDecoration(),
        transform: _isPressed
            ? Matrix4.translationValues(4, 4, 0)
            : Matrix4.identity(),
        child: Center(child: _buildIcon()),
      ),
    );

    // 当前状态添加脉冲动画
    if (widget.node.status == NodeStatus.current) {
      nodeContent = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.08);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: nodeContent,
      );
    }

    return Align(
      alignment: widget.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          nodeContent,
          const SizedBox(height: 8),
          Text(
            widget.node.title,
            style: NeoBrutalTheme.styleBodyMedium.copyWith(
              color: widget.node.status == NodeStatus.locked
                  ? Colors.grey.shade500
                  : NeoBrutalTheme.charcoal,
              fontWeight: widget.node.status == NodeStatus.current
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
