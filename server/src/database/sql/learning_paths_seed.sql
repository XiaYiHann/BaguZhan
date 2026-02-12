-- Learning Paths Initial Data
-- 插入初始学习路径、分类和节点数据

-- ============ 学习路径 ============

INSERT OR IGNORE INTO learning_paths (id, tech_stack, title, subtitle, character_icon, character_dialog) VALUES
('path_js', 'javascript', 'JavaScript核心', '从基础到进阶，掌握JS核心概念', '🗡️', '准备好斩题了吗？'),
('path_react', 'react', 'React框架', '掌握React生态，构建现代Web应用', '⚛️', '组件化的艺术！'),
('path_vue', 'vue', 'Vue框架', '渐进式JavaScript框架学习之路', '💚', 'Vue你行！');

-- ============ JavaScript 路径分类 ============

INSERT OR IGNORE INTO path_categories (id, path_id, name, icon, color, sort_order) VALUES
('cat_js_basic', 'path_js', '基础语法', '📘', '#58CC02', 1),
('cat_js_advanced', 'path_js', '进阶概念', '⚡', '#FF9600', 2),
('cat_js_es6', 'path_js', 'ES6+特性', '🚀', '#1CB0F6', 3);

-- JavaScript 基础语法节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_var', 'cat_js_basic', '变量与作用域', '☕', 'primary', 1, '["js-1","js-2","js-3"]', NULL, 10),
('node_js_type', 'cat_js_basic', '数据类型', '🔢', 'primary', 2, '["js-4","js-5","js-6"]', 'node_js_var', 10),
('node_js_operator', 'cat_js_basic', '运算符与表达式', '➕', 'primary', 3, '["js-7","js-8","js-9"]', 'node_js_type', 10),
('node_js_control', 'cat_js_basic', '流程控制', '🔀', 'primary', 4, '["js-10","js-11","js-12"]', 'node_js_operator', 10),
('node_js_function_basic', 'cat_js_basic', '函数基础', '🔧', 'primary', 5, '["js-13","js-14","js-15"]', 'node_js_control', 15);

-- JavaScript 进阶概念节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_scope', 'cat_js_advanced', '作用域链', '🔗', 'secondary', 1, '["js-16","js-17","js-18"]', 'node_js_function_basic', 15),
('node_js_hoisting', 'cat_js_advanced', '变量提升', '⬆️', 'secondary', 2, '["js-19","js-20","js-21"]', 'node_js_scope', 15),
('node_js_this', 'cat_js_advanced', 'this指向', '🎯', 'secondary', 3, '["js-22","js-23","js-24"]', 'node_js_hoisting', 20),
('node_js_prototype', 'cat_js_advanced', '原型与继承', '🧬', 'secondary', 4, '["js-25","js-26","js-27"]', 'node_js_this', 20),
('node_js_closure', 'cat_js_advanced', '闭包', '🔒', 'secondary', 5, '["js-28","js-29","js-30"]', 'node_js_prototype', 20);

-- JavaScript ES6+特性节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_js_letconst', 'cat_js_es6', 'let与const', '🆕', 'primary', 1, '["js-31","js-32","js-33"]', 'node_js_closure', 10),
('node_js_arrow', 'cat_js_es6', '箭头函数', '➡️', 'primary', 2, '["js-34","js-35","js-36"]', 'node_js_letconst', 10),
('node_js_promise', 'cat_js_es6', 'Promise', '🤝', 'primary', 3, '["js-37","js-38","js-39"]', 'node_js_arrow', 20),
('node_js_asyncawait', 'cat_js_es6', 'Async/Await', '⚡', 'primary', 4, '["js-40","js-41","js-42"]', 'node_js_promise', 20),
('node_js_module', 'cat_js_es6', '模块化', '📦', 'primary', 5, '["js-43","js-44","js-45"]', 'node_js_asyncawait', 15);

-- ============ React 路径分类 ============

INSERT OR IGNORE INTO path_categories (id, path_id, name, icon, color, sort_order) VALUES
('cat_react_basic', 'path_react', 'React基础', '⚛️', '#61DAFB', 1),
('cat_react_hooks', 'path_react', 'Hooks', '🎣', '#61DAFB', 2),
('cat_react_advanced', 'path_react', '进阶模式', '🎯', '#61DAFB', 3);

