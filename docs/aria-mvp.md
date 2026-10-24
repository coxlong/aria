# Aria MVP 实现文档

> 版本：v1（2026-10-24）
> 适用仓库：`/Users/xlong/workspace/aria`
> 本文是实现依据；与代码冲突时以本文为准并修正代码。

---

## 1. 产品概述

### 1.1 定位

Aria 是一个 **ACP（Agent Client Protocol）客户端**：

> Aria，让你和 AI 的合作，像一段流畅的二重奏。

「二重奏」不是视觉隐喻，而是交互契约：

- **回合归属清晰**：任何时刻都能看出是 agent 在演奏，还是轮到你。
- **可随时打断**：停止键始终可达；权限审批是一次明确的「停拍」。
- **不丢拍**：断线、切后台、切换网络后，消息不丢、不重复、回合可继续。
- **低噪音**：界面退到内容后面，强调只留给「agent 正在工作」。

### 1.2 目标用户与场景

- 在手机或平板上，远程驱动一台机器上已经跑着的编码 agent。
- 在桌面上，把它当作一个轻量、专注的 agent 对话窗口。
- 典型链路：`Aria (ws/wss) → bridge（如 stdio-to-ws）→ ACP agent（如 claude-agent-acp / hermes）`。

### 1.3 MVP 成功标准

用户可以在手机和桌面上：

1. 保存多个 agent 服务器并一键连接；
2. 发送消息，实时看到思考、工具调用与正文；
3. 在 agent 执行敏感操作前审批；
4. 断网恢复后继续原来的会话；
5. 切换模型、模式、推理强度；
6. 查看并恢复历史会话。

### 1.4 非目标（MVP 外）

- 图片/文件附件、`@` 提及
- 计划（plan）与可用命令的完整 UI
- 终端与文件系统能力（客户端不广告）
- Web 平台
- Agent 角色（只实现 client）
- 多会话并行展示（库支持多会话，UI 一次一个）

---

## 2. 总体架构

### 2.1 分层

```
┌─────────────────────────────────────────────┐
│ UI (Flutter)                                │
│  connect / chat / sheets / responsive shell │
├─────────────────────────────────────────────┤
│ State (ChangeNotifier controllers)           │
│  ServersController / ConnectionController    │
│  ConversationController / Reducer            │
├─────────────────────────────────────────────┤
│ acp package (pure Dart)                      │
│  AcpClient / AcpSession / models             │
│  JSON-RPC / NDJSON / WsTransport             │
├─────────────────────────────────────────────┤
│ WebSocket (ws/wss) → bridge → agent          │
└─────────────────────────────────────────────┘
```

依赖规则：

- `packages/acp` **不得依赖 Flutter**，只依赖 Dart SDK。
- `lib/state` 可以依赖 `acp`，但不得依赖具体 widget。
- `lib/features` 只通过控制器读写状态；不得直接创建 `AcpClient`。
- 用户可见文案只存在于 ARB 资源与 UI 层。

### 2.2 仓库结构

```
aria/
├── docs/aria-mvp.md
├── packages/acp/
│   ├── pubspec.yaml
│   ├── lib/acp.dart
│   ├── lib/src/{transport,protocol,models,client,internal}/
│   └── test/
├── l10n.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── l10n/{app_en.arb,app_zh.arb}
│   ├── core/{error_mapping.dart,error_text.dart,models/,persistence/}
│   ├── state/
│   └── features/{connect,chat}/
├── test/
├── integration_test/
└── tool/
```

---

## 3. ACP 协议参考

### 3.1 传输

- WebSocket（`ws://` / `wss://`），子协议 `acp.v1`。
- 握手头：
  - `Authorization: Bearer <token>`（可选）
  - `X-Client-Id: <bridge-assigned id>`（重连复用）
- 帧格式：**NDJSON**。每条消息一行 JSON，以 `\n` 结尾。
- 接收端必须处理：
  - 一帧包含多行；
  - 一行被拆成多帧；
  - 最后一行没有换行符。

### 3.2 JSON-RPC 2.0

