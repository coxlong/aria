# Aria 工具调用数据（运行时实测）

数据来源：正在运行的 macOS 调试实例（VM Service），不是示例值。

- Session: `1bdae7a9-5b71-4f0e-b7c5-89a7ad561bd1`
- 读取路径：`Chat` notifier 实例 → `_blocks` → `ToolBlock.step` → `_WorkStep` 实例
- 读取方式：VM Service `getInstances` / `getObject` / `evaluate`（debug 模式）

---

## 1. 两层字段

### 1.1 ACP 协议层：`ToolCallInfo`
`packages/acp/lib/src/models/tool_call.dart`

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `id` | `String` | 来自 JSON 的 `toolCallId`（兼容 `id`） |
| `title` | `String` | 展示标题，缺省 `"Tool"` |
| `kind` | `String?` | ACP 的工具类别（agent 上报，如 read/edit/execute） |
| `status` | `String?` | `pending` / `in_progress` / `completed` / `failed` |
| `locations` | `List<Map<String, Object?>>?` | 涉及的文件/位置 |
| `rawInput` | `Object?` | 原始输入（结构由 agent 决定） |
| `rawOutput` | `Object?` | 原始输出 |
| `content` | `List<Map<String, Object?>>?` | 展示用内容块，文本在 `block['content']['text']` |
| `meta` | `Map<String, Object?>?` | 来自 JSON `_meta`；Claude Code 放 `{claudeCode: {toolName: ...}}` |

派生属性：`toolName`（从 `meta` 取）、`isCompleted`、`contentText`（拼 `content` 里的文本）。

### 1.2 应用模型层：`WorkStep`
`lib/domain/chat/work_step.dart`（freezed `_WorkStep`）

| 字段 | 类型 | 来源 |
| --- | --- | --- |
| `id` | `String` | `ToolCallInfo.id` |
| `title` | `String` | `ToolCallInfo.title` |
| `status` | `StepStatus` | `status` 字符串映射：completed→completed，failed→failed，in_progress→running，其余→pending |
| `kind` | `StepKind` | 构造时默认 `tool`；思考不走这个字段，而是独立的 `ThoughtBlock` |
| `detail` | `String?` | `ToolCallInfo.content` 各块文本用换行拼接后的结果 |
| `input` | `String?` | `rawInput`：字符串原样保留，其他类型 JSON 序列化（缩进 2 空格） |
| `output` | `String?` | `rawOutput`：规则同上 |
| `startedAt` | `DateTime?` | **客户端**在 `Chat._applyStep` 收到该步骤时打的点，不是 agent 时间 |
| `endedAt` | `DateTime?` | 同上，步骤首次到达终态时打点 |

派生：`duration`（`endedAt - startedAt`，小于 1 秒返回 `null`）、`StepStatus.isTerminal`。

---

## 2. 本次会话里的三个工具（实测值）

三个都为 `status = completed`、`kind = tool`。

### 2.1 `ls -la /Users/xlong/workspace/test`

```yaml
id: call_00_zsKPV6A6gRgSrYisVuAL2151
title: ls -la /Users/xlong/workspace/test
status: completed
kind: tool
input: null
startedAt: 2026-10-25T10:49:03.794234
endedAt: 2026-10-25T10:49:03.794256
```

`detail`：

````text
```console
total 0
drwxr-xr-x   2 xlong  staff    64 Oct 25 10:48 .
drwxr-xr-x  37 xlong  staff  1184 Oct 25 10:48 ..
```
````

`output`：

```text
total 0
drwxr-xr-x   2 xlong  staff    64 Oct 25 10:48 .
drwxr-xr-x  37 xlong  staff  1184 Oct 25 10:48 ..
```

