import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ForgotpassView extends StatefulWidget {
  const ForgotpassView({super.key});

  @override
  State<ForgotpassView> createState() {
    return _ForgotpassViewState();
  }
}

class _ForgotpassViewState extends State<ForgotpassView> {
  final GlobalKey<FormState> _forgotFormKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  late final WebViewController wvcontroller;

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
              key: _forgotFormKey,
              child: Column(children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: "Forgot Password",
                          fontsize: 32,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        TextWidget(
                          text: "Enter your email to reset your password",
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
                  height: (_haserror) ? 38.h : 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0x4ACCB78F), // Background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
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
                                        color: Color.fromARGB(0, 255, 255, 255),
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
                                      color: Color.fromRGBO(163, 163, 163, 1)),
                                  hintText: 'Enter your email address',
                                ),
                                validator: validateEmail,
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
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
                    text: "Reset Password",
                    onTap: () async {
                      showLoaderDialog(context);
                      if (!_forgotFormKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                      if (_forgotFormKey.currentState!.validate()) {
                        String email = _emailTextController.text;

                        var url = Uri.parse(
                            "$urlapi/auth/resetpassword?email=$email");
                        await satoshiAPI(url, jsonEncode(null)).then((ress) {
                          var result = jsonDecode(ress);

                          if (result['code'] == "200") {
                            wvcontroller = WebViewController();
                            wvcontroller.loadRequest(
                              Uri.parse(
                                  "$urlbase/widget/auth/send_resetpassword/${Uri.encodeComponent(email)}"),
                            );
                            Get.toNamed("/front-screen/new-password",
                                arguments: [
                                  {
                                    "email": _emailTextController.text,
                                  },
                                ]);
                            _forgotFormKey.currentState?.reset();
                            _emailTextController.clear();
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
                    },
                    textcolor: const Color(0xFF000000),
                    backcolor: const Color(0xFFBFA573),
                    width: 200,
                    radiuscolor: const Color(0xFFFFFFFF),
                    fontsize: 16,
                    radius: 5),
                SizedBox(height: 8.h),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
