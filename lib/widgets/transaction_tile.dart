import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_modal.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      // DELETE
      onDismissed: (_) async {
        await ref
            .read(transactionListProvider.notifier)
            .deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction deleted")),
        );
      },

      child: ListTile(
        title: Text(transaction.note.isEmpty ? transaction.category : transaction.note),
        subtitle: Text(
          "${transaction.category} • ₹${transaction.amount}",
        ),

        trailing: Text(
          "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // LONG PRESS → EDIT
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddTransactionModal(
              editTransaction: transaction,
            ),
          );
        },
      ),
    );
  }
}
