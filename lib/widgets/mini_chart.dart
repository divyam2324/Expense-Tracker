import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class MiniChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  const MiniChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final last7days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final List<FlSpot> spots = [];

    for (int i = 0; i < last7days.length; i++) {
      final day = last7days[i];
      final total = transactions
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold<double>(0, (sum, t) => sum + (t.isExpense ? -t.amount : t.amount));
      spots.add(FlSpot(i.toDouble(), total));
    }

    return LineChart(LineChartData(
      gridData:  FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles:  AxisTitles(),
        topTitles:  AxisTitles(),
        rightTitles:  AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final index = v.toInt();
                if (index >= 0 && index < last7days.length) {
                  return Text(DateFormat('E').format(last7days[index]),
                      style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              }),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          barWidth: 2,
          spots: spots,
          color: Theme.of(context).colorScheme.primary,
          dotData:  FlDotData(show: false),
        )
      ],
    ));
  }
}
