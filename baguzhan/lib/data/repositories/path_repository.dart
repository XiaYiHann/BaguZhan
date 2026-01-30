import '../models/learning_path_model.dart';
import '../models/path_category_model.dart';
import '../models/path_node_model.dart';
import '../models/question_model.dart';

/// 学习路径仓库抽象类
///
/// 定义了获取学习路径数据的标准接口
abstract class PathRepository {
  /// 获取指定技术栈的学习路径
  ///
  /// [techStack] 技术栈名称，如："JavaScript"
  /// 返回 [LearningPathModel] 包含完整路径信息
  Future<LearningPathModel> getLearningPath(String techStack);

  /// 获取指定技术栈的路径分类列表
  ///
  /// [techStack] 技术栈名称
  /// 返回 [PathCategoryModel] 列表
  Future<List<PathCategoryModel>> getPathCategories(String techStack);

  /// 获取指定分类下的路径节点列表
  ///
  /// [categoryId] 分类ID
  /// 返回 [PathNodeModel] 列表
  Future<List<PathNodeModel>> getCategoryNodes(String categoryId);

  /// 获取指定节点关联的题目列表
  ///
  /// [nodeId] 节点ID
  /// 返回 [QuestionModel] 列表
  Future<List<QuestionModel>> getNodeQuestions(String nodeId);

  /// 完成节点学习
  ///
  /// [nodeId] 完成的节点ID
  /// [userId] 用户ID
  /// [correctCount] 答对题目数
  /// [totalCount] 总题目数
  /// 返回是否成功完成
  Future<bool> completeNode(
    String nodeId,
    String userId,
    int correctCount,
    int totalCount,
  );
}
