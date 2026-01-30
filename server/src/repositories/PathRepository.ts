import type { DbClient } from '../database/connection';

export type LearningPath = {
  id: string;
  techStack: string;
  name: string;
  description: string | null;
  totalNodes: number;
};

export type PathCategory = {
  id: string;
  pathId: string;
  name: string;
  description: string | null;
  orderIndex: number;
  nodeCount: number;
};

export type PathNode = {
  id: string;
  categoryId: string;
  name: string;
  description: string | null;
  orderIndex: number;
  questionCount: number;
  isLocked: boolean;
  isCompleted: boolean;
  prerequisites: string[];
};

export type NodeQuestion = {
  id: string;
  nodeId: string;
  questionId: string;
  orderIndex: number;
  question: {
    id: string;
    content: string;
    difficulty: string;
    topic: string;
  };
};

export type UserNodeProgress = {
  id: string;
  userId: string;
  nodeId: string;
  isCompleted: boolean;
  correctCount: number;
  totalCount: number;
  accuracyRate: number;
  completedAt: string | null;
  createdAt: string;
};

export type CompleteNodeData = {
  correctCount: number;
  totalCount: number;
};

type PathRow = {
  id: string;
  tech_stack: string;
  name: string;
  description: string | null;
  total_nodes: number;
};

type CategoryRow = {
  id: string;
  path_id: string;
  name: string;
  description: string | null;
  order_index: number;
  node_count: number;
};

type NodeRow = {
  id: string;
  category_id: string;
  name: string;
  description: string | null;
  order_index: number;
  question_count: number;
  prerequisites: string | null;
};

type NodeQuestionRow = {
  id: string;
  node_id: string;
  question_id: string;
  order_index: number;
  question_content: string;
  question_difficulty: string;
  question_topic: string;
};

type UserNodeProgressRow = {
  id: string;
  user_id: string;
  node_id: string;
  is_completed: number;
  correct_count: number;
  total_count: number;
  completed_at: string | null;
  created_at: string;
};

export class PathRepository {
  constructor(private readonly db: DbClient) {}

  // 根据技术栈获取学习路径
  async getPathByTechStack(techStack: string): Promise<LearningPath | null> {
    const sql = `
      SELECT 
        p.*,
        COUNT(n.id) as total_nodes
      FROM learning_paths p
      LEFT JOIN path_categories pc ON pc.path_id = p.id
      LEFT JOIN path_nodes n ON n.category_id = pc.id
      WHERE p.tech_stack = ?
      GROUP BY p.id
    `;
    const row = await this.db.get<PathRow>(sql, [techStack]);
    return row ? this.mapPathRow(row) : null;
  }

  // 根据路径ID获取所有分类
  async getCategoriesByPathId(pathId: string): Promise<PathCategory[]> {
    const sql = `
      SELECT 
        pc.*,
        COUNT(n.id) as node_count
      FROM path_categories pc
      LEFT JOIN path_nodes n ON n.category_id = pc.id
      WHERE pc.path_id = ?
      GROUP BY pc.id
      ORDER BY pc.order_index ASC
    `;
    const rows = await this.db.all<CategoryRow>(sql, [pathId]);
    return rows.map(this.mapCategoryRow);
  }

  // 根据分类ID获取所有节点
  async getNodesByCategoryId(
    categoryId: string,
    userId?: string
  ): Promise<PathNode[]> {
    // 获取节点基本信息
    const sql = `
      SELECT 
        n.*,
        GROUP_CONCAT(np.prerequisite_node_id) as prerequisites
      FROM path_nodes n
      LEFT JOIN node_prerequisites np ON np.node_id = n.id
      WHERE n.category_id = ?
      GROUP BY n.id
      ORDER BY n.order_index ASC
    `;
    const rows = await this.db.all<NodeRow>(sql, [categoryId]);

    // 如果有用户ID，获取用户进度信息
    let userProgress: Map<string, UserNodeProgress> = new Map();
    if (userId) {
      const nodeIds = rows.map((row) => row.id);
      if (nodeIds.length > 0) {
        const placeholders = nodeIds.map(() => '?').join(',');
        const progressSql = `
          SELECT * FROM user_node_progress
          WHERE user_id = ? AND node_id IN (${placeholders})
        `;
        const progressRows = await this.db.all<UserNodeProgressRow>(
          progressSql,
          [userId, ...nodeIds]
        );
        for (const row of progressRows) {
          userProgress.set(row.node_id, this.mapUserNodeProgressRow(row));
        }
      }
    }

    return rows.map((row) => {
      const progress = userProgress.get(row.id);
      const prerequisites = row.prerequisites
        ? row.prerequisites.split(',')
        : [];

      // 检查节点是否被锁定（有前置条件且前置条件未完成）
      let isLocked = false;
      if (prerequisites.length > 0 && userId) {
        isLocked = prerequisites.some((prereqId) => {
          const prereqProgress = userProgress.get(prereqId);
          return !prereqProgress?.isCompleted;
        });
      }

      return {
        id: row.id,
        categoryId: row.category_id,
        name: row.name,
        description: row.description,
        orderIndex: row.order_index,
        questionCount: row.question_count,
        isLocked,
        isCompleted: progress?.isCompleted ?? false,
        prerequisites,
      };
    });
  }

