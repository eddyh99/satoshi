import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color textcolor;
  final Color backcolor;
  final Color radiuscolor;
  final double width;
  final double fontsize;
  final double radius;
  final dynamic onTap;
  const ButtonWidget(
      {super.key,
      required this.text,
      required this.onTap,
      required this.textcolor,
      required this.backcolor,
      required this.width,
      required this.radiuscolor,
      required this.fontsize,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: backcolor, // Background color of the button
            foregroundColor: textcolor, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius), // Elliptical shape
              side: BorderSide(
                color: radiuscolor, // Border color
                width: 1.0, // Border width
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 40.0, vertical: 8.0), // Adjust padding
          ),
          child: Text(
            text,
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: fontsize),
            ),
          ),
        ));
  }
}
