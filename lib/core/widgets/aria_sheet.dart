import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';
import '../theme/aria_type.dart';

/// Opens a sheet from the bottom of the screen.
///
/// The design's sheets are one layer over a blurred scrim, not a stack of
/// dialogs: content changes in place when a sheet goes a page deeper.
Future<T?> showAriaSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  final colors = context.ariaColors;
  // A blocking sheet is a decision, not a panel: its scrim goes deeper.
  final scrim = dismissible ? colors.scrim : const Color(0xB3040405);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'sheet',
    barrierColor: Colors.transparent,
    transitionDuration: AriaMotion.sheet,
    pageBuilder: (context, animation, secondaryAnimation) {
      final curved = CurvedAnimation(parent: animation, curve: AriaMotion.ease);
      final insets = MediaQuery.viewInsetsOf(context);
      return FadeTransition(
        opacity: curved,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: dismissible ? () => Navigator.of(context).pop() : null,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ColoredBox(color: scrim),
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: insets.bottom),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AriaSpacing.readingColumn,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.94,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(curved),
                        child: builder(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// The sheet surface: a raised page with a header, a scrolling body and an
/// optional footer pinned to the bottom.
class AriaSheet extends StatelessWidget {
  const AriaSheet({
    super.key,
    this.kicker,
    required this.title,
    this.onClose,
    this.onBack,
    required this.body,
    this.foot,
    this.maxHeight,
  });

  final String? kicker;
  final String title;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final Widget body;
  final Widget? foot;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: AriaRadius.sheetTop,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark ? const Color(0xBF000000) : const Color(0x59141518),
            offset: const Offset(0, -40),
            blurRadius: 90,
            spreadRadius: -30,
          ),
        ],
      ),
      child: Material(
        color: colors.sheet,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.sheetTop),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                maxHeight ??
                MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).top -
                    8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: AriaSpacing.xs),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.panel3,
                      borderRadius: AriaRadius.pillAll,
                    ),
                  ),
                ),
              ),
              _SheetHead(
                kicker: kicker,
                title: title,
                onClose: onClose,
                onBack: onBack,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AriaSpacing.page,
                    AriaSpacing.xs,
                    AriaSpacing.page,
                    foot == null
                        ? AriaSpacing.page +
                              MediaQuery.paddingOf(context).bottom
                        : AriaSpacing.md,
                  ),
                  child: body,
                ),
              ),
              if (foot != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AriaSpacing.page,
                    0,
                    AriaSpacing.page,
                    AriaSpacing.sm + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AriaSpacing.xxs),
                    child: foot,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHead extends StatelessWidget {
  const _SheetHead({
    required this.kicker,
    required this.title,
    required this.onClose,
    required this.onBack,
  });

  final String? kicker;
  final String title;
  final VoidCallback? onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AriaSpacing.page,
        AriaSpacing.sm,
        AriaSpacing.page,
        AriaSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (onBack != null) ...<Widget>[
            _RoundIcon(
              icon: Icons.arrow_back_rounded,
              label: MaterialLocalizations.of(context).backButtonTooltip,
              onTap: onBack,
              size: 44,
              margin: const EdgeInsets.only(right: AriaSpacing.sm),
            ),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (kicker != null && kicker!.isNotEmpty) ...<Widget>[
                  Text(
                    kicker!,
                    style: type.kicker.copyWith(color: colors.gold),
                  ),
                  const SizedBox(height: AriaSpacing.xxs),
                ],
                Text(title, style: type.sheetTitle.copyWith(color: colors.ink)),
              ],
            ),
          ),
          if (onClose != null) ...<Widget>[
            const SizedBox(width: AriaSpacing.sm),
            _RoundIcon(
              icon: Icons.close_rounded,
              label: MaterialLocalizations.of(context).closeButtonTooltip,
              onTap: onClose,
              size: 44,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.size,
    this.margin = EdgeInsets.zero,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Padding(
      padding: margin,
      child: Material(
        color: colors.panel,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: 18,
              color: colors.ink2,
              semanticLabel: label,
            ),
          ),
        ),
      ),
    );
  }
}

/// A section label inside a sheet.
class AriaSection extends StatelessWidget {
  const AriaSection({
    super.key,
    required this.title,
    this.contextLabel,
    required this.child,
  });

  final String title;
  final String? contextLabel;

  /// The widget, named so the field above can be the section's own context.
  final Widget child;

  @override
  Widget build(BuildContext buildContext) {
    final colors = buildContext.ariaColors;
    final type = buildContext.ariaType;
    final detail = contextLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: title,
                style: type.tiny.copyWith(
                  color: colors.muted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              if (detail != null && detail.isNotEmpty)
                TextSpan(
                  text: '  ·  $detail',
                  style: type.tiny.copyWith(
                    color: colors.ink2,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AriaSpacing.xs),
        child,
      ],
    );
  }
}

/// A note under a form or a section.
class AriaNote extends StatelessWidget {
  const AriaNote(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.ariaType.caption.copyWith(
        color: color ?? context.ariaColors.muted,
        height: 1.6,
      ),
    );
  }
}

