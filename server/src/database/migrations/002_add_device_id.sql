-- Migration 002: Add Device ID Support
-- 此迁移确保用户相关表具有 user_id 字段和必要的索引
-- 用于支持基于设备 ID 的用户识别

-- 确保 user_answers 表有 user_id 字段（如果已有则忽略）
ALTER TABLE user_answers ADD COLUMN IF NOT EXISTS user_id TEXT;

-- 确保 wrong_book 表有 user_id 字段（如果已有则忽略）
ALTER TABLE wrong_book ADD COLUMN IF NOT EXISTS user_id TEXT;

-- 确保 learning_progress 表有 user_id 字段（如果已有则忽略）
ALTER TABLE learning_progress ADD COLUMN IF NOT EXISTS user_id TEXT;

-- 创建索引加速查询（如果已存在则忽略）
CREATE INDEX IF NOT EXISTS idx_user_answers_device_id ON user_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_wrong_books_device_id ON wrong_book(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_device_id ON learning_progress(user_id);
