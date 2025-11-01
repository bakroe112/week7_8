import 'package:flutter/material.dart';
import 'notification_service.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  DateTime? _selectedDateTime;

  final List<_ReminderItem> _reminders = [];

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );
    if (!mounted) return; // fix warning
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: (now.minute + 1) % 60),
    );
    if (!mounted) return; // fix warning
    if (time == null) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedDateTime = picked;
    });
  }

  Future<void> _schedule() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final dateTime = _selectedDateTime;

    if (title.isEmpty || body.isEmpty || dateTime == null) {
      _showSnack('Điền đủ tiêu đề, nội dung và thời gian.');
      return;
    }

    try {
      final id = _reminders.length + 1;
      await NotificationService().scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: dateTime,
      );

      if (!mounted) return;
      setState(() {
        _reminders.add(
          _ReminderItem(
            id: id,
            title: title,
            body: body,
            dateTime: dateTime,
          ),
        );
      });

      _titleController.clear();
      _bodyController.clear();
      _selectedDateTime = null;

      _showSnack('Đã đặt nhắc nhở.');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Lỗi: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Chưa chọn thời gian'
                        : 'Thời gian: ${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} '
                            '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickDateTime,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Chọn thời gian'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _schedule,
                child: const Text('Đặt nhắc nhở'),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nhắc nhở đã đặt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(child: Text('Chưa có nhắc nhở.'))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final item = _reminders[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.notifications_active),
                            title: Text(item.title),
                            subtitle: Text(
                              '${item.body}\n${item.dateTime}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderItem {
  final int id;
  final String title;
  final String body;
  final DateTime dateTime;

  _ReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });
}
