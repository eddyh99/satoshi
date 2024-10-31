import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Image.asset(
              "assets/images/logo-satoshi.png",
              width: 186,
              height: 210,
              fit: BoxFit.contain,
            )),
      ),
    ));
  }
}
