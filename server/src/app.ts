import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import { openDatabase, type DbClient } from './database/connection';
import { HealthController } from './controllers/HealthController';
import { QuestionController } from './controllers/QuestionController';
import { AdminController } from './controllers/AdminController';
import { errorHandler } from './middlewares/errorHandler';
import { createHealthRouter } from './routes/health';
import { createQuestionRouter } from './routes/questions';
import { createUserProgressRouter } from './routes/userProgress';
import { createAdminRouter } from './routes/admin';
import { QuestionRepository } from './repositories/QuestionRepository';
import { QuestionService } from './services/QuestionService';
import { AdminService } from './services/AdminService';
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

  const adminService = new AdminService(questionRepository);
  const adminController = new AdminController(adminService);

  const userProgressRepository = new UserProgressRepository(database);
  const userProgressService = new UserProgressService(userProgressRepository);

  const pathRepository = new PathRepository(database);
  const pathService = new PathService(pathRepository);
  app.use(cors());
  app.use(express.json());
  app.use(morgan('dev'));

  // 注意：更具体的路由路径应该先注册
  // /api/admin 必须在 /api 之前注册，否则会被 /api 的中间件拦截
  app.use('/health', createHealthRouter(healthController));
  app.use('/questions', createQuestionRouter(questionController));
  app.use('/api/admin', createAdminRouter(adminController));
  app.use('/api/paths', createPathRouter(pathService));
  app.use('/api', createUserProgressRouter(userProgressService));

  app.use((_req, res) => {
    res.status(404).json({
      error: '资源不存在',
      message: '未找到对应的接口',
    });
  });

  app.use(errorHandler);

  return app;
};
