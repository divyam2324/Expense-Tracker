import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class LocalRepository {
  static const String boxName = 'transactions_box';
  late Box<TransactionModel> box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    box = await Hive.openBox<TransactionModel>(boxName);
  }

  List<TransactionModel> getAll() =>
      box.values.toList().cast<TransactionModel>();

  Future<void> add(TransactionModel t) async => await box.put(t.id, t);

  Future<void> update(TransactionModel t) async => await t.save();

  Future<void> delete(String id) async => await box.delete(id);

  Future<List<TransactionModel>> getByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));
    return Future.value(
      box.values
          .where(
            (t) =>
                t.date.isAfter(start.subtract(Duration(milliseconds: 1))) &&
                t.date.isBefore(end),
          )
          .toList(),
    );
  }
}
