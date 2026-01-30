import 'path_node_model.dart';

/// 路径分类模型
///
/// 表示学习路径中的一个分类/章节，包含多个路径节点
class PathCategoryModel {
  /// 分类唯一标识符
  final String id;

  /// 分类名称，如："基础语法"
  final String name;

  /// 分类图标，如："📘"
  final String icon;

  /// 主题色，如："#58CC02"
  final String color;

  /// 排序顺序
  final int order;

  /// 总节点数
  final int totalNodes;

  /// 已完成节点数
  final int completedNodes;

  /// 该分类下的路径节点列表
  final List<PathNodeModel> nodes;

  const PathCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
    required this.totalNodes,
    required this.completedNodes,
    required this.nodes,
  });

  /// 从JSON创建PathCategoryModel实例
  factory PathCategoryModel.fromJson(Map<String, dynamic> json) {
    return PathCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      order: json['order'] as int,
      totalNodes: json['totalNodes'] as int,
      completedNodes: json['completedNodes'] as int,
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => PathNodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 将模型转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
      'totalNodes': totalNodes,
      'completedNodes': completedNodes,
      'nodes': nodes.map((e) => e.toJson()).toList(),
    };
  }

  /// 创建带有更新字段的副本
  PathCategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? order,
    int? totalNodes,
    int? completedNodes,
    List<PathNodeModel>? nodes,
  }) {
    return PathCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      totalNodes: totalNodes ?? this.totalNodes,
      completedNodes: completedNodes ?? this.completedNodes,
      nodes: nodes ?? this.nodes,
    );
  }

  /// 计算完成进度百分比（0-100）
  double get progressPercentage {
    if (totalNodes == 0) return 0.0;
    return (completedNodes / totalNodes) * 100;
  }

  /// 检查该分类是否已完成
  bool get isCompleted => completedNodes >= totalNodes;

  /// 检查该分类是否已解锁（至少有一个节点可访问）
  bool get isUnlocked => nodes.any((node) => node.status != NodeStatus.locked);
}
