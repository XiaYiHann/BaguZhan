import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/neo_brutal_theme.dart';
import '../../core/device_id.dart';
import '../../data/models/path_node_model.dart' as model;
import '../providers/learning_path_provider.dart';
import '../widgets/neo/neo_bottom_nav.dart';
import '../widgets/neo/neo_path_node.dart';
import '../widgets/neo/neo_stat_bar.dart';
import '../widgets/path/character_dialog_widget.dart';
import 'path_category_page.dart'; // for TechStackModel

/// 学习路径地图页面
///
/// 垂直路径地图，显示学习节点
/// 使用 NeoStatBar 在顶部
/// 使用 NeoBottomNav 在底部
/// 支持左/中/右交替排列的节点
class LearningPathMapPage extends StatefulWidget {
  final TechStackModel techStack;
  final String categoryId;

  const LearningPathMapPage({
    super.key,
    required this.techStack,
    required this.categoryId,
  });

  @override
  State<LearningPathMapPage> createState() => _LearningPathMapPageState();
}

class _LearningPathMapPageState extends State<LearningPathMapPage> {
  // 底部导航选中项
  String _selectedNavId = 'path';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final deviceId = await DeviceId.get();
    final provider = context.read<LearningPathProvider>();
    provider.setUserId(deviceId);
    await provider.loadNodes(widget.categoryId);
  }

  Future<void> _refreshData() async {
    final provider = context.read<LearningPathProvider>();
    await provider.loadNodes(widget.categoryId);
  }

  /// 获取节点的水平对齐方式（交替排列）
  Alignment _getNodeAlignment(int index) {
    switch (index % 3) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  void _onNodeTap(model.PathNodeModel node) {
    if (node.status == model.NodeStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${node.title} 尚未解锁'),
          backgroundColor: NeoBrutalTheme.charcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMd),
            side: const BorderSide(
              color: NeoBrutalTheme.charcoal,
              width: 2,
            ),
          ),
        ),
      );
      return;
    }

    // 导航到题目页面
    Navigator.of(context).pushNamed(
      '/quiz',
      arguments: {
        'nodeId': node.id,
        'nodeTitle': node.title,
        'techStack': widget.techStack,
        'categoryId': widget.categoryId,
      },
    );
  }

  void _onNavTap(String navId) {
    setState(() {
      _selectedNavId = navId;
    });

    // 处理导航切换
    switch (navId) {
      case 'path':
        // 已经在路径页面，不做操作
        break;
      case 'rank':
        Navigator.of(context).pushNamed('/rank');
        break;
      case 'drill':
        Navigator.of(context).pushNamed('/drill');
        break;
      case 'inbox':
        Navigator.of(context).pushNamed('/inbox');
        break;
      case 'me':
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LearningPathProvider>(
      builder: (context, provider, child) {
        final nodes = provider.nodes;
        final isLoading = provider.isLoadingNodes;
        final errorMessage = provider.errorMessage;
        final completedCount =
            nodes.where((n) => n.status == model.NodeStatus.completed).length;

        return Scaffold(
          backgroundColor: NeoBrutalTheme.background,
          body: Column(
            children: [
              // 顶部统计栏
              NeoStatBar.standard(
                streak: 12,
                accuracy: 0.85,
                totalQuestions: 156,
                xp: 2850,
              ),

              // 页面标题栏
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: NeoBrutalTheme.spaceMd,
                  vertical: NeoBrutalTheme.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: NeoBrutalTheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: NeoBrutalTheme.borderColor,
                      width: NeoBrutalTheme.borderWidth,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      // 返回按钮
                      GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NeoBrutalTheme.surface,
                            border: NeoBrutalTheme.createBorder(),
                            borderRadius:
                                BorderRadius.circular(NeoBrutalTheme.radiusSm),
                            boxShadow: NeoBrutalTheme.shadowSm,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: NeoBrutalTheme.charcoal,
                          ),
                        ),
                      ),

                      const SizedBox(width: NeoBrutalTheme.spaceMd),

                      // 标题
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryId,
                              style: NeoBrutalTheme.styleHeadlineSmall,
                            ),
                            Text(
                              '${widget.techStack.name} • $completedCount/${nodes.length} 完成',
                              style: NeoBrutalTheme.styleBodyMedium.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 路径地图内容
              Expanded(
                child: _buildContent(
                  provider: provider,
                  nodes: nodes,
                  isLoading: isLoading,
                  errorMessage: errorMessage,
                  completedCount: completedCount,
                ),
              ),

              // 底部导航栏
              NeoBottomNav(
                items: defaultNavItems,
                selectedId: _selectedNavId,
                onTap: _onNavTap,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建内容区域
  Widget _buildContent({
    required LearningPathProvider provider,
    required List<model.PathNodeModel> nodes,
    required bool isLoading,
    required String? errorMessage,
    required int completedCount,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: NeoBrutalTheme.primary,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: NeoBrutalTheme.styleBodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: NeoBrutalTheme.spaceMd),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: NeoBrutalTheme.primary,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (nodes.isEmpty) {
      return const Center(
        child: Text('暂无学习节点'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: NeoBrutalTheme.primary,
      backgroundColor: NeoBrutalTheme.surface,
      child: CustomScrollView(
        slivers: [
          // 角色对话框（显示当前单元信息）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(NeoBrutalTheme.spaceMd),
              child: Center(
                child: CharacterDialogWidget(
                  message:
                      '${widget.categoryId} - 共 ${nodes.length} 个关卡，已完成 $completedCount 个',
                  characterIcon: widget.techStack.icon,
                  avatarBackgroundColor: NeoBrutalTheme.primary,
                ),
              ),
            ),
          ),

          // 路径节点列表
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoBrutalTheme.spaceMd,
              vertical: NeoBrutalTheme.spaceLg,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= nodes.length) return null;

                  final node = nodes[index];
                  final alignment = _getNodeAlignment(index);

                  return _buildNodeItem(
                    node: node,
                    alignment: alignment,
                    isLast: index == nodes.length - 1,
                  );
                },
                childCount: nodes.length,
              ),
            ),
          ),

          // 底部留白
          const SliverToBoxAdapter(
            child: SizedBox(height: NeoBrutalTheme.spaceXl),
          ),
        ],
      ),
    );
  }

  /// 构建单个节点项
  Widget _buildNodeItem({
    required model.PathNodeModel node,
    required Alignment alignment,
    required bool isLast,
  }) {
    // 将 NodeStatus 转换为 PathNodeStatus
    final pathNodeStatus = _mapNodeStatus(node.status);

    return Container(
      margin: const EdgeInsets.only(bottom: NeoBrutalTheme.spaceLg),
      child: Stack(
        children: [
          // 节点组件 - 使用 NeoPathNode
          Align(
            alignment: alignment,
            child: NeoPathNode(
              status: pathNodeStatus,
              label: node.title,
              size: 72,
              onTap: node.status != model.NodeStatus.locked
                  ? () => _onNodeTap(node)
                  : null,
            ),
          ),

          // 如果不是最后一个节点，显示连接线
          if (!isLast)
            Positioned(
              left: 0,
              right: 0,
              top: 80, // 节点下方
              child: Center(
                child: NeoPathConnection(
                  height: 60,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 将旧的 NodeStatus 映射到新的 PathNodeStatus
  PathNodeStatus _mapNodeStatus(model.NodeStatus status) {
    switch (status) {
      case model.NodeStatus.completed:
        return PathNodeStatus.completed;
      case model.NodeStatus.unlocked:
        return PathNodeStatus.current;
      case model.NodeStatus.locked:
        return PathNodeStatus.locked;
    }
  }
}
