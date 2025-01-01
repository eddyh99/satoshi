import 'dart:developer';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/main.dart';
import 'package:satoshi/utils/event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Satoshinav extends StatefulWidget {
  final int number;
  const Satoshinav({super.key, required this.number});

  @override
  State<Satoshinav> createState() {
    return _SatoshinavState();
  }
}

class _SatoshinavState extends State<Satoshinav> {
  bool hasNewMessage = false;
  bool hasNewSignal = false;

  @override
  void initState() {
    super.initState();
    eventBus.on<ReloadBadgeEvent>().listen((event) {
      _refreshBadges(); // Refresh badges when ReloadBadgeEvent is triggered
    });
    appLifecycleNotifier.addListener(_handleAppLifecycleChange);

    // Initial badge status check
    _refreshBadges();
  }

  void _handleAppLifecycleChange() {
    if (appLifecycleNotifier.value == AppLifecycleState.resumed) {
      // Refresh badge data when app resumes
      _refreshBadges();
    }
  }

  Future<void> _refreshBadges() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasNewMessage = prefs.getBool('hasNewMessage') ?? false;
      log("on nav hasnewmessage : $hasNewMessage");
      hasNewSignal = prefs.getBool('hasNewSignal') ?? false;
    });
  }

  // Handle navigation when a tab is tapped
  void _onTabSelected(int index) {
    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Get.toNamed("/front-screen/home");
        setState(() {
          hasNewSignal = false;
        });
        break;
      case 1:
        Get.toNamed("/front-screen/history");
        break;
      case 2:
        Get.toNamed("/front-screen/message");
        setState(() {
          hasNewMessage = false;
        });
        log("message is tapped : $hasNewMessage");
        break;
      case 3:
        Get.toNamed("/front-screen/setting");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.react,
      activeColor: const Color(0xFFB48B3D),
      backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
      items: [
        TabItem(
          title: 'Signal',
          icon: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              widget.number == 0
                  ? const ImageIcon(
                      AssetImage('assets/images/signal.png'),
                      color: Color(0xFFB48B3D),
                    )
                  : const ImageIcon(
                      AssetImage('assets/images/signal.png'),
                      color: Colors.white,
                    ),
              (hasNewSignal)
                  ? Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
        TabItem(
          title: 'History',
          icon: widget.number == 1
              ? const ImageIcon(AssetImage('assets/images/history.png'),
                  color: Color(0xFFB48B3D))
              : const ImageIcon(AssetImage('assets/images/history.png'),
                  color: Colors.white),
        ),
        TabItem(
          title: 'Message',
          icon: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              widget.number == 2
                  ? const ImageIcon(
                      AssetImage('assets/images/message.png'),
                      color: Color(0xFFB48B3D),
                    )
                  : const ImageIcon(
                      AssetImage('assets/images/message.png'),
                      color: Colors.white,
                    ),
              (hasNewMessage)
                  ? Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
        TabItem(
          title: 'Settings',
          icon: widget.number == 3
              ? const ImageIcon(AssetImage('assets/images/setting.png'),
                  color: Color(0xFFB48B3D))
              : const ImageIcon(AssetImage('assets/images/setting.png'),
                  color: Colors.white),
        ),
      ],
      initialActiveIndex: widget.number,
      onTap: _onTabSelected,
    );
  }
}