  // 获取节点的题目
  async getNodeQuestions(nodeId: string): Promise<NodeQuestion[]> {
    const sql = `
      SELECT 
        nq.*,
        q.content as question_content,
        q.difficulty as question_difficulty,
        q.topic as question_topic
      FROM node_questions nq
      JOIN questions q ON q.id = nq.question_id
      WHERE nq.node_id = ?
      ORDER BY nq.order_index ASC
    `;
    const rows = await this.db.all<NodeQuestionRow>(sql, [nodeId]);
    return rows.map(this.mapNodeQuestionRow);
  }

  // 完成节点并记录进度
  async completeNode(
    userId: string,
    nodeId: string,
    data: CompleteNodeData
  ): Promise<UserNodeProgress> {
    const accuracyRate =
      data.totalCount > 0 ? data.correctCount / data.totalCount : 0;

    // 检查是否已有进度记录
    const existingSql = `
      SELECT * FROM user_node_progress
      WHERE user_id = ? AND node_id = ?
    `;
    const existing = await this.db.get<UserNodeProgressRow>(existingSql, [
      userId,
      nodeId,
    ]);

    if (existing) {
      // 更新现有记录
      const updateSql = `
        UPDATE user_node_progress
        SET 
          is_completed = 1,
          correct_count = ?,
          total_count = ?,
          completed_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      await this.db.run(updateSql, [
        data.correctCount,
        data.totalCount,
        existing.id,
      ]);

      return {
        id: existing.id,
        userId,
        nodeId,
        isCompleted: true,
        correctCount: data.correctCount,
        totalCount: data.totalCount,
        accuracyRate,
        completedAt: new Date().toISOString(),
        createdAt: existing.created_at,
      };
    }

    // 创建新记录
    const id = crypto.randomUUID();
    const insertSql = `
      INSERT INTO user_node_progress (
        id, user_id, node_id, is_completed, correct_count, total_count, completed_at
      ) VALUES (?, ?, ?, 1, ?, ?, CURRENT_TIMESTAMP)
    `;
    await this.db.run(insertSql, [
      id,
      userId,
      nodeId,
      data.correctCount,
      data.totalCount,
    ]);

    return {
      id,
      userId,
      nodeId,
      isCompleted: true,
      correctCount: data.correctCount,
      totalCount: data.totalCount,
      accuracyRate,
      completedAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
  }

  // 获取用户路径进度
  async getUserPathProgress(
    userId: string,
    pathId: string
  ): Promise<{
    completedNodes: number;
    totalNodes: number;
    completionRate: number;
  }> {
    // 获取路径总节点数
    const totalSql = `
      SELECT COUNT(n.id) as total
      FROM path_categories pc
      JOIN path_nodes n ON n.category_id = pc.id
      WHERE pc.path_id = ?
    `;
    const totalResult = await this.db.get<{ total: number }>(totalSql, [pathId]);
    const totalNodes = totalResult?.total ?? 0;

    // 获取用户已完成节点数
    const completedSql = `
      SELECT COUNT(unp.id) as completed
      FROM user_node_progress unp
      JOIN path_nodes n ON n.id = unp.node_id
      JOIN path_categories pc ON pc.id = n.category_id
      WHERE unp.user_id = ? AND pc.path_id = ? AND unp.is_completed = 1
    `;
    const completedResult = await this.db.get<{ completed: number }>(
      completedSql,
      [userId, pathId]
    );
    const completedNodes = completedResult?.completed ?? 0;

    return {
      completedNodes,
      totalNodes,
      completionRate: totalNodes > 0 ? completedNodes / totalNodes : 0,
    };
  }

  // 获取节点的下一个节点
  async getNextNode(nodeId: string): Promise<PathNode | null> {
    // 首先获取当前节点的信息
    const currentSql = `
      SELECT category_id, order_index FROM path_nodes WHERE id = ?
    `;
    const current = await this.db.get<{
      category_id: string;
      order_index: number;
    }>(currentSql, [nodeId]);

    if (!current) return null;

    // 尝试获取同一分类中的下一个节点
    const nextSql = `
      SELECT 
        n.*,
        GROUP_CONCAT(np.prerequisite_node_id) as prerequisites
      FROM path_nodes n
      LEFT JOIN node_prerequisites np ON np.node_id = n.id
      WHERE n.category_id = ? AND n.order_index > ?
      GROUP BY n.id
      ORDER BY n.order_index ASC
      LIMIT 1
    `;
    const next = await this.db.get<NodeRow>(nextSql, [
      current.category_id,
      current.order_index,
    ]);

    if (next) {
      return {
        id: next.id,
        categoryId: next.category_id,
        name: next.name,
        description: next.description,
        orderIndex: next.order_index,
        questionCount: next.question_count,
        isLocked: false,
        isCompleted: false,
        prerequisites: next.prerequisites
          ? next.prerequisites.split(',')
          : [],
      };
    }

    // 如果没有下一个节点，尝试获取下一个分类的第一个节点
    const pathSql = `
      SELECT pc.path_id, pc.order_index 
      FROM path_categories pc 
      WHERE pc.id = ?
    `;
    const pathInfo = await this.db.get<{
      path_id: string;
      order_index: number;
    }>(pathSql, [current.category_id]);

    if (!pathInfo) return null;

    const nextCategorySql = `
      SELECT pc.id
      FROM path_categories pc
      WHERE pc.path_id = ? AND pc.order_index > ?
      ORDER BY pc.order_index ASC
      LIMIT 1
    `;
    const nextCategory = await this.db.get<{ id: string }>(nextCategorySql, [
      pathInfo.path_id,
      pathInfo.order_index,
    ]);

    if (!nextCategory) return null;

    const nextCategoryFirstNodeSql = `
      SELECT 
        n.*,
        GROUP_CONCAT(np.prerequisite_node_id) as prerequisites
      FROM path_nodes n
      LEFT JOIN node_prerequisites np ON np.node_id = n.id
      WHERE n.category_id = ?
      GROUP BY n.id
      ORDER BY n.order_index ASC
      LIMIT 1
    `;
    const nextCategoryFirstNode = await this.db.get<NodeRow>(
      nextCategoryFirstNodeSql,
      [nextCategory.id]
    );

    if (!nextCategoryFirstNode) return null;

    return {
      id: nextCategoryFirstNode.id,
      categoryId: nextCategoryFirstNode.category_id,
      name: nextCategoryFirstNode.name,
      description: nextCategoryFirstNode.description,
      orderIndex: nextCategoryFirstNode.order_index,
      questionCount: nextCategoryFirstNode.question_count,
      isLocked: false,
      isCompleted: false,
      prerequisites: nextCategoryFirstNode.prerequisites
        ? nextCategoryFirstNode.prerequisites.split(',')
        : [],
    };
  }

  // Helper methods
  private mapPathRow(row: PathRow): LearningPath {
    return {
      id: row.id,
      techStack: row.tech_stack,
      name: row.name,
      description: row.description,
      totalNodes: row.total_nodes,
    };
  }

  private mapCategoryRow(row: CategoryRow): PathCategory {
    return {
      id: row.id,
      pathId: row.path_id,
      name: row.name,
      description: row.description,
      orderIndex: row.order_index,
      nodeCount: row.node_count,
    };
  }

  private mapNodeQuestionRow(row: NodeQuestionRow): NodeQuestion {
    return {
      id: row.id,
      nodeId: row.node_id,
      questionId: row.question_id,
      orderIndex: row.order_index,
      question: {
        id: row.question_id,
        content: row.question_content,
        difficulty: row.question_difficulty,
        topic: row.question_topic,
      },
    };
  }

  private mapUserNodeProgressRow(row: UserNodeProgressRow): UserNodeProgress {
    return {
      id: row.id,
      userId: row.user_id,
      nodeId: row.node_id,
      isCompleted: Boolean(row.is_completed),
      correctCount: row.correct_count,
      totalCount: row.total_count,
      accuracyRate:
        row.total_count > 0 ? row.correct_count / row.total_count : 0,
      completedAt: row.completed_at,
      createdAt: row.created_at,
    };
  }
}
