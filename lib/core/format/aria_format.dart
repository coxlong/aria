import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// The clock timestamps are compared against. Golden tests pin it so a date
/// column does not drift with the real calendar.
@visibleForTesting
DateTime Function() ariaNow = DateTime.now;

/// Durations read as one value with a unit, never as a raw counter.
String formatDuration(AppLocalizations l10n, Duration duration) {
  final seconds = duration.inSeconds;
  if (seconds < 60) return l10n.secondsShort(seconds < 1 ? 1 : seconds);
  return l10n.minutesShort(duration.inMinutes);
}

/// A conversation's age in the smallest honest unit: just now, minutes, hours,
/// then the date itself.
String formatRelative(BuildContext context, DateTime time) {
  final l10n = AppLocalizations.of(context);
  final diff = ariaNow().difference(time);
  if (diff.inSeconds < 60) return l10n.now;
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inHours < 6) return l10n.hoursAgo(diff.inHours);
  return formatTimestamp(context, time);
}

/// Time of day for today, a date otherwise. Numbers use tabular figures at the
/// call site so a ticking value does not shift.
String formatTimestamp(BuildContext context, DateTime time) {
  final locale = Localizations.localeOf(context).toString();
  final now = ariaNow();
  final sameDay =
      now.year == time.year && now.month == time.month && now.day == time.day;
  if (sameDay) return DateFormat.Hm(locale).format(time);
  if (now.year == time.year) return DateFormat.MMMd(locale).format(time);
  return DateFormat.yMMMd(locale).format(time);
}
