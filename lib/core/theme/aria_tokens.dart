import 'package:material_ui/material_ui.dart';

/// The spacing scale, in logical pixels.
abstract final class AriaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// The reading column used by the home and chat surfaces.
  static const double readingColumn = 640;

  /// A user message never runs wider than this.
  static const double userMessageMax = 380;

  /// Horizontal page padding from the design.
  static const double page = 20;

  /// The same padding on a 360px phone.
  static const double pageNarrow = 16;
}

/// Corner radii from the design.
abstract final class AriaRadius {
  static const double xs = 10;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 22;
  static const double composer = 25;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius composerAll = BorderRadius.all(
    Radius.circular(composer),
  );
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  /// A sheet sits against the bottom of the screen.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Motion durations and curves. The design keeps movement short and quiet.
abstract final class AriaMotion {
  static const Duration press = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 260);
  static const Duration sheet = Duration(milliseconds: 260);

  static const Curve ease = Cubic(0.22, 0.72, 0.2, 1);
  static const Curve entering = Curves.easeOut;
  static const Curve leaving = Curves.easeIn;

  /// Durations collapse to zero when the platform asks for reduced motion.
  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Minimum interactive target, from the accessibility rules.
const double ariaMinTarget = 44;
