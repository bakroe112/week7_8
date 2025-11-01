import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpenseService _expenseService = ExpenseService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showAddExpenseDialog() async {
    _titleController.clear();
    _amountController.clear();
    _selectedCategory = ExpenseCategory.food;
    _selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm chi tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                  ),
                ),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  items: ExpenseCategory.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(_categoryLabel(e)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nhóm',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Ngày:'),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final amountText = _amountController.text.trim();
                if (title.isEmpty || amountText.isEmpty) return;
                final amount = double.tryParse(amountText);
                if (amount == null) return;

                final expense = Expense(
                  amount: amount,
                  title: title,
                  date: _selectedDate,
                  category: _selectedCategory,
                );
                await _expenseService.addExpense(expense);
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  String _categoryLabel(ExpenseCategory c) {
    switch (c) {
      case ExpenseCategory.food:
        return 'Ăn uống';
      case ExpenseCategory.transport:
        return 'Di chuyển';
      case ExpenseCategory.shopping:
        return 'Mua sắm';
      case ExpenseCategory.bills:
        return 'Hóa đơn';
      case ExpenseCategory.other:
        return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = _expenseService.getBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ExpenseChart(service: _expenseService),
          ),
          const Divider(height: 0),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Expense> box, _) {
                if (box.values.isEmpty) {
                  return const Center(
                    child: Text('Chưa có chi tiêu nào.'),
                  );
                }

                final keys = box.keys.cast<int>().toList().reversed.toList();

                return ListView.builder(
                  itemCount: keys.length,
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final expense = box.get(key)!;
                    return Dismissible(
                      key: ValueKey(key),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        _expenseService.deleteExpense(key);
                      },
                      child: ListTile(
                        title: Text(expense.title),
                        subtitle: Text(
                          '${_categoryLabel(expense.category)} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        ),
                        trailing: Text(
                          '-${expense.amount.toStringAsFixed(0)} đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
