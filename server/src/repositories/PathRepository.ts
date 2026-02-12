import type { DbClient } from '../database/connection';

// ============ Types ============

export type LearningPath = {
  id: string;
  techStack: string;
  title: string;
  subtitle: string | null;
  characterIcon: string | null;
  characterDialog: string | null;
  createdAt: string | null;
};

export type PathCategory = {
  id: string;
  pathId: string;
  name: string;
  icon: string | null;
  color: string | null;
  sortOrder: number;
  createdAt: string | null;
};

export type PathNode = {
  id: string;
  categoryId: string;
  title: string;
  icon: string | null;
  color: string | null;
  sortOrder: number;
  questionIds: string[];
  prerequisiteNodeId: string | null;
  estimatedMinutes: number;
  createdAt: string | null;
  // 用户进度相关（运行时计算）
  status?: 'locked' | 'unlocked' | 'completed';
  correctCount?: number;
  totalCount?: number;
};

export type UserPathProgress = {
  id: number;
  userId: string;
  nodeId: string;
  status: 'locked' | 'unlocked' | 'completed';
  correctCount: number;
  totalCount: number;
  completedAt: string | null;
  createdAt: string | null;
};

export type CreatePathInput = {
  id: string;
  techStack: string;
  title: string;
  subtitle?: string;
  characterIcon?: string;
  characterDialog?: string;
};

export type UpdatePathInput = Partial<Omit<CreatePathInput, 'id'>>;

export type CreateCategoryInput = {
  id: string;
  pathId: string;
  name: string;
  icon?: string;
  color?: string;
  sortOrder?: number;
};

export type UpdateCategoryInput = Partial<Omit<CreateCategoryInput, 'id' | 'pathId'>>;

export type CreateNodeInput = {
  id: string;
  categoryId: string;
  title: string;
  icon?: string;
  color?: string;
  sortOrder?: number;
  questionIds?: string[];
  prerequisiteNodeId?: string;
  estimatedMinutes?: number;
};

export type UpdateNodeInput = Partial<Omit<CreateNodeInput, 'id' | 'categoryId'>>;

// ============ Row Types ============

type PathRow = {
  id: string;
  tech_stack: string;
  title: string;
  subtitle: string | null;
  character_icon: string | null;
  character_dialog: string | null;
  created_at: string | null;
};

type CategoryRow = {
  id: string;
  path_id: string;
  name: string;
  icon: string | null;
  color: string | null;
  sort_order: number;
  created_at: string | null;
};

type NodeRow = {
  id: string;
  category_id: string;
  title: string;
  icon: string | null;
  color: string | null;
  sort_order: number;
  question_ids: string | null;
  prerequisite_node_id: string | null;
  estimated_minutes: number;
  created_at: string | null;
};

type ProgressRow = {
  id: number;
  user_id: string;
  node_id: string;
  status: string;
  correct_count: number;
  total_count: number;
  completed_at: string | null;
  created_at: string | null;
};

// ============ Repository ============

export class PathRepository {
  constructor(private readonly db: DbClient) {}

  // ============ Public Methods (查询) ============

  /**
   * 获取所有学习路径
   */
  async getAllPaths(): Promise<LearningPath[]> {
    const sql = `SELECT * FROM learning_paths ORDER BY created_at ASC`;
    const rows = await this.db.all<PathRow>(sql);
    return rows.map(this.mapPathRow);
  }

  /**
   * 根据 ID 获取学习路径
   */
  async getPathById(id: string): Promise<LearningPath | null> {
    const sql = `SELECT * FROM learning_paths WHERE id = ?`;
    const row = await this.db.get<PathRow>(sql, [id]);
    return row ? this.mapPathRow(row) : null;
  }

  /**
   * 根据技术栈获取学习路径
   */
  async getPathByTechStack(techStack: string): Promise<LearningPath | null> {
    const sql = `SELECT * FROM learning_paths WHERE tech_stack = ?`;
    const row = await this.db.get<PathRow>(sql, [techStack.toLowerCase()]);
    return row ? this.mapPathRow(row) : null;
  }

  /**
   * 获取路径的所有分类
   */
  async getCategoriesByPathId(pathId: string): Promise<PathCategory[]> {
    const sql = `
      SELECT * FROM path_categories 
      WHERE path_id = ? 
      ORDER BY sort_order ASC
    `;
    const rows = await this.db.all<CategoryRow>(sql, [pathId]);
    return rows.map(this.mapCategoryRow);
  }

