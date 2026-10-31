# Aria

**English** | [简体中文](README.zh-CN.md)

**An open, outcome-first AI workspace.**

> One intent. Every capability.

Aria connects human intent with models, agents, tools, and long-term context. You define the goal; Aria organizes the work, enforces its boundaries, advances execution, and delivers outcomes you can inspect and verify.

It is not meant to be just another chat window, nor should it require you to manage a crowd of agents. You interact with one unified Aria while different forms of intelligence and tooling work together behind it.

> **Status: early development.** This repository currently contains a cross-platform **ACP (Agent Client Protocol) client MVP**. Multi-agent orchestration, Missions, Artifacts, and durable capability building describe the product direction; they are not all implemented today.

## Why Aria

Most AI products are organized around a model, a conversation, or an individual agent. Aria is concerned with something else: **reliably turning intent into outcomes.**

| From | To |
| --- | --- |
| Managing disconnected conversations | Advancing a goal with explicit completion criteria |
| Choosing and coordinating agents yourself | Letting Aria assemble the right capabilities |
| Searching through replies for an answer | Reviewing standalone, traceable outcomes |
| Starting over every time | Carrying context forward and reusing capabilities |
| Approving every individual action | Granting bounded autonomy while keeping key decisions with people |

For Aria, “super” does not mean an unlimited number of features. It means reducing the coordination cost between goals, tools, and executors.

## Product direction

Over time, Aria will be an action workspace built around five core objects. This section describes the product direction, not a claim that the current MVP implements all of them.

These are internal system objects. The interface does not turn them into vocabulary the user has to learn.

| Object | Purpose |
| --- | --- |
| **Space** | The durable world of a project, team, or area of life, containing context, resources, memory, and permissions |
| **Mission** | A goal to accomplish, with completion criteria, constraints, plans, progress, decisions, and verification records |
| **Artifact** | The actual deliverable: code, a document, a design, a data view, or an interactive tool |
| **Capability** | A reusable agent, tool, automation, template, or new capability retained from previous work |
| **Policy** | The boundaries of autonomy and responsibility, including permissions, budgets, approvals, and scope |

In this model, chat remains important, but it becomes a way to communicate within a Mission rather than the entire product.

**Chat is a universal input; it should not be the universal output.** Aria may ultimately deliver a report, a working build, a live dashboard, or a small application created for the goal at hand.

### Multi-agent without the theater

Multi-agent execution is a strategy, not a group performance in the interface.

Aria should bring in multiple executors only when parallelism, specialization, or independent verification adds real value. By default, it presents goal-level progress, blockers, and outcomes. You can inspect the work graph, trace sources, and intervene in a specific branch when needed.

### From completing work to compounding capability

A research task can become continuous monitoring. A release can become a repeatable process. A fix can leave behind tests and checks.

Aria should not only finish work; it should leave useful capabilities behind.

## What the current MVP does

The current version has a concrete focus: **reliably connecting to and working with an ACP-compatible agent from mobile and desktop devices.**

- Save, edit, and delete multiple agent server profiles;
- Connect to ACP agents through `ws://` / `wss://` WebSocket bridges, with optional Bearer Token authentication;
- Start a conversation from the home surface, or reopen one the agent still knows about;
- Stream agent messages, thoughts, and tool calls into one transcript, folding consecutive thinking and tool calls into a run and keeping prose as the only break;
- Open a run's work log, read each step's input and output, and follow a failure to the step that failed;
- Interrupt the active turn while keeping what was already produced;
- Review permission requests before sensitive operations;
- Switch models, modes, and reasoning effort when supported by the agent;
- List and restore previous sessions when supported by the agent;
- Reconnect automatically and flush the transport outbox in order after reconnecting;
- Use English, Simplified Chinese, or the system language;
- Choose a dark, light, or system theme;
- Work with a phone-first interface that stays one centered reading column on wide screens;
- Store server tokens using secure storage.

Aria is not a model and does not embed an agent runtime. The current connection path is:

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

ACP is the current execution adapter, not the ultimate boundary of the product.

## Getting started

### Requirements

- Flutter **3.47.8** (the current development version)
- Dart **3.13.7** or a compatible version
- A working ACP-compatible agent
- An ACP bridge that exposes the agent over WebSocket

The current MVP targets Android, iOS, macOS, Windows, and Linux. Web is not currently supported.

### 1. Install dependencies

```bash
flutter pub get
flutter gen-l10n
```

### 2. Start an agent and bridge

The following is just one example. The exact command depends on your chosen agent and bridge:

```bash
npx stdio-to-ws "npx @agentclientprotocol/claude-agent-acp" --port 3000
```

This starts a real agent service. Before running it, verify the command source, working directory, permissions, and any model usage costs.

### 3. Run Aria

```bash
flutter run
```

You can also select a device explicitly:

```bash
flutter run -d macos
```

### 4. Add a server

Enter the following information in Aria:

| Field | Description |
| --- | --- |
| Name | A recognizable name for the server |
| URL | The ACP bridge address, such as `ws://127.0.0.1:3000` |
| Token | An optional Bearer Token matching the bridge configuration |
| Working directory | The agent working directory, expressed as a path on the machine running the agent |

The connection address depends on your device:

- Desktop or iOS simulator connecting to the same machine: usually `127.0.0.1`;
- Android emulator connecting to the host machine: usually `10.0.2.2`;
- Physical device connecting to another machine: use its LAN address and check the port and firewall configuration.

