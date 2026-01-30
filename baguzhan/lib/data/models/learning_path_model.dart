import 'path_category_model.dart';

/// 学习路径模型
///
/// 表示一个技术栈的完整学习路径，包含多个分类和角色引导
class LearningPathModel {
  /// 路径唯一标识符
  final String id;

  /// 技术栈名称，如："JavaScript"
  final String techStack;

  /// 显示标题，如："JavaScript核心"
  final String title;

  /// 副标题，如："从基础到进阶"
  final String subtitle;

  /// 角色图标，如："🗡️"
  final String characterIcon;

  /// 角色对话框文本
  final String characterDialog;

  /// 该路径下的分类列表
  final List<PathCategoryModel> categories;

  /// 总节点数
  final int totalNodes;

  /// 已完成节点数
  final int completedNodes;

  const LearningPathModel({
    required this.id,
    required this.techStack,
    required this.title,
    required this.subtitle,
    required this.characterIcon,
    required this.characterDialog,
    required this.categories,
    required this.totalNodes,
    required this.completedNodes,
  });

  /// 从JSON创建LearningPathModel实例
  factory LearningPathModel.fromJson(Map<String, dynamic> json) {
    return LearningPathModel(
      id: json['id'] as String,
      techStack: json['techStack'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      characterIcon: json['characterIcon'] as String,
      characterDialog: json['characterDialog'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => PathCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalNodes: json['totalNodes'] as int,
      completedNodes: json['completedNodes'] as int,
    );
  }

  /// 将模型转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'techStack': techStack,
      'title': title,
      'subtitle': subtitle,
      'characterIcon': characterIcon,
      'characterDialog': characterDialog,
      'categories': categories.map((e) => e.toJson()).toList(),
      'totalNodes': totalNodes,
      'completedNodes': completedNodes,
    };
  }

  /// 创建带有更新字段的副本
  LearningPathModel copyWith({
    String? id,
    String? techStack,
    String? title,
    String? subtitle,
    String? characterIcon,
    String? characterDialog,
    List<PathCategoryModel>? categories,
    int? totalNodes,
    int? completedNodes,
  }) {
    return LearningPathModel(
      id: id ?? this.id,
      techStack: techStack ?? this.techStack,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      characterIcon: characterIcon ?? this.characterIcon,
      characterDialog: characterDialog ?? this.characterDialog,
      categories: categories ?? this.categories,
      totalNodes: totalNodes ?? this.totalNodes,
      completedNodes: completedNodes ?? this.completedNodes,
    );
  }

  /// 计算整体完成进度百分比（0-100）
  double get progressPercentage {
    if (totalNodes == 0) return 0.0;
    return (completedNodes / totalNodes) * 100;
  }

  /// 检查该路径是否已完成
  bool get isCompleted => completedNodes >= totalNodes;

  /// 获取已完成的分类数量
  int get completedCategoriesCount =>
      categories.where((cat) => cat.isCompleted).length;

  /// 获取第一个未完成的分类（用于继续学习）
  PathCategoryModel? get firstIncompleteCategory {
    try {
      return categories.firstWhere((cat) => !cat.isCompleted);
    } catch (e) {
      return null;
    }
  }
}
