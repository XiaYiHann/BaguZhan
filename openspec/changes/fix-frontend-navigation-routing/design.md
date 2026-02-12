## 上下文

当前 Flutter 客户端的导航由 `MaterialApp(onGenerateRoute: ...)` 集中处理，但页面与组件中仍存在大量“硬编码 route 字符串”，且部分字符串未在路由表中注册，导致：

- 点击入口后跳转失败，并被路由兜底静默返回首页（用户感知为“点了没反应/迷路”）。
- 底部导航的 tab id 与实际跳转目标不一致，且多个 tab 指向未注册路由。
- 多个 Provider/页面依赖 `userId`，但应用启动流程未建立 userId，导致正常浏览流程出现“用户未登录”。

已确认的路由不一致/断裂（证据来自现有实现）：

- 未注册但被使用的路由：`/quiz`、`/rank`、`/drill`、`/inbox`、`/profile`、`/learning-path`
  - 例如 `baguzhan/lib/presentation/pages/learning_path_map_page.dart` 使用 `/quiz`、`/rank`、`/drill`、`/inbox`、`/profile`
  - `baguzhan/lib/presentation/pages/progress_dashboard_page.dart` 使用 `/quiz`
  - `baguzhan/lib/presentation/pages/path_category_page.dart` 使用 `/learning-path`
- 已注册的相近目标路由：`/question`、`/path-map`（但调用侧没有统一使用）

约束：

- 以最小风险修复为目标，继续使用 Navigator 1.0 + `onGenerateRoute`，不引入新的路由框架（例如 GoRouter）。
- 本变更聚焦“导航可靠性与一致性”，不在此变更中引入完整的登录体系或实现 Rank/Inbox 等业务能力。

## 目标 / 非目标

**目标：**

- 提供单一可信的路由注册表（canonical route names）与集中式 route 常量，逐步消除散落的硬编码字符串。
- 通过“路由归一化 + 别名映射”兼容现有调用侧不一致的路由名，避免入口在修复期间继续断裂。
- 明确底部导航 tab id 与“tab 根页面路由”的映射关系，确保：
  - 点击 tab 永远到达真实页面
  - selected 状态与当前页面一致
- 在应用启动阶段建立可用的 `userId`（匿名/本地持久化即可），并在 Provider 可发起用户域请求前完成注入，避免默认出现“用户未登录”。
- 增加防回归机制：未知路由不再静默回首页，而是显式展示 NotFound（或至少在调试环境显式报错/日志）。

**非目标：**

- 不迁移到 GoRouter / Router 2.0，不做深链（deep link）完整方案。
- 不实现真实的“排行榜/收件箱/个人资料”等业务功能（可使用占位页保证导航不崩）。
- 不做完整的主题系统统一（`AppTheme` vs `NeoBrutalTheme`）重构；只做与导航修复直接相关的最小改动。

## 决策

### 1) 路由框架：保留 Navigator 1.0 + onGenerateRoute

选择：继续以 `MaterialApp.onGenerateRoute` 为唯一入口，集中处理所有路由构建与参数解析。

替代方案：引入 GoRouter。

- 不选原因：迁移成本高、涉及面广（所有入口/测试/回退逻辑），与“快速修复断链”的目标不匹配。

### 2) 路由常量与路由归一化（normalize）

选择：引入集中定义的路由常量，并在路由生成器内做“name 归一化”。

建议形态（示例，不是实现要求）：

- `lib/routes/app_routes.dart`：定义 `AppRoutes` 常量（`static const question = '/question'` 等）。
- `lib/routes/app_router.dart`：提供 `normalizeRouteName(String?) -> String?` 与 `onGenerateRoute(RouteSettings)`。

别名映射（最小集合，覆盖现存断链）：

- `'/quiz'` -> `AppRoutes.question`
- `'/learning-path'` -> `AppRoutes.pathMap`

对于 `rank/drill/inbox/profile`：

- 选项 A（推荐，最小可用）：为这些路由注册占位页（ComingSoon/NotImplemented），避免跳转失败。
- 选项 B：将其映射到现有页面（例如 achievements/dashboard）。不选原因：语义更混乱，用户更难理解。

### 3) 未知路由不再静默回首页

选择：增加明确的 NotFound 页面（展示 `settings.name`），作为 unknown route 的落点。

替代方案：默认落回 `/`。

- 不选原因：会掩盖错误，用户感知为“按钮失灵”，且会阻碍问题定位。

### 4) 底部导航：tab id <-> tab 根路由统一映射

现状：底部导航 item id 集合为 `path/rank/drill/inbox/me`，但调用侧存在不一致：

- `HomePage` 的 selectedId 使用了不存在的 `home`，并且点击处理里还出现了 `achievements` 这种不在 nav items 里的 id。
- `LearningPathMapPage` 的 `rank/drill/inbox/me` 点击会 push 到未注册路由。

选择：定义一个集中式映射：

- `tabId -> tabRootRoute`（例如 `path -> /dashboard`，其余 tab -> 对应占位页路由）
- `routeName -> owningTabId`（用于根据当前路由计算高亮 tab，而不是页面各自维护一份 `_selectedNavId`）

替代方案：每个页面自行维护 selectedId 与跳转逻辑。

- 不选原因：必然继续分叉，且很难保证一致性与可测性。

### 5) userId 启动策略：匿名优先（最小可用）

选择：应用启动时生成/加载持久化的匿名 `userId`（例如存入 `SharedPreferences`），并在进入页面前向相关 Provider 注入。

替代方案：严格登录 gating（没有登录就禁止进入/请求）。

- 不选原因：需要额外的登录 UI 与会话管理，无法满足“快速修复默认报错”的目标。

边界：

- 匿名 userId 仅用于“进度/错题本/答题记录”类数据的最小可用写入与读取。
- 若未来引入真实账号体系，需要提供匿名数据迁移/合并策略（不在本变更范围）。

## 风险 / 权衡

- [别名映射可能掩盖更深的产品分歧（例如 `/quiz` 的入口参数语义）] -> 在路由层记录告警日志（debug 环境），并在 `specs/app-navigation` 中明确参数契约与弃用计划。
- [占位页会让用户觉得“功能没做完”】【但比“点了没反应”更可接受】 -> 占位页需明确文案与返回入口；后续由业务变更替换为真实页面。
- [单 Navigator 的 tab 切换可能导致返回栈混乱] -> 采用“切 tab 时回到 tab 根路由/清理栈”的策略；后续如需独立栈，再引入 nested navigator。
- [匿名 userId 可能与后端权限模型冲突] -> 仅在后端允许匿名 userId 的端点使用；若后端要求鉴权，客户端改为对相关页面展示登录引导而非直接请求。
