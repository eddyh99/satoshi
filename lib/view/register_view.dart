import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() {
    return _RegisterViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _password2TextController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _passwordVisible = false;
  bool _password2Visible = false;
  bool agreement = false;

  late String _password;
  double _strength = 0;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");
  RegExp charReg = RegExp(r".*[!@#$%^&*()].*");

  void _checkPassword(String value) {
    _password = value.trim();

    if (_password.isEmpty) {
      setState(() {
        _strength = 0;
      });
    } else if (_password.length < 8) {
      setState(() {
        _strength = 1 / 4;
      });
    } else if (!charReg.hasMatch(_password)) {
      setState(() {
        _strength = 2 / 4;
      });
    } else {
      if (!letterReg.hasMatch(_password) || !numReg.hasMatch(_password)) {
        setState(() {
          // Password length >= 8
          // But doesn't contain both letter and digit characters
          _strength = 3 / 4;
        });
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        setState(() {
          _strength = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 3.w),
        child: Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Column(children: [
                          const Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: "REGISTER",
                                    fontsize: 32,
                                  ),
                                  TextWidget(
                                    text: "Please register to continue",
                                    fontsize: 16,
                                  )
                                ],
                              )),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                              width: 100.w,
                              height: 75.h,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0x4ACCB78F), // Background color
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                              ),
                              child: Form(
                                  key: _signupFormKey,
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 3.h, vertical: 3.h),
                                      child: SizedBox(
                                          width: 75.w,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const TextWidget(
                                                text: "Email Address",
                                                fontsize: 12,
                                              ),
                                              SizedBox(height: 0.5.h),
                                              TextFormField(
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                                controller:
                                                    _emailTextController,
                                                maxLines: 1,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                  prefixIconColor: Colors.white,
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                  ),
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color.fromRGBO(
                                                          163, 163, 163, 1)),
                                                  hintText:
                                                      'Enter your email address',
                                                ),
                                                validator: validateEmail,
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              const TextWidget(
                                                text: "Password",
                                                fontsize: 12,
                                              ),
                                              SizedBox(height: 1.h),
                                              TextFormField(
                                                controller:
                                                    _passwordTextController,
                                                obscureText: !_passwordVisible,
                                                maxLines: 1,
                                                keyboardType:
                                                    TextInputType.text,
                                                onChanged: (value) =>
                                                    _checkPassword(value),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                      icon: Icon(
                                                        // Based on passwordVisible state choose the icon
                                                        _passwordVisible
                                                            ? Icons.visibility
                                                            : Icons
                                                                .visibility_off,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                      onPressed: () {
                                                        // Update the state i.e. toogle the state of passwordVisible variable
                                                        setState(() {
                                                          _passwordVisible =
                                                              !_passwordVisible;
                                                        });
                                                      }),
                                                  isDense: true,
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                  ),
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color.fromRGBO(
                                                          163, 163, 163, 1)),
                                                  hintText:
                                                      'Enter your Password',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please enter your password";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              const TextWidget(
                                                text: "Password",
                                                fontsize: 12,
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              TextFormField(
                                                controller:
                                                    _password2TextController,
                                                // onChanged: (value) => _checkPassword(value),
                                                obscureText: !_password2Visible,
                                                maxLines: 1,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  suffixIcon: IconButton(
                                                      icon: Icon(
                                                        // Based on passwordVisible state choose the icon
                                                        _password2Visible
                                                            ? Icons.visibility
                                                            : Icons
                                                                .visibility_off,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      onPressed: () {
                                                        // Update the state i.e. toogle the state of passwordVisible variable
                                                        setState(() {
                                                          _password2Visible =
                                                              !_password2Visible;
                                                        });
                                                      }),
                                                  isDense: true,
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          bottom: 11,
                                                          right: 13,
                                                          top: 11),
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color.fromRGBO(
                                                          163, 163, 163, 1)),
                                                  hintText: 'repeat password',
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please enter your confirm password";
                                                  }
                                                  if (value !=
                                                      _passwordTextController
                                                          .text) {
                                                    return "Password doesn't match";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(
                                                height: 2.h,
                                              ),
                                              SizedBox(
                                                width: 80.w,
                                                child: LinearProgressIndicator(
                                                  value: _strength,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  color: _strength <= 1 / 4
                                                      ? Colors.red
                                                      : _strength == 2 / 4
                                                          ? Colors.yellow
                                                          : _strength == 3 / 4
                                                              ? Colors.blue
                                                              : Colors.green,
                                                  minHeight: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              SizedBox(
                                                width: 80.w,
                                                child: const TextWidget(
                                                  text:
                                                      "Use 8 or more characters with a mix of letters, numbers & symbols.",
                                                  fontsize: 10,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              const TextWidget(
                                                text: "Referral (Optional)",
                                                fontsize: 12,
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              TextFormField(
                                                controller:
                                                    _password2TextController,
                                                // onChanged: (value) => _checkPassword(value),
                                                maxLines: 1,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  errorBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    borderSide:
                                                        const BorderSide(
                                                            color: Color(
                                                                0xFFBFA573),
                                                            width: 1.0),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          bottom: 11,
                                                          right: 13,
                                                          top: 11),
                                                  hintStyle: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color.fromRGBO(
                                                          163, 163, 163, 1)),
                                                  hintText:
                                                      'Enter your Referral',
                                                ),
                                              ),
                                              SizedBox(
                                                width: 100.w,
                                                child: Column(
                                                  children: [
                                                    Center(
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Checkbox(
                                                            value: agreement,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                agreement =
                                                                    value!;
                                                              });
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          const TextWidget(
                                                            text:
                                                                "I agree with Terms and Privacy",
                                                            fontsize: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    ButtonWidget(
                                                      text: "Continue",
                                                      onTap: () {
                                                        Get.toNamed(
                                                            "/front-screen/subscribe");
                                                      },
                                                      textcolor: const Color(
                                                          0xFF000000),
                                                      backcolor: const Color(
                                                          0xFFBFA573),
                                                      width: 150,
                                                      radiuscolor: const Color(
                                                          0xFFFFFFFF),
                                                      fontsize: 16,
                                                      radius: 5,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ))))),
                          SizedBox(height: 3.h),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 12),
                            ),
                            TextSpan(
                              text: 'Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed("/front-screen/login");
                                },
                            ),
                          ]))
                        ]))))));
  }
}
