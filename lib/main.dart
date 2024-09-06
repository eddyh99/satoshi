import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satoshi/view/landing_view.dart';
import 'package:satoshi/view/member/history_view.dart';
import 'package:satoshi/view/member/home_view.dart';
import 'package:satoshi/view/member/setting_view.dart';
import 'package:satoshi/view/register_view.dart';
import 'package:satoshi/view/signin_view.dart';
import 'package:satoshi/view/splashscreen.dart';
import 'package:satoshi/view/subscribe_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
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

  // This widget is the root of your application.
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
              name: '/front-screen/setting',
              page: () => const SettingView(),
              transition: Transition.fadeIn)
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