Do not expose an unauthenticated agent bridge to an untrusted network. Use `wss://` and appropriate network protection when crossing trust boundaries.

## Verification

### Static analysis and application tests

From the repository root:

```bash
flutter analyze
flutter test
```

### End-to-end flow

`flutter test` only discovers `test/`. The flow against a scripted ACP bridge lives in `integration_test/` and needs a device (the host is usually enough):

```bash
flutter test integration_test/app_flow_test.dart -d macos
```

It runs the real app against `tool/fake_bridge.dart`: connect, send a turn, watch the process pill, answer the approval, and resume another session. The same bridge can be run by hand — `dart run tool/fake_bridge.dart 3000` — if you want to poke at the app yourself.

### ACP protocol tests

```bash
cd packages/acp
dart pub get
dart test
```

`packages/acp` is a pure Dart package. The protocol layer does not depend on Flutter and can be tested independently.

### Verify against a live agent

An end-to-end verification script is also included:

```bash
cd packages/acp
dart run tool/verify_acp.dart ws://127.0.0.1:3000 /path/to/project
```

If your bridge requires a token:

```bash
dart run tool/verify_acp.dart ws://127.0.0.1:3000 /path/to/project --token=YOUR_TOKEN
```

This script creates real sessions, sends prompts, and invokes agent capabilities. It may incur model usage costs. Check the target agent, working directory, and permissions before running it.

## Repository structure

```text
aria/
├── lib/
│   ├── core/                 # Theme, errors, formatting, storage, shared widgets
│   ├── domain/               # Pure Dart models and the Executor interface
│   ├── data/                 # The ACP implementation of Executor
│   ├── features/
│   │   ├── connection/       # AgentManager: one runtime per agent, session state per conversation
│   │   ├── connect/          # Agent list and connection entry
│   │   ├── home/             # The question, the new-conversation input, recent sessions
│   │   ├── chat/             # One stream, folded runs, work log, and permissions
│   │   └── settings/         # Agent profiles, theme, and language
│   ├── router/               # go_router configuration
│   └── l10n/                 # English and Simplified Chinese resources
├── packages/
│   └── acp/                  # Pure Dart ACP client library
│       ├── lib/
│       ├── test/
│       └── tool/verify_acp.dart
├── test/                     # Domain, widget, theme, and golden tests
├── integration_test/         # End-to-end flow against a scripted ACP bridge
└── tool/                     # fake_bridge.dart and other developer scripts
```

### Layering rules

- `packages/acp` depends only on the Dart SDK, not Flutter, and contains no UI copy;
- `lib/domain` depends on neither Flutter nor `package:acp`; `lib/data` translates protocol types into domain types and never leaks them upward;
- `lib/features` accesses state through controllers rather than creating ACP clients directly;
- Conversation data and rendering are separate: `AgentManager` receives events and owns `ChatSession` state keyed by `(agent, session)`, while pages only read that state and send commands. Leaving a conversation does not stop its turn, and reopening one the executor still holds is a switch, not a reload;
- Each connected agent has its own runtime, so several agents can stay connected without sharing connection or turn state;
- User-visible copy is provided through Flutter localization resources instead of being hardcoded in widgets;
- Connection state and turn state remain separate so a network reconnect is not mistaken for the end of a turn.

## Roadmap

These are capability stages, not date commitments.

### Now: a reliable ACP execution adapter

- Cross-platform connection and session experience;
- Streaming, permissions, interruption, and recovery;
- A stable, pure Dart ACP protocol layer.

### Next: from chat to verified outcomes

- Let a conversation carry a goal and explicit completion criteria;
- Give deliverables a life outside the message stream;
- Record decisions, sources, and what was actually verified;
- Keep the interface conversational: the internal model grows, the surface does not.

### Then: from one executor to capability routing

- Connect additional models, tools, and execution environments beyond ACP;
- Let different capabilities contribute to the same goal;
- Support parallel execution and independent verification where they add value;
- Manage permissions, budgets, and human approval through unified policies.

### Later: durable work and compounding capability

- Long-lived Spaces with user-controlled memory;
- Proactive work driven by schedules and events;
- Reusable Capabilities retained from completed work;
- Purpose-built views, tools, and durable systems generated for a goal.

## Product principles

1. **Center outcomes, not messages.**
2. **Present one Aria while the system absorbs complexity by default.**
3. **Treat multi-agent execution as a scheduling strategy, not visual theater.**
4. **Make outcomes inspectable, traceable, and verifiable.**
5. **Pair autonomy with clear boundaries, and keep key decisions available to people.**
6. **Use proactivity to reduce work, not to manufacture notifications.**
7. **Treat memory as user-owned: visible, correctable, deletable, and scoped.**
8. **Allow models and protocols to change without sacrificing the user's goals, outcomes, and long-term context.**

## Contributing

The project is at an early stage, and its architecture and APIs may change quickly.

Before submitting changes, run:

```bash
dart format .
flutter analyze
flutter test
(cd packages/acp && dart test)
```

When contributing:

- Preserve the pure Dart boundary of the ACP protocol layer;
- Put user-visible copy in ARB localization resources;
- Add appropriate tests for new behavior;
- Clearly distinguish implemented capabilities from future product ideas.

For protocol details, see [`packages/acp`](packages/acp) and its tests, which are the normative description of what the client supports.
