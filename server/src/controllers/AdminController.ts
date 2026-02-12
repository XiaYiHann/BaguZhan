import type { Request, Response } from 'express';
import type { CreateQuestionInput, UpdateQuestionInput } from '../types/question';
import { AdminService } from '../services/AdminService';

export class AdminController {
  constructor(private readonly service: AdminService) {}

  /**
   * POST /api/admin/login
   * 管理员登录
   */
  login = async (req: Request, res: Response): Promise<void> => {
    const { apiKey } = req.body;

    if (!apiKey) {
      res.status(400).json({
        error: '缺少 API Key',
        message: '请求体必须包含 apiKey 字段',
      });
      return;
    }

    const result = this.service.validateApiKey(apiKey);
    if (!result) {
      res.status(401).json({
        error: '无效的 API Key',
        message: '提供的 API Key 无效',
      });
      return;
    }

    res.json({
      token: result.token,
      expiresIn: result.expiresIn,
    });
  };

  /**
   * GET /api/admin/questions
   * 获取题目列表
   */
  listQuestions = async (req: Request, res: Response): Promise<void> => {
    const result = await this.service.listQuestions({
      topic: req.query.topic as string | undefined,
      difficulty: req.query.difficulty as string | undefined,
      limit: req.query.limit as string | undefined,
      offset: req.query.offset as string | undefined,
      includeDeleted: req.query.includeDeleted as string | undefined,
    });

    res.json({
      data: result.questions,
      pagination: {
        total: result.total,
        limit: req.query.limit ? Number(req.query.limit) : 20,
        offset: req.query.offset ? Number(req.query.offset) : 0,
      },
    });
  };

  /**
   * GET /api/admin/questions/:id
   * 获取单个题目
   */
  getQuestion = async (req: Request, res: Response): Promise<void> => {
    const question = await this.service.getRepository().getById(req.params.id);
    if (!question) {
      res.status(404).json({
        error: '题目不存在',
        message: `未找到 ID 为 ${req.params.id} 的题目`,
      });
      return;
    }
    res.json(question);
  };

  /**
   * POST /api/admin/questions
   * 创建题目
   */
  createQuestion = async (req: Request, res: Response): Promise<void> => {
    const input: CreateQuestionInput = req.body;
    const question = await this.service.createQuestion(input);
    res.status(201).json(question);
  };

  /**
   * PUT /api/admin/questions/:id
   * 更新题目
   */
  updateQuestion = async (req: Request, res: Response): Promise<void> => {
    const input: UpdateQuestionInput = req.body;
    const question = await this.service.updateQuestion(req.params.id, input);
    res.json(question);
  };

  /**
   * DELETE /api/admin/questions/:id
   * 软删除题目
   */
  deleteQuestion = async (req: Request, res: Response): Promise<void> => {
    await this.service.deleteQuestion(req.params.id);
    res.status(204).send();
  };

  /**
   * POST /api/admin/questions/import
   * 批量导入题目
   */
  importQuestions = async (req: Request, res: Response): Promise<void> => {
    const questions: CreateQuestionInput[] = req.body;

    if (!Array.isArray(questions)) {
      res.status(400).json({
        error: '无效的数据格式',
        message: '请求体必须是题目数组',
      });
      return;
    }

    const result = await this.service.importQuestions(questions);
    res.json(result);
  };

  /**
   * GET /api/admin/stats
   * 获取题库统计信息
   */
  getStats = async (req: Request, res: Response): Promise<void> => {
    const stats = await this.service.getStats();
    res.json(stats);
  };
}
