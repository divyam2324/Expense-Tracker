import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_modal.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import '../widgets/mini_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);
    final todayTotal = transactions.where((t) => t.date.day == DateTime.now().day && t.date.month == DateTime.now().month && t.date.year == DateTime.now().year)
      .fold<double>(0, (prev, t) => prev + (t.isExpense ? -t.amount : t.amount));

    // quick payment mode totals
    double cash=0,upi=0,card=0;
    for(var t in transactions){
      if (t.paymentMode=='Cash') cash += t.isExpense ? t.amount : -t.amount;
      if (t.paymentMode=='UPI') upi += t.isExpense ? t.amount : -t.amount;
      if (t.paymentMode=='Card') card += t.isExpense ? t.amount : -t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height:8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Net: ₹${todayTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall),
                      ElevatedButton.icon(
                        onPressed: () => showModalBottomSheet(context: context, builder: (_) => AddTransactionModal()),
                        icon: const Icon(Icons.add),
                        label: const Text('Quick Add'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 120, child: MiniChart(transactions: transactions)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryCard('Cash', cash),
              _summaryCard('UPI', upi),
              _summaryCard('Card', card),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar View'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analytics'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(context: context, builder: (_) => AddTransactionModal()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(String title, double amount){
    return Column(
      children: [
        Text(title),
        const SizedBox(height:8),
        Text('₹${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }
}
