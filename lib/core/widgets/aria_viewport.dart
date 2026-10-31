import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/aria_colors.dart';
import '../theme/aria_tokens.dart';

/// One continuous field with a single reading column.
///
/// On a phone the column is the screen; on a wide window it stays phone-width
/// and centered, so the same layout is what everyone sees.
class AriaViewport extends StatelessWidget {
  const AriaViewport({
    super.key,
    required this.child,
    this.safeTop = true,
    this.safeBottom = true,
  });

  final Widget child;
  final bool safeTop;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Scaffold(
      backgroundColor: colors.ground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AriaSpacing.readingColumn,
          ),
          child: SizedBox.expand(
            child: SafeArea(
              top: safeTop,
              bottom: safeBottom,
              left: false,
              right: false,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The warm halo behind the home hero. It is decoration, never content.
///
/// It breathes on a ten-second cycle: slow enough to read as presence rather
/// than animation, and still entirely when motion is reduced.
class AriaAura extends StatefulWidget {
  const AriaAura({super.key});

  @override
  State<AriaAura> createState() => _AriaAuraState();
}

class _AriaAuraState extends State<AriaAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Opacity(
            opacity: 0.75 + 0.25 * t,
            child: Transform.scale(scale: 1 + 0.07 * t, child: child),
          );
        },
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            width: 360,
            height: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  colors.goldGlow.withValues(alpha: 0.42),
                  colors.goldGlow.withValues(alpha: 0.12),
                  colors.goldGlow.withValues(alpha: 0),
                ],
                stops: const <double>[0, 0.48, 0.72],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
