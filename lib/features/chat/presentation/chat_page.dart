import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_sheet.dart';
import '../../../core/widgets/aria_toast.dart';
import '../../../core/widgets/aria_viewport.dart';
import '../../../core/widgets/connection_banner.dart';
import '../../../domain/chat/chat_session.dart';
import '../../../domain/session/agent_connection.dart';
import '../../../domain/session/agent_session.dart';
import '../../../domain/session/session_ref.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/agent_manager.dart';
import 'widgets/message_list.dart';
import 'widgets/permission_sheet.dart';
import 'widgets/selector_sheet.dart';

/// One conversation: what was said, what is being done, and the one input.
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, this.initialText});

  /// The first message of a conversation started from home.
  final String? initialText;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  /// The decision currently on screen, so a rebuild never opens a second one.
  String? _showingDecisionId;
  bool _sentInitial = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Only this conversation's state is watched. Drafts and other sessions
    // change the manager without rebuilding this page.
    final view = ref.watch(
      agentManagerProvider.select(
        (state) => (
          agent: state.activeAgent,
          sessionRef: state.activeSessionRef,
          chat: state.activeSession,
        ),
      ),
    );
    final agent = view.agent;
    final sessionRef = view.sessionRef;
    final chat = view.chat;

    // The route guard sends the person back when this agent disconnects; this
    // only covers the frame before that happens.
    if (agent == null || sessionRef == null || chat == null) {
      return const SizedBox.shrink();
    }

    _syncDecision(sessionRef, chat);
    _maybeSendInitial(sessionRef);

    final summary = _summaryOf(agent.sessions, sessionRef.sessionId);
    final pending = chat.pendingDecision;
    final title = summary != null && summary.hasTitle
        ? summary.title
        : l10n.newConversation;

    return AriaViewport(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ChatTopBar(
            title: title,
            onBack: () =>
                context.canPop() ? context.pop() : context.go('/home'),
            onDecision: pending == null
                ? null
                : () => _openDecision(sessionRef, chat),
          ),
          if (agent.status == AgentStatus.reconnecting)
            const ConnectionBanner(),
          Expanded(
            child: MessageList(
              key: ValueKey<SessionRef>(sessionRef),
              session: chat,
            ),
          ),
          _ComposerBar(
            key: ValueKey<SessionRef>(sessionRef),
            agent: agent,
            chat: chat,
            sessionRef: sessionRef,
          ),
        ],
      ),
    );
  }

  static AgentSessionSummary? _summaryOf(
    List<AgentSessionSummary> sessions,
    String id,
  ) {
    for (final summary in sessions) {
      if (summary.id == id) return summary;
    }
    return null;
  }

  void _maybeSendInitial(SessionRef sessionRef) {
    final text = widget.initialText?.trim();
    if (_sentInitial || text == null || text.isEmpty) return;
    _sentInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(agentManagerProvider.notifier).send(sessionRef, text));
    });
  }

  /// Opens the approval sheet for the head of this session's decision queue,
  /// once.
  void _syncDecision(SessionRef sessionRef, ChatSession chat) {
    final decision = chat.pendingDecision;
    if (decision == null) {
      _showingDecisionId = null;
      return;
    }
    if (_showingDecisionId == decision.id) return;
    _showingDecisionId = decision.id;

    final queued = chat.queuedDecisions;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        showPermission(
          context,
          decision,
          queued: queued,
          onAnswer: (option) => unawaited(
            ref.read(agentManagerProvider.notifier).answer(sessionRef, option),
          ),
        ).whenComplete(() {
          if (!mounted) return;
          if (_showingDecisionId != decision.id) return;
          _showingDecisionId = null;
          // A failed answer leaves the decision open; ask again rather than
          // pretending it was delivered.
          final current = ref
              .read(agentManagerProvider)
              .session(sessionRef)
              .pendingDecision;
          if (current?.id == decision.id) setState(() {});
        }),
      );
    });
  }

  void _openDecision(SessionRef sessionRef, ChatSession chat) {
    final decision = chat.pendingDecision;
    if (decision == null) return;
    if (_showingDecisionId == decision.id) return;
    _showingDecisionId = decision.id;
    final queued = chat.queuedDecisions;
    unawaited(
      showPermission(
        context,
        decision,
        queued: queued,
        onAnswer: (option) => unawaited(
          ref.read(agentManagerProvider.notifier).answer(sessionRef, option),
        ),
      ).whenComplete(() {
        if (!mounted) return;
        if (_showingDecisionId != decision.id) return;
        _showingDecisionId = null;
        final current = ref
            .read(agentManagerProvider)
            .session(sessionRef)
            .pendingDecision;
        if (current?.id == decision.id) setState(() {});
      }),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({
    required this.title,
    required this.onBack,
    required this.onDecision,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDecision;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
      child: Row(
        children: <Widget>[
          AriaIconButton(
            icon: Icons.chevron_left_rounded,
            label: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: type.chatTitle.copyWith(color: colors.ink),
            ),
          ),
          if (onDecision != null)
            AriaIconButton(
              icon: Icons.error_outline_rounded,
              label: AppLocalizations.of(context).needsApproval,
              onTap: onDecision,
              active: true,
            )
          else
            const SizedBox(width: ariaMinTarget),
        ],
      ),
    );
  }
}

