import 'package:flutter/material.dart';

class DailyNutritionRecord {
  final DateTime date;
  final double karbohidrat;
  final double protein;
  final double lemak;
  final double serat;
  final double kalori;

  DailyNutritionRecord({
    required this.date,
    required this.karbohidrat,
    required this.protein,
    required this.lemak,
    required this.serat,
    required this.kalori,
  });
}

/// Simple in-memory store for nutrition records.
/// Use `NutritionStore.instance` to access.
class NutritionStore extends ValueNotifier<List<DailyNutritionRecord>> {
  NutritionStore._() : super([]);

  static final NutritionStore instance = NutritionStore._();

  void addRecord(DailyNutritionRecord r) {
    value = [...value, r];
    notifyListeners();
  }

  /// Returns the most recent [count] records, newest last.
  List<DailyNutritionRecord> recent(int count) {
    final list = List<DailyNutritionRecord>.from(value);
    if (list.isEmpty) return [];
    list.sort((a, b) => a.date.compareTo(b.date));
    if (list.length <= count) return list;
    return list.sublist(list.length - count);
  }

  double averageCalories({int lastDays = 7}) {
    final rec = recent(lastDays);
    if (rec.isEmpty) return 0;
    return rec.map((r) => r.kalori).reduce((a, b) => a + b) / rec.length;
  }

  double _avg(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  List<WeeklyAverage> sevenDayAverages({
    List<DailyNutritionRecord>? records,
    int groups = 4,
  }) {
    final recs = (records ?? value).toList();
    if (recs.isEmpty) return [];
    recs.sort((a, b) => a.date.compareTo(b.date));

    final chunks = <List<DailyNutritionRecord>>[];
    for (var i = recs.length; i > 0; i -= 7) {
      chunks.add(
        recs.sublist(i - 7 < 0 ? 0 : i - 7, i),
      );
    }

    final limited = chunks.take(groups).toList().reversed;

    return limited.map((chunk) {
      final weekStart = chunk.first.date;
      return WeeklyAverage(
        weekStart: weekStart,
        avgCalories: _avg(chunk.map((e) => e.kalori).toList()),
        avgKarbohidrat: _avg(chunk.map((e) => e.karbohidrat).toList()),
        avgProtein: _avg(chunk.map((e) => e.protein).toList()),
        avgLemak: _avg(chunk.map((e) => e.lemak).toList()),
        avgSerat: _avg(chunk.map((e) => e.serat).toList()),
      );
    }).toList();
  }

  /// Represents average calories for a week starting on [weekStart].
  /// [weekStart] is normalized to the Monday of that week.
  List<WeeklyAverage> weeklyAverages({List<DailyNutritionRecord>? records}) {
    final recs = (records ?? value).toList();
    if (recs.isEmpty) return [];

    // group by week start (Monday)
    final Map<DateTime, List<DailyNutritionRecord>> byWeek = {};
    for (var r in recs) {
      final monday = DateTime(
        r.date.year,
        r.date.month,
        r.date.day,
      ).subtract(Duration(days: r.date.weekday - 1));
      final key = DateTime(monday.year, monday.month, monday.day);
      byWeek.putIfAbsent(key, () => []).add(r);
    }

    final weeks = <WeeklyAverage>[];
    byWeek.forEach((weekStart, list) {
      weeks.add(WeeklyAverage(
        weekStart: weekStart,
        avgCalories: _avg(list.map((e) => e.kalori).toList()),
        avgKarbohidrat: _avg(list.map((e) => e.karbohidrat).toList()),
        avgProtein: _avg(list.map((e) => e.protein).toList()),
        avgLemak: _avg(list.map((e) => e.lemak).toList()),
        avgSerat: _avg(list.map((e) => e.serat).toList()),
      ));
    });

    weeks.sort((a, b) => a.weekStart.compareTo(b.weekStart));
    return weeks;
  }

  /// Aggregate weekly averages into monthly averages (average of weekly averages in the same month).
  List<MonthlyAverage> monthlyFromWeekly(List<WeeklyAverage> weekly) {
    if (weekly.isEmpty) return [];
    final Map<String, List<WeeklyAverage>> byMonth = {};
    for (var w in weekly) {
      final key =
          '${w.weekStart.year}-${w.weekStart.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => []).add(w);
    }

    final months = <MonthlyAverage>[];
    byMonth.forEach((key, vals) {
      final parts = key.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      months.add(MonthlyAverage(
        month: dt,
        avgCalories: _avg(vals.map((e) => e.avgCalories).toList()),
        avgKarbohidrat: _avg(vals.map((e) => e.avgKarbohidrat).toList()),
        avgProtein: _avg(vals.map((e) => e.avgProtein).toList()),
        avgLemak: _avg(vals.map((e) => e.avgLemak).toList()),
        avgSerat: _avg(vals.map((e) => e.avgSerat).toList()),
      ));
    });
    months.sort((a, b) => a.month.compareTo(b.month));
    return months;
  }
}

class WeeklyAverage {
  final DateTime weekStart;
  final double avgCalories;
  final double avgKarbohidrat;
  final double avgProtein;
  final double avgLemak;
  final double avgSerat;

  WeeklyAverage({
    required this.weekStart,
    required this.avgCalories,
    required this.avgKarbohidrat,
    required this.avgProtein,
    required this.avgLemak,
    required this.avgSerat,
  });
}

class MonthlyAverage {
  final DateTime month;
  final double avgCalories;
  final double avgKarbohidrat;
  final double avgProtein;
  final double avgLemak;
  final double avgSerat;

  MonthlyAverage({
    required this.month,
    required this.avgCalories,
    required this.avgKarbohidrat,
    required this.avgProtein,
    required this.avgLemak,
    required this.avgSerat,
  });
}
