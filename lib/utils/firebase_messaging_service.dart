import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:satoshi/utils/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void initialize() async {
    // Request permissions for iOS devices and initialize local notifications
    _requestPermission();

    // Initialize local notifications
    initializeLocalNotifications();

    // Create the default notification channel once
    final prefs = await SharedPreferences.getInstance();
    final isSoundEnabled = prefs.getBool('sound') ?? true;
    final isVibrationEnabled = prefs.getBool('vibration') ?? true;
    await _createNotificationChannel(isSoundEnabled, isVibrationEnabled);

    log('Firebase Messaging Service Initialized');
    // Set up foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        final Uri uri = Uri.parse(message.data['link'] ?? '');
        if (uri.scheme == 'satoshi') {
          final prefs = await SharedPreferences.getInstance();

          if (uri.host == 'message') {
            await prefs.setBool('hasNewMessage', true);
            _showNotification(
                message.notification!.title ?? 'Message Notification',
                message.notification!.body ?? 'Check out Message!',
                'message');
            eventBus.fire(ReloadBadgeEvent());
            eventBus.fire(ReloadWebViewEvent());
          } else if (uri.host == 'signal') {
            await prefs.setBool('hasNewSignal', true);
            _showNotification(
                message.notification!.title ?? 'Signal Notification',
                message.notification!.body ?? 'Check out the signal!',
                'signal');
            eventBus.fire(ReloadBadgeEvent());
            eventBus.fire(ReloadSignalViewEvent());
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
          } else if (uri.host == 'message') {
            final String? messageId =
                uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
            if (messageId != null) {
              await prefs.setString('lastMessageId', messageId);
            }
            await prefs.setBool('hasNewMessage', true);
            Get.toNamed("/front-screen/message");
          }
        }
      }
    });
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

// Define the channel ID globally for reuse
  String messageChannelId = 'message_channel_id';
  String signalChannelId = 'signal_channel_id';

// Create channel during initialization
  Future<void> _createNotificationChannel(
      bool isSoundEnabled, bool isVibrationEnabled) async {
    AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
      messageChannelId,
      'Message Notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          'message'), // Reference sound without extension
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 2000]),
    );

    // Channel for signal notifications
    AndroidNotificationChannel signalChannel = AndroidNotificationChannel(
      signalChannelId,
      'Signal Notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
          'signal'), // Reference sound without extension
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 1000]),
    );

    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(messageChannel);
      await androidImplementation.createNotificationChannel(signalChannel);
    }
  }

  Future<void> _showNotification(String title, String body, String type) async {
    final prefs = await SharedPreferences.getInstance();
    final isSoundEnabled = prefs.getBool('sound') ?? true;
    final isVibrationEnabled = prefs.getBool('vibration') ?? true;

    // Use the pre-created channel
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      type == 'message' ? messageChannelId : signalChannelId,
      type == 'message' ? 'Message Notifications' : 'Signal Notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: isVibrationEnabled,
      showWhen: true,
      playSound: true,
      sound: isSoundEnabled
          ? RawResourceAndroidNotificationSound(
              type == 'message' ? 'message' : 'signal',
            )
          : null,
      vibrationPattern:
          isVibrationEnabled ? Int64List.fromList([0, 1000, 500, 2000]) : null,
    );

    DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: isSoundEnabled,
      sound: isSoundEnabled ? 'default' : null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