-- React 基础节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_react_jsx', 'cat_react_basic', 'JSX语法', '⚛️', 'primary', 1, '["react-1","react-2","react-3"]', NULL, 10),
('node_react_components', 'cat_react_basic', '组件基础', '🧩', 'primary', 2, '["react-4","react-5","react-6"]', 'node_react_jsx', 15),
('node_react_props', 'cat_react_basic', 'Props传递', '📤', 'primary', 3, '["react-7","react-8","react-9"]', 'node_react_components', 10),
('node_react_state', 'cat_react_basic', 'State管理', '📊', 'primary', 4, '["react-10","react-11","react-12"]', 'node_react_props', 15),
('node_react_events', 'cat_react_basic', '事件处理', '🖱️', 'primary', 5, '["react-13","react-14","react-15"]', 'node_react_state', 10);

-- React Hooks节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_react_usestate', 'cat_react_hooks', 'useState', '🎣', 'primary', 1, '["react-16","react-17","react-18"]', 'node_react_events', 15),
('node_react_useeffect', 'cat_react_hooks', 'useEffect', '🔄', 'primary', 2, '["react-19","react-20","react-21"]', 'node_react_usestate', 20),
('node_react_usecontext', 'cat_react_hooks', 'useContext', '🌐', 'primary', 3, '["react-22","react-23","react-24"]', 'node_react_useeffect', 15),
('node_react_usereducer', 'cat_react_hooks', 'useReducer', '📉', 'primary', 4, '["react-25","react-26","react-27"]', 'node_react_usecontext', 20),
('node_react_custom_hooks', 'cat_react_hooks', '自定义Hooks', '✨', 'primary', 5, '["react-28","react-29","react-30"]', 'node_react_usereducer', 25);

-- ============ Vue 路径分类 ============

INSERT OR IGNORE INTO path_categories (id, path_id, name, icon, color, sort_order) VALUES
('cat_vue_basic', 'path_vue', 'Vue基础', '💚', '#42B883', 1),
('cat_vue_components', 'path_vue', '组件系统', '🧩', '#42B883', 2),
('cat_vue_advanced', 'path_vue', '进阶特性', '🚀', '#42B883', 3);

-- Vue 基础节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_vue_instance', 'cat_vue_basic', 'Vue实例', '💚', 'primary', 1, '["vue-1","vue-2","vue-3"]', NULL, 10),
('node_vue_template', 'cat_vue_basic', '模板语法', '📝', 'primary', 2, '["vue-4","vue-5","vue-6"]', 'node_vue_instance', 15),
('node_vue_data', 'cat_vue_basic', '数据绑定', '🔗', 'primary', 3, '["vue-7","vue-8","vue-9"]', 'node_vue_template', 10),
('node_vue_directives', 'cat_vue_basic', '指令系统', '🎯', 'primary', 4, '["vue-10","vue-11","vue-12"]', 'node_vue_data', 15),
('node_vue_computed', 'cat_vue_basic', '计算属性', '🧮', 'primary', 5, '["vue-13","vue-14","vue-15"]', 'node_vue_directives', 10);

-- Vue 组件系统节点
INSERT OR IGNORE INTO path_nodes (id, category_id, title, icon, color, sort_order, question_ids, prerequisite_node_id, estimated_minutes) VALUES
('node_vue_components', 'cat_vue_components', '组件基础', '🧩', 'primary', 1, '["vue-16","vue-17","vue-18"]', 'node_vue_computed', 15),
('node_vue_props', 'cat_vue_components', 'Props与Events', '📤', 'primary', 2, '["vue-19","vue-20","vue-21"]', 'node_vue_components', 15),
('node_vue_slots', 'cat_vue_components', '插槽', '📦', 'primary', 3, '["vue-22","vue-23","vue-24"]', 'node_vue_props', 10),
('node_vue_composition', 'cat_vue_components', 'Composition API', '🎼', 'primary', 4, '["vue-25","vue-26","vue-27"]', 'node_vue_slots', 20),
('node_vue_lifecycle', 'cat_vue_components', '生命周期', '🔄', 'primary', 5, '["vue-28","vue-29","vue-30"]', 'node_vue_composition', 15);
