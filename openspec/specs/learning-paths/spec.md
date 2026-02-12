# 学习路径规范

## 新增需求

### 需求：路径数据模型

系统必须支持学习路径的数据存储和查询。

#### 场景：创建学习路径
- **当** 管理员 POST 有效的路径数据到 `/api/admin/paths`
- **那么** 系统返回 201 Created 状态码
- **并且** 响应包含创建的路径（含生成的 ID）
- **并且** 路径包含：name, icon, description, techStack, sortOrder

#### 场景：查询所有路径
- **当** 客户端 GET `/api/paths`
- **那么** 系统返回 200 OK 状态码
- **并且** 响应包含所有学习路径列表
- **并且** 路径按 sortOrder 排序

#### 场景：按技术栈筛选路径
- **当** 客户端 GET `/api/paths?tech_stack=javascript`
- **那么** 系统只返回 JavaScript 技术栈的路径

### 需求：路径节点管理

系统必须支持路径节点的 CRUD 操作。

#### 场景：创建路径节点
- **当** 管理员 POST 节点数据到 `/api/admin/paths/:id/nodes`
- **那么** 系统返回 201 Created 状态码
- **并且** 节点关联到指定路径
- **并且** 节点包含：title, icon, color, order, prerequisiteNodeId, questionIds, estimatedMinutes

#### 场景：节点颜色限制
- **当** 创建或更新节点时
- **那么** color 必须是以下值之一：primary, secondary, accent, error, diamond

#### 场景：查询路径节点
- **当** 客户端 GET `/api/paths/:id/nodes`
- **那么** 系统返回该路径的所有节点
- **并且** 节点按 order 排序
- **并且** 响应包含每个节点的 status（locked, unlocked, completed）

### 需求：节点解锁逻辑

系统必须根据前置节点完成状态自动解锁后续节点。

#### 场景：首节点默认解锁
- **当** 用户首次访问一个学习路径
- **那么** 系统将该路径的首节点状态设为 unlocked
- **并且** 其他节点状态为 locked

#### 场景：完成节点后解锁下一节点
- **当** 用户完成一个节点（所有题目答对）
- **那么** 系统将该节点状态设为 completed
- **并且** 系统查找以该节点为 prerequisiteNodeId 的所有节点
- **并且** 将这些依赖节点的状态从 locked 改为 unlocked

#### 场景：前置节点未完成
- **当** 用户尝试访问一个前置节点未完成的节点
- **那么** 该节点保持 locked 状态
- **并且** 用户无法开始该节点的题目

### 需求：用户路径进度

系统必须记录和查询用户在学习路径上的进度。

#### 场景：记录节点完成
- **当** 用户完成一个节点的所有题目
- **那么** 系统在 user_path_progress 表中创建或更新记录
- **并且** 设置 status 为 completed
- **并且** 设置 completed_at 为当前时间

#### 场景：查询路径进度
- **当** 客户端 GET `/api/paths/:id/progress`（带 X-Device-ID Header）
- **那么** 系统返回该用户在该路径上的进度
- **并且** 响应包含：completedNodes 数量, currentNode, totalNodes, progressPercent

#### 场景：进度自动初始化
- **当** 用户首次访问路径且无进度记录
- **那么** 系统自动创建进度记录
- **并且** 首节点状态为 current

### 需求：节点与题目关联

系统必须支持节点关联多个题目。

#### 场景：节点包含题目数组
- **当** 创建或更新节点时
- **那么** questionIds 字段必须是 JSON 字符串数组
- **例如**: `["q1", "q2", "q3"]`

#### 场景：获取节点题目
- **当** 查询节点详情时
- **那么** 响应包含该节点的所有题目 ID
- **并且** 客户端可以使用这些 ID 从题目 API 获取完整题目数据

### 需求：路径删除级联

系统必须在删除路径时正确处理关联数据。

#### 场景：删除路径
- **当** 管理员 DELETE `/api/admin/paths/:id`
- **那么** 系统返回 204 No Content
- **并且** 该路径下的所有节点被删除（级联）
- **并且** 用户在该路径的进度记录被保留（用于历史查询）

#### 场景：删除节点
- **当** 管理员 DELETE `/api/admin/nodes/:id`
- **那么** 系统返回 204 No Content
- **并且** 该节点被软删除（deleted_at 设置）
- **并且** 以此节点为前置节点的其他节点需要更新 prerequisiteNodeId
