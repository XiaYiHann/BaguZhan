import type { DbClient } from '../database/connection';
import type {
  Question,
  QuestionFilters,
  RandomFilters,
  CreateQuestionInput,
  UpdateQuestionInput,
  QuestionStats,
} from '../types/question';

type QuestionRow = {
  id: string;
  content: string;
  topic: string;
  difficulty: string;
  explanation: string | null;
  mnemonic: string | null;
  scenario: string | null;
  tags: string | null;
  deleted_at: string | null;
  option_id: string | null;
  option_text: string | null;
  option_order: number | null;
  is_correct: number | null;
};

const parseTags = (tags: string | null) => {
  if (!tags) {
    return [] as string[];
  }
  try {
    const parsed = JSON.parse(tags) as unknown;
    if (Array.isArray(parsed)) {
      return parsed.filter((tag) => typeof tag === 'string');
    }
  } catch (_) {
    return [] as string[];
  }
  return [] as string[];
};

const mapRowsToQuestions = (rows: QuestionRow[]): Question[] => {
  const map = new Map<string, Question>();
  for (const row of rows) {
    const existing = map.get(row.id);
    if (!existing) {
      map.set(row.id, {
        id: row.id,
        content: row.content,
        topic: row.topic,
        difficulty: row.difficulty as Question['difficulty'],
        explanation: row.explanation,
        mnemonic: row.mnemonic,
        scenario: row.scenario,
        tags: parseTags(row.tags),
        options: [],
        deletedAt: row.deleted_at,
      });
    }
    if (row.option_id) {
      map.get(row.id)?.options.push({
        id: row.option_id,
        optionText: row.option_text ?? '',
        optionOrder: row.option_order ?? 0,
        isCorrect: Boolean(row.is_correct),
      });
    }
  }
  return Array.from(map.values());
};

const buildFilterClause = (filters: QuestionFilters) => {
  const conditions: string[] = [];
  const params: unknown[] = [];
  if (filters.topic) {
    conditions.push('q.topic = ?');
    params.push(filters.topic);
  }
  if (filters.difficulty) {
    conditions.push('q.difficulty = ?');
    params.push(filters.difficulty);
  }
  // 默认过滤掉已删除的题目，除非明确要求包含
  if (!filters.includeDeleted) {
    conditions.push('q.deleted_at IS NULL');
  }
  const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  return { where, params };
};

const buildPaginationClause = (filters: QuestionFilters) => {
  const clauses: string[] = [];
  const params: unknown[] = [];
  if (typeof filters.limit === 'number') {
    clauses.push('LIMIT ?');
    params.push(filters.limit);
  }
  if (typeof filters.offset === 'number') {
    clauses.push('OFFSET ?');
    params.push(filters.offset);
  }
  return { pagination: clauses.join(' '), params };
};

export class QuestionRepository {
  constructor(private readonly db: DbClient) {}

  async getAll(filters: QuestionFilters): Promise<Question[]> {
    const { where, params } = buildFilterClause(filters);
    const { pagination, params: paginationParams } = buildPaginationClause(filters);

    const sql = `
      WITH filtered_questions AS (
        SELECT q.*
        FROM questions q
        ${where}
        ORDER BY q.id
        ${pagination}
      )
      SELECT fq.*, o.id as option_id, o.option_text, o.option_order, o.is_correct
      FROM filtered_questions fq
      LEFT JOIN options o ON o.question_id = fq.id
      ORDER BY fq.id, o.option_order
    `;

    const rows = await this.db.all<QuestionRow>(sql, [...params, ...paginationParams]);
    return mapRowsToQuestions(rows);
  }

  async getById(id: string): Promise<Question | null> {
    const sql = `
      SELECT q.*, o.id as option_id, o.option_text, o.option_order, o.is_correct
      FROM questions q
      LEFT JOIN options o ON o.question_id = q.id
      WHERE q.id = ?
      ORDER BY o.option_order
    `;
    const rows = await this.db.all<QuestionRow>(sql, [id]);
    const questions = mapRowsToQuestions(rows);
    return questions[0] ?? null;
  }

  async getRandom(filters: RandomFilters): Promise<Question[]> {
    const baseFilters: QuestionFilters = {
      topic: filters.topic,
      difficulty: filters.difficulty,
    };
    const { where, params } = buildFilterClause(baseFilters);

    const idsSql = `
      SELECT q.id
      FROM questions q
      ${where}
      ORDER BY RANDOM()
      LIMIT ?
    `;

    const idRows = await this.db.all<{ id: string }>(idsSql, [...params, filters.count]);
    const ids = idRows.map((row) => row.id);
    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(', ');
    const sql = `
      SELECT q.*, o.id as option_id, o.option_text, o.option_order, o.is_correct
      FROM questions q
      LEFT JOIN options o ON o.question_id = q.id
      WHERE q.id IN (${placeholders})
      ORDER BY q.id, o.option_order
    `;
    const rows = await this.db.all<QuestionRow>(sql, ids);
    const questions = mapRowsToQuestions(rows);

    const order = new Map(ids.map((id, index) => [id, index]));
    return questions.sort((a, b) => (order.get(a.id) ?? 0) - (order.get(b.id) ?? 0));
  }

