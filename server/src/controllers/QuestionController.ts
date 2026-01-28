import type { Request, Response } from 'express';

import { QuestionService } from '../services/QuestionService';

export class QuestionController {
  constructor(private readonly service: QuestionService) {}

  list = async (req: Request, res: Response) => {
    const questions = await this.service.queryQuestions({
      topic: req.query.topic ? String(req.query.topic) : undefined,
      difficulty: req.query.difficulty ? String(req.query.difficulty) : undefined,
      limit: req.query.limit ? String(req.query.limit) : undefined,
      offset: req.query.offset ? String(req.query.offset) : undefined,
    });
    res.json(questions);
  };

  random = async (req: Request, res: Response) => {
    const questions = await this.service.getRandomQuestions({
      topic: req.query.topic ? String(req.query.topic) : undefined,
      difficulty: req.query.difficulty ? String(req.query.difficulty) : undefined,
      count: req.query.count ? String(req.query.count) : undefined,
    });
    res.json(questions);
  };

  getById = async (req: Request, res: Response) => {
    const question = await this.service.getQuestionById(String(req.params.id));
    res.json(question);
  };
}
