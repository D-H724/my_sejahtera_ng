import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzd;
import 'package:timezone/timezone.dart' as tzt;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzd.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Note: Request permissions for iOS separately in main.dart or here
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsDarwin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Set default time zone for Malaysia
    try {
      tzt.setLocalLocation(tzt.getLocation('Asia/Kuala_Lumpur'));
    } catch (e) {
      debugPrint("Timezone Error: $e");
      // Fallback to UTC if something goes wrong
      tzt.setLocalLocation(tzt.getLocation('UTC'));
    }

    // Create the channel on the device (Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel_v5', // id forced update
      'Medication Reminders', // title
      description: 'Critical reminders to take your medication', // description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
       final androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
       await androidImplementation?.requestNotificationsPermission();
       await androidImplementation?.requestExactAlarmsPermission(); 
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
       await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
         alert: true,
         badge: true,
         sound: true,
       );
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    final tzt.TZDateTime scheduledDate = _nextInstanceOfTime(time);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel_v5',
      'Medication Reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    // Ensure iOS notifications show up in foreground
    const DarwinNotificationDetails iosPlatformChannelSpecifics = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    debugPrint("✅ Scheduled Notification [$id] '$title' at $scheduledDate (Local)");
  }

  Future<void> scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    // Safety Check: Ensure Timezone is initialized
    try {
      tzt.TZDateTime.now(tzt.local);
    } catch (e) {
      debugPrint("⚠️ Timezone not initialized. Re-initializing...");
       tzd.initializeTimeZones();
       try {
         tzt.setLocalLocation(tzt.getLocation('Asia/Kuala_Lumpur'));
       } catch (_) {
         tzt.setLocalLocation(tzt.getLocation('UTC'));
       }
    }

    // Robust Timezone Handling for Relative Timers:
    // Calculate the duration from "device now" to "target time"
    final Duration offset = time.difference(DateTime.now());
    
    // Apply that duration to the "notification timezone now"
    final tzt.TZDateTime scheduledDate = tzt.TZDateTime.now(tzt.local).add(offset);
    // DEBUG: Immediate confirmation that logic reached here
    await showNotification(
      id: id + 99999, // Offset ID to avoid conflict
      title: "Timer Started ⏱️", 
      body: "Will ring at ${DateFormat.jm().format(scheduledDate)}",
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel_v5', // Use v5
      'Medication Reminders',
      channelDescription: 'Reminders to take your medication',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosPlatformChannelSpecifics = 
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // If time is in the past (e.g. user selected 1 min ago), schedule for now + 5 seconds
    if (scheduledDate.isBefore(tzt.TZDateTime.now(tzt.local))) {
        debugPrint("⚠️ Scheduled time $scheduledDate is in the past. Current time: ${tzt.TZDateTime.now(tzt.local)}. Scheduling for 5 seconds from now.");
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzt.TZDateTime.now(tzt.local).add(const Duration(seconds: 5)),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        return;
    }

    // Force AlarmClock mode for critical medication reminders (guaranteed to ring)
    // Force AlarmClock mode for critical medication reminders (guaranteed to ring)
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.alarmClock, // Ensure it wakes up device
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null, 
      );
      debugPrint("✅ Scheduled Critical Alarm [$id] '$title' at $scheduledDate (Now: ${tzt.TZDateTime.now(tzt.local)})");
    } catch (e) {
      debugPrint("❌ Error scheduling alarm: $e");
      // Fallback: Show immediate notification if scheduling fails
      await showNotification(
        id: id, 
        title: "Timer Error (Fallback)", 
        body: "Could not schedule exact alarm. Verify permissions in settings."
      );
    }
  }

  tzt.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tzt.TZDateTime now = tzt.TZDateTime.now(tzt.local);
    tzt.TZDateTime scheduledDate = tzt.TZDateTime(
        tzt.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
    
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel_v5',
      'Medication Reminders',
      channelDescription: 'test channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(id, title, body, details, payload: payload);
  }
}
