import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() {
    return _SigninViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _SigninViewState extends State<SigninView> {
  final GlobalKey<FormState> _signinFormKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  bool _rememberIsChecked = false;
  bool _passwordVisible = false;

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
        minimum: EdgeInsets.symmetric(horizontal: 3.w),
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    child: Column(children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
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
                          )),
                      SizedBox(
                        height: 10.h,
                      ),
                      Container(
                          width: 100.w,
                          height: 230,
                          decoration: BoxDecoration(
                            color: const Color(0x4ACCB78F), // Background color
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Form(
                              key: _signinFormKey,
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3.h, vertical: 3.h),
                                  child: SingleChildScrollView(
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
                                                    prefixIconColor:
                                                        Colors.white,
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
                                                              width: 0.0),
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
                                                  obscureText:
                                                      !_passwordVisible,
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
                                                  height: 1.h,
                                                ),
                                                Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                "Forgot password? ",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayLarge
                                                                ?.copyWith(
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                          TextSpan(
                                                            text: 'Reset',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .displayLarge
                                                                ?.copyWith(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                            recognizer:
                                                                TapGestureRecognizer()
                                                                  ..onTap = () {
                                                                    Get.toNamed(
                                                                        "/front-screen/register");
                                                                  },
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ])))))),
                      SizedBox(
                        height: 1.h,
                      ),
                      ButtonWidget(
                          text: "Login",
                          onTap: () => (),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed("/front-screen/register");
                                },
                            ),
                          ],
                        ),
                      ),
                    ])))));
  }
}