  /**
   * 创建新题目
   */
  async create(input: CreateQuestionInput): Promise<Question> {
    const tagsJson = input.tags ? JSON.stringify(input.tags) : null;

    await this.db.run(
      `INSERT INTO questions (id, content, topic, difficulty, explanation, mnemonic, scenario, tags)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        input.id,
        input.content,
        input.topic,
        input.difficulty,
        input.explanation ?? null,
        input.mnemonic ?? null,
        input.scenario ?? null,
        tagsJson,
      ]
    );

    // 插入选项
    for (const option of input.options) {
      const optionId = `${input.id}_opt${option.optionOrder}`;
      await this.db.run(
        `INSERT INTO options (id, question_id, option_text, option_order, is_correct)
         VALUES (?, ?, ?, ?, ?)`,
        [optionId, input.id, option.optionText, option.optionOrder, option.isCorrect ? 1 : 0]
      );
    }

    return (await this.getById(input.id))!;
  }

  /**
   * 更新题目
   */
  async update(id: string, input: UpdateQuestionInput): Promise<Question | null> {
    const existing = await this.getById(id);
    if (!existing) {
      return null;
    }

    const updates: string[] = [];
    const params: unknown[] = [];

    if (input.content !== undefined) {
      updates.push('content = ?');
      params.push(input.content);
    }
    if (input.topic !== undefined) {
      updates.push('topic = ?');
      params.push(input.topic);
    }
    if (input.difficulty !== undefined) {
      updates.push('difficulty = ?');
      params.push(input.difficulty);
    }
    if (input.explanation !== undefined) {
      updates.push('explanation = ?');
      params.push(input.explanation);
    }
    if (input.mnemonic !== undefined) {
      updates.push('mnemonic = ?');
      params.push(input.mnemonic);
    }
    if (input.scenario !== undefined) {
      updates.push('scenario = ?');
      params.push(input.scenario);
    }
    if (input.tags !== undefined) {
      updates.push('tags = ?');
      params.push(JSON.stringify(input.tags));
    }

    if (updates.length > 0) {
      params.push(id);
      await this.db.run(
        `UPDATE questions SET ${updates.join(', ')} WHERE id = ?`,
        params
      );
    }

    // 更新选项
    if (input.options !== undefined) {
      // 删除旧选项
      await this.db.run('DELETE FROM options WHERE question_id = ?', [id]);

      // 插入新选项
      for (const option of input.options) {
        const optionId = `${id}_opt${option.optionOrder}`;
        await this.db.run(
          `INSERT INTO options (id, question_id, option_text, option_order, is_correct)
           VALUES (?, ?, ?, ?, ?)`,
          [optionId, id, option.optionText, option.optionOrder, option.isCorrect ? 1 : 0]
        );
      }
    }

    return await this.getById(id);
  }

  /**
   * 软删除题目
   */
  async softDelete(id: string): Promise<boolean> {
    const existing = await this.getById(id);
    if (!existing) {
      return false;
    }

    const now = new Date().toISOString();
    await this.db.run(
      'UPDATE questions SET deleted_at = ? WHERE id = ?',
      [now, id]
    );
    return true;
  }

  /**
   * 统计题目数量
   */
  async count(filters: QuestionFilters = {}): Promise<number> {
    const { where, params } = buildFilterClause(filters);
    const sql = `SELECT COUNT(*) as count FROM questions q ${where}`;
    const row = await this.db.get<{ count: number }>(sql, params);
    return row?.count ?? 0;
  }

  /**
   * 获取题目统计信息
   */
  async getStats(): Promise<QuestionStats> {
    // 总数（排除已删除）
    const totalRow = await this.db.get<{ count: number }>(
      'SELECT COUNT(*) as count FROM questions WHERE deleted_at IS NULL'
    );
    const total = totalRow?.count ?? 0;

    // 按主题分组
    const topicRows = await this.db.all<{ topic: string; count: number }>(
      'SELECT topic, COUNT(*) as count FROM questions WHERE deleted_at IS NULL GROUP BY topic'
    );
    const byTopic: Record<string, number> = {};
    for (const row of topicRows) {
      byTopic[row.topic] = row.count;
    }

    // 按难度分组
    const difficultyRows = await this.db.all<{ difficulty: string; count: number }>(
      'SELECT difficulty, COUNT(*) as count FROM questions WHERE deleted_at IS NULL GROUP BY difficulty'
    );
    const byDifficulty: Record<string, number> = {};
    for (const row of difficultyRows) {
      byDifficulty[row.difficulty] = row.count;
    }

    return { total, byTopic, byDifficulty };
  }
}
