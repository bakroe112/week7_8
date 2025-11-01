import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../services/expense_service.dart';

class ExpenseChart extends StatelessWidget {
  final ExpenseService service;

  const ExpenseChart({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final data = service.getDailyTotalsLast7Days();

    // tạo list 7 ngày gần nhất
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final d = now.subtract(Duration(days: 6 - index));
      return DateTime(d.year, d.month, d.day);
    });

    final maxY = data.values.isEmpty
        ? 100.0
        : (data.values.reduce((a, b) => a > b ? a : b)) * 1.2;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          // chỗ này phải là double
          maxY: maxY == 0 ? 100.0 : maxY,
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= days.length) {
                    return const SizedBox.shrink();
                  }
                  final d = days[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('E').format(d),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(days.length, (index) {
            final day = days[index];
            // ép về double cho chắc
            final amount = (data[day] ?? 0).toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  width: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
