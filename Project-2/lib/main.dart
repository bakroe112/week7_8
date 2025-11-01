import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoItem {
  final String id;
  final String title;
  final bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    required this.isDone,
  });

  TodoItem copyWith({String? id, String? title, bool? isDone}) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
    // đơn giản đúng kiểu local state
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as String,
      title: map['title'] as String,
      isDone: map['isDone'] as bool,
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<TodoItem> _todos = [];
  static const String _storageKey = 'todos_v1';

  @override
  void initState() {
    super.initState();
    _loadTodosFromLocal();
  }

  Future<void> _loadTodosFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    final List decoded = jsonDecode(raw) as List;
    final loaded = decoded
        .map((e) => TodoItem.fromMap(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _todos.clear();
      _todos.addAll(loaded);
    });
  }

  Future<void> _saveTodosToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_todos.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _addTodoDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Thêm việc mới'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'VD: Học Flutter 30 phút',
            ),
            autofocus: true,
            onSubmitted: (_) {
              _addTodo(controller.text.trim());
              Navigator.of(ctx).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                _addTodo(controller.text.trim());
                Navigator.of(ctx).pop();
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _addTodo(String title) {
    if (title.isEmpty) return;
    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      isDone: false,
    );
    setState(() {
      _todos.add(newTodo);
    });
    _saveTodosToLocal();
  }

  void _toggleTodo(String id) {
    final index = _todos.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final old = _todos[index];
    final updated = old.copyWith(isDone: !old.isDone);
    setState(() {
      _todos[index] = updated;
    });
    _saveTodosToLocal();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((e) => e.id == id);
    });
    _saveTodosToLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App (Local State)'),
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text(
                'Chưa có việc nào.\nẤn nút + để thêm.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Dismissible(
                  key: ValueKey(todo.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteTodo(todo.id),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isDone,
                      onChanged: (_) => _toggleTodo(todo.id),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isDone ? Colors.grey : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteTodo(todo.id),
                    ),
                    onTap: () => _toggleTodo(todo.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
