/// 路径节点状态枚举
///
/// 用于表示学习路径中节点的解锁状态
enum NodeStatus {
  /// 锁定状态 - 前置条件未完成，无法访问
  locked,

  /// 解锁状态 - 可以开始学习
  unlocked,

  /// 已完成状态 - 已完成该节点的学习
  completed,
}

/// 路径节点模型
///
/// 表示学习路径中的一个关卡/节点，包含题目和进度信息
class PathNodeModel {
  /// 节点唯一标识符
  final String id;

  /// 节点标题，如："变量与作用域"
  final String title;

  /// 节点图标，如："☕"
  final String icon;

  /// 节点颜色主题，如："primary", "secondary", "accent"
  final String color;

  /// 在路径中的顺序
  final int order;

  /// 节点状态：锁定/解锁/已完成
  final NodeStatus status;

  /// 关联题目ID列表
  final List<String> questionIds;

  /// 前置节点ID（可选）
  final String? prerequisiteNodeId;

  /// 预计完成时间（分钟）
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
    required this.estimatedMinutes,
  });

  /// 从JSON创建PathNodeModel实例
  factory PathNodeModel.fromJson(Map<String, dynamic> json) {
    return PathNodeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      order: json['order'] as int,
      status: _parseStatus(json['status'] as String),
      questionIds: (json['questionIds'] as List<dynamic>).cast<String>(),
      prerequisiteNodeId: json['prerequisiteNodeId'] as String?,
      estimatedMinutes: json['estimatedMinutes'] as int,
    );
  }

  /// 将模型转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'color': color,
      'order': order,
      'status': status.name,
      'questionIds': questionIds,
      'prerequisiteNodeId': prerequisiteNodeId,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  /// 创建带有更新字段的副本
  PathNodeModel copyWith({
    String? id,
    String? title,
    String? icon,
    String? color,
    int? order,
    NodeStatus? status,
    List<String>? questionIds,
    String? prerequisiteNodeId,
    int? estimatedMinutes,
  }) {
    return PathNodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      status: status ?? this.status,
      questionIds: questionIds ?? this.questionIds,
      prerequisiteNodeId: prerequisiteNodeId ?? this.prerequisiteNodeId,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  /// 解析状态字符串为NodeStatus枚举
  static NodeStatus _parseStatus(String status) {
    switch (status) {
      case 'unlocked':
        return NodeStatus.unlocked;
      case 'completed':
        return NodeStatus.completed;
      case 'locked':
      default:
        return NodeStatus.locked;
    }
  }
}
