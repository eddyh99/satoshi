import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
import 'package:satoshi/view/landing_view.dart';
import 'package:satoshi/view/member/history_view.dart';
import 'package:satoshi/view/member/home_view.dart';
import 'package:satoshi/view/member/language_view.dart';
import 'package:satoshi/view/member/message_view.dart';
import 'package:satoshi/view/member/setting_view.dart';
import 'package:satoshi/view/register_view.dart';
import 'package:satoshi/view/signin_view.dart';
import 'package:satoshi/view/splashscreen.dart';
import 'package:satoshi/view/subscribe_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Firebase (for Android/iOS)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDb3qJmaBk2Q2tK3sUeQWPZAfCnFORLLtM',
      appId: '1:167593974745:android:71382cf6fa39b97507d7c8',
      messagingSenderId: '167593974745',
      projectId: 'satoshi-signal',
      storageBucket: 'satoshi-signal.appspot.com',
    ),
  );

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Background messaging handler setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Run the app
  runApp(const MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
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
            name: '/front-screen/subscribe',
            page: () => const SubscribeView(),
            transition: Transition.rightToLeft,
          ),
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