  /**
   * 获取分类详情
   */
  async getCategoryById(id: string): Promise<PathCategory | null> {
    const sql = `SELECT * FROM path_categories WHERE id = ?`;
    const row = await this.db.get<CategoryRow>(sql, [id]);
    return row ? this.mapCategoryRow(row) : null;
  }

  /**
   * 获取分类下的所有节点
   */
  async getNodesByCategoryId(categoryId: string, userId?: string): Promise<PathNode[]> {
    const sql = `
      SELECT * FROM path_nodes 
      WHERE category_id = ? 
      ORDER BY sort_order ASC
    `;
    const rows = await this.db.all<NodeRow>(sql, [categoryId]);

    // 如果有用户ID，获取用户进度
    const progressMap = new Map<string, UserPathProgress>();
    if (userId) {
      const nodeIds = rows.map((r) => r.id);
      if (nodeIds.length > 0) {
        const placeholders = nodeIds.map(() => '?').join(',');
        const progressSql = `
          SELECT * FROM user_path_progress 
          WHERE user_id = ? AND node_id IN (${placeholders})
        `;
        const progressRows = await this.db.all<ProgressRow>(progressSql, [userId, ...nodeIds]);
        for (const row of progressRows) {
          progressMap.set(row.node_id, this.mapProgressRow(row));
        }
      }
    }

    return rows.map((row) => {
      const progress = progressMap.get(row.id);
      return {
        ...this.mapNodeRow(row),
        status: progress?.status,
        correctCount: progress?.correctCount,
        totalCount: progress?.totalCount,
      };
    });
  }

  /**
   * 获取节点详情
   */
  async getNodeById(id: string): Promise<PathNode | null> {
    const sql = `SELECT * FROM path_nodes WHERE id = ?`;
    const row = await this.db.get<NodeRow>(sql, [id]);
    return row ? this.mapNodeRow(row) : null;
  }

  /**
   * 获取用户在路径上的进度统计
   */
  async getUserPathProgress(userId: string, pathId: string): Promise<{
    totalNodes: number;
    completedNodes: number;
    completionRate: number;
  }> {
    // 获取路径总节点数
    const totalSql = `
      SELECT COUNT(n.id) as total
      FROM path_categories c
      JOIN path_nodes n ON n.category_id = c.id
      WHERE c.path_id = ?
    `;
    const totalResult = await this.db.get<{ total: number }>(totalSql, [pathId]);
    const totalNodes = totalResult?.total ?? 0;

    // 获取用户已完成节点数
    const completedSql = `
      SELECT COUNT(up.id) as completed
      FROM user_path_progress up
      JOIN path_nodes n ON n.id = up.node_id
      JOIN path_categories c ON c.id = n.category_id
      WHERE up.user_id = ? AND c.path_id = ? AND up.status = 'completed'
    `;
    const completedResult = await this.db.get<{ completed: number }>(completedSql, [userId, pathId]);
    const completedNodes = completedResult?.completed ?? 0;

    return {
      totalNodes,
      completedNodes,
      completionRate: totalNodes > 0 ? completedNodes / totalNodes : 0,
    };
  }

  /**
   * 完成节点并记录进度
   */
  async completeNode(
    userId: string,
    nodeId: string,
    correctCount: number,
    totalCount: number
  ): Promise<UserPathProgress> {
    // 检查是否已有进度记录
    const existingSql = `
      SELECT * FROM user_path_progress 
      WHERE user_id = ? AND node_id = ?
    `;
    const existing = await this.db.get<ProgressRow>(existingSql, [userId, nodeId]);

    if (existing) {
      // 更新现有记录
      const updateSql = `
        UPDATE user_path_progress 
        SET status = 'completed', correct_count = ?, total_count = ?, completed_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `;
      await this.db.run(updateSql, [correctCount, totalCount, existing.id]);
      return {
        ...this.mapProgressRow(existing),
        status: 'completed',
        correctCount,
        totalCount,
        completedAt: new Date().toISOString(),
      };
    }

    // 创建新记录
    const insertSql = `
      INSERT INTO user_path_progress (user_id, node_id, status, correct_count, total_count, completed_at)
      VALUES (?, ?, 'completed', ?, ?, CURRENT_TIMESTAMP)
    `;
    const result = await this.db.run(insertSql, [userId, nodeId, correctCount, totalCount]);

    return {
      id: result.lastID ?? 0,
      userId,
      nodeId,
      status: 'completed',
      correctCount,
      totalCount,
      completedAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
    };
  }

