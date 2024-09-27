import 'dart:developer';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Satoshinav extends StatelessWidget {
  const Satoshinav({super.key, this.number});

  final number;

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
              icon: number == 0
                  ? const ImageIcon(AssetImage('assets/images/signal.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/signal.png'),
                      color: Colors.white, // Inactive color
                    )),
          TabItem(
              title: 'History',
              icon: number == 1
                  ? const ImageIcon(AssetImage('assets/images/history.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/history.png'),
                      color: Colors.white, // Inactive color
                    )),
          TabItem(
              title: 'Message',
              icon: number == 2
                  ? const ImageIcon(AssetImage('assets/images/message.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/message.png'),
                      color: Colors.white, // Inactive color
                    )),
          TabItem(
              title: 'Settings',
              icon: number == 3
                  ? const ImageIcon(AssetImage('assets/images/setting.png'),
                      color: Color(0xFFB48B3D) // Active color
                      )
                  : const ImageIcon(
                      AssetImage('assets/images/setting.png'),
                      color: Colors.white, // Inactive color
                    )),
        ],
        initialActiveIndex: number,
        onTap: (int i) => {
              if (i == 0)
                {Get.toNamed("/front-screen/home")}
              else if (i == 1)
                {Get.toNamed("/front-screen/history")}
              else if (i == 2)
                {Get.toNamed("/front-screen/message")}
              else if (i == 3)
                {Get.toNamed("/front-screen/setting")}
            });
  }
}
