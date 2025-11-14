import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/ocr_service.dart';
import '../utils/category_ai.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  final TransactionModel? editTransaction; // EDIT MODE

  const AddTransactionModal({super.key, this.editTransaction});

  @override
  ConsumerState<AddTransactionModal> createState() =>
      _AddTransactionModalState();
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

  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // EDIT MODE - Populate existing values
    if (widget.editTransaction != null) {
      final t = widget.editTransaction!;
      amount = t.amount;
      isExpense = t.isExpense;
      category = t.category;
      paymentMode = t.paymentMode;
      date = t.date;
      note = t.note;
      receiptPath = t.receiptPath ?? '';

      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editTransaction != null;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                isEditing ? "Edit Transaction" : "Add Transaction",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₹",
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter amount" : null,
                onSaved: (v) => amount = double.tryParse(v ?? "0") ?? 0,
              ),
              const SizedBox(height: 12),

              // Note
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: "Note"),
                onChanged: (v) {
                  note = v;
                  final suggestion = CategoryAI.suggestCategory(v);
                  if (suggestion != null) {
                    setState(() => category = suggestion);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Income/Expense
              DropdownButtonFormField<String>(
                value: isExpense ? "Expense" : "Income",
                items: const [
                  DropdownMenuItem(value: "Expense", child: Text("Expense")),
                  DropdownMenuItem(value: "Income", child: Text("Income")),
                ],
                onChanged: (v) => setState(() {
                  isExpense = v == "Expense";
                }),
                decoration: const InputDecoration(labelText: "Type"),
              ),

              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                items: [
                  'Food',
                  'Travel',
                  'Bills',
                  'Shopping',
                  'Salary',
                  'Others'
                ]
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: "Category"),
              ),

              const SizedBox(height: 12),

              // Payment Mode
              DropdownButtonFormField<String>(
                value: paymentMode,
                items: ['Cash', 'UPI', 'Card']
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => paymentMode = v!),
                decoration: const InputDecoration(labelText: "Payment Mode"),
              ),

              const SizedBox(height: 12),

              // Date Picker
              Row(
                children: [
                  Text("Date: ${date.toLocal().toString().split(" ")[0]}"),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => date = picked);
                      }
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Receipt Scanner
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final path = await OcrService.scanReceipt();
                      if (path == null) return;

                      setState(() => receiptPath = path);

                      final ocrText = await OcrService.extractText(path);
                      final parsed =
                          OcrService.extractAmountAndDate(ocrText);

                      if (parsed.amount != null) {
                        _amountCtrl.text = parsed.amount.toString();
                        amount = parsed.amount;
                      }

                      final suggestion =
                          CategoryAI.suggestCategory(ocrText);
                      if (suggestion != null) {
                        setState(() => category = suggestion);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan Receipt"),
                  ),

                  const SizedBox(width: 12),
                  Text(
                    receiptPath.isEmpty
                        ? "No receipt"
                        : "Receipt attached",
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final notifier =
                        ref.read(transactionListProvider.notifier);

                    if (isEditing) {
                      // UPDATE
                      await notifier.updateTransaction(
                        TransactionModel(
                          id: widget.editTransaction!.id,
                          amount: amount!,
                          isExpense: isExpense,
                          category: category,
                          paymentMode: paymentMode,
                          date: date,
                          note: _noteCtrl.text,
                          receiptPath: receiptPath,
                        ),
                      );
                    } else {
                      // ADD NEW
                      await notifier.addTransaction(
                        amount: amount!,
                        isExpense: isExpense,
                        category: category,
                        paymentMode: paymentMode,
                        date: date,
                        note: _noteCtrl.text,
                        receiptPath: receiptPath,
                      );
                    }

                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? "Update" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
