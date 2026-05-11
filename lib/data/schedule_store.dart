import 'package:flutter/foundation.dart';

class ScheduleStore {
  // Simple in-memory schedule list (per current user in this demo)
  static final ValueNotifier<List<DateTime>> schedulesNotifier =
      ValueNotifier<List<DateTime>>(<DateTime>[]);

  static List<DateTime> get schedules => schedulesNotifier.value;

  static void add(DateTime date) {
    final list = [...schedulesNotifier.value, date];
    list.sort();
    schedulesNotifier.value = List<DateTime>.from(list);
  }

  static void removeAt(int index) {
    final list = [...schedulesNotifier.value];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    schedulesNotifier.value = List<DateTime>.from(list);
  }

  static DateTime? next() {
    final now = DateTime.now();
    try {
      return schedulesNotifier.value.firstWhere((d) => !d.isBefore(now));
    } catch (e) {
      return null;
    }
  }

  static String nextLabel() {
    final n = next();
    if (n == null) return 'Belum ada';
    final d = n.day.toString().padLeft(2, '0');
    final m = n.month.toString().padLeft(2, '0');
    final y = n.year.toString();
    return '$d/$m/$y';
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(DateTime(now.year, now.month, now.day));
    return diff.inDays;
  }
}