/// A quiet, full-width line of action text.
class AriaLinkButton extends StatelessWidget {
  const AriaLinkButton({
    super.key,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.align = TextAlign.left,
  });

  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: danger ? colors.danger : colors.muted,
        textStyle: context.ariaType.caption,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: const Size(44, 44),
        alignment: Alignment.centerLeft,
      ),
      child: Text(label, textAlign: align),
    );
  }
}

/// One of a row of mutually exclusive choices.
class AriaSegmented<T> extends StatelessWidget {
  const AriaSegmented({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: AriaRadius.pillAll,
      ),
      child: Row(
        children: <Widget>[
          for (var index = 0; index < values.length; index++)
            Expanded(
              child: Material(
                color: values[index] == selected
                    ? colors.key
                    : Colors.transparent,
                borderRadius: AriaRadius.pillAll,
                child: InkWell(
                  onTap: () => onChanged(values[index]),
                  borderRadius: AriaRadius.pillAll,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.copyWith(
                        fontSize: 12.5,
                        color: values[index] == selected
                            ? colors.keyInk
                            : colors.ink2,
                        fontWeight: values[index] == selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        letterSpacing: 0,
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

/// The circle that sends or stops.
class AriaSendButton extends StatelessWidget {
  const AriaSendButton({
    super.key,
    required this.running,
    required this.enabled,
    required this.onSend,
    required this.sendLabel,
    required this.stopLabel,
    this.onStop,
    this.size = 50,
  });

  final bool running;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final String sendLabel;
  final String stopLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final showStop = running && onStop != null;
    final active = showStop || enabled;
    return Semantics(
      button: true,
      enabled: active,
      label: showStop ? stopLabel : sendLabel,
      child: AnimatedOpacity(
        duration: AriaMotion.fast,
        opacity: active ? 1 : 0.28,
        child: AnimatedContainer(
          duration: AriaMotion.fast,
          curve: AriaMotion.ease,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: showStop ? colors.panel2 : colors.goldFill,
            boxShadow: enabled && !showStop
                ? <BoxShadow>[
                    BoxShadow(
                      color: colors.goldGlow,
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                      spreadRadius: -12,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: active ? (showStop ? onStop : onSend) : null,
              customBorder: const CircleBorder(),
              child: Icon(
                showStop ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                size: size < 50 ? 17 : 18,
                color: showStop ? colors.ink : colors.goldInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 44px square action that lives in a top bar.
class AriaIconButton extends StatelessWidget {
  const AriaIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final tint = color ?? (active ? colors.gold : colors.ink2);
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        borderRadius: AriaRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AriaRadius.mdAll,
          child: SizedBox(
            width: ariaMinTarget,
            height: ariaMinTarget,
            child: Icon(icon, size: 18, color: tint, semanticLabel: label),
          ),
        ),
      ),
    );
  }
}

/// The brand mark: a quiet dot that warms and breathes when something is
/// waiting.
class AriaBrandDot extends StatelessWidget {
  const AriaBrandDot({super.key, this.tone = BrandTone.quiet});

  final BrandTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bool warn = tone == BrandTone.warn;
    final dormant = dark ? const Color(0xFF5B5954) : const Color(0xFFA9A8A4);
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (tone) {
          BrandTone.quiet => colors.goldFill,
          BrandTone.warn => null,
          BrandTone.off => dormant,
        },
        gradient: warn
            ? const RadialGradient(
                center: Alignment(-0.24, -0.32),
                stops: <double>[0, 0.18, 0.62, 1],
                colors: <Color>[
                  Color(0xFFFFF4E2),
                  Color(0xFFFFF4E2),
                  Color(0xFFF0BA79),
                  Color(0xFFD79A53),
                ],
              )
            : null,
        boxShadow: switch (tone) {
          BrandTone.quiet => <BoxShadow>[
            BoxShadow(color: colors.goldSoft, spreadRadius: 4),
          ],
          BrandTone.warn => <BoxShadow>[
            BoxShadow(color: colors.goldGlow, blurRadius: 20, spreadRadius: 3),
          ],
          BrandTone.off => null,
        },
      ),
    );
    if (!warn) return dot;
    return AriaBreath(child: dot);
  }
}

enum BrandTone { quiet, warn, off }

/// A slow opacity breath. Stops entirely when motion is reduced.
class AriaBreath extends StatefulWidget {
  const AriaBreath({super.key, required this.child, this.duration});

  final Widget child;
  final Duration? duration;

  @override
  State<AriaBreath> createState() => _AriaBreathState();
}

class _AriaBreathState extends State<AriaBreath>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true, min: 0.35);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: widget.child);
  }
}

/// A 7px mark that means "running".
class AriaLiveDot extends StatelessWidget {
  const AriaLiveDot({super.key, this.size = 7});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return AriaBreath(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.goldFill,
          boxShadow: <BoxShadow>[
            BoxShadow(color: colors.goldGlow, blurRadius: 10),
          ],
        ),
      ),
    );
  }
}
