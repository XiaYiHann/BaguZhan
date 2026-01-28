import type { Question, QuestionFilters, RandomFilters } from '../types/question';
import { HttpError } from '../errors/HttpError';
import { QuestionRepository } from '../repositories/QuestionRepository';

const ALLOWED_DIFFICULTIES = ['easy', 'medium', 'hard'] as const;

const DEFAULT_LIMIT = 10;
const MAX_LIMIT = 50;
const DEFAULT_OFFSET = 0;
const DEFAULT_RANDOM_COUNT = 5;
const MAX_RANDOM_COUNT = 20;

const normalizeTopic = (topic?: string | null) => {
  if (topic === undefined || topic === null) {
    return undefined;
  }
  const trimmed = topic.trim();
  return trimmed.length > 0 ? trimmed : undefined;
};

const validateDifficulty = (difficulty?: string | null) => {
  if (!difficulty) {
    return undefined;
  }
  if (!ALLOWED_DIFFICULTIES.includes(difficulty as (typeof ALLOWED_DIFFICULTIES)[number])) {
    throw new HttpError(400, '难度参数不合法', {
      allowed: ALLOWED_DIFFICULTIES,
    });
  }
  return difficulty as Question['difficulty'];
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

export class QuestionService {
  constructor(private readonly repository: QuestionRepository) {}

  async queryQuestions(params: {
    topic?: string;
    difficulty?: string;
    limit?: string;
    offset?: string;
  }): Promise<Question[]> {
    const topic = normalizeTopic(params.topic);
    const difficulty = validateDifficulty(params.difficulty ?? undefined);
    const limit = parseNumber(params.limit, DEFAULT_LIMIT);
    const offset = parseNumber(params.offset, DEFAULT_OFFSET);

    if (limit <= 0 || limit > MAX_LIMIT) {
      throw new HttpError(400, 'limit 超出允许范围', {
        max: MAX_LIMIT,
      });
    }
    if (offset < 0) {
      throw new HttpError(400, 'offset 不能为负数');
    }

    const filters: QuestionFilters = {
      topic,
      difficulty,
      limit,
      offset,
    };

    return this.repository.getAll(filters);
  }

  async getRandomQuestions(params: {
    topic?: string;
    difficulty?: string;
    count?: string;
  }): Promise<Question[]> {
    const topic = normalizeTopic(params.topic);
    const difficulty = validateDifficulty(params.difficulty ?? undefined);
    const count = params.count ? parseNumber(params.count, DEFAULT_RANDOM_COUNT) : DEFAULT_RANDOM_COUNT;

    if (count <= 0 || count > MAX_RANDOM_COUNT) {
      throw new HttpError(400, 'count 超出允许范围', {
        max: MAX_RANDOM_COUNT,
      });
    }

    const filters: RandomFilters = {
      topic,
      difficulty,
      count,
    };

    return this.repository.getRandom(filters);
  }

  async getQuestionById(id: string): Promise<Question> {
    const trimmed = id.trim();
    if (!trimmed) {
      throw new HttpError(400, '题目 ID 不能为空');
    }
    const question = await this.repository.getById(trimmed);
    if (!question) {
      throw new HttpError(404, '题目不存在');
    }
    return question;
  }
}
