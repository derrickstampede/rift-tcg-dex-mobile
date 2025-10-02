import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _requestPermission();
      await _setupMessageHandlers();

      try {
        final token = await FirebaseMessaging.instance.getToken();
        // final token =
        //     Platform.isIOS ? await FirebaseMessaging.instance.getAPNSToken() : await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');
      } catch (e) {
        print('Failed to get FCM token: $e');
        // Continue app execution even if token retrieval fails
      }
    } catch (e) {
      print('Error initializing notification service: $e');
      // Allow app to continue even if notification setup fails
    }
  }

  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isInitialized) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Important Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    

    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification here if needed
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {});

    _isInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Important Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            )),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    // foreground message
    FirebaseMessaging.onMessage.listen((message) async {
      print('foreground message');
      print('onMessage: $message');
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('foreground message');
      print('onMessage: $message');
      // showNotification(message);
    });

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // showNotification(initialMessage);
    }
  }
}
