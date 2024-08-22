import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 1.0,
        widthFactor: 1.0,
        alignment: Alignment.center,
        child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Image.asset("assets/images/logo.png")),
      ),
    );
  }
}
