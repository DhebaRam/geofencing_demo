// Flutter imports:

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_map_task/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


  static Future<void> requestNotificationPermission() async {
    // Check if permission is granted
    if (await Permission.notification.isGranted) {
      debugPrint("Notification permission already granted.");
    } else {
      // Request permission
      final status = await Permission.notification.request();

      if (status.isGranted) {
        debugPrint("Notification permission granted.");
      } else if (status.isDenied) {
        debugPrint("Notification permission denied.");
      } else if (status.isPermanentlyDenied) {
        debugPrint("Notification permission permanently denied. Open settings.");
        await openAppSettings();
      }
    }
  }

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings());
    _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {});
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void normaldisplay(int id, String title, String body, context) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = const NotificationDetails(
          android: AndroidNotificationDetails(
            "Car Service",
            "carservicechannel",
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails());

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );
      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
              iOS: DarwinInitializationSettings());
      _notificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (payload) async {});
    } on Exception catch (e) {
      safePrint(e.toString());
    }
  }
}
