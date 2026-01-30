# question-flow 规范增量 - M3 连击系统

## 新增需求

### Requirement: 连击统计

系统 MUST 记录用户的连续答对次数，提供游戏化激励。

#### 场景：答对递增连击

- **当** 用户提交正确答案
- **那么** 当前连击数加 1
- **并且** 如果超过历史最大连击数，更新最大连击数
- **并且** 通知所有监听器状态变化

#### 场景：答错重置连击

- **当** 用户提交错误答案
- **那么** 当前连击数重置为 0
- **并且** 通知所有监听器状态变化

#### 场景：切换主题重置连击

- **当** 用户加载新主题题目
- **那么** 当前连击数重置为 0
- **并且** 最大连击数保持不变

#### 场景：获取连击状态

- **当** 组件需要显示连击信息
- **那么** 可获取 `currentStreak` 和 `maxStreak`
- **并且** `currentStreak` 为当前连续答对次数
- **并且** `maxStreak` 为本次会话的最高连击数

---

### Requirement: QuestionProvider 状态扩展

QuestionProvider MUST 扩展状态管理以支持连击统计。

#### 场景：新增状态字段

- **当** QuestionProvider 初始化
- **那么** 包含以下新字段：
  - `_currentStreak: int = 0` - 当前连击数
  - `_maxStreak: int = 0` - 最大连击数

#### 场景：新增 getter 方法

- **当** 外部组件访问连击数据
- **那么** 可通过以下 getter 获取：
  - `int get currentStreak` - 当前连击数
  - `int get maxStreak` - 最大连击数

#### 场景：新增重置方法

- **当** 需要重置连击状态
- **那么** 调用 `resetStreak()` 方法
- **并且** `_currentStreak` 重置为 0
- **并且** `_maxStreak` 保持不变

---

## 修改需求

### Requirement: 提交答案逻辑（修改）

提交答案方法 MUST 包含连击更新逻辑。

#### 场景：提交时更新连击（新增）

- **当** `submitAnswer()` 方法执行
- **并且** 答案正确
- **那么** `_currentStreak` 自增
- **并且** 如果 `_currentStreak > _maxStreak`，更新 `_maxStreak`

#### 场景：错误时重置连击（新增）

- **当** `submitAnswer()` 方法执行
- **并且** 答案错误
- **那么** `_currentStreak` 重置为 0
- **并且** `_maxStreak` 保持不变

---

### Requirement: 加载题目逻辑（修改）

加载题目方法 MUST 重置当前连击。

#### 场景：加载新主题重置连击（新增）

- **当** `loadQuestions(topic)` 方法执行
- **那么** `_currentStreak` 重置为 0
- **并且** `_maxStreak` 保持不变
