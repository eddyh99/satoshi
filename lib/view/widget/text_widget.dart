import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double fontsize;
  const TextWidget({
    super.key,
    required this.text,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .displayLarge
          ?.copyWith(fontSize: fontsize),
    );
  }
}
