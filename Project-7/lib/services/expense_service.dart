import 'package:hive/hive.dart';

import '../models/expense.dart';

class ExpenseService {
  static const String boxName = 'expenses_box';

  Future<Box<Expense>> openBox() async {
    return Hive.openBox<Expense>(boxName);
  }

  Box<Expense> getBox() {
    return Hive.box<Expense>(boxName);
  }

  Future<void> addExpense(Expense expense) async {
    final box = getBox();
    await box.add(expense);
  }

  Future<void> deleteExpense(int key) async {
    final box = getBox();
    await box.delete(key);
  }

  List<Expense> getExpensesOfLast7Days() {
    final box = getBox();
    final now = DateTime.now();
    final last7 = now.subtract(const Duration(days: 6));

    return box.values
        .where(
          (e) => e.date.isAfter(
            DateTime(last7.year, last7.month, last7.day),
          ),
        )
        .toList();
  }

  Map<DateTime, double> getDailyTotalsLast7Days() {
    final list = getExpensesOfLast7Days();
    final Map<DateTime, double> totals = {};

    for (var e in list) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      totals[day] = (totals[day] ?? 0) + e.amount;
    }

    return totals;
  }
}
