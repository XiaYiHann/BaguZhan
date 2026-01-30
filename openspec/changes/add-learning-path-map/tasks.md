# 实施任务清单

## 1. 数据库设计
- [ ] 1.1 创建 `learning_paths` 表
- [ ] 1.2 创建 `path_categories` 表
- [ ] 1.3 创建 `path_nodes` 表
- [ ] 1.4 创建 `user_path_progress` 表
- [ ] 1.5 添加示例数据（JavaScript路径）

## 2. BFF API 实现
- [ ] 2.1 创建 PathRepository 数据访问层
- [ ] 2.2 实现 `GET /api/paths/:techStack` 接口
- [ ] 2.3 实现 `GET /api/paths/:techStack/categories` 接口
- [ ] 2.4 实现 `GET /api/paths/nodes/:nodeId/questions` 接口
- [ ] 2.5 实现 `POST /api/paths/nodes/:nodeId/complete` 接口
- [ ] 2.6 编写 API 测试

## 3. 数据模型（Flutter）
- [ ] 3.1 创建 `LearningPathModel`
- [ ] 3.2 创建 `PathCategoryModel`
- [ ] 3.3 创建 `PathNodeModel`
- [ ] 3.4 创建 `PathRepository` 抽象类
- [ ] 3.5 实现 `ApiPathRepository`

## 4. 组件实现
- [ ] 4.1 创建 `PathNodeWidget` - 路径节点组件
- [ ] 4.2 创建 `PathLinePainter` - 路径连线绘制器
- [ ] 4.3 创建 `CharacterDialogWidget` - 角色对话框
- [ ] 4.4 创建 `PathCategoryCard` - 分类卡片
- [ ] 4.5 创建 `PathProgressBanner` - 进度横幅

## 5. 页面实现
- [ ] 5.1 创建 `PathCategoryPage` - 路径分类页面
- [ ] 5.2 创建 `LearningPathMapPage` - 学习路径地图页面
- [ ] 5.3 创建 `NodeDetailPage` - 节点详情页面（可选）
- [ ] 5.4 修改 `HomePage` - 点击进入 PathCategoryPage
- [ ] 5.5 修改 `QuestionPage` - 支持 nodeId 参数

## 6. 状态管理
- [ ] 6.1 创建 `LearningPathProvider`
- [ ] 6.2 实现路径数据加载逻辑
- [ ] 6.3 实现节点解锁/完成逻辑
- [ ] 6.4 实现进度追踪

## 7. 测试
- [ ] 7.1 编写组件 Widget 测试
- [ ] 7.2 编写页面集成测试
- [ ] 7.3 编写 API 单元测试
- [ ] 7.4 添加 Golden 测试（路径地图视觉效果）

## 8. 文档
- [ ] 8.1 更新 README.md 添加路径地图功能说明
- [ ] 8.2 创建路径数据配置文档
- [ ] 8.3 更新 OpenSpec 规范

## 9. 示例数据
- [ ] 9.1 配置 JavaScript 学习路径
- [ ] 9.2 配置 React 学习路径
- [ ] 9.3 配置 Vue 学习路径
