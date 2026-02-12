-- Migration 004: Add Learning Paths Tables
-- 此迁移为学习路径管理系统创建必要的数据库表
-- 包括：学习路径、路径分类、路径节点、用户进度

-- 学习路径表：存储学习路径定义
CREATE TABLE IF NOT EXISTS learning_paths (
  id VARCHAR(50) PRIMARY KEY,
  tech_stack VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  subtitle VARCHAR(200),
  character_icon VARCHAR(10) DEFAULT '🗡️',
  character_dialog VARCHAR(200) DEFAULT '准备好斩题了吗？',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 路径分类表：存储路径分类
CREATE TABLE IF NOT EXISTS path_categories (
  id VARCHAR(50) PRIMARY KEY,
  path_id VARCHAR(50) NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  color VARCHAR(20) DEFAULT '#58CC02',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 路径节点表：存储路径节点
CREATE TABLE IF NOT EXISTS path_nodes (
  id VARCHAR(50) PRIMARY KEY,
  category_id VARCHAR(50) NOT NULL REFERENCES path_categories(id) ON DELETE CASCADE,
  title VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  color VARCHAR(20) DEFAULT 'primary',
  sort_order INTEGER DEFAULT 0,
  question_ids TEXT,
  prerequisite_node_id VARCHAR(50) REFERENCES path_nodes(id),
  estimated_minutes INTEGER DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户路径进度表：存储用户进度
CREATE TABLE IF NOT EXISTS user_path_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id VARCHAR(50) NOT NULL,
  node_id VARCHAR(50) NOT NULL REFERENCES path_nodes(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'locked' CHECK (status IN ('locked', 'unlocked', 'completed')),
  correct_count INTEGER DEFAULT 0,
  total_count INTEGER DEFAULT 0,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, node_id)
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_path_categories_path_id ON path_categories(path_id);
CREATE INDEX IF NOT EXISTS idx_path_nodes_category_id ON path_nodes(category_id);
CREATE INDEX IF NOT EXISTS idx_path_nodes_prerequisite ON path_nodes(prerequisite_node_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_user_id ON user_path_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_node_id ON user_path_progress(node_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_status ON user_path_progress(status);
