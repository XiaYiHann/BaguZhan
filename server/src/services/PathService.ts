import type { PathRepository } from '../repositories/PathRepository';
import type {
  LearningPath,
  PathCategory,
  PathNode,
  UserNodeProgress,
} from '../repositories/PathRepository';
import { HttpError } from '../errors/HttpError';

export class PathService {
  constructor(private readonly repository: PathRepository) {}

  // 获取学习路径（包含用户进度）
  async getLearningPath(
    techStack: string,
    userId?: string
  ): Promise<{
    path: LearningPath;
    progress: {
      completedNodes: number;
      totalNodes: number;
      completionRate: number;
    } | null;
  }> {
    const trimmedTechStack = techStack.trim().toLowerCase();
    if (!trimmedTechStack) {
      throw new HttpError(400, '技术栈参数不能为空');
    }

    const path = await this.repository.getPathByTechStack(trimmedTechStack);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', {
        techStack: trimmedTechStack,
      });
    }

    let progress = null;
    if (userId) {
      progress = await this.repository.getUserPathProgress(userId, path.id);
    }

    return { path, progress };
  }

  // 获取路径分类列表
  async getPathCategories(techStack: string): Promise<{
    path: LearningPath;
    categories: PathCategory[];
  }> {
    const trimmedTechStack = techStack.trim().toLowerCase();
    if (!trimmedTechStack) {
      throw new HttpError(400, '技术栈参数不能为空');
    }

    const path = await this.repository.getPathByTechStack(trimmedTechStack);
    if (!path) {
      throw new HttpError(404, '学习路径不存在', {
        techStack: trimmedTechStack,
      });
    }

    const categories = await this.repository.getCategoriesByPathId(path.id);

    return { path, categories };
  }

  // 获取分类下的节点列表
  async getCategoryNodes(
    categoryId: string,
    userId?: string
  ): Promise<{
    categoryId: string;
    nodes: PathNode[];
  }> {
    const trimmedCategoryId = categoryId.trim();
    if (!trimmedCategoryId) {
      throw new HttpError(400, '分类ID不能为空');
    }

    const nodes = await this.repository.getNodesByCategoryId(
      trimmedCategoryId,
      userId
    );

    return { categoryId: trimmedCategoryId, nodes };
  }

  // 完成节点并解锁下一个
  async completeNodeAndUnlockNext(
    userId: string,
    nodeId: string,
    correctCount: number,
    totalCount: number
  ): Promise<{
    progress: UserNodeProgress;
    nextNode: PathNode | null;
    unlocked: boolean;
  }> {
    // 参数验证
    const trimmedUserId = userId.trim();
    const trimmedNodeId = nodeId.trim();

    if (!trimmedUserId) {
      throw new HttpError(400, '用户ID不能为空');
    }
    if (!trimmedNodeId) {
      throw new HttpError(400, '节点ID不能为空');
    }
    if (correctCount < 0 || totalCount < 0) {
      throw new HttpError(400, '答题数量不能为负数');
    }
    if (correctCount > totalCount) {
      throw new HttpError(400, '正确答题数不能超过总答题数');
    }

    // 完成节点
    const progress = await this.repository.completeNode(
      trimmedUserId,
      trimmedNodeId,
      {
        correctCount,
        totalCount,
      }
    );

    // 获取下一个节点
    const nextNode = await this.repository.getNextNode(trimmedNodeId);

    // 判断是否解锁了下一个节点
    // 解锁条件：完成当前节点且正确率达到60%以上
    const unlocked = progress.accuracyRate >= 0.6 && nextNode !== null;

    return {
      progress,
      nextNode,
      unlocked,
    };
  }
}
