import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../repositories/local_repository.dart';
import 'package:uuid/uuid.dart';

final localRepoProvider =
    Provider<LocalRepository>((ref) => LocalRepository());

final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, List<TransactionModel>>(
        (ref) {
  final repo = ref.read(localRepoProvider);
  return TransactionListNotifier(repo);
});

class TransactionListNotifier extends StateNotifier<List<TransactionModel>> {
  final LocalRepository repo;

  TransactionListNotifier(this.repo) : super([]) {
    _load();
  }

  Future<void> _load() async {
    await repo.init();
    state = repo.getAll()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction({
    required double amount,
    required bool isExpense,
    required String category,
    required String paymentMode,
    required DateTime date,
    String note = '',
    String receiptPath = '',
    bool recurring = false,
  }) async {
    final id = const Uuid().v4();

    final tx = TransactionModel(
      id: id,
      amount: amount,
      isExpense: isExpense,
      category: category,
      paymentMode: paymentMode,
      date: date,
      note: note,
      receiptPath: receiptPath,
      recurring: recurring,
    );

    await repo.add(tx);

    state = [...state, tx]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteTransaction(String id) async {
    await repo.delete(id);
    state = state.where((t) => t.id != id).toList();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await repo.update(t);

    state = [
      for (final old in state) (old.id == t.id ? t : old)
    ]..sort((a, b) => b.date.compareTo(a.date));
  }
}
