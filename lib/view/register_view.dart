import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
// import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  final TextEditingController _refTextController = TextEditingController();
  late final WebViewController wvcontroller;
  String _ipAddress = 'Fetching IP...';

  @override
  void initState() {
    super.initState();
     _getIPAddress(); 
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _passwordVisible = false;
  bool _password2Visible = false;
  bool agreement = false;
  bool _emailerror = false;
  bool _haserror = false;

  late String _password;
  double _strength = 0;
  dynamic _zone = 'hello';

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

  String? validateEmail(String? email) {
    dynamic isValid = EmailValidator.validate('$email');

    // Navigator.pop(context);
    if (email == null || email.isEmpty) {
      setState(() {
        _emailerror = true;
        _haserror = true;
      });
      return "Please enter your email";
    }

    if (!isValid) {
      setState(() {
        _emailerror = true;
        _haserror = true;
      });
      return "Please enter a valid email";
    }

    return null;
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
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TextWidget(
                            text: "REGISTER",
                            fontsize: 32,
                          ),
                          const TextWidget(
                            text: "Please register to continue",
                            fontsize: 16,
                          ),
                          TextWidget(
                            text: _zone,
                            fontsize: 16,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    width: 100.w,
                    height: (_haserror) ? 86.h : 70.h,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(101, 91, 70, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _signupFormKey,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.h, vertical: 3.h),
                        child: SizedBox(
                          width: 75.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
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
                                    errorMaxLines: 2,
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
                                          10.0, // Control the height of the input field
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
                                  onChanged: (value) => _checkPassword(value),
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
                                    if (_strength != 1) {
                                      setState(() {
                                        _haserror = true;
                                      });
                                      return "Your password must Unique";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              const TextWidget(
                                text: "Confirm Password",
                                fontsize: 12,
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              SizedBox(
                                height: (_haserror) ? 10.h : 6.h,
                                child: TextFormField(
                                  controller: _password2TextController,
                                  // onChanged: (value) => _checkPassword(value),
                                  obscureText: !_password2Visible,
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _password2Visible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _password2Visible =
                                                !_password2Visible;
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
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                      horizontal: 20.0,
                                    ),
                                    hintStyle: const TextStyle(
                                        fontSize: 10,
                                        color:
                                            Color.fromRGBO(163, 163, 163, 1)),
                                    hintText: 'Repeat Your Password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      setState(() {
                                        _haserror = true;
                                      });
                                      return "Please enter your confirm password";
                                    }
                                    if (value != _passwordTextController.text) {
                                      setState(() {
                                        _haserror = true;
                                      });
                                      return "Password doesn't match";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              SizedBox(
                                width: 80.w,
                                child: LinearProgressIndicator(
                                  value: _strength,
                                  backgroundColor: Colors.grey[300],
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
                                controller: _refTextController,
                                maxLines: 1,
                                keyboardType: TextInputType.text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, bottom: 10, right: 13, top: 10),
                                  hintStyle: const TextStyle(
                                      fontSize: 10,
                                      color: Color.fromRGBO(163, 163, 163, 1)),
                                  hintText: 'Enter your Referral',
                                ),
                              ),
                              SizedBox(
                                width: 100.w,
                                child: Column(
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Transform.scale(
                                            scale: 0.6,
                                            child: Checkbox(
                                              value: agreement,
                                              checkColor: Colors
                                                  .white, // Color of the check mark
                                              activeColor: Colors.blue,
                                              side: const BorderSide(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  agreement = value!;
                                                });
                                              },
                                            ),
                                          ),
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
                                      onTap: () async {
                                        // showLoaderDialog(context);
                                        // printDebug(context.mounted);
                                        if (!_signupFormKey.currentState!
                                            .validate()) {
                                          // Navigator.pop(context);
                                        }
                                        if (_signupFormKey.currentState!
                                            .validate()) {
                                                   log("100-$_ipAddress");

                                          Map<String, dynamic> mdata;
                                          mdata = {
                                            'email': _emailTextController.text,
                                            'password': sha1
                                                .convert(utf8.encode(
                                                    _passwordTextController
                                                        .text))
                                                .toString(),
                                            "ipaddress": _ipAddress,
                                            "referral":
                                                _refTextController.text.isEmpty
                                                    ? null
                                                    : _refTextController.text
                                          };
                                          var url = Uri.parse(
                                              "$urlapi/auth/register");
                                          await satoshiAPI(
                                                  url, jsonEncode(mdata))
                                              .then((ress) {
                                              var result = jsonDecode(ress);
                                            if (result['code'] == '201') {
                                              dynamic email =
                                                  _emailTextController.text;
                                              wvcontroller =
                                                  WebViewController();
                                              wvcontroller.loadRequest(
                                                Uri.parse(
                                                    "$urlbase/auth/send_activation/${Uri.encodeComponent(email)}?token=${result['message']['token']}"),
                                              );
                                              Get.toNamed(
                                                "/front-screen/subscribe",
                                                arguments: [
                                                  {
                                                    "email": email,
                                                    "password": sha1
                                                        .convert(utf8.encode(
                                                            _passwordTextController
                                                                .text))
                                                        .toString(),
                                                    "referral":
                                                        _refTextController
                                                                .text.isEmpty
                                                            ? null
                                                            : _refTextController
                                                                .text
                                                  },
                                                ],
                                              );
                                            } else {
                                              var psnerr = result['message'];
                                              Navigator.pop(context);
                                              showAlert(psnerr, context);
                                            }
                                          }).catchError((err) {
                                            Navigator.pop(context);
                                            showAlert(
                                              "Something Wrong, Please Contact Administrator",
                                              context,
                                            );
                                          });
                                        }
                                        // Get.toNamed("/front-screen/home");
                                      },
                                      textcolor: const Color(0xFF000000),
                                      backcolor: const Color(0xFFBFA573),
                                      width: 150,
                                      radiuscolor: const Color(0xFFFFFFFF),
                                      fontsize: 16,
                                      radius: 5,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  RichText(
                    text: TextSpan(
                      children: [
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
                                  fontSize: 12, fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed("/front-screen/login");
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _getIPAddress() async {
    try {
      // Call the IPify API to get the IP address
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        setState(() {
          _ipAddress = data['ip'];
        });
      } else {
        setState(() {
          _ipAddress = 'Failed to get IP address';
        });
      }
    } catch (e) {
      setState(() {
        _ipAddress = 'Error occurred: $e';
      });
    }
  }
}
