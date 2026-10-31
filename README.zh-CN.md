# Aria

[English](README.md) | **简体中文**

**一个以目标为中心的开放 AI 行动空间。**

> One intent. Every capability.

Aria 希望把人的意图与模型、Agent、工具及长期上下文连接起来：你提出目标，Aria 负责组织工作、控制边界、推进执行，并交付可以检查和验收的成果。

它不应该只是一个聊天窗口，也不要求用户管理一群 Agent。用户面对的是一个统一的 Aria；在其背后，不同智能与工具可以按需要组合。

> **当前状态：早期开发。** 仓库目前实现的是跨平台 **ACP（Agent Client Protocol）客户端 MVP**。多 Agent 编排、Mission、Artifact 和长期能力沉淀是产品演进方向，并非全部已经实现。

## 为什么是 Aria

现有 AI 产品往往以模型、会话或单个 Agent 为中心。Aria 更关心另一件事：**如何可靠地把意图变成成果。**

| 从 | 到 |
| --- | --- |
| 管理一段段对话 | 推进一个有完成标准的目标 |
| 选择并协调不同 Agent | 由 Aria 按需组织能力 |
| 在回复中寻找答案 | 验收独立、可追溯的成果 |
| 每次重新开始 | 延续上下文并复用已有能力 |
| 反复确认每个动作 | 在明确策略内授权，关键决策交还给人 |

Aria 所追求的“超级”，不是堆叠无限功能，而是减少人在目标、工具和执行者之间的协调成本。

## 产品方向

长期来看，Aria 是一个由五类核心对象组成的行动空间。这一节描述产品方向，不代表当前 MVP 已具备全部能力。

这些是系统内部的对象；界面不会把它们变成用户必须学习的词汇。

| 对象 | 含义 |
| --- | --- |
| **Space** | 一个项目、团队或生活领域的长期世界，承载上下文、资源、记忆与权限 |
| **Mission** | 一个有待完成的目标，包含完成标准、约束、计划、进展、决策和验证记录 |
| **Artifact** | 真正交付的成果，例如代码、文档、设计、数据视图或交互式小工具 |
| **Capability** | 可以复用的 Agent、工具、自动化、模板及由任务沉淀下来的新能力 |
| **Policy** | 自治与责任边界，包括权限、预算、审批规则和允许执行的范围 |

在这个模型中，聊天仍然存在，但它是 Mission 的沟通方式，而不是产品的全部。

**聊天是通用输入，不应该是通用输出。** Aria 的最终交付可以是一份报告、一个可运行的版本、一张持续更新的仪表盘，或者一个为当前目标生成的小应用。

### 多 Agent，但不表演多 Agent

多 Agent 是执行策略，不是界面上的群体表演。

Aria 应该在并行、专业化或独立验证确有价值时才组织多个执行者。默认呈现目标级进展、阻塞和成果；用户可以按需展开工作图、追溯来源并介入具体分支。

### 从完成任务到积累能力

一次调研可以沉淀为持续监测，一次发布可以沉淀为可重复流程，一次修复可以沉淀为测试与检查规则。

Aria 不只希望让任务结束，也希望让能力留下。

## 当前 MVP 能做什么

当前版本聚焦一件具体的事：**在手机和桌面上，可靠地连接并使用一个 ACP 兼容 Agent。**

- 保存、编辑和删除多个 Agent 服务器配置；
- 通过 `ws://` / `wss://` WebSocket 桥接 ACP Agent，支持可选 Bearer Token；
- 从首页交代一件事，或重新打开 Agent 仍记得的会话；
- 把 Agent 正文、思考过程和工具调用流式接进同一条记录：连续的思考与工具合并成一个 run，正文是唯一的断点；
- 打开一个 run 的执行记录，查看每一步的输入输出，并从失败摘要直接落到出错的那一步；
- 中断当前回合，保留已经产生的内容；
- 在敏感操作前处理权限审批；
- 根据 Agent 能力切换模型、模式与推理强度；
- 在 Agent 支持时列出并恢复历史会话；
- 自动重连，并在重连后按序补发传输层队列中的消息；
- 英语、简体中文及跟随系统语言；
- 深色、浅色或跟随系统的主题；
- 手机优先的界面；宽屏时仍保持一列居中的阅读宽度；
- 使用安全存储保存服务器 Token。