  /**
   * 初始化用户路径进度（首节点解锁）
   */
  async initializeUserProgress(userId: string, pathId: string): Promise<void> {
    // 获取路径的第一个分类
    const categorySql = `
      SELECT id FROM path_categories 
      WHERE path_id = ? 
      ORDER BY sort_order ASC 
      LIMIT 1
    `;
    const firstCategory = await this.db.get<{ id: string }>(categorySql, [pathId]);
    if (!firstCategory) return;

    // 获取分类的第一个节点
    const nodeSql = `
      SELECT id FROM path_nodes 
      WHERE category_id = ? 
      ORDER BY sort_order ASC 
      LIMIT 1
    `;
    const firstNode = await this.db.get<{ id: string }>(nodeSql, [firstCategory.id]);
    if (!firstNode) return;

    // 检查是否已有进度记录
    const existingSql = `
      SELECT id FROM user_path_progress 
      WHERE user_id = ? AND node_id = ?
    `;
    const existing = await this.db.get<{ id: number }>(existingSql, [userId, firstNode.id]);
    if (existing) return;

    // 创建首节点的解锁记录
    const insertSql = `
      INSERT INTO user_path_progress (user_id, node_id, status)
      VALUES (?, ?, 'unlocked')
    `;
    await this.db.run(insertSql, [userId, firstNode.id]);
  }

  // ============ Admin Methods (CRUD) ============

  /**
   * 创建学习路径
   */
  async createPath(input: CreatePathInput): Promise<LearningPath> {
    const sql = `
      INSERT INTO learning_paths (id, tech_stack, title, subtitle, character_icon, character_dialog)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    await this.db.run(sql, [
      input.id,
      input.techStack.toLowerCase(),
      input.title,
      input.subtitle ?? null,
      input.characterIcon ?? '🗡️',
      input.characterDialog ?? '准备好斩题了吗？',
    ]);

    return (await this.getPathById(input.id))!;
  }

  /**
   * 更新学习路径
   */
  async updatePath(id: string, input: UpdatePathInput): Promise<LearningPath | null> {
    const updates: string[] = [];
    const params: unknown[] = [];

    if (input.techStack !== undefined) {
      updates.push('tech_stack = ?');
      params.push(input.techStack.toLowerCase());
    }
    if (input.title !== undefined) {
      updates.push('title = ?');
      params.push(input.title);
    }
    if (input.subtitle !== undefined) {
      updates.push('subtitle = ?');
      params.push(input.subtitle);
    }
    if (input.characterIcon !== undefined) {
      updates.push('character_icon = ?');
      params.push(input.characterIcon);
    }
    if (input.characterDialog !== undefined) {
      updates.push('character_dialog = ?');
      params.push(input.characterDialog);
    }

    if (updates.length === 0) {
      return this.getPathById(id);
    }

    params.push(id);
    await this.db.run(`UPDATE learning_paths SET ${updates.join(', ')} WHERE id = ?`, params);
    return this.getPathById(id);
  }

  /**
   * 删除学习路径（级联删除分类和节点）
   */
  async deletePath(id: string): Promise<boolean> {
    const existing = await this.getPathById(id);
    if (!existing) return false;

    await this.db.run('DELETE FROM learning_paths WHERE id = ?', [id]);
    return true;
  }

  /**
   * 创建分类
   */
  async createCategory(input: CreateCategoryInput): Promise<PathCategory> {
    const sql = `
      INSERT INTO path_categories (id, path_id, name, icon, color, sort_order)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    await this.db.run(sql, [
      input.id,
      input.pathId,
      input.name,
      input.icon ?? null,
      input.color ?? '#58CC02',
      input.sortOrder ?? 0,
    ]);

    return (await this.getCategoryById(input.id))!;
  }

