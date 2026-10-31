import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_markdown.dart';
import '../../../../domain/chat/chat_session.dart';
import '../../../../l10n/app_localizations.dart';
import '../chat_stream.dart';
import 'run_row.dart';

/// The conversation is a record, not a control panel: one stream, in order,
/// with folded runs where prose follows them.
class MessageList extends StatefulWidget {
  const MessageList({super.key, required this.session});

  final ChatSession session;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _controller = ScrollController();
  bool _farFromBottom = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToEnd());
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  bool get _isAtBottom {
    if (!_controller.hasClients) return true;
    final position = _controller.position;
    return position.maxScrollExtent - position.pixels <= 90;
  }

  void _onScroll() {
    final far =
        _controller.hasClients &&
        _controller.position.maxScrollExtent - _controller.position.pixels >
            160;
    if (far != _farFromBottom) setState(() => _farFromBottom = far);
  }

  void _jumpToEnd() {
    if (!mounted || !_controller.hasClients) return;
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Streaming may grow the page, but it must never yank the reader.
    if (!_isAtBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToEnd());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = buildChatStream(widget.session.turns);

    if (items.isEmpty) return const SizedBox.expand();

    return Stack(
      children: <Widget>[
        ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.fromLTRB(
            AriaSpacing.page,
            AriaSpacing.xs,
            AriaSpacing.page,
            AriaSpacing.lg,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AriaSpacing.md),
            child: _ItemView(item: items[index]),
          ),
        ),
        if (_farFromBottom)
          Positioned(
            right: AriaSpacing.xs,
            bottom: AriaSpacing.xs,
            child: Material(
              color: context.ariaColors.panel2,
              borderRadius: AriaRadius.pillAll,
              child: InkWell(
                onTap: () {
                  _controller.animateTo(
                    _controller.position.maxScrollExtent,
                    duration: AriaMotion.base,
                    curve: AriaMotion.ease,
                  );
                },
                borderRadius: AriaRadius.pillAll,
                child: Container(
                  constraints: const BoxConstraints(minHeight: ariaMinTarget),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 13,
                        color: context.ariaColors.ink2,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.jumpLatest,
                        style: context.ariaType.tiny.copyWith(
                          color: context.ariaColors.ink2,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemView extends StatelessWidget {
  const _ItemView({required this.item});

  final ChatItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      UserItem(:final text) => _UserBubble(text: text),
      ProseItem(:final text, :final streaming) => AriaMarkdown(
        text,
        streaming: streaming,
      ),
      final RunItem run => RunView(run: run),
      NoticeItem() => const _Notice(),
    };
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * 0.84,
            minWidth: 0,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: colors.panel3,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: SelectableText(
              text,
              style: context.ariaType.body.copyWith(
                color: colors.ink,
                fontSize: 15.5,
                height: 1.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.panel3,
            ),
          ),
        ),
        const SizedBox(width: AriaSpacing.xs),
        Expanded(
          child: Text(
            l10n.stoppedNotice,
            style: context.ariaType.caption.copyWith(color: colors.muted),
          ),
        ),
      ],
    );
  }
}
