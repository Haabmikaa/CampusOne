import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Request permissions for iOS/Android 13+
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(message);
      }
    });
  }

  static Future<void> updateToken(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        await userRef.update({
          'fcmToken': token,
        });
        await FirebaseMessaging.instance.subscribeToTopic('all');
        await FirebaseMessaging.instance.unsubscribeFromTopic('student');
        await FirebaseMessaging.instance.unsubscribeFromTopic('staff');

        final userSnap = await userRef.get();
        final role = userSnap.data()?['role']?.toString();
        if (role == 'student') {
          await FirebaseMessaging.instance.subscribeToTopic('student');
        } else if (role == 'staff' || role == 'lecturer') {
          await FirebaseMessaging.instance.subscribeToTopic('staff');
        }
      }
    } catch (e) {
      // Ignored if user doc doesn't exist or permissions denied
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'campus_one_channel',
      'CampusOne Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }
}
