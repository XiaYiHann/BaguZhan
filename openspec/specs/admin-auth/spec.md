# 管理员认证

## 目的

提供基于 API Key 的管理员认证机制，保护题库管理 API 端点的安全访问。

## 需求

### 需求：管理员 API Key 认证

系统必须提供基于 API Key 的管理员认证机制来保护管理端点。

#### 场景：有效的 API Key 登录
- **当** 管理员使用有效的 API Key 请求登录
- **那么** 系统返回 200 OK 状态码
- **并且** 响应包含会话 token
- **并且** 响应包含 token 过期时间（默认 24 小时）

#### 场景：无效的 API Key
- **当** 管理员使用无效的 API Key 请求登录
- **那么** 系统返回 401 Unauthorized 状态码
- **并且** 错误消息说明 API Key 无效

#### 场景：管理端点认证要求
- **当** 请求访问任何 `/api/admin/*` 端点
- **那么** 系统必须验证 `X-Admin-API-Key` Header
- **并且** 无效或缺失 API Key 时返回 401 Unauthorized

#### 场景：API Key 通过 Header 传递
- **当** 管理员调用管理 API
- **那么** API Key 必须通过 `X-Admin-API-Key` HTTP Header 传递
- **并且** 不接受请求体或查询参数中的 API Key（安全考虑）