请求：

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}
```

响应：

```json
{"jsonrpc":"2.0","id":1,"result":{...}}
{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}
```

通知（无 `id`，不回包）：

```json
{"jsonrpc":"2.0","method":"session/cancel","params":{"sessionId":"s1"}}
```

`session/update` 也是通知。

### 3.3 客户端方法

| 方法 | 参数 | 结果 | 超时 |
|---|---|---|---|
| `initialize` | `protocolVersion`, `clientCapabilities`, `clientInfo` | `protocolVersion`, `agentCapabilities`, `authMethods` | 60s |
| `session/new` | `cwd`, `mcpServers` | `sessionId` + 配置面 | 60s |
| `session/load` | `sessionId`, `cwd`, `mcpServers` | `{}`（历史先回放） | 60s |
| `session/list` | `cwd?` | `sessions[]` | 60s |
| `session/prompt` | `sessionId`, `prompt[]` | `stopReason` | **无** |
| `session/cancel` | `sessionId` | 通知 | — |
| `session/close` | `sessionId` | `{}` | 60s |
| `session/set_mode` | `sessionId`, `modeId` | `{}` | 60s |
| `session/set_config_option` | `sessionId`, `configId`, `value` | `configOptions` | 60s |
| `session/set_model` | `sessionId`, `modelId` | `{}` | 60s |
| `authenticate` | `methodId` | `{}` | 60s |

`initialize` 的客户端能力：

```json
{
  "protocolVersion": 1,
  "clientCapabilities": {
    "fs": {"readTextFile": false, "writeTextFile": false}
  },
  "clientInfo": {"name": "aria", "title": "Aria", "version": "1.0.0"}
}
```

### 3.4 服务端请求与通知

- `session/update`：见 3.5。
- `session/request_permission`：必须回答。
- `fs/*`、`terminal/*`、`elicitation/*`、未知方法：统一回 `-32601`。

权限响应：

```json
{"jsonrpc":"2.0","id":42,"result":{"outcome":{"outcome":"selected","optionId":"allow_once"}}}
{"jsonrpc":"2.0","id":42,"result":{"outcome":{"outcome":"cancelled"}}}
```

### 3.5 `session/update` 变体

| `sessionUpdate` | 处理 |
|---|---|
| `user_message_chunk` | 用户消息（回放时常见） |
| `agent_message_chunk` | 助手正文 |
| `agent_thought_chunk` | 思考过程 |
| `tool_call` | 新工具调用 |
| `tool_call_update` | 按 `toolCallId` 打补丁 |
| `current_mode_update` | 更新模式 chip |
| `config_option_update` | 重新解析模型/强度 |
| 其他 | `UnknownSessionUpdate(kind, raw)`，忽略但不报错 |

工具调用的关键字段：

```json
{
  "toolCallId": "call_1",
  "title": "Running tests",
  "kind": "bash",
  "status": "in_progress",
  "rawInput": {"command": "flutter test"},
  "rawOutput": "...",
  "content": [...],
  "_meta": {"claudeCode": {"toolName": "Bash"}}
}
```

### 3.6 配置面

Agent 用两种形状之一广告模型：

1. `models` 对象（hermes）：
   ```json
   {"models":{"availableModels":[{"modelId":"m1","name":"Model 1"}],"currentModelId":"m1"}}
   ```
   切换：`session/set_model {sessionId, modelId}`。

2. `configOptions[]`（标准 / Claude Code）：
   ```json
   [{"id":"model","category":"model","currentValue":"m1","options":[{"value":"m1","name":"Model 1"}]}]
   ```
   切换：`session/set_config_option {sessionId, configId:"model", value:"m1"}`。

模式：

```json
{"modes":{"currentModeId":"code","availableModes":[{"id":"code","name":"Code"}]}}
```

切换：`session/set_mode {sessionId, modeId}`。

推理强度：`configOptions[]` 中 `category == "thought_level"`，切换同 `set_config_option`。

### 3.7 错误码

| code | 含义 | 客户端处理 |
|---|---|---|
| `-32700` | Parse error | 记录并忽略该帧 |
| `-32600` | Invalid request | 记录 |
| `-32601` | Method not found | 能力降级 |
| `-32602` | Invalid params | 展示参数错误 |
| `-32603` | Internal error | 展示 agent 错误 |
| `-32000` | 认证/会话错误 | 映射为鉴权或会话失效 |

### 3.8 重连与 bridge

`WsTransport` 在 socket 断开后：

1. 不关闭 `frames` 流（协议层无感）；
2. 按 0.5s → 30s 指数退避重连；
3. 重连带 `X-Client-Id`，bridge 复用原有子进程；
4. 断线期间的发送进入 outbox，重连后按序补发；
5. bridge 回放缓冲帧，进行中的请求自然恢复；
6. 过滤 bridge 前导帧 `{"type":"connected"}` / `{"type":"reconnect"}`。

若 bridge 不保活：重连后由应用层调用 `session/load` 恢复会话。

---

## 4. `acp` 库设计

### 4.1 公共 API

```dart
final transport = await WsTransport.connect(
  Uri.parse(url),
  token: token,                     // optional bearer token
  initialClientId: clientId,        // optional; reuse a previous bridge slot
  onClientId: (id) => store.save(id),
);
final client = AcpClient(transport);
final init = await client.initialize();

final session = await client.newSession(cwd: cwd);
session.updates.listen(reducer.apply);
final result = await session.prompt('Hello');   // resolves at turn end
await session.cancel();

await session.setModel('model-id');
await session.setMode('mode-id');
await session.setConfigOption('effort', 'high');

client.permissionRequests.listen((request) {
  request.allow(optionId);   // or request.deny();
});
```

### 4.2 类型

```dart
abstract interface class AcpTransport {
  Stream<String> get frames;
  Stream<AcpTransportState> get states;
  Future<void> send(String line);
  Future<void> close();
  String? get clientId;
}

enum AcpTransportState { connecting, connected, reconnecting, closed }

final class AcpClient {
  AcpClient(AcpTransport transport, {Duration requestTimeout = const Duration(seconds: 60)});
  Stream<AcpTransportState> get states;
  Stream<PermissionRequest> get permissionRequests;
  Future<InitializeResult> initialize({ClientInfo? clientInfo});
  Future<AcpSession> newSession({required String cwd});
  Future<AcpSession> loadSession({required String sessionId, required String cwd});
  Future<List<SessionSummary>> listSessions({String? cwd});
  AcpSession? session(String sessionId);
  Future<void> close();
}

final class AcpSession {
  String get id;
  SessionModels get models;
  SessionModes get modes;
  SessionEfforts get efforts;
  Stream<SessionUpdate> get updates;
  bool get isRunning;
  Future<PromptResult> prompt(String text);
  Future<void> cancel();
  Future<void> setModel(String modelId);
  Future<void> setMode(String modeId);
  Future<void> setConfigOption(String configId, String value);
  Future<void> close();
}
```

### 4.3 状态机

```
disconnected
    │ connect()
    ▼
connecting ──fail──► closed
    │ ok
    ▼
connected ◄──────► reconnecting
    │ close()
    ▼
closed
```

- `connected` / `reconnecting` 属于传输层状态。
- 回合状态（`isRunning`）独立维护；重连不改变回合状态。
- 主动 `close()` 不触发「意外断开」事件。

### 4.4 不变量

1. 每个 session 同时只有一个进行中的 `prompt`；重复调用抛 `StateError`。
2. 权限请求必须恰好回答一次；`cancel()` 先把未决权限回 `cancelled`。
3. 更新严格按线序投递；`tool_call_update` 在回合结束后仍可打补丁。
4. 重连不 reject 进行中的 prompt；只有主动关闭才 reject 全部在途请求。
5. `session/load` 回放期间消息标记为历史。
6. 未知 `session/update` 不破坏后续解析。

### 4.5 错误模型

```dart
sealed class AcpError implements Exception {}

final class AcpRemoteError extends AcpError {
  final int code;
  final String message;
  final Object? data;
}

final class AcpRequestTimeout extends AcpError { final String method; }
final class AcpTransportClosed extends AcpError { final String reason; }
final class AcpProtocolError extends AcpError { final String message; }
```

### 4.6 内部结构

```
lib/acp.dart                      public exports
src/transport/acp_transport.dart  interface + state enum
src/transport/ndjson.dart         encode/decode + buffering
src/transport/ws_transport.dart   WebSocket + reconnect + heartbeat + outbox
src/protocol/json_rpc.dart        envelopes + id generation
src/protocol/methods.dart         method name constants
src/models/...                    update/tool/permission/config/session
src/client/acp_client.dart        routing + request tracking
src/client/acp_session.dart       session handle + turn lifecycle
```

### 4.7 测试

- `FakeTransport`：脚本化帧、断言发送、模拟断线。
- 本地 `HttpServer` WebSocket：握手头、子协议、分片、心跳、重连、outbox。
- 协议：请求关联、超时、`-32601`、权限单次回答、关闭时 reject。
- 配置面：两种模型形状、modes、thought_level、`config_option_update`。

---

## 5. 应用层

### 5.1 控制器

| 控制器 | 职责 |
|---|---|
| `ServersController` | 服务器 CRUD、token 安全存储、持久化 |
| `ConnectionController` | 连接状态机、client/session 生命周期、权限队列、配置面操作 |
| `ConversationController` | 消息列表、回合状态、过程步骤 |
| `ConversationReducer` | 纯 Dart，把 `SessionUpdate` 折叠进消息模型 |

`AppScope`（`InheritedWidget`）向下提供控制器与 `AppLocalizations`。

### 5.2 关键状态分离

- `connectionState`：`disconnected / connecting / connected / reconnecting / error`
- `turnState`：`idle / running / cancelling`
- `pendingPermission`：`PermissionRequest?`

重连时只改 `connectionState`；回合结束时必须把 `turnState` 置回 `idle`，消息的 `streaming` 置 `false`。这是 omux 曾出现的「拒绝权限后卡在运行态」的根因，必须由测试覆盖。

### 5.3 持久化

- `shared_preferences`：
  - `aria.servers`：服务器元数据（id/name/url/cwd）
  - `aria.sessions.<serverId>`：会话缓存
  - `aria.locale`：`system` / `en` / `zh`
- `flutter_secure_storage`：`aria.token.<serverId>`。
- `clientId` 只在单次运行内复用；启动时重新获取，避免接到陈旧进程。

### 5.4 错误映射

| 类型 | 文案 key |
|---|---|
| 连接超时 / 不可达 | `errorNetworkUnreachable` |
| HTTP 401 / 认证方法失败 | `errorAuthFailed` |
| 协议版本不支持 | `errorProtocolMismatch` |
| agent 返回错误 | `errorAgent(code)` |
| 请求超时 | `errorRequestTimeout` |
| 会话失效 | `errorSessionLost` |

原始异常只放在可展开的「技术详情」里，默认不展示。

---

## 6. UI / UX

### 6.1 响应式

| 宽度 | 布局 |
|---|---|
| `< 720` | 单栏；会话列表为抽屉；顶栏含抽屉按钮 |
| `720–1100` | 240px 侧栏 + 聊天 |
| `> 1100` | 320px 侧栏 + 聊天 |

触控目标 ≥ 44×44；内容最大宽度 720。

### 6.2 页面与组件

- **ConnectPage**：服务器列表、连接按钮、管理入口、错误卡、语言入口。
- **ServerManagePage**：新增/编辑/删除；字段 name / url / token / cwd。
- **ChatPage**：顶栏（连接状态、模型/模式 chip）、消息列表、composer。
- **MessageList**：自动滚底；用户上滑时暂停自动滚动。
- **MessageView**：用户消息、助手正文（MVP 按纯文本渲染，不引入 Markdown 渲染包）、流式指示。
- **ProcessEntry / ProcessSheet**：每轮一条「执行过程」入口；sheet 分列表页与详情页。
- **PermissionSheet**：不可关闭；按工具类型展示命令/路径/修改前后内容。
- **SelectorSheet**：模型、模式、推理强度，按 agent 能力显隐。
- **SessionPanel**：新对话、最近会话、当前连接、切换/退出。

### 6.3 关键流程

**连接**

```
用户选服务器 → ConnectionController.connect()
→ WsTransport.connect → AcpClient.initialize → session/new
→ 解析模型/模式/强度 → 进入 ChatPage
```

**发送回合**

```
composer → ConversationController.send(text)
→ reducer.onUserMessage → session.prompt(text)
→ updates 持续到达 → 正文/工具/思考渲染
→ prompt resolve → endTurn(stopReason) → idle
```

**权限**

```
agent request → client.permissionRequests
→ ConnectionController.pendingPermission
→ PermissionSheet（不可关闭）
→ allow(optionId) / deny() → 回包 → 清理 pending
```

**重连**

```
socket drop → transport reconnecting → UI 顶部提示，发送按钮禁用
→ 重连成功 → 桥接回放 → 进行中回合继续
→ 若 bridge 不保活 → session/load 恢复
```

---

## 7. 本地化

- 资源：`lib/l10n/app_en.arb`（模板）、`lib/l10n/app_zh.arb`。
- `l10n.yaml`：

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

- `MaterialApp` 配置 `localizationsDelegates`、`supportedLocales: [Locale('en'), Locale('zh')]`。
- 语言偏好：`system`（默认）/ `en` / `zh`，持久化到 `shared_preferences`。
- 规则：
  - 所有 UI 文案从 `AppLocalizations` 取。
  - 不在 widget 中硬编码中英文字符串。
  - 协议层不翻译任何内容。
  - 新增文案先加 `app_en.arb`，再补 `app_zh.arb`。
  - 日期时间用 `intl` 格式化。

---

### 7.1 MVP 依赖边界

应用层只引入功能必需的包：`shared_preferences`（元数据）、`flutter_secure_storage`（令牌）、`flutter_localizations`（SDK）。**不引入额外的 UI 组件包、Markdown 渲染包或状态管理库**，页面直接用 Material 基础组件与 `AppLocalizations`。仓库根目录生成的语言资源由 `flutter gen-l10n` 产出。

---

## 8. 工程约定

- 标识符、注释、doc comment、测试名、commit message 一律英文。
- 中文只出现在 ARB、文档、用户可见内容中。
- 提交前：

```bash
dart format .
flutter gen-l10n
flutter analyze
cd packages/acp && dart test
cd ../.. && flutter test
```

- 不在 UI 层直接抛/展示原始异常。
- 不为单次使用写抽象；不为未确认的需求加配置项。

---

## 9. 里程碑

| 阶段 | 内容 | 验证 |
|---|---|---|
| M0 | 骨架、`packages/acp`、l10n、本文档 | `flutter analyze`、`dart test` |
| M1 | 传输层（NDJSON、WebSocket、心跳、重连、outbox） | WS 单测 + bridge spike |
| M2 | 协议层（JSON-RPC、模型、client/session、权限） | 不变量单测 |
| M3 | 聚合层（reducer） | 纯 Dart 单测 |
| M4 | 连接页、服务器管理、持久化、l10n | widget 测试 |
| M5 | 聊天 UI、过程、权限、选择器 | widget 测试 + 真实 agent |
| M6 | 会话列表/恢复、重连提示、响应式收尾 | 断网演练 + 三档宽度 |

---

## 10. 验收标准

1. 服务器可新增/编辑/删除；token 存 secure storage。
2. `ws://` / `wss://` + Bearer 可连接；失败给出可行动的本地化错误。
3. thinking / tool / text 按顺序流式出现；停止键可中断。
4. 权限弹窗不可误关；允许/拒绝均送达 agent；拒绝后不残留运行态。
5. 断网 30s 恢复：提示 → 自动重连 → 不丢、不重、回合可继续。
6. 模型/模式/推理强度 chip 正确反映 agent 能力。
7. 会话列表来自 agent；恢复历史不闪烁、不重复。
8. 三档宽度布局正确；触控目标 ≥44px。
9. 中英切换即时生效；无硬编码文案。
10. `flutter analyze` 无错误；`acp` 与 reducer 单测全绿。

---

## 11. 测试计划

### 11.1 单元测试（`packages/acp`）

- NDJSON：分片、粘包、尾行无换行。
- 传输：握手头、子协议、心跳、断线重连、outbox 顺序。
- 协议：请求关联、超时、错误码、未知方法 `-32601`。
- 权限：单次回答、取消时自动回 `cancelled`。
- 配置：两种模型形状、modes、thought_level。

### 11.2 应用测试

- Reducer：块顺序、工具补丁、回放、流式状态、拒绝路径复位。
- Widget：服务器表单校验、权限弹窗决策、语言切换、三档布局。

### 11.3 手工/端到端

```bash
npx stdio-to-ws "npx @agentclientprotocol/claude-agent-acp" --port 3000
cd packages/acp
dart run tool/verify_acp.dart ws://127.0.0.1:3000 /path/to/project
# optional: --permission (write a file, exercise approval) --cancel
```

检查项：连接、新建会话、流式、权限、取消、模型/模式/强度、会话恢复、断网重连。

---

## 12. 风险

| 风险 | 对策 |
|---|---|
| ACP 版本漂移 | 只依赖稳定 v1；实验方法能力门控 |
| agent 差异 | 双形状解析；未广告能力隐藏 |
| bridge 线格式 | 传输层补 `\n`、过滤前导帧、spike 实测 |
| bridge 不保活 | 重连后 `session/load` 恢复 |
| iOS 后台挂起 | 回前台检测并重连，不假设回合连续 |
| secure storage 平台差异 | 失败降级为内存 token 并提示 |
| 大工具输出 | UI 截断，详情按需加载 |
| 文案漏翻 | ARB 模板 + grep 校验 + 英文回退 |

---

## 13. 附录

### 13.1 `$/ping`

```json
{"jsonrpc":"2.0","method":"$/ping"}
```

每 25 秒发送一次。Dart 字符串中 `$` 需要转义：`'{\"jsonrpc\":\"2.0\",\"method\":\"\$/ping\"}'`。

### 13.2 stopReason

常见值：`end_turn`、`max_tokens`、`cancelled`、`refusal`、`unknown`。UI 只在 `cancelled` 时提示「已停止」。

### 13.3 术语

| 术语 | 含义 |
|---|---|
| ACP | Agent Client Protocol |
| bridge | 把 WebSocket 帧转发给 stdio agent 的中间层 |
| client id | bridge 分配的连接槽位标识 |
| config surface | agent 广告的模型/模式/强度等可配置面 |
| turn | 一次 prompt 到 stopReason 的完整回合 |
