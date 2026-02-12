import type { PathRepository } from '../repositories/PathRepository';
import type {
  LearningPath,
  PathCategory,
  PathNode,
  CreatePathInput,
  UpdatePathInput,
  CreateCategoryInput,
  UpdateCategoryInput,
  CreateNodeInput,
  UpdateNodeInput,
} from '../repositories/PathRepository';
import { HttpError } from '../errors/HttpError';

export class PathService {
  constructor(private readonly repository: PathRepository) {}

  // ============ Public Methods ============

  /**
   * 获取所有学习路径
   */
  async getAllPaths(): Promise<LearningPath[]> {
    return this.repository.getAllPaths();
  }

  /**
   * 获取学习路径详情（包含分类和节点）
   */
  async getPathById(id: string, userId?: string): Promise<{
    path: LearningPath;
    categories: PathCategory[];
    progress?: {
      totalNodes: number;
      completedNodes: number;
      completionRate: number;
    };
  }> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '路径 ID 不能为空');
    }

    const path = await this.repository.getPathById(trimmedId);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', { id: trimmedId });
    }

    const categories = await this.repository.getCategoriesByPathId(path.id);

    let progress;
    if (userId) {
      // 初始化用户进度（如果是首次访问）
      await this.repository.initializeUserProgress(userId, path.id);
      progress = await this.repository.getUserPathProgress(userId, path.id);
    }

    return { path, categories, progress };
  }

  /**
   * 根据技术栈获取学习路径
   */
  async getPathByTechStack(techStack: string, userId?: string): Promise<{
    path: LearningPath;
    categories: PathCategory[];
    progress?: {
      totalNodes: number;
      completedNodes: number;
      completionRate: number;
    };
  }> {
    const trimmedTechStack = techStack.trim().toLowerCase();
    if (!trimmedTechStack) {
      throw new HttpError(400, '技术栈参数不能为空');
    }

    const path = await this.repository.getPathByTechStack(trimmedTechStack);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', { techStack: trimmedTechStack });
    }

    const categories = await this.repository.getCategoriesByPathId(path.id);

    let progress;
    if (userId) {
      await this.repository.initializeUserProgress(userId, path.id);
      progress = await this.repository.getUserPathProgress(userId, path.id);
    }

    return { path, categories, progress };
  }

  /**
   * 获取分类下的节点列表
   */
  async getCategoryNodes(categoryId: string, userId?: string): Promise<{
    category: PathCategory;
    nodes: PathNode[];
  }> {
    const trimmedCategoryId = categoryId.trim();
    if (!trimmedCategoryId) {
      throw new HttpError(400, '分类 ID 不能为空');
    }

    const category = await this.repository.getCategoryById(trimmedCategoryId);
    if (!category) {
      throw new HttpError(404, '分类不存在', { categoryId: trimmedCategoryId });
    }

    const nodes = await this.repository.getNodesByCategoryId(trimmedCategoryId, userId);

    return { category, nodes };
  }

  /**
   * 获取用户在路径上的进度
   */
  async getUserProgress(userId: string, pathId: string): Promise<{
    path: LearningPath;
    progress: {
      totalNodes: number;
      completedNodes: number;
      completionRate: number;
    };
  }> {
    const path = await this.repository.getPathById(pathId);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', { pathId });
    }

    // 初始化用户进度
    await this.repository.initializeUserProgress(userId, pathId);
    const progress = await this.repository.getUserPathProgress(userId, pathId);

    return { path, progress };
  }

  /**
   * 完成节点
   */
  async completeNode(
    userId: string,
    nodeId: string,
    correctCount: number,
    totalCount: number
  ): Promise<{
    node: PathNode;
    progress: ReturnType<PathRepository['completeNode']> extends Promise<infer T> ? T : never;
    nextNode: PathNode | null;
  }> {
    // 参数验证
    const trimmedUserId = userId.trim();
    const trimmedNodeId = nodeId.trim();

    if (!trimmedUserId) {
      throw new HttpError(400, '用户 ID 不能为空');
    }
    if (!trimmedNodeId) {
      throw new HttpError(400, '节点 ID 不能为空');
    }
    if (correctCount < 0 || totalCount < 0) {
      throw new HttpError(400, '答题数量不能为负数');
    }
    if (correctCount > totalCount) {
      throw new HttpError(400, '正确答题数不能超过总答题数');
    }

    // 检查节点是否存在
    const node = await this.repository.getNodeById(trimmedNodeId);
    if (!node) {
      throw new HttpError(404, '节点不存在', { nodeId: trimmedNodeId });
    }

    // 完成节点
    const progress = await this.repository.completeNode(
      trimmedUserId,
      trimmedNodeId,
      correctCount,
      totalCount
    );

    // 获取下一个节点（用于前端导航）
    const nextNode = await this.getNextNode(node);

    return { node, progress, nextNode };
  }

  /**
   * 获取下一个节点
   */
  private async getNextNode(currentNode: PathNode): Promise<PathNode | null> {
    // 获取同一分类中排序在后的节点
    const nodes = await this.repository.getNodesByCategoryId(currentNode.categoryId);
    const currentIndex = nodes.findIndex((n) => n.id === currentNode.id);

    if (currentIndex < nodes.length - 1) {
      return nodes[currentIndex + 1];
    }

    // 如果是分类中最后一个节点，获取下一个分类的第一个节点
    const category = await this.repository.getCategoryById(currentNode.categoryId);
    if (!category) return null;

    const categories = await this.repository.getCategoriesByPathId(category.pathId);
    const categoryIndex = categories.findIndex((c) => c.id === currentNode.categoryId);

    if (categoryIndex < categories.length - 1) {
      const nextCategory = categories[categoryIndex + 1];
      const nextCategoryNodes = await this.repository.getNodesByCategoryId(nextCategory.id);
      return nextCategoryNodes[0] ?? null;
    }

    return null;
  }

  // ============ Admin Methods ============

  /**
   * 创建学习路径
   */
  async createPath(input: CreatePathInput): Promise<LearningPath> {
    if (!input.id?.trim()) {
      throw new HttpError(400, '路径 ID 不能为空');
    }
    if (!input.techStack?.trim()) {
      throw new HttpError(400, '技术栈不能为空');
    }
    if (!input.title?.trim()) {
      throw new HttpError(400, '标题不能为空');
    }

    // 检查 ID 是否已存在
    const existing = await this.repository.getPathById(input.id);
    if (existing) {
      throw new HttpError(409, '路径 ID 已存在', { id: input.id });
    }

    // 检查技术栈是否已存在
    const existingTech = await this.repository.getPathByTechStack(input.techStack);
    if (existingTech) {
      throw new HttpError(409, '技术栈已存在', { techStack: input.techStack });
    }

    return this.repository.createPath(input);
  }

  /**
   * 更新学习路径
   */
  async updatePath(id: string, input: UpdatePathInput): Promise<LearningPath> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '路径 ID 不能为空');
    }

    const existing = await this.repository.getPathById(trimmedId);
    if (!existing) {
      throw new HttpError(404, '学习路径不存在', { id: trimmedId });
    }

    // 如果要更新技术栈，检查是否与其他路径冲突
    if (input.techStack && input.techStack.toLowerCase() !== existing.techStack) {
      const existingTech = await this.repository.getPathByTechStack(input.techStack);
      if (existingTech) {
        throw new HttpError(409, '技术栈已存在', { techStack: input.techStack });
      }
    }

    const updated = await this.repository.updatePath(trimmedId, input);
    if (!updated) {
      throw new HttpError(500, '更新路径失败');
    }

    return updated;
  }

  /**
   * 删除学习路径
   */
  async deletePath(id: string): Promise<void> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '路径 ID 不能为空');
    }

    const deleted = await this.repository.deletePath(trimmedId);
    if (!deleted) {
      throw new HttpError(404, '学习路径不存在', { id: trimmedId });
    }
  }

  /**
   * 创建分类
   */
  async createCategory(input: CreateCategoryInput): Promise<PathCategory> {
    if (!input.id?.trim()) {
      throw new HttpError(400, '分类 ID 不能为空');
    }
    if (!input.pathId?.trim()) {
      throw new HttpError(400, '路径 ID 不能为空');
    }
    if (!input.name?.trim()) {
      throw new HttpError(400, '分类名称不能为空');
    }

    // 检查路径是否存在
    const path = await this.repository.getPathById(input.pathId);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', { pathId: input.pathId });
    }

    // 检查分类 ID 是否已存在
    const existing = await this.repository.getCategoryById(input.id);
    if (existing) {
      throw new HttpError(409, '分类 ID 已存在', { id: input.id });
    }

    return this.repository.createCategory(input);
  }

  /**
   * 更新分类
   */
  async updateCategory(id: string, input: UpdateCategoryInput): Promise<PathCategory> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '分类 ID 不能为空');
    }

    const existing = await this.repository.getCategoryById(trimmedId);
    if (!existing) {
      throw new HttpError(404, '分类不存在', { id: trimmedId });
    }

    const updated = await this.repository.updateCategory(trimmedId, input);
    if (!updated) {
      throw new HttpError(500, '更新分类失败');
    }

    return updated;
  }

  /**
   * 删除分类
   */
  async deleteCategory(id: string): Promise<void> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '分类 ID 不能为空');
    }

    const deleted = await this.repository.deleteCategory(trimmedId);
    if (!deleted) {
      throw new HttpError(404, '分类不存在', { id: trimmedId });
    }
  }

  /**
   * 创建节点
   */
  async createNode(input: CreateNodeInput): Promise<PathNode> {
    if (!input.id?.trim()) {
      throw new HttpError(400, '节点 ID 不能为空');
    }
    if (!input.categoryId?.trim()) {
      throw new HttpError(400, '分类 ID 不能为空');
    }
    if (!input.title?.trim()) {
      throw new HttpError(400, '节点标题不能为空');
    }

    // 检查分类是否存在
    const category = await this.repository.getCategoryById(input.categoryId);
    if (!category) {
      throw new HttpError(404, '分类不存在', { categoryId: input.categoryId });
    }

    // 检查节点 ID 是否已存在
    const existing = await this.repository.getNodeById(input.id);
    if (existing) {
      throw new HttpError(409, '节点 ID 已存在', { id: input.id });
    }

    // 如果有前置节点，检查是否存在
    if (input.prerequisiteNodeId) {
      const prereq = await this.repository.getNodeById(input.prerequisiteNodeId);
      if (!prereq) {
        throw new HttpError(400, '前置节点不存在', { prerequisiteNodeId: input.prerequisiteNodeId });
      }
    }

    return this.repository.createNode(input);
  }

  /**
   * 更新节点
   */
  async updateNode(id: string, input: UpdateNodeInput): Promise<PathNode> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '节点 ID 不能为空');
    }

    const existing = await this.repository.getNodeById(trimmedId);
    if (!existing) {
      throw new HttpError(404, '节点不存在', { id: trimmedId });
    }

    // 如果要更新前置节点，检查是否存在
    if (input.prerequisiteNodeId !== undefined && input.prerequisiteNodeId !== null) {
      const prereq = await this.repository.getNodeById(input.prerequisiteNodeId);
      if (!prereq) {
        throw new HttpError(400, '前置节点不存在', { prerequisiteNodeId: input.prerequisiteNodeId });
      }
      // 检查是否形成循环依赖
      if (input.prerequisiteNodeId === trimmedId) {
        throw new HttpError(400, '节点不能以自己为前置节点');
      }
    }

    const updated = await this.repository.updateNode(trimmedId, input);
    if (!updated) {
      throw new HttpError(500, '更新节点失败');
    }

    return updated;
  }

  /**
   * 删除节点
   */
  async deleteNode(id: string): Promise<void> {
    const trimmedId = id.trim();
    if (!trimmedId) {
      throw new HttpError(400, '节点 ID 不能为空');
    }

    const deleted = await this.repository.deleteNode(trimmedId);
    if (!deleted) {
      throw new HttpError(404, '节点不存在', { id: trimmedId });
    }
  }
}
