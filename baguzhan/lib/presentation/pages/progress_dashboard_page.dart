/// 学习进度仪表板页面
///
/// 游戏化的学习主页，展示学习进度、统计数据和操作入口
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/neo_brutal_theme.dart';
import '../providers/learning_progress_provider.dart';
import '../widgets/neo/neo_bottom_nav.dart';
import '../widgets/neo/neo_icon_button.dart';
import '../widgets/neo/neo_progress_ring.dart';
import '../widgets/neo/neo_stat_bar.dart';
import '../widgets/neo/neo_unit_banner.dart';

/// 学习进度仪表板页面
class ProgressDashboardPage extends StatefulWidget {
  const ProgressDashboardPage({super.key});

  @override
  State<ProgressDashboardPage> createState() => _ProgressDashboardPageState();
}

class _ProgressDashboardPageState extends State<ProgressDashboardPage> {
  String _selectedNavId = 'path';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      body: SafeArea(
        child: Consumer<LearningProgressProvider>(
          builder: (context, provider, child) {
            final progress = provider.progress;

            return Column(
              children: [
                // 顶部统计栏
                NeoStatBar.standard(
                  streak: progress?.currentStreak ?? 0,
                  accuracy: progress?.accuracyRate ?? 0.0,
                  totalQuestions: progress?.totalAnswered ?? 0,
                  xp: (progress?.totalCorrect ?? 0) * 10,
                ),

                // 主内容区
                Expanded(
                  child: Stack(
                    children: [
                      // 中央内容
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 单元横幅
                            NeoUnitBanner(
                              unit: 1,
                              part: 7,
                              topic: 'JavaScript Closures',
                              subtitle: 'Master memory & scope',
                            ),

                            const SizedBox(height: 48),

                            // 环形进度按钮
                            NeoProgressButton(
                              progress: 0.75,
                              size: 160,
                              buttonIcon: Icons.star,
                              buttonLabel: 'SLASH!',
                              onPressed: () {
                                // 跳转到答题页面
                                Navigator.of(context).pushNamed('/quiz');
                              },
                            ),
                          ],
                        ),
                      ),

                      // 右侧功能图标组
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 80,
                        child: NeoIconButtonGroup(
                          buttons: [
                            NeoIconButtonData(
                              icon: Icons.description_outlined,
                              backgroundColor: NeoBrutalTheme.surface,
                              tooltip: '错题本',
                              onPressed: () {
                                Navigator.of(context).pushNamed('/wrong-book');
                              },
                            ),
                            NeoIconButtonData(
                              icon: Icons.grade_outlined,
                              backgroundColor: NeoBrutalTheme.surface,
                              tooltip: '收藏',
                              onPressed: () {},
                            ),
                            NeoIconButtonData(
                              icon: Icons.history_outlined,
                              backgroundColor: NeoBrutalTheme.surface,
                              tooltip: '历史',
                              onPressed: () {},
                            ),
                            NeoIconButtonData(
                              icon: Icons.settings_outlined,
                              backgroundColor: NeoBrutalTheme.surface,
                              tooltip: '设置',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // 底部导航
      bottomNavigationBar: NeoBottomNav(
        items: defaultNavItems,
        selectedId: _selectedNavId,
        onTap: (id) {
          setState(() => _selectedNavId = id);
          // 导航逻辑
        },
      ),
    );
  }
}
