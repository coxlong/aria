/// The one line a step gets in a list.
///
/// Rows are previews: the first line only, capped so a long sentence cannot
/// push the status or the chevron off the row. Everything past it lives on the
/// detail page behind the row.
String firstLineOf(String text, {int maxLength = 60}) {
  final line = text.trim().split('\n').first;
  if (line.length <= maxLength) return line;
  return '${line.substring(0, maxLength - 3)}…';
}
