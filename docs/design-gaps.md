# Aria 与 OpenDesign 设计稿的差异记录

- **日期**：2026-10-27（2026-10-31 同步最新稿）
- **设计源**：`/Users/xlong/Library/Application Support/Open Design/namespaces/release-stable/data/projects/71f8e25f-5d9c-4e8a-9342-8b73e93b05b1`
  - `设计说明.md`
  - `index.html`
  - `assets/cockpit.css`
  - `assets/cockpit.js`
- **当前实现**：`/Users/xlong/workspace/aria`（Flutter，接真实 ACP）
- **范围**：按确认过的“不需要演示内容、接真实 ACP”。记忆、模拟断线、脚本对话、演示重置没有进入产品代码。

## 2026-10-31 同步最新稿

设计稿在 10/30–10/31 的一轮修改已经进入实现：

- 未连接时只保留唤醒屏：暗点 → 原地连接 → 光环收束成亮点 → 首页；不再有独立连接页、Agent 列表和大按钮。切换 Agent 收成「名称 · 切换」。
- 对话页去掉标题下的时间/状态和输入框上方的「正在做…」；顶部只剩返回、标题、等待授权的提示。
- 执行记录改为单行：图标 + 名称 · 目标 + 右侧异常标记；列表间距收紧到 4px，标题就是 run 摘要。折叠摘要改为「名称、名称 · N 步」「等 N 步」「 · 失败」。
- 首页增加「最近对话」栏和数量；会话行显示最后一句（含「你：」）或 live 行、相对时间、运行/等待点；去掉「由 X 接」。
- 主题 token 对齐：半透明表面、深色 ground/sheet、字号与字重、sheet 投影/0.7 遮罩/拖柄、用户气泡 1.55 行高、发送按钮禁用态、品牌点与 aura 呼吸。
- Sheet 去掉 kicker；权限弹窗把工具内容标成「命令」；停止/断开/保存/删除/设为默认补上 toast。

仍需处理的是原表中与本轮无关的部分：描边 SVG 图标体系、删除 Agent 的撤销、Agent 配置的「连接并读取目录」、进程退出后的会话持久化、宽屏适配。

## 结论

主流程、首页/对话结构、run 折叠规则、执行记录、权限、模型、Agent 配置、主题和语言都已经按设计稿落地。2026-10-28 完成了数据与渲染解耦：`AgentManager` 常驻持有每个 Agent 的运行时和每个会话的 `ChatSession` 状态，页面只读取和发命令，因此 §1.1 的会话保活、草稿保留、运行中回合跨页继续已经解决。剩余差异分四类：

1. **交互与状态模型**：会话状态已保活；进程重启后的持久化、首页“最后一句”、无转场切换仍未解决。
2. **Agent 配置**：缺少“连接并读取目录”，工作目录是手填且非必填，默认 Agent 与当前连接的语义有分歧。
3. **视觉细节**：图标体系、禁用发送态、kicker 大小写、折叠行尺寸、气泡行高、sheet 投影等。
4. **数据/能力限制**：记忆、演示内容、首页最后一句、工具 target/meta、模型描述、列目录等。

## 1. 交互与状态模型

### 1.1 切换会话保持状态（已解决）

- **设计稿**：会话是本地状态，打开只是切换视图；`c.draft` 按会话保存；正在跑的回合在切走/切回时继续。
- **重构后**：`lib/features/connection/application/agent_manager.dart` 是 `keepAlive` 的常驻状态中心，按 `SessionRef(agentId, sessionId)` 持有 `ChatSession`；事件订阅在运行时建立，页面销毁不取消；`openSession` 对 Executor 已持有的会话只切换视图，不重新 `session/load`；草稿、运行状态、权限请求都随会话保存。
- **仍缺**：状态在内存中，App 进程退出后不恢复；如需跨启动恢复，需要另加持久化层（Drift/SQLite 或本地缓存）。

