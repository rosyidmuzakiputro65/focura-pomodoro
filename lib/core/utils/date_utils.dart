/// Helper tanggal yang dipakai oleh statistik.
class AppDateUtils {
  const AppDateUtils._();

  static DateTime startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
