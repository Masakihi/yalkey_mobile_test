import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late TextEditingController _titleController;
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now();
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _getReminderList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate)
      setState(() {
        _selectedDate = pickedDate;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() {
        _selectedTime = pickedTime;
      });
  }

  Future<void> _getReminderList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Reminder> cachedReminderList = prefs
            .getStringList('reminder_list')
            ?.map((reminder) => Reminder.fromJson(jsonDecode(reminder)))
            .toList() ??
        [];
    setState(() {
      _reminders = cachedReminderList;
    });
  }

  void _addReminder() {
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF,
      title: _titleController.text.trim(),
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );
    addReminder(newReminder);
    setState(() {
      _reminders.add(newReminder);
      _titleController.clear();
    });
  }

  void _updateReminder(int id, Reminder updatedReminder) {
    updateReminder(id, updatedReminder);
    setState(() {
      int index = _reminders.indexWhere((reminder) => reminder.id == id);
      if (index != -1) {
        _reminders[index] = updatedReminder;
      }
    });
  }

  void _deleteReminder(int id) {
    deleteReminder(id);
    setState(() {
      _reminders.removeWhere((reminder) => reminder.id == id);
    });
  }

  void _deleteAllReminders() {
    deleteAllReminders();
    setState(() {
      _reminders.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                            'Select Date: ${_selectedDate.toString().substring(0, 10)}'),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectTime(context),
                        child: Text(
                            'Select Time: ${_selectedTime.format(context)}'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _addReminder,
                  child: Text('Add Reminder'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text(reminder.dateTime.toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // 更新ボタンが押されたときの処理
                          _selectDate(context);
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          // 削除ボタンが押されたときの処理
                          _deleteReminder(reminder.id);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _deleteAllReminders,
            child: Text('Delete All Reminders'),
          ),
        ],
      ),
    );
  }
}
