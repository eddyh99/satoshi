import 'dart:developer';
import 'dart:typed_data';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
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

// Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        final Uri uri = Uri.parse(message.data['link'] ?? '');
        if (uri.scheme == 'satoshi') {
          final prefs = await SharedPreferences.getInstance();

          if (uri.host == 'message') {
            await prefs.setBool('hasNewMessage', true);
            _showNotification(
              message.notification!.title ?? 'No Title',
              message.notification!.body ?? 'No Body',
            );
            eventBus.fire(ReloadWebViewEvent());
          } else if (uri.host == 'signal') {
            await prefs.setBool('hasNewSignal', true);
            _showNotification(
              message.notification!.title ?? 'Signal Notification',
              message.notification!.body ?? 'Check out the signal!',
            );
            eventBus.fire(ReloadWebViewEvent());
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final prefs = await SharedPreferences.getInstance();
      if (message.data['link'] != null) {
        final Uri uri = Uri.parse(message.data['link']);
        if (uri.scheme == 'satoshi') {
          if (uri.host == 'signal') {
            await prefs.setBool('hasNewSignal', true);
            Get.toNamed("/front-screen/home");
          } else {
            await prefs.setBool('hasNewMessage', true);
            Get.toNamed("/front-screen/message");
          }
        }
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
    final FirebaseMessagingService firebaseMessagingService =
        FirebaseMessagingService();

    if (message.notification != null) {
      final Uri uri = Uri.parse(message.data['link'] ?? '');
      if (uri.scheme == 'satoshi') {
        final prefs = await SharedPreferences.getInstance();

        if (uri.host == 'message') {
          await prefs.setBool('hasNewMessage', true);
          await firebaseMessagingService._showNotification(
            message.notification!.title ?? 'No Title',
            message.notification!.body ?? 'No Body',
          );
          eventBus.fire(ReloadWebViewEvent());
        } else if (uri.host == 'signal') {
          await prefs.setBool('hasNewSignal', true);
          await firebaseMessagingService._showNotification(
            message.notification!.title ?? 'No Title',
            message.notification!.body ?? 'No Body',
          );
          eventBus.fire(ReloadWebViewEvent());
        }
      }
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
  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Ensure you have a launcher icon

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(); // No need for onDidReceiveLocalNotification

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    log('Local notification plugin initialized');

    // Explicitly request notification permission on Android 13+ devices
    // Check and request notification permission on Android 13+
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        log('Notification permission granted on Android 13+');
      } else {
        log('Notification permission denied by the user');
        // Optionally show a dialog explaining why notifications are important
      }
    } else {
      log('Notification permission already granted');
    }
  }

  // Callback for iOS foreground notifications
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Handle iOS foreground notification
    print("Received iOS foreground notification: $title - $body");
  }

// Callback for general notification response
  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    // Handle notification response
    print("Notification tapped with payload: ${response.payload}");
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
      enableVibration: true,
      playSound: isSoundEnabled,
      sound: null,
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
    log("100-$isSoundEnabled");
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
      enableVibration: true,
      showWhen: true,
      playSound: true,
      sound: null,
      vibrationPattern:
          isVibrationEnabled ? Int64List.fromList([0, 1000, 500, 2000]) : null,
    );

    // iOS Notification Details
    // iOS/macOS Notification Details
    DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true, // Show alert
      presentBadge: true, // Display badge
      presentSound: isSoundEnabled, // Play sound
      sound: isSoundEnabled ? 'default' : null, // Custom sound or default
    );

    // Unified platform-specific notification details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS:
            iosPlatformChannelSpecifics); // Use DarwinNotificationDetails for iOS/macOS

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

class ReloadWebViewEvent {}
