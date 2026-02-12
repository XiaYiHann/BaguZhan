import type { QuestionFilters, CreateQuestionInput, UpdateQuestionInput } from '../types/question';
import { HttpError } from '../errors/HttpError';
import { QuestionRepository } from '../repositories/QuestionRepository';
import { config } from '../config/config';

const ALLOWED_DIFFICULTIES = ['easy', 'medium', 'hard'] as const;

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 100;
const DEFAULT_OFFSET = 0;
const MAX_IMPORT_COUNT = 100;

const validateDifficulty = (difficulty?: string | null) => {
  if (!difficulty) {
    return undefined;
  }
  if (!ALLOWED_DIFFICULTIES.includes(difficulty as (typeof ALLOWED_DIFFICULTIES)[number])) {
    throw new HttpError(400, '难度参数不合法', {
      allowed: ALLOWED_DIFFICULTIES,
    });
  }
  return difficulty as (typeof ALLOWED_DIFFICULTIES)[number];
};

const parseNumber = (value: string | undefined, fallback: number) => {
  if (value === undefined) {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new HttpError(400, '分页参数必须为数字');
  }
  return parsed;
};

const validateQuestionInput = (input: CreateQuestionInput, index?: number): void => {
  const prefix = index !== undefined ? `第 ${index + 1} 题: ` : '';

  if (!input.content || input.content.trim().length === 0) {
    throw new HttpError(422, `${prefix}题目内容不能为空`);
  }

  if (!input.topic || input.topic.trim().length === 0) {
    throw new HttpError(422, `${prefix}题目主题不能为空`);
  }

  if (!input.difficulty || !ALLOWED_DIFFICULTIES.includes(input.difficulty)) {
    throw new HttpError(422, `${prefix}难度必须是 easy、medium 或 hard`);
  }

  if (!input.options || input.options.length < 2) {
    throw new HttpError(422, `${prefix}选项数量至少需要 2 个`);
  }

  if (input.options.length > 6) {
    throw new HttpError(422, `${prefix}选项数量不能超过 6 个`);
  }

  const correctOptions = input.options.filter((opt) => opt.isCorrect);
  if (correctOptions.length === 0) {
    throw new HttpError(422, `${prefix}至少需要一个正确选项`);
  }

  // 验证选项顺序
  const orders = input.options.map((opt) => opt.optionOrder);
  const uniqueOrders = new Set(orders);
  if (uniqueOrders.size !== orders.length) {
    throw new HttpError(422, `${prefix}选项顺序不能重复`);
  }
};

export class AdminService {
  constructor(private readonly repository: QuestionRepository) {}

  /**
   * 获取底层的 QuestionRepository 实例
   * 用于控制器直接访问某些仓库方法
   */
  getRepository(): QuestionRepository {
    return this.repository;
  }

  async listQuestions(params: {
    topic?: string;
    difficulty?: string;
    limit?: string;
    offset?: string;
    includeDeleted?: string;
  }): Promise<{ questions: ReturnType<QuestionRepository['getAll']> extends Promise<infer T> ? T : never; total: number }> {
    const topic = params.topic?.trim() || undefined;
    const difficulty = validateDifficulty(params.difficulty);
    const limit = parseNumber(params.limit, DEFAULT_LIMIT);
    const offset = parseNumber(params.offset, DEFAULT_OFFSET);
    const includeDeleted = params.includeDeleted === 'true';

    if (limit <= 0 || limit > MAX_LIMIT) {
      throw new HttpError(400, 'limit 超出允许范围', { max: MAX_LIMIT });
    }
    if (offset < 0) {
      throw new HttpError(400, 'offset 不能为负数');
    }

    const filters: QuestionFilters = {
      topic,
      difficulty,
      limit,
      offset,
      includeDeleted,
    };

    const [questions, total] = await Promise.all([
      this.repository.getAll(filters),
      this.repository.count(filters),
    ]);

    return { questions, total };
  }

  async createQuestion(input: CreateQuestionInput): Promise<ReturnType<QuestionRepository['create']> extends Promise<infer T> ? T : never> {
    validateQuestionInput(input);

    const existing = await this.repository.getById(input.id);
    if (existing) {
      throw new HttpError(409, '题目 ID 已存在', { id: input.id });
    }

    return this.repository.create(input);
  }

  async updateQuestion(id: string, input: UpdateQuestionInput): Promise<ReturnType<QuestionRepository['update']> extends Promise<infer T> ? T : never> {
    const trimmed = id.trim();
    if (!trimmed) {
      throw new HttpError(400, '题目 ID 不能为空');
    }

    if (input.difficulty !== undefined && !ALLOWED_DIFFICULTIES.includes(input.difficulty)) {
      throw new HttpError(400, '难度必须是 easy、medium 或 hard');
    }

    if (input.options !== undefined) {
      if (input.options.length < 2) {
        throw new HttpError(422, '选项数量至少需要 2 个');
      }
      if (input.options.length > 6) {
        throw new HttpError(422, '选项数量不能超过 6 个');
      }
      const correctOptions = input.options.filter((opt) => opt.isCorrect);
      if (correctOptions.length === 0) {
        throw new HttpError(422, '至少需要一个正确选项');
      }
    }

    const question = await this.repository.update(trimmed, input);
    if (!question) {
      throw new HttpError(404, '题目不存在');
    }

    return question;
  }

  async deleteQuestion(id: string): Promise<void> {
    const trimmed = id.trim();
    if (!trimmed) {
      throw new HttpError(400, '题目 ID 不能为空');
    }

    const deleted = await this.repository.softDelete(trimmed);
    if (!deleted) {
      throw new HttpError(404, '题目不存在');
    }
  }

  async importQuestions(questions: CreateQuestionInput[]): Promise<{
    imported: number;
    failed: number;
    errors: Array<{ index: number; message: string }>;
  }> {
    if (questions.length === 0) {
      throw new HttpError(400, '导入数据不能为空');
    }

    if (questions.length > MAX_IMPORT_COUNT) {
      throw new HttpError(400, `一次最多导入 ${MAX_IMPORT_COUNT} 道题`);
    }

    const errors: Array<{ index: number; message: string }> = [];
    let imported = 0;

    for (let i = 0; i < questions.length; i++) {
      const input = questions[i];
      try {
        validateQuestionInput(input, i);

        const existing = await this.repository.getById(input.id);
        if (existing) {
          errors.push({ index: i, message: `题目 ID "${input.id}" 已存在` });
          continue;
        }

        await this.repository.create(input);
        imported++;
      } catch (error) {
        const message = error instanceof HttpError ? error.message : String(error);
        errors.push({ index: i, message });
      }
    }

    return {
      imported,
      failed: errors.length,
      errors,
    };
  }

  async getStats(): Promise<ReturnType<QuestionRepository['getStats']> extends Promise<infer T> ? T : never> {
    return this.repository.getStats();
  }

  validateApiKey(apiKey: string): { token: string; expiresIn: number } | null {
    if (apiKey !== config.adminApiKey) {
      return null;
    }

    // 生成一个简单的会话 token（实际生产中应该使用 JWT 或其他安全机制）
    const token = Buffer.from(`${apiKey}:${Date.now()}`).toString('base64');
    return {
      token,
      expiresIn: 86400, // 24 小时
    };
  }
}
