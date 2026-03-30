/// Formats an ISO 8601 datetime string as "M/D" (e.g. "3/26").
String formatMonthDay(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${dt.month}/${dt.day}';
}
