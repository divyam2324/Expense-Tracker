import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'package:intl/intl.dart';

class DailyDetailScreen extends ConsumerWidget {
  final DateTime date;
  const DailyDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);
    final dayList = transactions
        .where((t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day)
        .toList();

    double cash = 0, upi = 0, card = 0;
    for (var t in dayList) {
      if (t.paymentMode == 'Cash') cash += t.amount;
      if (t.paymentMode == 'UPI') upi += t.amount;
      if (t.paymentMode == 'Card') card += t.amount;
    }

    return Scaffold(
      appBar: AppBar(title: Text(DateFormat('EEE, MMM d, yyyy').format(date))),
      body: dayList.isEmpty
          ? const Center(child: Text('No transactions for this day'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final t in dayList) TransactionTile(transaction: t),
                const Divider(),
                const SizedBox(height: 10),
                Text('Totals by Payment Mode:',
                    style: Theme.of(context).textTheme.titleMedium),
                _totalRow('Cash', cash),
                _totalRow('UPI', upi),
                _totalRow('Card', card),
              ],
            ),
    );
  }

  Widget _totalRow(String mode, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(mode), Text('₹${amount.toStringAsFixed(2)}')],
      ),
    );
  }
}
