import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() {
    return _LandingViewState();
  }
}

class _LandingViewState extends State<LandingView> {
  Future<dynamic> getPrefer() async {
    final navigator = Navigator.of(context);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? getEmail = prefs.getString("email");
    String? password = prefs.getString("password");
    if (getEmail != null) {
      Map<String, dynamic> mdata;
      mdata = {'email': getEmail, 'password': password};
      var url = Uri.parse("$urlapi/auth/signin");
      await satoshiAPI(url, jsonEncode(mdata)).then((ress) {
        var result = jsonDecode(ress);
        log(result.toString());

        if ((result['code'] == "200") &&
            (result["message"]["role"] == "member")) {
          prefs.setString("id", result["message"]["id"]);
          prefs.setString("end_date", result["message"]["end_date"]);
          prefs.setString('period', result["message"]["total_period"]);
          prefs.setString(
              "id_referral", result["message"]["id_referral"] ?? "");
          prefs.setString("role", result["message"]["role"]);
          prefs.setString("membership", result["message"]["membership"]);
          if (result["message"]["membership"] == "expired") {
            Get.toNamed("/front-screen/subscribe");
          } else {
            Get.toNamed("/front-screen/home");
          }
        } else {
          var psnerr = result['message'];
          navigator.pop();
          showAlert(psnerr, context);
        }
      }).catchError((err) {
        navigator.pop();
        showAlert(
          "Something Wrong, Please Contact Administrator",
          context,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPrefer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchURL() async {
    String url = "";
    url = 'https://pnglobalinternational.com/member/auth/register';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
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
              image: AssetImage('assets/images/logo-satoshi.png'),
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
