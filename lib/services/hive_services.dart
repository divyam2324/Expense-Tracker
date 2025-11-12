import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

class HiveService {
  static final Box _box = Hive.box('transactions');

  // Add a transaction
  static Future<void> addTransaction(TransactionModel transaction) async {
    await _box.add(transaction.toMap());
  }

  // Get all transactions
  static List<TransactionModel> getAllTransactions() {
    return _box.values
        .map((data) => TransactionModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  // Delete a transaction
  static Future<void> deleteTransaction(int index) async {
    await _box.deleteAt(index);
  }

  // Edit a transaction
  static Future<void> editTransaction(int index, TransactionModel updated) async {
    await _box.putAt(index, updated.toMap());
  }
}
