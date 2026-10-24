import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Durations read as one value with a unit, never as a raw counter.
String formatDuration(AppLocalizations l10n, Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) return l10n.secondsShort(seconds < 1 ? 1 : seconds);
  return l10n.minutesShort(duration.inMinutes);
}

/// Time of day for today, a date otherwise. Numbers use tabular figures at the
/// call site so a ticking value does not shift.
String formatTimestamp(BuildContext context, DateTime time) {
  final locale = Localizations.localeOf(context).toString();
  final now = DateTime.now();
  final sameDay =
      now.year == time.year && now.month == time.month && now.day == time.day;
  if (sameDay) return DateFormat.Hm(locale).format(time);
  if (now.year == time.year) return DateFormat.MMMd(locale).format(time);
  return DateFormat.yMMMd(locale).format(time);
}