### 1.2 首页会话行

- **设计稿**：标题 + 最后一句（含“你：”前缀、live 行）+ 相对时间 + live/等待点；等待授权时写 `等你授权：{title}`。
- **当前**：标题 + cwd 或 `Needs approval` + 绝对时间（`09:30` / `Oct 26`）；等待审批的金点现在来自该会话自己的状态，不再只限当前打开的会话；运行中的 live 点仍未显示。
- **原因**：`session/list` 只返回标题、cwd、更新时间；最后一句和每会话 live 行需要该会话已加载到 `AgentManager`，未打开过的会话没有这些内容。
- **建议**：已加载会话可以直接补“最后一句 / 运行点”；未加载会话仍受执行端字段限制。

### 1.3 默认 Agent 与当前连接分离

- **设计稿**：`defaultAgent` 决定下一件事由谁接；设置里的 Agent 行显示它。
- **当前**：“设为默认”只改 `activeProfileId`，不会切换当前连接；首页“由 X 接”用的是当前连接。连接非默认 Agent 后，设置里显示 A、首页提示 B。
- **建议**：连接成功时同步 `activeProfileId`，或明确把“默认”定义为“下次连接预选”；两者选一种并统一文案。

### 1.4 页面切换与加载

- **设计稿**：home/chat 在同一个 shell 内瞬间切换，无页面转场。
- **当前**：`context.push('/chat')` 使用 Material 路由动画；打开会话行会先显示 spinner，然后进入。
- **建议**：如果要贴近设计，可以改成无转场或共享 shell；否则接受这是真实网络的必要反馈。

### 1.5 toast / undo

- **设计稿**：停止、保存配置、删除 Agent、重连都有 toast；删 Agent 提供撤销。
- **当前**：停止只在对话末尾留 notice；保存/断开没有确认提示；删除 Agent 用确认框。
- **建议**：补一个轻量 toast 组件；删除 Agent 改成“删除 + 撤销”。

## 2. Agent 配置

| 项 | 设计稿 | 当前 |
| --- | --- | --- |
| 连接流程 | 填地址/Token → “连接并读取目录” → 从服务器返回的目录里选 cwd | 地址/Token/cwd 手填；配置页有「连接这个 Agent」，但执行端没有列目录能力 |
| 新建时 cwd | 必须先连接并选目录 | 已改为必填，不再退回 `/` |
| 名称长度 | `maxlength=8` | 已改为 8 |
| Token 是否已保存 | 按 `tokenSet` 显示“保留已保存”或“不需要” | 已有 Agent 仍一律显示“留空则保留” |
| 删除 | 默认 Agent 不可删；删除用 undo toast | 默认不可删；连接中也不可删；用确认弹窗，无撤销 |
| “默认不能删” | 只隐藏删除入口 | 额外显示一行说明 |

真实执行端目前没有列目录能力；要么执行端补一个 list-dirs 能力，要么保持手填并明确提示。

## 3. 视觉细节

| 设计稿 | 当前实现（2026-10-31） |
| --- | --- |
| 1.55px 描边 SVG 图标集；back 是 chevron | back 已是 chevron；图标仍为 Material，未移植描边集 |
| 英文 kicker 全大写 | sheet 已去掉 kicker |
| 禁用发送按钮：金色按钮 `opacity: .28` | 已对齐 |
| run 折叠行视觉 36px、chevron 11px、hover 右移 | 12px 文案、chevron 11、44px 触摸；无 hover 位移 |
| 用户气泡 `line-height: 1.55` | 已对齐 |
| sheet 有向上投影 `0 -40px 90px -30px` | 已对齐，并补了顶部拖柄 |
| blocking scrim 加深到 0.7；scrim `saturate(.9)` | 0.7 / 0.58，只有 blur，未做 saturate |
| 深色 `--panel` 是白色叠在背景上 | 已改为半透明白 |
| 浅色 muted / goldFill / goldSoft | 已用半透明 token；gold/muted 略深以过 AA |
| 品牌点径向渐变；home aura 10s 呼吸；运行中工具点呼吸 | 已对齐 |
| 字重 550 / 620 / 630 / 640 | 用 600 近似 |
| hover translate/scale；`:focus-visible` 2px 金框 | 多数是 InkWell overlay；focus 为 goldSoft 覆盖 |
| jump-latest 和 sheet 有 backdrop blur | sheet 有；jump-latest 仍纯 panel |
| ≤360px：padding 16 / hero 32 / topbar 14 | 仍统一 20 / 34 |
| 隐藏滚动条、overscroll contain | 桌面端可能显示细滚动条 |
| toast 组件 | 已补：停止、断开、保存、删除、设为默认 |

