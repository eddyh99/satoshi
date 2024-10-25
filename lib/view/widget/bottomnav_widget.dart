import 'dart:developer';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
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

  @override
  void initState() {
    super.initState();
    _checkNewMessageStatus();

    // Listen to the event bus for WebView reload and message updates
    eventBus.on<ReloadWebViewEvent>().listen((event) {
      _checkNewMessageStatus();  // Refresh message badge state
    });
  }

  // Check SharedPreferences to see if there's a new message
  Future<void> _checkNewMessageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool newMessage = prefs.getBool('hasNewMessage') ?? false;
    setState(() {
      hasNewMessage = newMessage;
    });
  }

  // Handle navigation tap
  void _onTabSelected(int index) {
    if (index == 2) {
      // If "Message" tab is tapped, clear the badge
      setState(() {
        hasNewMessage = false;
      });
      _clearNewMessageFlag();
    }

    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Get.toNamed("/front-screen/home");
        break;
      case 1:
        Get.toNamed("/front-screen/history");
        break;
      case 2:
        Get.toNamed("/front-screen/message");
        break;
      case 3:
        Get.toNamed("/front-screen/setting");
        break;
    }
  }

  // Clear new message flag in SharedPreferences
  Future<void> _clearNewMessageFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasNewMessage', false);
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
        style: TabStyle.react,
        activeColor: const Color(0xFFB48B3D),

        // cornerRadius: 20,
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
        items: [
          TabItem(
              title: 'Signal',
              icon: widget.number == 0
                  ? const ImageIcon(AssetImage('assets/images/signal.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/signal.png'),
                      color: Colors.white, // Inactive color
                    )),
          TabItem(
              title: 'History',
              icon: widget.number == 1
                  ? const ImageIcon(AssetImage('assets/images/history.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/history.png'),
                      color: Colors.white, // Inactive color
                    )),
          TabItem(
              title: 'Message',
              icon: Stack(
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
              if (hasNewMessage) // Show the red badge if there's a new message
                Positioned(
                  right: 0,
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
                ),
            ],
          )),
          TabItem(
              title: 'Settings',
              icon: widget.number == 3
                  ? const ImageIcon(AssetImage('assets/images/setting.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/setting.png'),
                      color: Colors.white, // Inactive color
                    )),
        ],
        initialActiveIndex: widget.number,
        onTap: _onTabSelected);
  }
}
