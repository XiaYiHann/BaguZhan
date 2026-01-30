import 'package:flutter/foundation.dart';

import '../../data/models/learning_path_model.dart';
import '../../data/models/path_category_model.dart';
import '../../data/models/path_node_model.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/path_repository.dart';
import '../../network/api_exception.dart';

/// 学习路径状态枚举
enum LearningPathState {
  /// 初始状态
  initial,

  /// 加载中
  loading,

  /// 已加载
  loaded,

  /// 加载错误
  error,
}

/// 学习路径Provider
///
/// 管理学习路径的状态、数据加载和业务逻辑
class LearningPathProvider extends ChangeNotifier {
  LearningPathProvider(
    this._repository, {
    String? userId,
  }) : _userId = userId;

  final PathRepository _repository;
  String? _userId;

  // 状态
  LearningPathState _state = LearningPathState.initial;
  String? _errorMessage;
  String? _currentTechStack;

  // 数据
  LearningPathModel? _currentPath;
  List<PathCategoryModel> _categories = [];
  List<PathNodeModel> _nodes = [];
  List<QuestionModel> _currentNodeQuestions = [];

  // 加载状态细分
  bool _isLoadingPath = false;
  bool _isLoadingCategories = false;
  bool _isLoadingNodes = false;
  bool _isCompletingNode = false;

  // Getters
  LearningPathState get state => _state;
  String? get errorMessage =>
      _state == LearningPathState.error ? _errorMessage : null;
  String? get currentTechStack => _currentTechStack;

  LearningPathModel? get currentPath => _currentPath;
  List<PathCategoryModel> get categories => _categories;
  List<PathNodeModel> get nodes => _nodes;
  List<QuestionModel> get currentNodeQuestions => _currentNodeQuestions;

  bool get isLoading => _state == LearningPathState.loading;
  bool get isLoadingPath => _isLoadingPath;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingNodes => _isLoadingNodes;
  bool get isCompletingNode => _isCompletingNode;
  bool get hasData => _currentPath != null;

  /// 设置用户ID
  void setUserId(String userId) {
    _userId = userId;
  }

