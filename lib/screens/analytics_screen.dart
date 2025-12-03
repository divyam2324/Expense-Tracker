import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';
import '../services/excel_export_service.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildAnalytics(context, transactions, days: 7),
          _buildAnalytics(context, transactions, days: 30),
          _buildCustomRange(context, transactions),
        ],
      ),
    );
  }

  Widget _buildAnalytics(
    BuildContext context,
    List<TransactionModel> transactions, {
    required int days,
  }) {
    final now = DateTime.now();
    // Normalize to whole days so the period is clear:
    // e.g. for 7 days, include today and previous 6 days.
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: days - 1));

    final filtered =
        transactions.where((t) {
          final d = DateTime(t.date.year, t.date.month, t.date.day);
          return (d.isAtSameMomentAs(startDate) || d.isAfter(startDate)) &&
              (d.isAtSameMomentAs(today) || d.isBefore(today));
        }).toList();

    double cash = 0, upi = 0, card = 0, totalExpense = 0;
    Map<String, double> categoryMap = {};

    for (var t in filtered) {
      totalExpense += t.amount;

      if (t.paymentMode == 'Cash') cash += t.amount;
      if (t.paymentMode == 'UPI') upi += t.amount;
      if (t.paymentMode == 'Card') card += t.amount;

      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Expenses: ₹${totalExpense.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
        const SizedBox(height: 10),
        const Text('Category Distribution', style: TextStyle(fontSize: 16)),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections:
                  categoryMap.entries
                      .map(
                        (e) => PieChartSectionData(
                          value: e.value,
                          title: e.key,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Payment Mode Totals', style: TextStyle(fontSize: 16)),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: cash)]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: upi)]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: card)]),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, meta) {
                      switch (v.toInt()) {
                        case 0:
                          return const Text('Cash');
                        case 1:
                          return const Text('UPI');
                        case 2:
                          return const Text('Card');
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              // Pass your filtered transactions and period name
              String filePath = await ExcelExportService.exportExpensesToExcel(
                filtered,
                days == 7 ? 'Weekly' : 'Monthly',
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Excel file saved at: $filePath')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error exporting file: $e')),
              );
            }
          },
          icon: const Icon(Icons.download),
          label: Text(
            days == 7 ? 'Export Weekly Report' : 'Export Monthly Report',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRange(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    DateTimeRange? selectedRange;

    return StatefulBuilder(
      builder: (context, setState) {
        final now = DateTime.now();
        final start =
            selectedRange?.start ?? now.subtract(const Duration(days: 7));
        final end = selectedRange?.end ?? now;

        final filtered =
            transactions
                .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
                .toList();

        double total = filtered.fold(0, (sum, t) => sum + t.amount);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedRange = picked);
              },
              child: const Text('Select Date Range'),
            ),
            const SizedBox(height: 10),
            Text(
              'Range: ${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}',
            ),
            const SizedBox(height: 10),
            Text(
              'Total Expense: ₹${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }
}
