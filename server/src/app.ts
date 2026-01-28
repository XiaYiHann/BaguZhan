import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import { openDatabase, type DbClient } from './database/connection';
import { HealthController } from './controllers/HealthController';
import { QuestionController } from './controllers/QuestionController';
import { errorHandler } from './middlewares/errorHandler';
import { createHealthRouter } from './routes/health';
import { createQuestionRouter } from './routes/questions';
import { QuestionRepository } from './repositories/QuestionRepository';
import { QuestionService } from './services/QuestionService';

export const createApp = (db?: DbClient) => {
  const app = express();
  const database = db ?? openDatabase();

  const questionRepository = new QuestionRepository(database);
  const questionService = new QuestionService(questionRepository);
  const questionController = new QuestionController(questionService);
  const healthController = new HealthController();

  app.use(cors());
  app.use(express.json());
  app.use(morgan('dev'));

  app.use('/health', createHealthRouter(healthController));
  app.use('/questions', createQuestionRouter(questionController));

  app.use((_req, res) => {
    res.status(404).json({
      error: '资源不存在',
      message: '未找到对应的接口',
    });
  });

  app.use(errorHandler);

  return app;
};