> 同一个工具上 `detail` 和 `output` 内容重复：`detail` 是 ACP `content` 块（带 ```console 围栏），`output` 是 `rawOutput`（纯文本）。

### 2.2 `Write hello.py`

```yaml
id: call_00_1o8RWGn62sGgGh0jxmie5345
title: Write hello.py
status: completed
kind: tool
detail: null
input: null
startedAt: 2026-10-25T10:49:03.794287
endedAt: 2026-10-25T10:49:03.794321
```

`output`（132 字符，实测完整值）：

```text
File created successfully at: /Users/xlong/workspace/test/hello.py (file state is current in your context — no need to Read it back)
```

### 2.3 `python3 -I /Users/xlong/workspace/test/hello.py`

```yaml
id: call_00_ET_XtE55x2yl8op7WmDAyUC7591
title: python3 -I /Users/xlong/workspace/test/hello.py
status: completed
kind: tool
input: null
startedAt: 2026-10-25T10:49:03.794339
endedAt: 2026-10-25T10:49:03.794346
```

`detail`：

````text
```console
Hello, World!
```
````

`output`：

```text
Hello, World!
```

---

## 3. 观察

1. **三个工具的时间戳几乎同时**（10:49:03.7942xx，相差几十微秒）。因为这些步骤是在 `attach` 时回放、由 `_applyStep` 依次打点的，反映的是客户端收到的时间，不是真实执行耗时。`duration` 因此全部小于 1 秒，UI 不会显示耗时。
2. **`input` 曾被清空，已确认是客户端 bug**：ACP 帧日志显示首帧 `tool_call` 确实带 `rawInput`（见下节），后续 `tool_call_update` 只带 status/rawOutput/content。旧实现整条重建 WorkStep，把首帧输入覆盖成 null；改为 `_calls` 缓存 + `copyWith` 合并后，实测三个步骤 input 长度分别为 105 / 100 / 109。
3. **`WorkStep.kind` 实际恒为 `tool`**：思考内容走 `ThoughtBlock`，中间回复走 `TextBlock`，不是 `StepKind.thought`。所以弹窗按块类型区分图标是对的，不能靠 `kind` 字段。
4. `detail` 和 `output` 可能重复（见 `ls`）；`Write` 只有 `output`；`python3` 两者都有但形式不同（围栏 vs 纯文本）。

---

## 4. ACP 帧日志证据

日志文件（app 容器 tmp）：`/Users/xlong/Library/Containers/com.example.aria/Data/tmp/aria-acp.log`

`session/load` 回放时收到的真实帧（截取）：

```jsonc
// tool_call —— 带 rawInput / kind / name / locations / _meta
{"sessionUpdate":"tool_call","toolCallId":"call_00_zsKPV6A6gRgSrYisVuAL2151",
 "title":"ls -la /Users/xlong/workspace/test","kind":"execute","name":"Bash",
 "status":"pending",
 "rawInput":{"command":"ls -la /Users/xlong/workspace/test","description":"List files in working directory"},
 "_meta":{"claudeCode":{"toolName":"Bash"}},
 "content":[{"type":"content","content":{"type":"text","text":"List files in working directory"}}]}

// tool_call_update —— 没有 rawInput
{"sessionUpdate":"tool_call_update","toolCallId":"call_00_zsKPV6A6gRgSrYisVuAL2151",
 "status":"completed","rawOutput":"total 0\n...","content":[...]}
```

`Write hello.py` 的首帧还带 `locations: [{"path": ".../hello.py"}]`，`content` 是 `{"type":"diff","path":...,"oldText":null,"newText":"print(\"Hello, World!\")\n"}`。

### 仍然没有进入 WorkStep 的字段

| ACP 字段 | 现状 |
| --- | --- |
| `kind`（execute / edit） | 丢弃 |
| `name` / `_meta.claudeCode.toolName`（Bash / Write） | 丢弃 |
| `locations` | 丢弃 |
| `content` 里的 `diff` 块 | `_detailOf` 只读文本块，diff 被丢弃（所以 `Write` 的 detail 为 null） |

### 读取方式

```bash
tail -f /Users/xlong/Library/Containers/com.example.aria/Data/tmp/aria-acp.log
```

每行格式：`2026-10-25T11:13:07.341066 ← {jsonrpc...}`，`←` 入站、`→` 出站。
