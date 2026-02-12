import 'package:flutter/material.dart';
import '../../core/theme/neo_brutal_theme.dart';
import '../widgets/neo/neo_bottom_nav.dart';
import '../widgets/neo/neo_path_node.dart';
import '../widgets/neo/neo_stat_bar.dart';
import '../widgets/path/character_dialog_widget.dart';
import '../widgets/path/path_node_widget.dart'; // 保留数据模型
import 'path_category_page.dart';

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
  bool _isLoading = true;
  String _categoryName = '';
  List<PathNodeModel> _nodes = [];
  int _completedCount = 0;

  // 底部导航选中项
  String _selectedNavId = 'path';

  @override
  void initState() {
    super.initState();
    _loadPathData();
  }

  Future<void> _loadPathData() async {
    // 模拟加载数据
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // 根据 categoryId 模拟不同的分类数据
    final categoryNames = {
      'basics': '基础语法',
      'oop': '面向对象',
      'collections': '集合框架',
      'concurrency': '并发编程',
      'io': 'IO与网络',
    };

    // 示例节点数据
    final mockNodes = [
      const PathNodeModel(
        id: 'node_1',
        title: 'Hello World',
        icon: '👋',
        color: 'primary',
        order: 1,
        status: NodeStatus.completed,
        questionIds: ['q1', 'q2', 'q3'],
        estimatedMinutes: 5,
      ),
      const PathNodeModel(
        id: 'node_2',
        title: '变量与类型',
        icon: '📦',
        color: 'primary',
        order: 2,
        status: NodeStatus.completed,
        questionIds: ['q4', 'q5', 'q6'],
        prerequisiteNodeId: 'node_1',
        estimatedMinutes: 10,
      ),
      const PathNodeModel(
        id: 'node_3',
        title: '运算符',
        icon: '➕',
        color: 'secondary',
        order: 3,
        status: NodeStatus.completed,
        questionIds: ['q7', 'q8'],
        prerequisiteNodeId: 'node_2',
        estimatedMinutes: 8,
      ),
      const PathNodeModel(
        id: 'node_4',
        title: '条件语句',
        icon: '🔀',
        color: 'secondary',
        order: 4,
        status: NodeStatus.current,
        questionIds: ['q9', 'q10', 'q11', 'q12'],
        prerequisiteNodeId: 'node_3',
        estimatedMinutes: 12,
      ),
      const PathNodeModel(
        id: 'node_5',
        title: '循环结构',
        icon: '🔄',
        color: 'accent',
        order: 5,
        status: NodeStatus.locked,
        questionIds: ['q13', 'q14', 'q15'],
        prerequisiteNodeId: 'node_4',
        estimatedMinutes: 15,
      ),
      const PathNodeModel(
        id: 'node_6',
        title: '数组基础',
        icon: '📊',
        color: 'accent',
        order: 6,
        status: NodeStatus.locked,
        questionIds: ['q16', 'q17', 'q18'],
        prerequisiteNodeId: 'node_5',
        estimatedMinutes: 10,
      ),
      const PathNodeModel(
        id: 'node_7',
        title: '方法定义',
        icon: '🔧',
        color: 'error',
        order: 7,
        status: NodeStatus.locked,
        questionIds: ['q19', 'q20'],
        prerequisiteNodeId: 'node_6',
        estimatedMinutes: 12,
      ),
      const PathNodeModel(
        id: 'node_8',
        title: '综合练习',
        icon: '🏆',
        color: 'diamond',
        order: 8,
        status: NodeStatus.locked,
        questionIds: ['q21', 'q22', 'q23', 'q24', 'q25'],
        prerequisiteNodeId: 'node_7',
        estimatedMinutes: 20,
      ),
    ];

    // 计算已完成数量
    final completed =
        mockNodes.where((n) => n.status == NodeStatus.completed).length;

    setState(() {
      _categoryName = categoryNames[widget.categoryId] ?? '学习路径';
      _nodes = mockNodes;
      _completedCount = completed;
      _isLoading = false;
    });
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

  void _onNodeTap(PathNodeModel node) {
    if (node.status == NodeStatus.locked) {
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
                          _categoryName,
                          style: NeoBrutalTheme.styleHeadlineSmall,
                        ),
                        Text(
                          '${widget.techStack.name} • $_completedCount/${_nodes.length} 完成',
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: NeoBrutalTheme.primary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPathData,
                    color: NeoBrutalTheme.primary,
                    backgroundColor: NeoBrutalTheme.surface,
                    child: CustomScrollView(
                      slivers: [
                        // 角色对话框（显示当前单元信息）
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(NeoBrutalTheme.spaceMd),
                            child: Center(
                              child: CharacterDialogWidget(
                                message:
                                    '$_categoryName - 共 ${_nodes.length} 个关卡，已完成 $_completedCount 个',
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
                                if (index >= _nodes.length) return null;

                                final node = _nodes[index];
                                final alignment = _getNodeAlignment(index);

                                return _buildNodeItem(
                                  node: node,
                                  alignment: alignment,
                                  isLast: index == _nodes.length - 1,
                                );
                              },
                              childCount: _nodes.length,
                            ),
                          ),
                        ),

                        // 底部留白
                        const SliverToBoxAdapter(
                          child: SizedBox(height: NeoBrutalTheme.spaceXl),
                        ),
                      ],
                    ),
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
  }

  /// 构建单个节点项
  Widget _buildNodeItem({
    required PathNodeModel node,
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
              onTap: node.status != NodeStatus.locked
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
  PathNodeStatus _mapNodeStatus(NodeStatus status) {
    switch (status) {
      case NodeStatus.completed:
        return PathNodeStatus.completed;
      case NodeStatus.current:
      case NodeStatus.unlocked:
        return PathNodeStatus.current;
      case NodeStatus.locked:
        return PathNodeStatus.locked;
    }
  }
}
