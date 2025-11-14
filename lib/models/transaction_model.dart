import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isExpense;

  @HiveField(3)
  String category;

  @HiveField(4)
  String paymentMode;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String note;

  @HiveField(7)
  String receiptPath;

  @HiveField(8)
  bool recurring;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.paymentMode,
    required this.date,
    this.note = '',
    this.receiptPath = '',
    this.recurring = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'isExpense': isExpense,
        'category': category,
        'paymentMode': paymentMode,
        'date': date.toIso8601String(),
        'note': note,
        'receiptPath': receiptPath,
        'recurring': recurring,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'],
        amount: (m['amount'] as num).toDouble(),
        isExpense: m['isExpense'],
        category: m['category'],
        paymentMode: m['paymentMode'],
        date: DateTime.parse(m['date']),
        note: m['note'] ?? '',
        receiptPath: m['receiptPath'] ?? '',
        recurring: m['recurring'] ?? false,
      );
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
      isExpense: fields[2] as bool,
      category: fields[3] as String,
      paymentMode: fields[4] as String,
      date: fields[5] as DateTime,
      note: (fields[6] as String?) ?? '',
      receiptPath: (fields[7] as String?) ?? '',
      recurring: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.isExpense)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.paymentMode)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.receiptPath)
      ..writeByte(8)
      ..write(obj.recurring);
  }
}
