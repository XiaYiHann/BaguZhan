import 'package:flutter/material.dart';
import '../../core/theme/neo_brutal_theme.dart';
import '../widgets/neo/neo_stat_bar.dart';
import '../widgets/path/path_category_card.dart';

/// 技术栈数据模型
class TechStackModel {
  final String id;
  final String name;
  final String icon;
  final String description;

  const TechStackModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}

/// 路径分类页面
///
/// 显示特定技术栈下的所有分类列表
/// 使用 NeoStatBar 在顶部显示统计信息
/// 使用 PathCategoryCard 显示每个分类
class PathCategoryPage extends StatefulWidget {
  final TechStackModel techStack;

  const PathCategoryPage({
    super.key,
    required this.techStack,
  });

  @override
  State<PathCategoryPage> createState() => _PathCategoryPageState();
}

class _PathCategoryPageState extends State<PathCategoryPage> {
  bool _isLoading = true;
  List<PathCategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // 模拟加载数据
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // 示例数据 - 实际应从API或本地数据库获取
    final mockCategories = [
      const PathCategoryModel(
        id: 'basics',
        name: '基础语法',
        icon: '📚',
        color: 'primary',
        order: 1,
        totalNodes: 10,
        completedNodes: 8,
      ),
      const PathCategoryModel(
        id: 'oop',
        name: '面向对象',
        icon: '🏗️',
        color: 'secondary',
        order: 2,
        totalNodes: 12,
        completedNodes: 5,
      ),
      const PathCategoryModel(
        id: 'collections',
        name: '集合框架',
        icon: '📦',
        color: 'accent',
        order: 3,
        totalNodes: 8,
        completedNodes: 0,
      ),
      const PathCategoryModel(
        id: 'concurrency',
        name: '并发编程',
        icon: '⚡',
        color: 'error',
        order: 4,
        totalNodes: 15,
        completedNodes: 0,
      ),
      const PathCategoryModel(
        id: 'io',
        name: 'IO与网络',
        icon: '🌐',
        color: 'diamond',
        order: 5,
        totalNodes: 10,
        completedNodes: 0,
      ),
    ];

    setState(() {
      _categories = mockCategories;
      _isLoading = false;
    });
  }

  void _onCategoryTap(PathCategoryModel category) {
    if (category.isLocked) {
      // 显示锁定提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.name} 尚未解锁，请先完成前面的分类'),
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

    // 导航到学习路径地图页面
    Navigator.of(context).pushNamed(
      '/learning-path',
      arguments: {
        'techStack': widget.techStack,
        'categoryId': category.id,
      },
    );
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

                  // 技术栈图标和名称
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: NeoBrutalTheme.primary,
                      border: NeoBrutalTheme.createBorder(),
                      borderRadius:
                          BorderRadius.circular(NeoBrutalTheme.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        widget.techStack.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  const SizedBox(width: NeoBrutalTheme.spaceSm),

                  // 标题
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.techStack.name,
                          style: NeoBrutalTheme.styleHeadlineSmall,
                        ),
                        Text(
                          widget.techStack.description,
                          style: NeoBrutalTheme.styleBodyMedium.copyWith(
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 分类列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: NeoBrutalTheme.primary,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCategories,
                    color: NeoBrutalTheme.primary,
                    backgroundColor: NeoBrutalTheme.surface,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: NeoBrutalTheme.spaceMd,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return PathCategoryCard(
                          category: category,
                          onTap: () => _onCategoryTap(category),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
