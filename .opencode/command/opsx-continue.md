---
description: 继续处理变更 - 创建下一个产出物（实验性）
---

通过创建下一个产出物继续处理变更。

**输入**：可选择在 `/opsx-continue` 后指定变更名称（例如，`/opsx-continue add-auth`）。如果省略，检查是否可以从对话上下文中推断出来。如果模糊或不明确，你必须提示可用的变更。

**步骤**

1. **如果没有提供变更名称，提示选择**

   运行 `openspec-cn list --json` 获取按最近修改排序的可用变更。然后使用 **AskUserQuestion tool** 让用户选择要处理哪个变更。

   展示前 3-4 个最近修改的变更作为选项，显示：
   - 变更名称
   - Schema（如果存在 `schema` 字段，否则为 "spec-driven"）
   - 状态（例如："0/5 tasks", "complete", "no tasks"）
   - 最近修改时间（来自 `lastModified` 字段）

   将最近修改的变更标记为 "(推荐)"，因为它很可能是用户想要继续的。

   **重要提示**：不要猜测或自动选择变更。始终让用户选择。

2. **检查当前状态**
   ```bash
   openspec-cn status --change "<name>" --json
   ```
   Parse the JSON to understand current state. The response includes:
   - `schemaName`: The workflow schema being used (e.g., "spec-driven")
   - `artifacts`: Array of artifacts with their status ("done", "ready", "blocked")
   - `isComplete`: Boolean indicating if all artifacts are complete

3. **根据状态行动**：

   ---

   **如果所有产出物已完成 (`isComplete: true`)**：
   - 祝贺用户
   - 显示最终状态，包括使用的 Schema
   - 建议："所有产出物已创建！您现在可以使用 `/opsx-apply` 实施此变更或使用 `/opsx-archive` 归档它。"
   - 停止

   ---

   **如果产出物准备好创建**（状态显示有 `status: "ready"` 的产出物）：
   - 从状态输出中选择第一个 `status: "ready"` 的产出物
   - 获取其指令：
     ```bash
     openspec-cn instructions <artifact-id> --change "<name>" --json
     ```
   - 解析 JSON。关键字段包括：
     - `context`：项目背景（对你的约束 - 不要包含在输出中）
     - `rules`：产出物特定规则（对你的约束 - 不要包含在输出中）
     - `template`：用于输出文件的结构
     - `instruction`：Schema 特定指导
     - `outputPath`：写入产出物的位置
     - `dependencies`：已完成的产出物，用于读取上下文
   - **创建产出物文件**：
     - 读取任何已完成的依赖文件以获取上下文
     - 使用 `template` 作为结构 - 填充其各个部分
     - 在编写时应用 `context` 和 `rules` 作为约束 - 但不要将它们复制到文件中
     - 写入指令中指定的输出路径
   - 显示创建的内容以及现在解锁的内容
   - 创建一个产出物后停止

   ---

   **如果没有产出物准备好（全部受阻）**：
   - 在有效的 Schema 下不应发生这种情况
   - 显示状态并建议检查问题

4. **创建产出物后，显示进度**
   ```bash
   openspec-cn status --change "<name>"
   ```

**输出**

每次调用后，显示：
- 创建了哪个产出物
- 正在使用的 Schema 工作流
- 当前进度（N/M 完成）
- 现在解锁了哪些产出物
- 提示："运行 `/opsx-continue` 以创建下一个产出物"

**产出物创建指南**

产出物类型及其用途取决于 Schema。使用指令输出中的 `instruction` 字段来了解要创建什么。

常见的产出物模式：

**spec-driven schema** (proposal → specs → design → tasks):
- **proposal.md**: Ask user about the change if not clear. Fill in Why, What Changes, Capabilities, Impact.
  - The Capabilities section is critical - each capability listed will need a spec file.
- **specs/<capability>/spec.md**: Create one spec per capability listed in the proposal's Capabilities section (use the capability name, not the change name).
- **design.md**: Document technical decisions, architecture, and implementation approach.
- **tasks.md**: Break down implementation into checkboxed tasks.

For other schemas, follow the `instruction` field from the CLI output.

**Guardrails**
- Create ONE artifact per invocation
- Always read dependency artifacts before creating a new one
- Never skip artifacts or create out of order
- If context is unclear, ask the user before creating
- Verify the artifact file exists after writing before marking progress
- Use the schema's artifact sequence, don't assume specific artifact names
- **IMPORTANT**: `context` and `rules` are constraints for YOU, not content for the file
  - Do NOT copy `<context>`, `<rules>`, `<project_context>` blocks into the artifact
  - These guide what you write, but should never appear in the output
