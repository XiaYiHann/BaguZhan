INSERT INTO questions (id, content, topic, difficulty, explanation, mnemonic, scenario, tags)
VALUES
  (
    'js-1',
    '事件循环由哪个组件负责调度？',
    'JavaScript',
    'easy',
    '事件循环由宿主环境调度，浏览器或 Node.js 决定任务队列执行时机。',
    '浏览器是指挥官，JS 只是士兵。',
    '高并发任务会被拆成队列，由宿主调度执行。',
    '["event-loop", "async"]'
  ),
  (
    'js-2',
    'Promise 的 then 回调属于哪种任务？',
    'JavaScript',
    'easy',
    'then 回调属于微任务队列，会在当前宏任务结束后立即执行。',
    '微任务先冲刺，宏任务后出发。',
    'UI 渲染前会先清空微任务，保证状态一致。',
    '["promise", "microtask"]'
  ),
  (
    'js-3',
    '闭包的本质是什么？',
    'JavaScript',
    'medium',
    '闭包是函数与其词法环境的组合，使函数可访问定义时作用域。',
    '函数带着背包出门。',
    '计数器函数通过闭包保存内部状态。',
    '["closure", "scope"]'
  ),
  (
    'js-4',
    '原型链用于解决什么问题？',
    'JavaScript',
    'medium',
    '原型链用于对象间属性共享与继承查找。',
    '找不到就去找祖先。',
    '实例访问方法时沿原型链向上查找。',
    '["prototype"]'
  ),
  (
    'js-5',
    'let 与 var 的主要区别是什么？',
    'JavaScript',
    'easy',
    'let 具备块级作用域且不会变量提升为可访问。',
    'let 有边界，var 到处跑。',
    '循环中使用 let 可避免闭包捕获同一变量。',
    '["scope", "es6"]'
  ),
  (
    'react-1',
    'React Diff 算法的时间复杂度近似为？',
    'React',
    'medium',
    'React 通过启发式优化将复杂度降低为 O(n)。',
    '同层比较，线性到底。',
    '列表对比时仅同级节点参与 Diff。',
    '["diff", "reconcile"]'
  ),
  (
    'react-2',
    '为何需要在列表渲染时提供 key？',
    'React',
    'easy',
    'key 用于标识元素身份，帮助 Diff 准确复用节点。',
    '身份证帮你对号入座。',
    '插入新元素时，key 可避免状态错位。',
    '["key", "list"]'
  ),
  (
    'vue-1',
    'Vue 的响应式系统核心是？',
    'Vue',
    'easy',
    'Vue 通过依赖收集与通知更新实现响应式。',
    '收集依赖，变化就通知。',
    '修改 data 会触发 watcher 更新视图。',
    '["reactivity"]'
  );

INSERT INTO options (id, question_id, option_text, option_order, is_correct)
VALUES
  ('js-1-a', 'js-1', 'JS 引擎', 0, 0),
  ('js-1-b', 'js-1', '宿主环境', 1, 1),
  ('js-1-c', 'js-1', 'DOM 引擎', 2, 0),
  ('js-1-d', 'js-1', 'V8 GC', 3, 0),
  ('js-2-a', 'js-2', '宏任务', 0, 0),
  ('js-2-b', 'js-2', '微任务', 1, 1),
  ('js-2-c', 'js-2', 'IO 任务', 2, 0),
  ('js-2-d', 'js-2', '渲染任务', 3, 0),
  ('js-3-a', 'js-3', '函数返回值', 0, 0),
  ('js-3-b', 'js-3', '函数+词法环境', 1, 1),
  ('js-3-c', 'js-3', '全局变量', 2, 0),
  ('js-3-d', 'js-3', '事件队列', 3, 0),
  ('js-4-a', 'js-4', '异步调度', 0, 0),
  ('js-4-b', 'js-4', '属性继承', 1, 1),
  ('js-4-c', 'js-4', '内存回收', 2, 0),
  ('js-4-d', 'js-4', '事件冒泡', 3, 0),
  ('js-5-a', 'js-5', 'let 有函数作用域', 0, 0),
  ('js-5-b', 'js-5', 'var 有块级作用域', 1, 0),
  ('js-5-c', 'js-5', 'let 有块级作用域', 2, 1),
  ('js-5-d', 'js-5', 'var 不会提升', 3, 0),
  ('react-1-a', 'react-1', 'O(n^3)', 0, 0),
  ('react-1-b', 'react-1', 'O(n^2)', 1, 0),
  ('react-1-c', 'react-1', 'O(n)', 2, 1),
  ('react-1-d', 'react-1', 'O(log n)', 3, 0),
  ('react-2-a', 'react-2', '提升渲染速度', 0, 0),
  ('react-2-b', 'react-2', '唯一标识节点', 1, 1),
  ('react-2-c', 'react-2', '避免样式冲突', 2, 0),
  ('react-2-d', 'react-2', '减少包体积', 3, 0),
  ('vue-1-a', 'vue-1', '虚拟 DOM', 0, 0),
  ('vue-1-b', 'vue-1', '依赖收集', 1, 1),
  ('vue-1-c', 'vue-1', '双向绑定', 2, 0),
  ('vue-1-d', 'vue-1', '路由系统', 3, 0);
