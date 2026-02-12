/// Neo-Brutal 风格学习路径节点组件
///
/// 用于展示学习路径上的不同节点状态
library;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';

/// 节点状态
enum PathNodeStatus {
  completed, // 已完成 - 绿色
  current,   // 进行中 - 粉色
  locked,    // 锁定 - 灰色
}

/// 学习路径节点组件
class NeoPathNode extends StatefulWidget {
  const NeoPathNode({
    super.key,
    required this.status,
    required this.label,
    this.size = 96,
    this.onTap,
    this.icon,
  });

  final PathNodeStatus status;
  final String label;
  final double size;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  State<NeoPathNode> createState() => _NeoPathNodeState();
}

class _NeoPathNodeState extends State<NeoPathNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.status == PathNodeStatus.current) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBgColor() {
    switch (widget.status) {
      case PathNodeStatus.completed:
        return NeoBrutalTheme.primary;
      case PathNodeStatus.current:
        return const Color(0xFFF06); // 粉色
      case PathNodeStatus.locked:
        return NeoBrutalTheme.lockedGray;
    }
  }

  Color _getIconColor() {
    switch (widget.status) {
      case PathNodeStatus.completed:
      case PathNodeStatus.current:
        return Colors.white;
      case PathNodeStatus.locked:
        return NeoBrutalTheme.charcoal.withOpacity(0.4);
    }
  }

  List<BoxShadow> _getShadow() {
    if (widget.status == PathNodeStatus.locked) {
      return const [
        BoxShadow(
          color: NeoBrutalTheme.lockedGray,
          offset: Offset(0, 8),
          blurRadius: 0,
        ),
      ];
    }
    return NeoBrutalTheme.shadowNodeActive;
  }

  Border? _getBorder() {
    if (widget.status == PathNodeStatus.locked) {
      return Border.all(
        color: NeoBrutalTheme.charcoal.withOpacity(0.3),
        width: 2,
        style: BorderStyle.solid,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.status == PathNodeStatus.locked;

    return GestureDetector(
      onTap: isLocked ? null : widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 节点圆圈
          if (widget.status == PathNodeStatus.current)
            // 带脉冲动画的当前节点
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: _buildNode(),
                );
              },
            )
          else
            _buildNode(),

          const SizedBox(height: 16),

          // 标签
          _buildLabel(),
        ],
      ),
    );
  }

  Widget _buildNode() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: _getBgColor(),
        border: _getBorder(),
        borderRadius: BorderRadius.circular(widget.size / 2),
        boxShadow: _getShadow(),
      ),
      child: Center(
        child: widget.icon != null
            ? Icon(
                widget.icon!,
                color: _getIconColor(),
                size: widget.size * 0.4,
              )
            : Icon(
                _getDefaultIcon(),
                color: _getIconColor(),
                size: widget.size * 0.4,
              ),
      ),
    );
  }

  Widget _buildLabel() {
    final labelColor = widget.status == PathNodeStatus.locked
        ? NeoBrutalTheme.charcoal.withOpacity(0.4)
        : NeoBrutalTheme.charcoal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: labelColor,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSm),
      ),
      child: Text(
        widget.label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    switch (widget.status) {
      case PathNodeStatus.completed:
        return Icons.check;
      case PathNodeStatus.current:
        return Icons.play_arrow;
      case PathNodeStatus.locked:
        return Icons.lock;
    }
  }
}

/// 路径连接线组件
class NeoPathConnection extends StatelessWidget {
  const NeoPathConnection({
    super.key,
    this.height = 80,
    this.width = 14,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NeoBrutalTheme.pathLine,
        border: Border.all(
          color: NeoBrutalTheme.charcoal,
          width: 2,
        ),
      ),
    );
  }
}

/// 路径图组件
class NeoPathMap extends StatelessWidget {
  const NeoPathMap({
    super.key,
    required this.nodes,
    this.onNodeTap,
  });

  final List<NeoPathNodeData> nodes;
  final ValueChanged<int>? onNodeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < nodes.length; i++) ...[
          if (i > 0)
            NeoPathConnection(
              height: nodes[i].gap ?? 80,
            ),
          NeoPathNode(
            status: nodes[i].status,
            label: nodes[i].label,
            icon: nodes[i].icon,
            onTap: nodes[i].status != PathNodeStatus.locked
                ? () => onNodeTap?.call(i)
                : null,
          ),
        ],
      ],
    );
  }
}

/// 路径节点数据
class NeoPathNodeData {
  const NeoPathNodeData({
    required this.status,
    required this.label,
    this.icon,
    this.gap = 80.0,
  });

  final PathNodeStatus status;
  final String label;
  final IconData? icon;
  final double gap;
}
