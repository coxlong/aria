import 'package:material_ui/material_ui.dart';

/// The 4px spacing scale.
abstract final class AriaSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// The reading column. Prose never runs wider than this.
  static const double readingColumn = 720;

  /// A user message never runs wider than this.
  static const double userMessageMax = 380;
}

/// Corner radii.
abstract final class AriaRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 20;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Motion durations.
abstract final class AriaMotion {
  static const Duration press = Duration(milliseconds: 100);
  static const Duration local = Duration(milliseconds: 170);
  static const Duration surface = Duration(milliseconds: 240);

  static const Curve entering = Curves.easeOut;
  static const Curve leaving = Curves.easeIn;

  /// Durations collapse to zero when the platform asks for reduced motion.
  static Duration resolve(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Minimum interactive target, from the accessibility rules.
const double ariaMinTarget = 44;
