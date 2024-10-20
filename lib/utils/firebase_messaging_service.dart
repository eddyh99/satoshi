import 'dart:developer';
import 'dart:typed_data';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

EventBus eventBus = EventBus();

class FirebaseMessagingService {
  // Singleton instance
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initialize() {
    // Initialize local notification for foreground messages
    initializeLocalNotifications();

    // Request permission for iOS devices
    _requestPermission();

    log('Firebase Messaging Service Initialized');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('Foreground message received: ${message.messageId}');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Notification Title: ${message.notification!.title}');
        log('Notification Body: ${message.notification!.body}');

        _showNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
        );
        eventBus.fire(ReloadWebViewEvent());
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    log('Handling background message: ${message.messageId}');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Background Notification Title: ${message.notification!.title}');
      log('Background Notification Body: ${message.notification!.body}');
      eventBus.fire(ReloadWebViewEvent()); // Trigger WebView reload event
    }
  }

  // Request permission for iOS devices
  void _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('Permission denied by the user');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted full permission');
    }
  }

  // Initialize local notifications (public method)
  void initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Ensure you have a launcher icon
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    log('Local notification plugin initialized');
  }

  Future<void> _createOrUpdateNotificationChannel(
      bool isSoundEnabled, bool isVibrationEnabled) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Delete the existing channel if it exists
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel('default_channel_id');

    // Create a new channel with updated settings
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel_id', // Channel ID
      'Default', // Channel name
      importance: Importance.max, // High importance
      enableVibration: isVibrationEnabled,
      playSound: isSoundEnabled,
      vibrationPattern: isVibrationEnabled
          ? Int64List.fromList([0, 1000, 500, 2000]) // Vibration pattern
          : null,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String> _createNotificationChannelWithUniqueId(
      bool isSoundEnabled, bool isVibrationEnabled) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Use a unique ID based on the timestamp
    String uniqueChannelId = 'channel_${DateTime.now().millisecondsSinceEpoch}';

    AndroidNotificationChannel channel = AndroidNotificationChannel(
      uniqueChannelId, // Dynamic Channel ID
      'Default', // Channel name
      importance: Importance.max,
      enableVibration: isVibrationEnabled,
      playSound: isSoundEnabled,
      vibrationPattern:
          isVibrationEnabled ? Int64List.fromList([0, 1000, 500, 2000]) : null,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    return uniqueChannelId; // Return the new channel ID
  }

  Future<void> _showNotification(String title, String body) async {
    // Fetch preferences dynamically
    final prefs = await SharedPreferences.getInstance();
    final isSoundEnabled = prefs.getBool('sound') ?? true;
    final isVibrationEnabled = prefs.getBool('vibration') ?? true;

    // Create a new notification channel with a unique ID
    String newChannelId = await _createNotificationChannelWithUniqueId(
        isSoundEnabled, isVibrationEnabled);

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      newChannelId, // Use the new unique channel ID
      'Default',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: isSoundEnabled,
      vibrationPattern:
          isVibrationEnabled ? Int64List.fromList([0, 1000, 500, 2000]) : null,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class ReloadWebViewEvent {}