  /**
   * 更新分类
   */
  async updateCategory(id: string, input: UpdateCategoryInput): Promise<PathCategory | null> {
    const updates: string[] = [];
    const params: unknown[] = [];

    if (input.name !== undefined) {
      updates.push('name = ?');
      params.push(input.name);
    }
    if (input.icon !== undefined) {
      updates.push('icon = ?');
      params.push(input.icon);
    }
    if (input.color !== undefined) {
      updates.push('color = ?');
      params.push(input.color);
    }
    if (input.sortOrder !== undefined) {
      updates.push('sort_order = ?');
      params.push(input.sortOrder);
    }

    if (updates.length === 0) {
      return this.getCategoryById(id);
    }

    params.push(id);
    await this.db.run(`UPDATE path_categories SET ${updates.join(', ')} WHERE id = ?`, params);
    return this.getCategoryById(id);
  }

  /**
   * 删除分类（级联删除节点）
   */
  async deleteCategory(id: string): Promise<boolean> {
    const existing = await this.getCategoryById(id);
    if (!existing) return false;

    await this.db.run('DELETE FROM path_categories WHERE id = ?', [id]);
    return true;
  }

  /**
   * 创建节点
   */
  async createNode(input: CreateNodeInput): Promise<PathNode> {
    const questionIdsJson = input.questionIds ? JSON.stringify(input.questionIds) : null;
    const sql = `
      INSERT INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    await this.db.run(sql, [
      input.id,
      input.categoryId,
      input.title,
      input.icon ?? null,
      input.color ?? 'primary',
      input.sortOrder ?? 0,
      questionIdsJson,
      input.prerequisiteNodeId ?? null,
      input.estimatedMinutes ?? 10,
    ]);

    return (await this.getNodeById(input.id))!;
  }

  /**
   * 更新节点
   */
  async updateNode(id: string, input: UpdateNodeInput): Promise<PathNode | null> {
    const updates: string[] = [];
    const params: unknown[] = [];

    if (input.title !== undefined) {
      updates.push('title = ?');
      params.push(input.title);
    }
    if (input.icon !== undefined) {
      updates.push('icon = ?');
      params.push(input.icon);
    }
    if (input.color !== undefined) {
      updates.push('color = ?');
      params.push(input.color);
    }
    if (input.sortOrder !== undefined) {
      updates.push('sort_order = ?');
      params.push(input.sortOrder);
    }
    if (input.questionIds !== undefined) {
      updates.push('question_ids = ?');
      params.push(JSON.stringify(input.questionIds));
    }
    if (input.prerequisiteNodeId !== undefined) {
      updates.push('prerequisite_node_id = ?');
      params.push(input.prerequisiteNodeId);
    }
    if (input.estimatedMinutes !== undefined) {
      updates.push('estimated_minutes = ?');
      params.push(input.estimatedMinutes);
    }

    if (updates.length === 0) {
      return this.getNodeById(id);
    }

    params.push(id);
    await this.db.run(`UPDATE path_nodes SET ${updates.join(', ')} WHERE id = ?`, params);
    return this.getNodeById(id);
  }

  /**
   * 删除节点
   */
  async deleteNode(id: string): Promise<boolean> {
    const existing = await this.getNodeById(id);
    if (!existing) return false;

    await this.db.run('DELETE FROM path_nodes WHERE id = ?', [id]);
    return true;
  }

  // ============ Helper Methods ============

  private mapPathRow(row: PathRow): LearningPath {
    return {
      id: row.id,
      techStack: row.tech_stack,
      title: row.title,
      subtitle: row.subtitle,
      characterIcon: row.character_icon,
      characterDialog: row.character_dialog,
      createdAt: row.created_at,
    };
  }

  private mapCategoryRow(row: CategoryRow): PathCategory {
    return {
      id: row.id,
      pathId: row.path_id,
      name: row.name,
      icon: row.icon,
      color: row.color,
      sortOrder: row.sort_order,
      createdAt: row.created_at,
    };
  }

  private mapNodeRow(row: NodeRow): PathNode {
    return {
      id: row.id,
      categoryId: row.category_id,
      title: row.title,
      icon: row.icon,
      color: row.color,
      sortOrder: row.sort_order,
      questionIds: row.question_ids ? JSON.parse(row.question_ids) : [],
      prerequisiteNodeId: row.prerequisite_node_id,
      estimatedMinutes: row.estimated_minutes,
      createdAt: row.created_at,
    };
  }

  private mapProgressRow(row: ProgressRow): UserPathProgress {
    return {
      id: row.id,
      userId: row.user_id,
      nodeId: row.node_id,
      status: row.status as UserPathProgress['status'],
      correctCount: row.correct_count,
      totalCount: row.total_count,
      completedAt: row.completed_at,
      createdAt: row.created_at,
    };
  }
}
