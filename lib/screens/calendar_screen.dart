import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import 'daily_detail_screen.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionListProvider);

    // Map of daily totals
    final Map<DateTime, double> dailyTotals = {};
    for (var t in transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      dailyTotals[key] =
          (dailyTotals[key] ?? 0) + (t.isExpense ? -t.amount : t.amount);
    }

    final daysInMonth = DateUtils.getDaysInMonth(
      focusedMonth.year,
      focusedMonth.month,
    );
    final firstWeekday =
        DateTime(focusedMonth.year, focusedMonth.month, 1).weekday;

    List<Widget> dayWidgets = [];
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, d);
      final total = dailyTotals[date] ?? 0;
      dayWidgets.add(
        GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DailyDetailScreen(date: date),
                ),
              ),
          child: Card(
            color:
                total == 0
                    ? Colors.grey[200]
                    : total > 0
                    ? Colors.green[100]
                    : Colors.red[100],
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$d',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (total != 0) ...[
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              total >= 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                focusedMonth = DateTime(
                  focusedMonth.year,
                  focusedMonth.month - 1,
                  focusedMonth.day,
                );
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                focusedMonth = DateTime(
                  focusedMonth.year,
                  focusedMonth.month + 1,
                  focusedMonth.day,
                );
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              DateFormat('MMMM yyyy').format(focusedMonth),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                children: dayWidgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
