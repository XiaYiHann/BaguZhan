-- Migration 003: Add Soft Delete Support
-- 此迁移为 questions 表添加软删除支持
-- 允许题目标记为已删除而非物理删除，保留历史数据

-- 添加 deleted_at 字段 (SQLite 不支持 IF NOT EXISTS)
ALTER TABLE questions ADD COLUMN deleted_at TIMESTAMP;

-- 创建索引加速软删除查询 (IF NOT EXISTS 对于 CREATE INDEX 是支持的)
CREATE INDEX IF NOT EXISTS idx_questions_deleted_at ON questions(deleted_at);
