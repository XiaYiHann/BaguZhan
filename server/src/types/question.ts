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
};

export type QuestionFilters = {
  topic?: string;
  difficulty?: Difficulty;
  limit?: number;
  offset?: number;
};

export type RandomFilters = {
  topic?: string;
  difficulty?: Difficulty;
  count: number;
};