  /// 加载学习路径
  ///
  /// [techStack] 技术栈名称
  Future<void> loadPath(String techStack) async {
    _currentTechStack = techStack;
    _isLoadingPath = true;
    _state = LearningPathState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPath = await _repository.getLearningPath(techStack);
      _categories = _currentPath?.categories ?? [];
      _state = LearningPathState.loaded;
    } catch (error) {
      _errorMessage = _parseError(error);
      _state = LearningPathState.error;
    } finally {
      _isLoadingPath = false;
      notifyListeners();
    }
  }

  /// 加载分类列表
  ///
  /// [techStack] 技术栈名称
  Future<void> loadCategories(String techStack) async {
    _currentTechStack = techStack;
    _isLoadingCategories = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getPathCategories(techStack);
    } catch (error) {
      _errorMessage = _parseError(error);
      _state = LearningPathState.error;
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  /// 加载分类下的节点列表
  ///
  /// [categoryId] 分类ID
  Future<void> loadNodes(String categoryId) async {
    _isLoadingNodes = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _nodes = await _repository.getCategoryNodes(categoryId);
      _updateNodeUnlockStates();
    } catch (error) {
      _errorMessage = _parseError(error);
    } finally {
      _isLoadingNodes = false;
      notifyListeners();
    }
  }

  /// 加载节点题目
  ///
  /// [nodeId] 节点ID
  Future<void> loadNodeQuestions(String nodeId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _currentNodeQuestions = await _repository.getNodeQuestions(nodeId);
    } catch (error) {
      _errorMessage = _parseError(error);
      notifyListeners();
    }
  }

  /// 完成节点学习
  ///
  /// [nodeId] 节点ID
  /// [correctCount] 答对题目数
  /// [totalCount] 总题目数
  /// 返回是否成功
  Future<bool> completeNode(
    String nodeId,
    int correctCount,
    int totalCount,
  ) async {
    if (_userId == null) {
      _errorMessage = '用户未登录';
      notifyListeners();
      return false;
    }

    _isCompletingNode = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.completeNode(
        nodeId,
        _userId!,
        correctCount,
        totalCount,
      );

      if (success) {
        // 更新本地节点状态
        _updateNodeStatus(nodeId, NodeStatus.completed);
        // 解锁下一个节点
        _unlockNextNode(nodeId);
        // 刷新路径数据以获取最新进度
        if (_currentTechStack != null) {
          await loadPath(_currentTechStack!);
        }
      }

      return success;
    } catch (error) {
      _errorMessage = _parseError(error);
      return false;
    } finally {
      _isCompletingNode = false;
      notifyListeners();
    }
  }

  /// 计算整体进度百分比
  double calculateProgress() {
    if (_currentPath == null) return 0.0;
    return _currentPath!.progressPercentage;
  }

  /// 计算分类进度百分比
  double calculateCategoryProgress(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw Exception('Category not found'),
    );
    return category.progressPercentage;
  }

  /// 获取第一个未完成的分类
  PathCategoryModel? getFirstIncompleteCategory() {
    return _currentPath?.firstIncompleteCategory;
  }

  /// 获取下一个可学习的节点
  PathNodeModel? getNextAvailableNode() {
    for (final category in _categories) {
      for (final node in category.nodes) {
        if (node.status == NodeStatus.unlocked) {
          return node;
        }
      }
    }
    return null;
  }

  /// 检查节点是否已解锁
  bool isNodeUnlocked(String nodeId) {
    final node = _findNodeById(nodeId);
    return node != null && node.status != NodeStatus.locked;
  }

  /// 检查节点是否已完成
  bool isNodeCompleted(String nodeId) {
    final node = _findNodeById(nodeId);
    return node != null && node.status == NodeStatus.completed;
  }

  /// 刷新当前路径数据
  Future<void> refresh() async {
    if (_currentTechStack != null) {
      await loadPath(_currentTechStack!);
    }
  }

  /// 重试加载
  Future<void> retry() async {
    if (_currentTechStack != null) {
      await loadPath(_currentTechStack!);
    }
  }

  /// 清除所有数据
  void clear() {
    _currentPath = null;
    _categories = [];
    _nodes = [];
    _currentNodeQuestions = [];
    _currentTechStack = null;
    _errorMessage = null;
    _state = LearningPathState.initial;
    notifyListeners();
  }

  /// 根据ID查找节点
  PathNodeModel? _findNodeById(String nodeId) {
    for (final category in _categories) {
      try {
        return category.nodes.firstWhere((n) => n.id == nodeId);
      } catch (_) {
        continue;
      }
    }
    for (final node in _nodes) {
      if (node.id == nodeId) return node;
    }
    return null;
  }

  /// 更新节点状态
  void _updateNodeStatus(String nodeId, NodeStatus status) {
    // 更新当前节点列表
    final nodeIndex = _nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex >= 0) {
      _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(status: status);
    }

    // 更新分类中的节点
    for (var i = 0; i < _categories.length; i++) {
      final category = _categories[i];
      final nodeIdx = category.nodes.indexWhere((n) => n.id == nodeId);
      if (nodeIdx >= 0) {
        final updatedNodes = List<PathNodeModel>.from(category.nodes);
        updatedNodes[nodeIdx] = updatedNodes[nodeIdx].copyWith(status: status);
        _categories[i] = category.copyWith(
          nodes: updatedNodes,
          completedNodes: status == NodeStatus.completed
              ? category.completedNodes + 1
              : category.completedNodes,
        );
        break;
      }
    }
  }

  /// 解锁下一个节点
  void _unlockNextNode(String completedNodeId) {
    // 在当前节点列表中查找下一个节点
    final currentIndex = _nodes.indexWhere((n) => n.id == completedNodeId);
    if (currentIndex >= 0 && currentIndex < _nodes.length - 1) {
      final nextNode = _nodes[currentIndex + 1];
      if (nextNode.status == NodeStatus.locked) {
        _nodes[currentIndex + 1] =
            nextNode.copyWith(status: NodeStatus.unlocked);
      }
    }
  }

  /// 更新节点解锁状态
  void _updateNodeUnlockStates() {
    // 第一个节点默认解锁
    if (_nodes.isNotEmpty && _nodes.first.status == NodeStatus.locked) {
      _nodes[0] = _nodes.first.copyWith(status: NodeStatus.unlocked);
    }

    // 已完成的节点解锁下一个
    for (var i = 0; i < _nodes.length - 1; i++) {
      if (_nodes[i].status == NodeStatus.completed &&
          _nodes[i + 1].status == NodeStatus.locked) {
        _nodes[i + 1] = _nodes[i + 1].copyWith(status: NodeStatus.unlocked);
      }
    }
  }

  /// 解析错误信息
  String _parseError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return '加载失败，请稍后重试';
  }
}
