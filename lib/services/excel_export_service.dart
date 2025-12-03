import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';

class ExcelExportService {
  static Future<String> exportExpensesToExcel(
    List<TransactionModel> transactions,
    String period,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Expenses'];

    // Header row
    sheet.appendRow([
      'Date',
      'Category',
      'Payment Method',
      'Amount',
      'Description',
    ]);

    // Data rows
    for (var tx in transactions) {
      sheet.appendRow([
        tx.date.toString(),
        tx.category,
        tx.paymentMode,
        tx.amount.toStringAsFixed(2),
        tx.note,
      ]);
    }

    // Save inside app-specific documents directory (no runtime permission needed)
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = "${directory.path}/ExpenseReports";
    await Directory(dirPath).create(recursive: true);

    final filePath = "$dirPath/Expense_Report_${period}.xlsx";
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    // Return the path so UI can show it or share it
    return filePath;
  }
}
