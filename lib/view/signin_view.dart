import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() {
    return _SigninViewState();
  }
}

class _SigninViewState extends State<SigninView> {
  final GlobalKey<FormState> _signinFormKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  bool _passwordVisible = false;
  bool _emailerror = false;
  bool _haserror = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? validateEmail(String? email) {
    dynamic isValid = EmailValidator.validate('$email');

    // Navigator.pop(context);
    if (email == null || email.isEmpty) {
      setState(() {
        _emailerror = true;
      });
      return "Please enter your email";
    }

    if (!isValid) {
      setState(() {
        _emailerror = true;
      });
      return "Please enter a valid email";
    }

    return null;
  }

  Future<void> _launchURL() async {
    String url = "";
    url = '$urlbase/member/auth/register';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 3.w),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Form(
                key: _signinFormKey,
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: "LOGIN",
                            fontsize: 32,
                          ),
                          TextWidget(
                            text: "Please login to continue",
                            fontsize: 16,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 100.w,
                    height: (_haserror) ? 38.h : 35.h,
                    decoration: BoxDecoration(
                      color: const Color(0x4ACCB78F), // Background color
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.h, vertical: 3.h),
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: 75.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const TextWidget(
                                text: "Email Address",
                                fontsize: 12,
                              ),
                              SizedBox(height: 0.5.h),
                              SizedBox(
                                height: (_emailerror) ? 10.h : 6.h,
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  controller: _emailTextController,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.visibility,
                                          color:
                                              Color.fromARGB(0, 255, 255, 255),
                                          size: 12,
                                        ),
                                        onPressed: () {}),
                                    fillColor: Colors.white,
                                    isDense: true,
                                    prefixIconColor: Colors.white,
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFFBFA573), width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFBFA573), width: 1.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          3.0, // Control the height of the input field
                                      horizontal: 20.0,
                                    ),
                                    hintStyle: const TextStyle(
                                        fontSize: 10,
                                        color:
                                            Color.fromRGBO(163, 163, 163, 1)),
                                    hintText: 'Enter your email address',
                                  ),
                                  validator: validateEmail,
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              const TextWidget(
                                text: "Password",
                                fontsize: 12,
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                height: (_haserror) ? 10.h : 6.h,
                                child: TextFormField(
                                  controller: _passwordTextController,
                                  obscureText: !_passwordVisible,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _passwordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0xFFFFFFFF),
                                          size: 14,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        }),
                                    isDense: true,
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xFFBFA573), width: 1.0),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFBFA573), width: 1.0),
                                    ),
                                    hintStyle: const TextStyle(
                                        fontSize: 10,
                                        color:
                                            Color.fromRGBO(163, 163, 163, 1)),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical:
                                          3.0, // Control the height of the input field
                                      horizontal: 20.0,
                                    ),
                                    hintText: 'Enter your Password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      setState(() {
                                        _haserror = true;
                                      });
                                      return "Please enter your password";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Forgot password? ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(fontSize: 12),
                                      ),
                                      TextSpan(
                                        text: 'Reset',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Get.toNamed(
                                                "/front-screen/forgot-password");
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  ButtonWidget(
                      text: "Login",
                      onTap: () async {
                        showLoaderDialog(context);
                        if (!_signinFormKey.currentState!.validate()) {
                          Navigator.pop(context);
                        }
                        if (_signinFormKey.currentState!.validate()) {
                          Map<String, dynamic> mdata;
                          mdata = {
                            'email': _emailTextController.text,
                            'password': sha1
                                .convert(
                                    utf8.encode(_passwordTextController.text))
                                .toString(),
                          };
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          var url = Uri.parse("$urlapi/auth/signin");
                          log(url.toString());
                          await satoshiAPI(url, jsonEncode(mdata)).then((ress) {
                            var result = jsonDecode(ress);
                            log("100-" + result.toString());
                            if ((result['code'] == "200") &&
                                (result["message"]["role"] == "member")) {
                              prefs.setString(
                                  "email", _emailTextController.text);
                              prefs.setString(
                                  "password",
                                  sha1
                                      .convert(utf8
                                          .encode(_passwordTextController.text))
                                      .toString());
                              prefs.setString("refcode",
                                  result["message"]["refcode"] ?? "");
                              prefs.setString("id", result["message"]["id"]);
                              prefs.setString("end_date",
                                  result["message"]["end_date"] ?? "");
                              prefs.setString('period',
                                  result["message"]["total_period"] ?? '0');
                              prefs.setString("id_referral",
                                  result["message"]["id_referral"] ?? "");
                              prefs.setString(
                                  "role", result["message"]["role"]);
                              prefs.setString("membership",
                                  result["message"]["membership"]);
                              if (result["message"]["membership"] ==
                                  "expired") {
                                if (Platform.isAndroid) {
                                  Get.toNamed("/front-screen/subscribe",
                                      arguments: [
                                        {
                                          "email": _emailTextController.text,
                                        },
                                      ]);
                                }
                                if (Platform.isIOS) {
                                  Get.toNamed("/front-screen/inapp",
                                      arguments: [
                                        {
                                          "email": _emailTextController.text,
                                        },
                                      ]);
                                }
                              } else {
                                Get.toNamed("/front-screen/home");
                              }
                              _signinFormKey.currentState?.reset();
                              _emailTextController.clear();
                              _passwordTextController.clear();
                            } else {
                              var psnerr = result['message'];
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              showAlert(psnerr, context);
                            }
                          }).catchError((err) {
                            log("100-" + err.toString());
                            Navigator.pop(context);
                            showAlert(
                              "Something Wrong, Please Contact Administrator",
                              context,
                            );
                          });
                        }
                      },
                      textcolor: const Color(0xFF000000),
                      backcolor: const Color(0xFFBFA573),
                      width: 150,
                      radiuscolor: const Color(0xFFFFFFFF),
                      fontsize: 16,
                      radius: 5),
                  SizedBox(height: 8.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 12),
                        ),
                        TextSpan(
                          text: 'Register',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed("/front-screen/register");
                            },
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ));
  }
}
