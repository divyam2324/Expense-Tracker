import 'package:google_ml_kit/google_ml_kit.dart';

class OcrService {
  // Example: open camera or gallery, save image and return path -- implement using image_picker
  static Future<String?> scanReceipt() async {
    // Use image_picker to capture image; return file path.
    return null; // placeholder to implement
  }

  static Future<String> extractText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final recognised = await textRecognizer.processImage(input);
    await textRecognizer.close();
    return recognised.text;
  }

  static ParsedReceipt extractAmountAndDate(String text) {
    // crude extraction using regex:
    final amountRegex = RegExp(r'₹?\s*([0-9]+(?:\.[0-9]{1,2})?)');
    final dateRegex = RegExp(r'([0-9]{2}[\/\-][0-9]{2}[\/\-][0-9]{2,4})');
    double? amount;
    DateTime? date;
    final am = amountRegex.firstMatch(text);
    if (am != null) amount = double.tryParse(am.group(1)!);
    final dt = dateRegex.firstMatch(text);
    if (dt != null) {
      // parse heuristically
    }
    return ParsedReceipt(amount: amount, date: date);
  }
}

class ParsedReceipt {
  final double? amount;
  final DateTime? date;
  ParsedReceipt({this.amount, this.date});
}
