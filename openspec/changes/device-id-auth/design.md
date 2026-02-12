# 设备 ID 认证 - 设计文档

## 上下文

**当前状态**:
- Flutter 客户端已有基本的答题功能，但用户数据无法跨会话关联
- BFF 已有用户数据 API（进度、错题本、答题记录），但缺少用户标识
- 数据库表已预留 `user_id` 字段，但未实际使用

**约束**:
- 不实现复杂的账号系统，保持匿名用户模式
- 不依赖设备指纹等不稳定方案
- 需要支持离线场景

## 目标 / 非目标

**目标：**
- 为每个设备生成唯一且持久的标识符
- 自动将设备 ID 附加到所有 API 请求
- 后端正确关联和存储用户数据

**非目标：**
- 不实现跨设备数据同步
- 不实现用户登录/注册
- 不实现设备指纹等复杂识别方案

## 决策

### 1. 设备 ID 生成方案

**决策**: 使用 UUID v4 作为设备 ID

**理由**:
- 标准化格式，易于处理
- 碰撞概率极低
- Flutter `uuid` 包提供原生支持

**替代方案**:
- 设备唯一标识符（如 iOS 的 identifierForVendor）: 跨平台复杂，且可能被重置
- 自定义随机字符串: 需要自行保证唯一性

### 2. 存储方案

**决策**: 使用 `shared_preferences` 本地存储

**理由**:
- Flutter 标准本地存储方案
- 数据持久化，不会因应用重启而丢失
- 简单易用

### 3. API 传递方式

**决策**: 通过 HTTP Header 传递设备 ID

**格式**: `X-Device-ID: <uuid>`

**理由**:
- 与业务参数分离
- 统一处理，避免每个接口单独传递
- 符合 RESTful 最佳实践

### 4. 后端验证策略

**决策**: 验证设备 ID 格式，但不强制注册

**理由**:
- 首次访问时自动创建用户数据
- 降低客户端复杂度
- 匿名用户场景下不需要预注册流程

## 风险 / 权衡

| 风险 | 缓解措施 |
|------|---------|
| 用户清除应用数据后设备 ID 丢失，历史数据无法关联 | 这是匿名方案的固有限制，可通过提示用户备份缓解 |
| UUID 可以被伪造 | 不存储敏感信息，伪造不影响数据安全 |
| 共用设备（如家庭平板）会混用数据 | 后续可考虑添加"用户切换"功能 |

## 迁移计划

1. **BFF 端**:
   - 添加设备 ID 验证中间件
   - 更新现有 API 路由要求设备 ID
   - 数据库迁移：确保 `user_id` 字段存在

2. **Flutter 端**:
   - 添加设备 ID 生成逻辑
   - 添加请求拦截器
   - 逐步更新各 Repository 调用

3. **部署顺序**:
   - 先部署 BFF（向后兼容，设备 ID 可选）
   - 再部署 Flutter（开始发送设备 ID）
   - 最后 BFF 强制要求设备 ID

## 数据库变更

```sql
-- 确保表有 user_id 字段
ALTER TABLE user_answers ADD COLUMN IF NOT EXISTS user_id TEXT;
ALTER TABLE wrong_books ADD COLUMN IF NOT EXISTS user_id TEXT;
ALTER TABLE user_progress ADD COLUMN IF NOT EXISTS user_id TEXT;

-- 创建索引加速查询
CREATE INDEX IF NOT EXISTS idx_user_answers_device_id ON user_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_wrong_books_device_id ON wrong_books(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_device_id ON user_progress(user_id);
```
