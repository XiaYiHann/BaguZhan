import type { DbClient } from '../database/connection';
import type { Question, QuestionFilters, RandomFilters } from '../types/question';

type QuestionRow = {
  id: string;
  content: string;
  topic: string;
  difficulty: string;
  explanation: string | null;
  mnemonic: string | null;
  scenario: string | null;
  tags: string | null;
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
}
