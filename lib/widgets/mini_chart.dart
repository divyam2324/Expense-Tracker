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

    final today = DateTime(now.year, now.month, now.day);
    final last7days =
        List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final List<FlSpot> spots = [];

    for (int i = 0; i < last7days.length; i++) {
      final day = last7days[i];

      final total = transactions
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold<double>(0, (sum, t) => sum + t.amount);

      spots.add(FlSpot(i.toDouble(), total));
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,

        // 👉 Clean chart like your image
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),

        // Axis titles
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index > 6 || value % 1 != 0) {
                  return const SizedBox.shrink();
                }

                final day = last7days[index];
                return Text(
                  DateFormat('E').format(day), // MON, TUE...
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
        ),

        // 👉 Straight line + dots (like your image)
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,          // ← Straight line
            color: Colors.black,      // ← Black line (like your example)
            barWidth: 2.5,            // Slightly thicker line

            dotData: const FlDotData(
              show: true,             // ← Show dots like the chart
            ),

            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