Aria 自身不是模型，也不内置 Agent 运行时。当前使用链路为：

```text
Aria (Flutter)
    │
    │  ACP / JSON-RPC / NDJSON
    │  WebSocket (ws / wss)
    ▼
ACP bridge
    │
    ▼
ACP-compatible agent
```

ACP 是当前的执行接入层，不是 Aria 的最终产品边界。

## 快速开始

### 环境要求

- Flutter **3.47.8**（当前开发版本）
- Dart **3.13.7** 或兼容版本
- 一个可运行的 ACP 兼容 Agent
- 将 Agent 暴露为 WebSocket 的 ACP bridge

当前 MVP 面向 Android、iOS、macOS、Windows 和 Linux；Web 不在当前支持范围内。

### 1. 获取依赖

```bash
flutter pub get
flutter gen-l10n
```

### 2. 启动 Agent 与 bridge

以下只是一种示例接入方式，具体命令取决于你使用的 Agent 和 bridge：

```bash
npx stdio-to-ws "npx @agentclientprotocol/claude-agent-acp" --port 3000
```

这会启动一个真实的 Agent 服务。运行前请确认命令来源、工作目录、权限及可能产生的模型费用。

### 3. 运行 Aria

```bash
flutter run
```

也可以通过 `-d` 指定设备：

```bash
flutter run -d macos
```

### 4. 添加服务器

在 Aria 中填写：

| 字段 | 说明 |
| --- | --- |
| Name | 便于识别的服务器名称 |
| URL | ACP bridge 地址，例如 `ws://127.0.0.1:3000` |
| Token | 可选的 Bearer Token，必须与 bridge 配置一致 |
| Working directory | Agent 使用的工作目录，必须是运行 Agent 的机器上的路径 |

连接地址需要根据设备调整：

- 桌面端或 iOS 模拟器连接本机：通常使用 `127.0.0.1`；
- Android 模拟器连接宿主机：通常使用 `10.0.2.2`；
- 真机连接另一台机器：使用该局域网地址，并确认端口与防火墙配置。

不要把无鉴权的 Agent bridge 直接暴露到不可信网络；跨不可信网络时使用 `wss://` 和适当的安全防护。

## 验证

### 静态检查与应用测试

在仓库根目录运行：

```bash
flutter analyze
flutter test
```

### ACP 协议库测试

```bash
cd packages/acp
dart pub get
dart test
```

`packages/acp` 是纯 Dart 包，协议层不依赖 Flutter，可以独立测试。

### 连接真实 Agent

仓库还提供了一个端到端验证脚本：

```bash
cd packages/acp
dart run tool/verify_acp.dart ws://127.0.0.1:3000 /path/to/project
```

如果 bridge 配置了 Token：

```bash
dart run tool/verify_acp.dart ws://127.0.0.1:3000 /path/to/project --token=YOUR_TOKEN
```

该脚本会真实创建会话、发送提示并调用 Agent 能力，可能产生模型费用。请先确认目标 Agent、工作目录和权限配置。

## 仓库结构

```text
aria/
├── lib/
│   ├── core/                 # 主题、错误、格式化、存储与通用组件
│   ├── domain/               # 纯 Dart 模型与 Executor 接口
│   ├── data/                 # Executor 的 ACP 实现
│   ├── features/
│   │   ├── connection/       # AgentManager：每个 Agent 一个运行时，每个会话一份状态
│   │   ├── connect/          # Agent 列表与连接入口
│   │   ├── home/             # 首页问题、新对话输入与最近会话
│   │   ├── chat/             # 一条流、折叠 run、执行记录与权限审批
│   │   └── settings/         # Agent 配置、主题与语言
│   ├── router/               # go_router 配置
│   └── l10n/                 # 英语与简体中文资源
├── packages/
│   └── acp/                  # 纯 Dart ACP 客户端库
│       ├── lib/
│       ├── test/
│       └── tool/verify_acp.dart
├── test/                     # 领域、组件、主题与 Golden 测试
├── integration_test/         # 针对脚本化 ACP bridge 的端到端流程
└── tool/                     # fake_bridge.dart 等开发脚本
```

