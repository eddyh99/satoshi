import 'dart:developer';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:satoshi/utils/event_bus.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
import 'package:satoshi/utils/vibration_worker.dart';
import 'package:satoshi/view/confirmation_view.dart';
import 'package:satoshi/view/forgot_pass/forgotpass_view.dart';
import 'package:satoshi/view/forgot_pass/newpass_view.dart';
import 'package:satoshi/view/landing_view.dart';
import 'package:satoshi/view/member/history_view.dart';
import 'package:satoshi/view/member/home_view.dart';
import 'package:satoshi/view/member/language_view.dart';
import 'package:satoshi/view/member/message_view.dart';
import 'package:satoshi/view/member/setting_view.dart';
import 'package:satoshi/view/member/upgrade_view.dart';
import 'package:satoshi/view/register_view.dart';
import 'package:satoshi/view/signin_view.dart';
import 'package:satoshi/view/splashscreen.dart';
import 'package:satoshi/view/subscribe_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
//import 'package:workmanager/workmanager.dart';

final appLifecycleNotifier =
    ValueNotifier<AppLifecycleState>(AppLifecycleState.resumed);

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    appLifecycleNotifier.value =
        state; // Notify listeners about lifecycle changes
    log("App Lifecycle State: $state");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Workmanager().initialize(callbackDispatcher);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase Initialization
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDb3qJmaBk2Q2tK3sUeQWPZAfCnFORLLtM',
        appId: '1:167593974745:android:71382cf6fa39b97507d7c8',
        messagingSenderId: '167593974745',
        projectId: 'satoshi-signal',
        storageBucket: 'satoshi-signal.appspot.com',
      ),
    );
  } else if (Platform.isIOS) {
    await Firebase.initializeApp();
  }

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await requestNotificationPermission();
  // Schedule an alarm
  // Run the app
  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
  log('Message data: ${message.data}');

  // Ensure SharedPreferences is initialized
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isVibrationEnabled = prefs.getBool('vibration') ?? true;

  log("vibration: $isVibrationEnabled");
  final Uri uri = Uri.parse(message.data['link'] ?? '');
  if (uri.scheme == 'satoshi') {
    if (uri.host == 'message') {
      await prefs.setBool('hasNewMessage', true); // Update preference
      bool isi = prefs.getBool("hasNewMessage") ?? false;

      log('Background: hasNewMessage set to $isi');

      if (isVibrationEnabled) {
        // Register a one-off task to trigger vibration
        Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
      }
      eventBus.fire(ReloadBadgeEvent());
    } else if (uri.host == 'signal') {
      await prefs.setBool('hasNewSignal', true); // Update preference
      log('Background: hasNewSignal set to true');

      // Register a one-off task to trigger vibration
      Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
      eventBus.fire(ReloadBadgeEvent());
    }
  }
}

class NoGlowScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Satoshi Signal',
        scrollBehavior: NoGlowScrollBehavior(),
        initialRoute: '/',
        smartManagement: SmartManagement.full,
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(displayColor: Colors.white),
        ),
        getPages: [
          GetPage(
            name: '/',
            page: () => const MainApp(),
          ),
          GetPage(
            name: '/front-screen/landing',
            page: () => const LandingView(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/front-screen/login',
            page: () => const SigninView(),
            transition: Transition.noTransition,
          ),
          GetPage(
            name: '/front-screen/register',
            page: () => const RegisterView(),
            transition: Transition.noTransition,
          ),
          GetPage(
            name: '/front-screen/confirm',
            page: () => const ConfirmationView(),
            transition: Transition.noTransition,
          ),
          GetPage(
            name: '/front-screen/subscribe',
            page: () => const SubscribeView(),
            transition: Transition.rightToLeft,
          ),
          // GetPage(
          //     name: '/front-screen/inapp',
          //     page: () => const InappView(),
          //     transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/home',
              page: () => const HomeView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/history',
              page: () => const HistoryView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/message',
              page: () => const MessageView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/setting',
              page: () => const SettingView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/language',
              page: () => const LanguageView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/upgrade-plan',
              page: () => const UpgradeView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/forgot-password',
              page: () => const ForgotpassView(),
              transition: Transition.fadeIn),
          GetPage(
              name: '/front-screen/new-password',
              page: () => const NewpassView(),
              transition: Transition.fadeIn),
        ]);
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessagingService().initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(seconds: 3), () {
        Get.offNamed('/front-screen/landing');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashScreen(),
    );
  }
}
