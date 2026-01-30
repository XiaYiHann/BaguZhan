import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import { openDatabase, type DbClient } from './database/connection';
import { HealthController } from './controllers/HealthController';
import { QuestionController } from './controllers/QuestionController';
import { errorHandler } from './middlewares/errorHandler';
import { createHealthRouter } from './routes/health';
import { createQuestionRouter } from './routes/questions';
import { createUserProgressRouter } from './routes/userProgress';
import { QuestionRepository } from './repositories/QuestionRepository';
import { QuestionService } from './services/QuestionService';
import { UserProgressRepository } from './repositories/UserProgressRepository';
import { UserProgressService } from './services/UserProgressService';
import { PathRepository } from './repositories/PathRepository';
import { PathService } from './services/PathService';
import { createPathRouter } from './routes/paths';

export const createApp = (db?: DbClient) => {
  const app = express();
  const database = db ?? openDatabase();

  const questionRepository = new QuestionRepository(database);
  const questionService = new QuestionService(questionRepository);
  const questionController = new QuestionController(questionService);
  const healthController = new HealthController();

  const userProgressRepository = new UserProgressRepository(database);
  const userProgressService = new UserProgressService(userProgressRepository);

  const pathRepository = new PathRepository(database);
  const pathService = new PathService(pathRepository);
  app.use(cors());
  app.use(express.json());
  app.use(morgan('dev'));

  app.use('/health', createHealthRouter(healthController));
  app.use('/questions', createQuestionRouter(questionController));
  app.use('/api', createUserProgressRouter(userProgressService));
  app.use('/api/paths', createPathRouter(pathService));

  app.use((_req, res) => {
    res.status(404).json({
      error: '资源不存在',
      message: '未找到对应的接口',
    });
  });

  app.use(errorHandler);

  return app;
};