补充两处具体不一致：

- **权限弹窗**：设计稿把工具内容标成“命令”，另有“详情/context”一段；当前统一标成 `Details`，ACP 的 `detail` 直接作为代码块展示。`lib/features/chat/presentation/widgets/permission_sheet.dart`
- **模型 sheet**：设计稿的模型有描述，并写“下一轮生效”；当前只有名称（ACP 不提供描述），`setModel` 是立即写回会话。`lib/features/chat/presentation/widgets/selector_sheet.dart`

## 4. 未实现 / 数据限制

以下不是漏写，是确认过的范围或执行端能力限制：

- **记忆折叠“我记得”**：未实现。ACP 没有记忆接口，硬做只能来自本地假数据。
- **演示内容**：模拟断线 5 秒、恢复会话、重置演示、脚本对话、邀请撤回、非权限的“决定”弹窗。
- **首页最后一句 / 每会话 live 行**：已加载到 `AgentManager` 的会话现在能提供运行状态；未加载会话仍只有 `session/list` 的标题、cwd、更新时间。
- **工具行的 name · target 分离、每步 meta、模型描述、耗时**：当前 ACP 映射没有对应字段；设计稿也明确不显示耗时。
- **选择工作目录时从服务器列目录**：执行端没有 list-dirs 方法。
- **手机外壳、状态栏、相机点、手势条**：当时选择手机优先单列 App，不画外壳。
- **宽屏 640px 居中列**：当时的选择，不是 390px 手机宽度。

## 5. 建议修复顺序

| 优先级 | 项 | 说明 |
| --- | --- | --- |
| ~~P0~~ | ~~会话保活~~ | 已完成（2026-10-28）：常驻 `AgentManager` + 按会话 `ChatSession`，草稿/运行状态/权限请求随会话保存，已持有会话不重复 load |
| P1 | 首页 live 行 | 已加载会话可显示最后一句/运行点；未加载会话仍受 `session/list` 字段限制 |
| P1 | 视觉对齐包 | kicker 大写、禁用发送金色、气泡 1.55、折叠行 36/chevron 11/hover、sheet 投影 |
| P1 | 权限弹窗 | “命令 / 详情”拆分；blocking scrim 0.7 |
| P1 | 深色 panel | 改回半透明 token；对比度测试按实际合成颜色计算 |
| P2 | Agent 配置 | cwd 必填、Token 已保存状态、默认/连接同步 |
| P2 | toast | 保存、删除撤销、停止、重连补发 |
| P2 | 图标体系 | 移植设计稿的描边 SVG 图标；工作量较大 |
| P3 | 小屏适配 | ≤360px 的 16px padding / 32px hero / 14px topbar |

## 验证基线

- `flutter analyze`：通过
- `flutter test`：89 个测试通过（含 `test/features/agent_manager_test.dart` 的 10 个状态层测试）
- `flutter test integration_test/app_flow_test.dart -d macos`：通过
- `cd packages/acp && dart test`：100 个测试通过
- Golden：`test/golden/goldens/`（home、chat、settings、agents、permission、run-sheet 等）
