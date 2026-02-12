CREATE TABLE IF NOT EXISTS questions (
  id TEXT PRIMARY KEY,
  content TEXT NOT NULL,
  topic TEXT NOT NULL,
  difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
  explanation TEXT,
  mnemonic TEXT,
  scenario TEXT,
  tags TEXT,
  deleted_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS options (
  id TEXT PRIMARY KEY,
  question_id TEXT NOT NULL,
  option_text TEXT NOT NULL,
  option_order INTEGER NOT NULL CHECK (option_order BETWEEN 0 AND 3),
  is_correct INTEGER NOT NULL DEFAULT 0,
  UNIQUE (question_id, option_order),
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_questions_topic ON questions(topic);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions(difficulty);
CREATE INDEX IF NOT EXISTS idx_questions_topic_difficulty ON questions(topic, difficulty);
CREATE INDEX IF NOT EXISTS idx_questions_deleted_at ON questions(deleted_at);
CREATE INDEX IF NOT EXISTS idx_options_question_id ON options(question_id);

-- 用户答题记录表
CREATE TABLE IF NOT EXISTS user_answers (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  selected_option_id TEXT NOT NULL,
  is_correct INTEGER NOT NULL,
  answer_time_ms INTEGER,
  answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- 错题本表
CREATE TABLE IF NOT EXISTS wrong_book (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  question_id TEXT NOT NULL,
  wrong_count INTEGER NOT NULL DEFAULT 1,
  last_wrong_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_mastered INTEGER NOT NULL DEFAULT 0,
  mastered_at TIMESTAMP,
  UNIQUE (user_id, question_id),
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);

-- 学习进度统计表
CREATE TABLE IF NOT EXISTS learning_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL UNIQUE,
  total_answered INTEGER NOT NULL DEFAULT 0,
  total_correct INTEGER NOT NULL DEFAULT 0,
  current_streak INTEGER NOT NULL DEFAULT 0,
  longest_streak INTEGER NOT NULL DEFAULT 0,
  last_answered_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 错题本和学习进度索引
CREATE INDEX IF NOT EXISTS idx_user_answers_user_id ON user_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_user_answers_user_time ON user_answers(user_id, answered_at DESC);
CREATE INDEX IF NOT EXISTS idx_wrong_book_user_id ON wrong_book(user_id);
CREATE INDEX IF NOT EXISTS idx_wrong_book_user_mastered ON wrong_book(user_id, is_mastered);
CREATE INDEX IF NOT EXISTS idx_wrong_book_user_question ON wrong_book(user_id, question_id);
CREATE INDEX IF NOT EXISTS idx_learning_progress_user_id ON learning_progress(user_id);

-- 学习路径地图系统表

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
  question_ids TEXT,  -- JSON 数组字符串，如 '["q001","q002","q003"')'
  prerequisite_node_id VARCHAR(50) REFERENCES path_nodes(id),
  estimated_minutes INTEGER DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 用户路径进度表：存储用户进度
CREATE TABLE IF NOT EXISTS user_path_progress (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  node_id VARCHAR(50) NOT NULL REFERENCES path_nodes(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'locked' CHECK (status IN ('locked', 'unlocked', 'completed')),
  correct_count INTEGER DEFAULT 0,
  total_count INTEGER DEFAULT 0,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, node_id)
);

-- JavaScript 学习路径示例数据

-- 插入 JavaScript 学习路径
INSERT INTO learning_paths (id, tech_stack, title, subtitle, character_icon, character_dialog) VALUES
('path_js', 'javascript', 'JavaScript核心', '从基础到进阶，掌握JS核心概念', '🗡️', '准备好斩题了吗？');

-- 插入路径分类：基础语法、进阶概念、ES6+特性
INSERT INTO path_categories (id, path_id, name, icon, color, sort_order) VALUES
('cat_js_basic', 'path_js', '基础语法', '📘', '#58CC02', 1),
('cat_js_advanced', 'path_js', '进阶概念', '⚡', '#FF9600', 2),
('cat_js_es6', 'path_js', 'ES6+特性', '🚀', '#1CB0F6', 3);

-- 插入基础语法分类节点（8个节点）
INSERT INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_var', 'cat_js_basic', '变量与作用域', '☕', 'primary', 1, '["q001","q002","q003"]', NULL, 10),
('node_js_type', 'cat_js_basic', '数据类型', '🔢', 'primary', 2, '["q004","q005","q006"]', 'node_js_var', 10),
('node_js_operator', 'cat_js_basic', '运算符与表达式', '➕', 'primary', 3, '["q007","q008","q009"]', 'node_js_type', 10),
('node_js_control', 'cat_js_basic', '流程控制', '🔀', 'primary', 4, '["q010","q011","q012"]', 'node_js_operator', 10),
('node_js_function_basic', 'cat_js_basic', '函数基础', '🔧', 'primary', 5, '["q013","q014","q015"]', 'node_js_control', 15),
('node_js_array', 'cat_js_basic', '数组操作', '📊', 'primary', 6, '["q016","q017","q018"]', 'node_js_function_basic', 15),
('node_js_object', 'cat_js_basic', '对象基础', '📦', 'primary', 7, '["q019","q020","q021"]', 'node_js_array', 15),
('node_js_basic_quiz', 'cat_js_basic', '基础语法测验', '🎁', 'accent', 8, '["q022","q023","q024","q025"]', 'node_js_object', 20);

-- 插入进阶概念分类节点（8个节点）
INSERT INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_scope', 'cat_js_advanced', '作用域链', '🔗', 'secondary', 1, '["q026","q027","q028"]', 'node_js_basic_quiz', 15),
('node_js_hoisting', 'cat_js_advanced', '变量提升', '⬆️', 'secondary', 2, '["q029","q030","q031"]', 'node_js_scope', 15),
('node_js_this', 'cat_js_advanced', 'this指向', '🎯', 'secondary', 3, '["q032","q033","q034"]', 'node_js_hoisting', 20),
('node_js_prototype', 'cat_js_advanced', '原型与继承', '🧬', 'secondary', 4, '["q035","q036","q037"]', 'node_js_this', 20),
('node_js_closure', 'cat_js_advanced', '闭包', '🔒', 'secondary', 5, '["q038","q039","q040"]', 'node_js_prototype', 20),
('node_js_async', 'cat_js_advanced', '异步编程', '⏱️', 'secondary', 6, '["q041","q042","q043"]', 'node_js_closure', 25),
('node_js_event', 'cat_js_advanced', '事件循环', '🔄', 'secondary', 7, '["q044","q045","q046"]', 'node_js_async', 25),
('node_js_advanced_quiz', 'cat_js_advanced', '进阶概念测验', '🎁', 'accent', 8, '["q047","q048","q049","q050"]', 'node_js_event', 25);

-- 插入ES6+特性分类节点（8个节点）
INSERT INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_letconst', 'cat_js_es6', 'let与const', '🆕', 'primary', 1, '["q051","q052","q053"]', 'node_js_advanced_quiz', 10),
('node_js_arrow', 'cat_js_es6', '箭头函数', '➡️', 'primary', 2, '["q054","q055","q056"]', 'node_js_letconst', 10),
('node_js_destructure', 'cat_js_es6', '解构赋值', '📋', 'primary', 3, '["q057","q058","q059"]', 'node_js_arrow', 15),
('node_js_spread', 'cat_js_es6', '展开运算符', '🌊', 'primary', 4, '["q060","q061","q062"]', 'node_js_destructure', 15),
('node_js_promise', 'cat_js_es6', 'Promise', '🤝', 'primary', 5, '["q063","q064","q065"]', 'node_js_spread', 20),
('node_js_asyncawait', 'cat_js_es6', 'Async/Await', '⚡', 'primary', 6, '["q066","q067","q068"]', 'node_js_promise', 20),
('node_js_module', 'cat_js_es6', '模块化', '📦', 'primary', 7, '["q069","q070","q071"]', 'node_js_asyncawait', 15),
('node_js_es6_quiz', 'cat_js_es6', 'ES6+特性测验', '🎁', 'accent', 8, '["q072","q073","q074","q075"]', 'node_js_module', 25);

-- 学习路径相关索引
CREATE INDEX IF NOT EXISTS idx_path_categories_path_id ON path_categories(path_id);
CREATE INDEX IF NOT EXISTS idx_path_nodes_category_id ON path_nodes(category_id);
CREATE INDEX IF NOT EXISTS idx_path_nodes_prerequisite ON path_nodes(prerequisite_node_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_user_id ON user_path_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_node_id ON user_path_progress(node_id);
CREATE INDEX IF NOT EXISTS idx_user_path_progress_status ON user_path_progress(status);
