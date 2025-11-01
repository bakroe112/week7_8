import 'package:hive/hive.dart';

/// Các nhóm chi tiêu
enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  other,
}

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  double amount;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  ExpenseCategory category;

  Expense({
    required this.amount,
    required this.title,
    required this.date,
    required this.category,
  });
}

// Vì không dùng build_runner nên tự viết adapter
class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final amount = reader.readDouble();
    final title = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final categoryIndex = reader.readInt();

    return Expense(
      amount: amount,
      title: title,
      date: date,
      category: ExpenseCategory.values[categoryIndex],
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeDouble(obj.amount);
    writer.writeString(obj.title);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.category.index);
  }
}
