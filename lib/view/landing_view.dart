import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/view/widget/button_widget.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() {
    return _LandingViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: 10.w),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to",
                      style: GoogleFonts.lato(
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Text(
                      "SATOSHI SIGNAL",
                      style: GoogleFonts.lato(
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 36),
                      ),
                    )
                  ],
                )),
            SizedBox(
              height: 10.h,
            ),
            const Image(
              image: AssetImage('assets/images/logo.png'),
              width: 186,
              height: 210,
            ),
            SizedBox(
              height: 10.h,
            ),
            ButtonWidget(
              text: "Login",
              onTap: () {
                Get.toNamed("/front-screen/login");
              },
              textcolor: const Color(0xFFB48B3D),
              backcolor: const Color(0xFFFFFFFF),
              width: 50.w,
              radiuscolor: const Color(0xFFB48B3D),
              fontsize: 16,
              radius: 30,
            ),
            SizedBox(
              height: 1.h,
            ),
            ButtonWidget(
              text: "Register",
              onTap: () {
                Get.toNamed("/front-screen/register");
              },
              textcolor: const Color(0xFFFFFFFF),
              backcolor: const Color(0x00000000),
              width: 50.w,
              radiuscolor: const Color(0xFFB48B3D),
              fontsize: 16,
              radius: 30,
            )
          ],
        )),
      ),
    );
  }
}
