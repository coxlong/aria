import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/aria_format.dart';
import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_error_line.dart';
import '../../../core/widgets/aria_sheet.dart';
import '../../../core/widgets/aria_viewport.dart';
import '../../../core/widgets/connection_banner.dart';
import '../../../domain/chat/chat_session.dart';
import '../../../domain/chat/chat_turn.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../domain/session/agent_connection.dart';
import '../../../domain/session/agent_session.dart';
import '../../../domain/session/session_ref.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/agent_manager.dart';
import '../../settings/presentation/settings_sheet.dart';
import 'search_sheet.dart';

/// Home: one question, one input, and the conversations that already exist.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _openingId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;

    // The home surface only follows its own agent's connection. Conversation
    // contents are read per row, so streaming in one does not rebuild them all.
    final agent = ref.watch(
      agentManagerProvider.select((state) => state.activeAgent),
    );
    final connected = agent?.isConnected ?? false;
    final sessions = agent?.sessions ?? const <AgentSessionSummary>[];

    return AriaViewport(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _HomeTopBar(
            onSearch: _search,
            onSettings: () => showSettings(context),
          ),
          if (agent?.status == AgentStatus.reconnecting)
            const ConnectionBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                if (agent != null && agent.canRefresh) {
                  await ref
                      .read(agentManagerProvider.notifier)
                      .refreshSessions(agent.profile.id);
                }
              },
              color: colors.gold,
              backgroundColor: colors.panel,
              child: Stack(
                children: <Widget>[
                  const Positioned(
                    top: -100,
                    left: 0,
                    right: 0,
                    child: Center(child: AriaAura()),
                  ),
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AriaSpacing.page,
                      AriaSpacing.sm,
                      AriaSpacing.page,
                      AriaSpacing.lg,
                    ),
                    children: <Widget>[
                      const SizedBox(height: 2),
                      Text(
                        l10n.heroQuestion,
                        style: context.ariaType.hero.copyWith(
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: AriaSpacing.md),
                      _HomeComposer(
                        starting: _openingId == 'new',
                        enabled: connected,
                        onStart: _startConversation,
                      ),
                      if (agent?.error != null &&
                          agent?.status != AgentStatus.failed)
                        Padding(
                          padding: const EdgeInsets.only(top: AriaSpacing.md),
                          child: AriaErrorLine(error: agent!.error!),
                        ),
                      if (sessions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 22, 6, 22),
                          child: Text(
                            l10n.noConversations,
                            textAlign: TextAlign.center,
                            style: context.ariaType.small.copyWith(
                              color: colors.muted,
                              height: 1.7,
                            ),
                          ),
                        )
                      else ...<Widget>[
                        _RecentHead(count: sessions.length),
                        for (final session in sessions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: _ConversationRow(
                              agentId: agent!.profile.id,
                              session: session,
                              busy: _openingId == session.id,
                              onTap: () => _openSession(session.id),
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _startConversation(String text) async {
    final agentId = ref.read(agentManagerProvider).activeAgentId;
    if (_openingId != null || agentId == null) return false;
    setState(() => _openingId = 'new');
    try {
      final created = await ref
          .read(agentManagerProvider.notifier)
          .newSession(agentId);
      if (!mounted || !created) return false;
      unawaited(context.push<void>('/chat', extra: text));
      return true;
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  Future<void> _search() async {
    final id = await showSearchSheet(context);
    if (id == null || !mounted) return;
    await _openSession(id);
  }

  Future<void> _openSession(String id) async {
    final agentId = ref.read(agentManagerProvider).activeAgentId;
    if (_openingId != null || agentId == null) return;
    setState(() => _openingId = id);
    try {
      final opened = await ref
          .read(agentManagerProvider.notifier)
          .openSession(agentId, id);
      if (!mounted || !opened) return;
      if (ref.read(agentManagerProvider).activeSessionRef?.sessionId != id) {
        return;
      }
      unawaited(context.push<void>('/chat'));
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }
}

class _HomeTopBar extends ConsumerWidget {
  const _HomeTopBar({required this.onSearch, required this.onSettings});

  final VoidCallback onSearch;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final active = ref.watch(
      agentManagerProvider.select((state) => state.activeAgent),
    );
    final status = active?.status ?? AgentStatus.idle;
    final agentName = active?.profile.displayName.trim() ?? '';
    final named = agentName.isNotEmpty && agentName != l10n.appName;

    final BrandTone tone = switch (status) {
      AgentStatus.reconnecting => BrandTone.warn,
      AgentStatus.failed || AgentStatus.idle => BrandTone.off,
      _ => BrandTone.quiet,
    };
    final stateLabel = switch (status) {
      AgentStatus.reconnecting => l10n.reconnectingShort,
      AgentStatus.connecting => l10n.connecting,
      AgentStatus.failed || AgentStatus.idle => l10n.connectionOffline,
      AgentStatus.connected => null,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
      child: Row(
        children: <Widget>[
          AriaBrandDot(tone: tone),
          const SizedBox(width: 10),
          Text(l10n.appName, style: type.brand.copyWith(color: colors.ink)),
          if (stateLabel != null ||
              (named && status == AgentStatus.connected)) ...<Widget>[
            const SizedBox(width: 10),
            Container(width: 1, height: 11, color: colors.panel3),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                stateLabel ?? agentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: type.small.copyWith(
                  color:
                      stateLabel != null && status == AgentStatus.reconnecting
                      ? colors.gold
                      : colors.muted,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
          const Spacer(),
          AriaIconButton(
            icon: Icons.search_rounded,
            label: l10n.searchConversations,
            onTap: onSearch,
          ),
          AriaIconButton(
            icon: Icons.tune_rounded,
            label: l10n.settings,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

/// "最近对话" and how many there are; the count is the only number here.
class _RecentHead extends StatelessWidget {
  const _RecentHead({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, AriaSpacing.sm, 12, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              AppLocalizations.of(context).recentConversations,
              style: type.caption.copyWith(
                color: colors.ink2,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.02,
              ),
            ),
          ),
          Text(
            '$count',
            style: type.tiny.copyWith(
              color: colors.muted,
              letterSpacing: 0,
              fontFeatures: AriaType.tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeComposer extends StatefulWidget {
  const _HomeComposer({
    required this.starting,
    required this.enabled,
    required this.onStart,
  });

  final bool starting;
  final bool enabled;
  final Future<bool> Function(String text) onStart;

  @override
  State<_HomeComposer> createState() => _HomeComposerState();
}

class _HomeComposerState extends State<_HomeComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _focus.removeListener(_onFocusChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _onFocusChanged() {
    if (_focused != _focus.hasFocus) setState(() => _focused = _focus.hasFocus);
  }

  bool get _canSend =>
      widget.enabled &&
      !widget.starting &&
      !_busy &&
      _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSend) return;
    final text = _controller.text.trim();
    setState(() => _busy = true);
    final accepted = await widget.onStart(text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!accepted) return;
    _controller.clear();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
    final isNumpad = event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter && !isNumpad) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    unawaited(_submit());
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    return AnimatedContainer(
      duration: AriaMotion.fast,
      curve: AriaMotion.ease,
      padding: const EdgeInsets.fromLTRB(14, 3, 3, 3),
      decoration: BoxDecoration(
        color: colors.panel2,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        border: Border.all(
          color: _focused ? colors.focus : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Focus(
              onKeyEvent: _onKey,
              child: TextField(
                key: const ValueKey<String>('home-compose-input'),
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                textInputAction: TextInputAction.done,
                style: context.ariaType.body.copyWith(color: colors.ink),
                cursorColor: colors.gold,
                onSubmitted: (_) => unawaited(_submit()),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: l10n.homeComposeHint,
                  hintStyle: context.ariaType.body.copyWith(
                    color: colors.muted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AriaSendButton(
            key: const ValueKey<String>('home-send'),
            size: 46,
            running: false,
            enabled: _canSend,
            sendLabel: l10n.startConversation,
            stopLabel: l10n.stop,
            onSend: () => unawaited(_submit()),
          ),
        ],
      ),
    );
  }
}

class _ConversationRow extends ConsumerWidget {
  const _ConversationRow({
    required this.agentId,
    required this.session,
    required this.busy,
    required this.onTap,
  });

  final String agentId;
  final AgentSessionSummary session;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    // A row rebuilds only when its own conversation changes, not when another
    // conversation streams.
    final chat = ref.watch(
      agentManagerProvider.select(
        (state) => state.sessions[SessionRef(agentId, session.id)],
      ),
    );
    final waiting = chat?.waiting ?? false;
    final running = chat?.running ?? false;
    final last = _lastLine(l10n, chat);

    final title = session.hasTitle ? session.title : l10n.untitled;
    final updated = session.updatedAt;
    final prompt = chat?.pendingDecision?.prompt.trim() ?? '';
    final lane = waiting
        ? (prompt.isEmpty ? l10n.needsApproval : l10n.needsApprovalWith(prompt))
        : last?.text ??
              (session.cwd.trim().isNotEmpty ? session.cwd.trim() : '');
    final you = !waiting && (last?.you ?? false);

    return Material(
      color: Colors.transparent,
      borderRadius: AriaRadius.smAll,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: AriaRadius.smAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (running)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: AriaLiveDot(size: 6),
                            )
                          else if (waiting)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.gold,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: colors.goldGlow,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: type.chatTitle.copyWith(color: colors.ink),
                            ),
                          ),
                          if (busy)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.6,
                                  color: colors.gold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (lane.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AriaSpacing.xxs),
                        Text(
                          you ? '${l10n.youPrefix}$lane' : lane,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.small.copyWith(
                            color: you ? colors.ink2 : colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AriaSpacing.sm),
                if (updated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      formatRelative(context, updated),
                      style: type.tiny.copyWith(
                        color: colors.muted,
                        letterSpacing: 0,
                        fontFeatures: AriaType.tabularFigures,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The last thing said, or what is happening now.
  static ({String text, bool you})? _lastLine(
    AppLocalizations l10n,
    ChatSession? chat,
  ) {
    if (chat == null) return null;
    if (chat.running) {
      final turn = chat.lastTurn;
      final tool = turn?.activeTool;
      if (tool != null) {
        final title = tool.title.trim();
        return (
          text: l10n.liveStep(title.isEmpty ? l10n.toolCall : title),
          you: false,
        );
      }
      final blocks = turn?.blocks ?? const <TurnBlock>[];
      if (blocks.isNotEmpty) {
        final last = blocks.last;
        if (last is ThoughtBlock) return (text: l10n.thinkingNow, you: false);
        if (last is TextBlock) return (text: l10n.replyingNow, you: false);
      }
      return (text: l10n.workingNote, you: false);
    }
    for (final turn in chat.turns.reversed) {
      for (final block in turn.blocks.reversed) {
        if (block is TextBlock && block.text.trim().isNotEmpty) {
          return (text: _firstLine(block.text), you: false);
        }
        if (block is ThoughtBlock && block.text.trim().isNotEmpty) {
          return (text: _firstLine(block.text, 40), you: false);
        }
      }
      if (turn.userText.trim().isNotEmpty) {
        return (text: _firstLine(turn.userText), you: true);
      }
    }
    return null;
  }
}

String _firstLine(String text, [int max = 60]) {
  final line = text.trim().split('\n').first.trim();
  if (line.length <= max) return line;
  return '${line.substring(0, max - 1)}…';
}
