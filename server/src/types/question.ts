export type Difficulty = 'easy' | 'medium' | 'hard';

export type Option = {
  id: string;
  optionText: string;
  optionOrder: number;
  isCorrect: boolean;
};

export type Question = {
  id: string;
  content: string;
  topic: string;
  difficulty: Difficulty;
  explanation?: string | null;
  mnemonic?: string | null;
  scenario?: string | null;
  tags: string[];
  options: Option[];
  deletedAt?: string | null;
};

export type QuestionFilters = {
  topic?: string;
  difficulty?: Difficulty;
  limit?: number;
  offset?: number;
  includeDeleted?: boolean;
};

export type RandomFilters = {
  topic?: string;
  difficulty?: Difficulty;
  count: number;
};

export type CreateQuestionInput = {
  id: string;
  content: string;
  topic: string;
  difficulty: Difficulty;
  explanation?: string | null;
  mnemonic?: string | null;
  scenario?: string | null;
  tags?: string[];
  options: {
    optionText: string;
    optionOrder: number;
    isCorrect: boolean;
  }[];
};

export type UpdateQuestionInput = Partial<Omit<CreateQuestionInput, 'id' | 'options'>> & {
  options?: CreateQuestionInput['options'];
};

export type QuestionStats = {
  total: number;
  byTopic: Record<string, number>;
  byDifficulty: Record<string, number>;
};