class _ComposerBar extends ConsumerWidget {
  const _ComposerBar({
    super.key,
    required this.agent,
    required this.chat,
    required this.sessionRef,
  });

  final AgentConnection agent;
  final ChatSession chat;
  final SessionRef sessionRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surfaces = chat.surfaces;
    final showOptions =
        surfaces.hasModels || surfaces.hasEfforts || surfaces.hasModes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AriaSpacing.md, 2, AriaSpacing.md, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showOptions)
            _ModelRow(
              surfaces: surfaces,
              enabled: agent.isConnected,
              onTap: () => showModelSheet(context),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: _ComposerBox(
                  running: chat.running,
                  enabled: agent.isConnected,
                  hint: l10n.composerPlaceholder,
                  label: l10n.composerLabel,
                  sendLabel: l10n.send,
                  stopLabel: l10n.stop,
                  initialDraft: ref
                      .read(agentManagerProvider)
                      .draft(sessionRef),
                  onDraftChanged: (text) => ref
                      .read(agentManagerProvider.notifier)
                      .setDraft(sessionRef, text),
                  onSend: (text) => ref
                      .read(agentManagerProvider.notifier)
                      .send(sessionRef, text),
                  onStop: () {
                    showAriaToast(l10n.stopToast);
                    unawaited(
                      ref.read(agentManagerProvider.notifier).stop(sessionRef),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.surfaces,
    required this.enabled,
    required this.onTap,
  });

  final SessionSurfaces surfaces;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    final model = surfaces.hasModels
        ? (surfaces.modelLabel ?? l10n.model)
        : null;
    final effort = surfaces.hasEfforts ? surfaces.effortLabel : null;
    final mode = surfaces.hasModes ? (surfaces.modeLabel ?? l10n.mode) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.transparent,
                borderRadius: AriaRadius.smAll,
                child: InkWell(
                  onTap: enabled ? onTap : null,
                  borderRadius: AriaRadius.smAll,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: ariaMinTarget),
                    child: Padding(
                      padding: const EdgeInsets.only(right: AriaSpacing.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (model != null)
                                  Flexible(
                                    child: Text(
                                      model,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: type.tiny.copyWith(
                                        color: enabled
                                            ? colors.muted
                                            : colors.muted.withValues(
                                                alpha: 0.45,
                                              ),
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                if (effort != null) ...<Widget>[
                                  Text(
                                    ' · ',
                                    style: type.tiny.copyWith(
                                      color: colors.muted,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      effort,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: type.tiny.copyWith(
                                        color: enabled
                                            ? colors.ink2
                                            : colors.muted.withValues(
                                                alpha: 0.45,
                                              ),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (mode != null) ...<Widget>[
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                mode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: type.tiny.copyWith(
                                  color: enabled
                                      ? colors.muted
                                      : colors.muted.withValues(alpha: 0.45),
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 13,
                            color: colors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerBox extends StatefulWidget {
  const _ComposerBox({
    required this.running,
    required this.enabled,
    required this.hint,
    required this.label,
    required this.sendLabel,
    required this.stopLabel,
    required this.initialDraft,
    required this.onDraftChanged,
    required this.onSend,
    required this.onStop,
  });

  final bool running;
  final bool enabled;
  final String hint;
  final String label;
  final String sendLabel;
  final String stopLabel;

  /// The draft this conversation was left with. Read once; after that the
  /// controller and the manager stay in step through [onDraftChanged].
  final String initialDraft;

  final ValueChanged<String> onDraftChanged;
  final Future<bool> Function(String text) onSend;
  final VoidCallback onStop;

  @override
  State<_ComposerBox> createState() => _ComposerBoxState();
}

class _ComposerBoxState extends State<_ComposerBox> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDraft.isNotEmpty) {
      _controller.text = widget.initialDraft;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
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

  void _onChanged() {
    widget.onDraftChanged(_controller.text);
    setState(() {});
  }

  void _onFocusChanged() {
    if (_focused != _focus.hasFocus) setState(() => _focused = _focus.hasFocus);
  }

  bool get _canSend => widget.enabled && _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSend || widget.running) return;
    final text = _controller.text.trim();
    final accepted = await widget.onSend(text);
    if (!mounted || !accepted) return;
    _controller.clear();
    _focus.requestFocus();
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
    final colors = context.ariaColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: AnimatedContainer(
            duration: AriaMotion.fast,
            curve: AriaMotion.ease,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.panel2,
              borderRadius: AriaRadius.composerAll,
              border: Border.all(
                color: _focused ? colors.focus : Colors.transparent,
                width: 2,
              ),
            ),
            child: Focus(
              onKeyEvent: _onKey,
              child: Semantics(
                label: widget.label,
                child: TextField(
                  key: const ValueKey<String>('chat-compose-input'),
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: context.ariaType.body.copyWith(color: colors.ink),
                  cursorColor: colors.gold,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: context.ariaType.body.copyWith(
                      color: colors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AriaSendButton(
          key: const ValueKey<String>('chat-send'),
          running: widget.running,
          enabled: _canSend,
          sendLabel: widget.sendLabel,
          stopLabel: widget.stopLabel,
          onSend: () => unawaited(_submit()),
          onStop: widget.onStop,
        ),
      ],
    );
  }
}
