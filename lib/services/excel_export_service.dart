import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

    // Ask for permission (for Android)
    if (await Permission.storage.request().isGranted) {
      Directory? directory = await getExternalStorageDirectory();
      String dirPath = "${directory!.path}/ExpenseReports";
      await Directory(dirPath).create(recursive: true);

      String filePath = "$dirPath/Expense_Report_${period}.xlsx";
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      return filePath;
    } else {
      throw Exception('Storage permission not granted');
    }
  }
}
