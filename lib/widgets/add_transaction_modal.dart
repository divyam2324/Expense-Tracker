import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../utils/ocr_service.dart';
import '../utils/category_ai.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  double? amount;
  bool isExpense = true;
  String category = 'Others';
  String paymentMode = 'Cash';
  DateTime date = DateTime.now();
  String note = '';
  String receiptPath = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // keyboard safe
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(isExpense ? 'Add Expense' : 'Add Income', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
                keyboardType: TextInputType.number,
                onSaved: (v) => amount = double.tryParse(v ?? '0') ?? 0,
                validator: (v) => (v==null || v.isEmpty) ? 'Enter amount' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note'),
                onChanged: (v) {
                  note = v;
                  // simple AI suggestion: infer category from note
                  final suggestion = CategoryAI.suggestCategory(v);
                  if (suggestion != null) setState(() => category = suggestion);
                },
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Food','Travel','Bills','Shopping','Salary','Others'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v)=> setState(()=> category = v!),
              ),
              DropdownButtonFormField<String>(
                value: paymentMode,
                items: ['Cash','UPI','Card'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v)=> setState(()=> paymentMode = v!),
              ),
              Row(
                children: [
                  Text('Date: ${date.toLocal().toString().split(' ')[0]}'),
                  TextButton(onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (picked != null) setState(()=> date = picked);
                  }, child: const Text('Change'))
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      // scan receipt -> OCR
                      final path = await OcrService.scanReceipt();
                      if (path != null) {
                        setState(()=> receiptPath = path);
                        final ocrText = await OcrService.extractText(path);
                        final parsed = OcrService.extractAmountAndDate(ocrText);
                        if (parsed.amount != null) {
                          setState(()=> amount = parsed.amount);
                        }
                        final suggestedCat = CategoryAI.suggestCategory(ocrText);
                        if (suggestedCat != null) setState(()=> category = suggestedCat);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Receipt'),
                  ),
                  const SizedBox(width: 12),
                  Text(receiptPath.isEmpty ? 'No receipt' : 'Receipt attached')
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref.read(transactionListProvider.notifier).addTransaction(
                      amount: amount ?? 0,
                      isExpense: isExpense,
                      category: category,
                      paymentMode: paymentMode,
                      date: date,
                      note: note,
                      receiptPath: receiptPath,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
