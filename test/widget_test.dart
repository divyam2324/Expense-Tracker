// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/repositories/local_repository.dart';

void main() {
  testWidgets('ExpenseTrackerApp renders home screen title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localRepoProvider.overrideWithValue(_FakeLocalRepository()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}

class _FakeLocalRepository extends LocalRepository {
  final Map<String, TransactionModel> _store = {};

  @override
  Future<void> init() async {}

  @override
  List<TransactionModel> getAll() => _store.values.toList();

  @override
  Future<void> add(TransactionModel t) async {
    _store[t.id] = t;
  }

  @override
  Future<void> update(TransactionModel t) async {
    _store[t.id] = t;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<TransactionModel>> getByDate(DateTime date) async {
    return _store.values
        .where(
          (t) =>
              t.date.year == date.year &&
              t.date.month == date.month &&
              t.date.day == date.day,
        )
        .toList();
  }
}
