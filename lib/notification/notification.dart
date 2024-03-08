import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class Reminder {
  final int id;
  final String title;
  final DateTime dateTime;

  Reminder({required this.id, required this.title, required this.dateTime});

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
        id: json['id'],
        title: json['title'],
        dateTime: DateTime.parse(json['date_time']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'date_time': dateTime.toIso8601String()};
  }
}

void addReminder(Reminder reminder) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Reminder> cachedReminderList = prefs
          .getStringList('reminder_list')
          ?.map((reminder) => Reminder.fromJson(jsonDecode(reminder)))
          .toList() ??
      [];
  cachedReminderList.add(reminder);
  prefs.setStringList(
      'reminder_list',
      cachedReminderList
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList());
  _scheduleNotification(reminder);
}

Future<void> _scheduleNotification(Reminder newReminder) async {
  // flutter_local_notificationsの初期化
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final initializationSettingsIOS = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  _flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    // 通知をタップしたときの処理
  });

  // タイムゾーンの初期化
  tz.initializeTimeZones();
  final scheduledDate = tz.TZDateTime.from(newReminder.dateTime, tz.local);

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'reminders_channel_id',
    'Reminders',
    channelDescription: 'Reminders notifications channel',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await _flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Reminder',
    newReminder.title,
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

void updateReminder(int id, Reminder updatedReminder) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Reminder> cachedReminderList = prefs
          .getStringList('reminder_list')
          ?.map((reminder) => Reminder.fromJson(jsonDecode(reminder)))
          .toList() ??
      [];

  // 指定されたIDに一致するリマインダーを検索して更新
  for (int i = 0; i < cachedReminderList.length; i++) {
    if (cachedReminderList[i].id == id) {
      cachedReminderList[i] = updatedReminder;
      break;
    }
  }

  // 更新されたリマインダーリストを保存
  prefs.setStringList(
      'reminder_list',
      cachedReminderList
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList());

  // 通知も更新
  await _updateNotification(id, updatedReminder);
}

Future<void> _updateNotification(int id, Reminder updatedReminder) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 更新する通知をキャンセル
  await flutterLocalNotificationsPlugin.cancel(id);

  // 新しい日時で通知を再スケジュール
  final scheduledDate = tz.TZDateTime.from(updatedReminder.dateTime, tz.local);
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'reminders_channel_id',
    'Reminders',
    channelDescription: 'Reminders notifications channel',
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Reminder',
    updatedReminder.title,
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

void deleteReminder(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<Reminder> cachedReminderList = prefs
          .getStringList('reminder_list')
          ?.map((reminder) => Reminder.fromJson(jsonDecode(reminder)))
          .toList() ??
      [];

  // 指定されたIDに一致するリマインダーを削除
  cachedReminderList.removeWhere((reminder) => reminder.id == id);

  // 更新されたリマインダーリストを保存
  prefs.setStringList(
      'reminder_list',
      cachedReminderList
          .map((reminder) => jsonEncode(reminder.toJson()))
          .toList());

  // 通知も削除
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.cancel(id);
}

void deleteAllReminders() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // 全てのリマインダーを削除
  prefs.remove('reminder_list');

  // 全ての通知も削除
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.cancelAll();
}
