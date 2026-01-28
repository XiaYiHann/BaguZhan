import '../models/question_model.dart';

class LocalQuestionDatasource {
  List<QuestionModel> getAllQuestions() {
    return _questionMaps.map(QuestionModel.fromJson).toList();
  }
}

final List<Map<String, dynamic>> _questionMaps = [
  {
    'id': 'js-1',
    'content': '事件循环由哪个组件负责调度？',
    'topic': 'JavaScript',
    'difficulty': 'easy',
    'explanation': '事件循环由宿主环境调度，浏览器或 Node.js 决定任务队列执行时机。',
    'mnemonic': '浏览器是指挥官，JS 只是士兵。',
    'scenario': '高并发任务会被拆成队列，由宿主调度执行。',
    'tags': ['event-loop', 'async'],
    'options': [
      {'id': 'js-1-a', 'optionText': 'JS 引擎', 'optionOrder': 0, 'isCorrect': false},
      {
        'id': 'js-1-b',
        'optionText': '宿主环境',
        'optionOrder': 1,
        'isCorrect': true
      },
      {'id': 'js-1-c', 'optionText': 'DOM 引擎', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'js-1-d', 'optionText': 'V8 GC', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'js-2',
    'content': 'Promise 的 then 回调属于哪种任务？',
    'topic': 'JavaScript',
    'difficulty': 'easy',
    'explanation': 'then 回调属于微任务队列，会在当前宏任务结束后立即执行。',
    'mnemonic': '微任务先冲刺，宏任务后出发。',
    'scenario': 'UI 渲染前会先清空微任务，保证状态一致。',
    'tags': ['promise', 'microtask'],
    'options': [
      {'id': 'js-2-a', 'optionText': '宏任务', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'js-2-b', 'optionText': '微任务', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'js-2-c', 'optionText': 'IO 任务', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'js-2-d', 'optionText': '渲染任务', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'js-3',
    'content': '闭包的本质是什么？',
    'topic': 'JavaScript',
    'difficulty': 'medium',
    'explanation': '闭包是函数与其词法环境的组合，使函数可访问定义时作用域。',
    'mnemonic': '函数带着背包出门。',
    'scenario': '计数器函数通过闭包保存内部状态。',
    'tags': ['closure', 'scope'],
    'options': [
      {'id': 'js-3-a', 'optionText': '函数返回值', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'js-3-b', 'optionText': '函数+词法环境', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'js-3-c', 'optionText': '全局变量', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'js-3-d', 'optionText': '事件队列', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'js-4',
    'content': '原型链用于解决什么问题？',
    'topic': 'JavaScript',
    'difficulty': 'medium',
    'explanation': '原型链用于对象间属性共享与继承查找。',
    'mnemonic': '找不到就去找祖先。',
    'scenario': '实例访问方法时沿原型链向上查找。',
    'tags': ['prototype'],
    'options': [
      {'id': 'js-4-a', 'optionText': '异步调度', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'js-4-b', 'optionText': '属性继承', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'js-4-c', 'optionText': '内存回收', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'js-4-d', 'optionText': '事件冒泡', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'js-5',
    'content': 'let 与 var 的主要区别是什么？',
    'topic': 'JavaScript',
    'difficulty': 'easy',
    'explanation': 'let 具备块级作用域且不会变量提升为可访问。',
    'mnemonic': 'let 有边界，var 到处跑。',
    'scenario': '循环中使用 let 可避免闭包捕获同一变量。',
    'tags': ['scope', 'es6'],
    'options': [
      {'id': 'js-5-a', 'optionText': 'let 有函数作用域', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'js-5-b', 'optionText': 'var 有块级作用域', 'optionOrder': 1, 'isCorrect': false},
      {'id': 'js-5-c', 'optionText': 'let 有块级作用域', 'optionOrder': 2, 'isCorrect': true},
      {'id': 'js-5-d', 'optionText': 'var 不会提升', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'react-1',
    'content': 'React Diff 算法的时间复杂度近似为？',
    'topic': 'React',
    'difficulty': 'medium',
    'explanation': 'React 通过启发式优化将复杂度降低为 O(n)。',
    'mnemonic': '同层比较，线性到底。',
    'scenario': '列表对比时仅同级节点参与 Diff。',
    'tags': ['diff', 'reconcile'],
    'options': [
      {'id': 'react-1-a', 'optionText': 'O(n^3)', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'react-1-b', 'optionText': 'O(n^2)', 'optionOrder': 1, 'isCorrect': false},
      {'id': 'react-1-c', 'optionText': 'O(n)', 'optionOrder': 2, 'isCorrect': true},
      {'id': 'react-1-d', 'optionText': 'O(log n)', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'react-2',
    'content': '为何需要在列表渲染时提供 key？',
    'topic': 'React',
    'difficulty': 'easy',
    'explanation': 'key 用于标识元素身份，帮助 Diff 准确复用节点。',
    'mnemonic': '身份证帮你对号入座。',
    'scenario': '插入新元素时，key 可避免状态错位。',
    'tags': ['key', 'list'],
    'options': [
      {'id': 'react-2-a', 'optionText': '提升渲染速度', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'react-2-b', 'optionText': '唯一标识节点', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'react-2-c', 'optionText': '避免样式冲突', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'react-2-d', 'optionText': '减少包体积', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
  {
    'id': 'vue-1',
    'content': 'Vue 的响应式系统核心是？',
    'topic': 'Vue',
    'difficulty': 'easy',
    'explanation': 'Vue 通过依赖收集与通知更新实现响应式。',
    'mnemonic': '收集依赖，变化就通知。',
    'scenario': '修改 data 会触发 watcher 更新视图。',
    'tags': ['reactivity'],
    'options': [
      {'id': 'vue-1-a', 'optionText': '虚拟 DOM', 'optionOrder': 0, 'isCorrect': false},
      {'id': 'vue-1-b', 'optionText': '依赖收集', 'optionOrder': 1, 'isCorrect': true},
      {'id': 'vue-1-c', 'optionText': '双向绑定', 'optionOrder': 2, 'isCorrect': false},
      {'id': 'vue-1-d', 'optionText': '路由系统', 'optionOrder': 3, 'isCorrect': false},
    ],
  },
];