### 分层约定

- `packages/acp` 只依赖 Dart SDK，不依赖 Flutter，也不包含 UI 文案；
- `lib/domain` 不依赖 Flutter、不依赖 `package:acp`；`lib/data` 把协议类型翻译成领域类型，不向上泄漏；
- `lib/features` 通过控制器访问状态，不直接创建 ACP 客户端；
- 数据与渲染分离：`AgentManager` 接收事件并以 `(agent, session)` 为键持有 `ChatSession` 状态，页面只读取状态、发送命令。离开对话不会中断回合，重新打开 Executor 仍持有的会话只是切换视图，不会重新加载；
- 每个已连接的 Agent 有独立运行时，多个 Agent 可以同时连接且互不共享连接状态或回合状态；
- 用户可见文案通过 Flutter 本地化资源提供，不在 Widget 中硬编码；
- 连接状态与回合状态分离，网络重连不应被误判为回合结束。

## 演进路线

路线按能力阶段划分，不是日期承诺。

### 现在：可靠的 ACP 执行接入

- 跨平台连接与会话体验；
- 流式更新、权限、中断与恢复；
- 稳定的纯 Dart ACP 协议层。

### 下一步：从对话到可验收的成果

- 让一段对话承载目标与明确的完成标准；
- 让成果独立于消息流存在；
- 记录决策、来源和真正验证过的内容；
- 界面保持对话形态：内部模型变复杂，表面不增加概念。

### 随后：从单执行者到能力路由

- 在 ACP 之外接入更多模型、工具与执行环境；
- 让不同能力围绕同一个目标协作；
- 在确有价值时支持并行执行与独立验证；
- 用统一策略管理权限、预算和人工审批。

### 更长期：持续工作与能力复利

- 长期 Space 与用户可管理的记忆；
- 定时和事件驱动的主动工作；
- 将任务沉淀为可复用 Capability；
- 根据目标生成专用视图、工具与持续系统。

## 产品原则

1. **以成果为中心，而不是以消息为中心。**
2. **用户面对一个 Aria，复杂性默认由系统吸收。**
3. **多 Agent 是调度策略，不是视觉表演。**
4. **成果必须可检查、可追溯、可验收。**
5. **自治必须伴随清晰边界，关键决策始终可以交还给人。**
6. **主动性用于减少工作，而不是制造通知。**
7. **记忆属于用户，应当可查看、纠正、删除和隔离。**
8. **模型与协议可以替换，用户的目标、成果和长期上下文应当延续。**

## 参与开发

项目仍处于早期阶段，架构和接口可能快速变化。

提交变更前，请运行：

```bash
dart format .
flutter analyze
flutter test
(cd packages/acp && dart test)
```

`flutter test` 只覆盖 `test/`。端到端流程在 `integration_test/`，需要一个设备（桌面端即可）：

```bash
flutter test integration_test/app_flow_test.dart -d macos
```

它用 `tool/fake_bridge.dart` 驱动真实应用走一遍：连接、发一轮、看过程胶囊、回答审批、切回另一个会话。也可以手工跑这个 bridge（`dart run tool/fake_bridge.dart 3000`）自己点。

贡献时请保持：

- ACP 协议层的纯 Dart 边界；
- 用户可见文案进入 ARB 本地化资源；
- 新行为附带相应测试；
- 明确区分已经实现的能力与仍处于设想阶段的方向。

协议细节请参阅 [`packages/acp`](packages/acp) 及其测试——它们才是客户端支持范围的规定性描述。
