import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// The one input.
///
/// The same component appears on every surface: it is never replaced by a
/// spinner, and it stays reachable while work runs — only the action on the
/// right changes from send to stop.
class AriaComposer extends StatefulWidget {
  const AriaComposer({
    super.key,
    required this.hint,
    required this.onSubmit,
    this.onStop,
    this.running = false,
    this.enabled = true,
    this.autofocus = false,
    this.initialText,
    this.chips = const <Widget>[],
  });

  final String hint;

  /// Called with the trimmed text. The field is cleared only when this returns
  /// true, so a send that is refused — a turn is already running — or that
  /// fails keeps the draft instead of discarding it.
  final Future<bool> Function(String text) onSubmit;

  final VoidCallback? onStop;
  final bool running;
  final bool enabled;
  final bool autofocus;
  final String? initialText;

  /// Configuration for this session, shown beside the send action. On a phone
  /// they only appear while the keyboard is open, so the composer can keep to
  /// one row the rest of the time.
  final List<Widget> chips;

  @override
  State<AriaComposer> createState() => _AriaComposerState();
}

class _AriaComposerState extends State<AriaComposer>
    with WidgetsBindingObserver {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// The keyboard is only visible through the view's insets, and those are not
  /// an inherited widget the composer could depend on. Rebuild on any metrics
  /// change and read the current inset in [build].
  @override
  void didChangeMetrics() => setState(() {});

  void _onChanged() => setState(() {});

  bool get _canSend => widget.enabled && _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSend || widget.running) return;
    final text = _controller.text.trim();
    final accepted = await widget.onSubmit(text);
    if (!mounted || !accepted) return;
    _controller.clear();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
    final isNumpad = event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter && !isNumpad) return KeyEventResult.ignored;

    final keyboard = HardwareKeyboard.instance;
    // Shift+Enter is a newline; everything else sends, as on every chat tool.
    if (keyboard.isShiftPressed) return KeyEventResult.ignored;
    unawaited(_submit());
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

    // On a phone the composer competes with the keyboard for height. While the
    // keyboard is away it stays on one row; the option chips come back once the
    // person is actually typing. Desktop never reports a soft-keyboard inset,
    // so its options stay visible.
    //
    // A Scaffold between this field and the app removes the keyboard inset
    // from the MediaQuery its body sees, so the view itself is the only
    // reliable source here.
    final mobile = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;
    final compact = mobile && !keyboardOpen;

    final action = _ComposerAction(
      running: widget.running,
      enabled: _canSend,
      onSend: () => unawaited(_submit()),
      onStop: widget.onStop,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AriaRadius.xlAll,
          border: Border.all(color: colors.borderStrong),
        ),
        padding: const EdgeInsets.fromLTRB(
          AriaSpacing.md,
          AriaSpacing.xs,
          AriaSpacing.xs,
          AriaSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      autofocus: widget.autofocus,
                      enabled: widget.enabled,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      style: type.body.copyWith(color: colors.text),
                      cursorColor: colors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AriaSpacing.xs,
                        ),
                        hintText: widget.hint,
                        hintStyle: type.body.copyWith(color: colors.textMuted),
                      ),
                    ),
                  ),
                ),
                if (compact) action,
              ],
            ),
            if (!compact) ...<Widget>[
              const SizedBox(height: AriaSpacing.xxs),
              Row(
                children: <Widget>[
                  for (final chip in widget.chips) ...<Widget>[
                    chip,
                    const SizedBox(width: AriaSpacing.xs),
                  ],
                  const Spacer(),
                  action,
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComposerAction extends StatelessWidget {
  const _ComposerAction({
    required this.running,
    required this.enabled,
    required this.onSend,
    required this.onStop,
  });

  final bool running;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final showStop = running && onStop != null;
    final active = showStop || enabled;

    return SizedBox(
      width: ariaMinTarget,
      height: ariaMinTarget,
      child: IconButton(
        onPressed: !active
            ? null
            : showStop
            ? onStop
            : onSend,
        style: IconButton.styleFrom(
          backgroundColor: showStop
              ? colors.inset
              : (enabled ? colors.primary : colors.inset),
          foregroundColor: showStop
              ? colors.text
              : (enabled ? colors.onPrimary : colors.textMuted),
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(showStop ? Icons.stop_rounded : Icons.arrow_upward_rounded),
      ),
    );
  }
}
