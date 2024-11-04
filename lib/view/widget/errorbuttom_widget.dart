import 'package:flutter/material.dart';
import 'package:satoshi/view/widget/button_widget.dart';

class ErrorBottomSheet extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorBottomSheet({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Connection error. Please check your internet and try again.',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ButtonWidget(
            text: "Retry",
            onTap: onRetry,
            textcolor: const Color(0xFF000000),
            backcolor: const Color(0xFFBFA573),
            width: 150,
            radiuscolor: const Color(0xFFFFFFFF),
            fontsize: 16,
            radius: 5,
          ),
        ],
      ),
    );
  }
}
