import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';

class NewpassView extends StatefulWidget {
  const NewpassView({super.key});

  @override
  State<NewpassView> createState() {
    return _NewpassViewState();
  }
}

class _NewpassViewState extends State<NewpassView> {
  final GlobalKey<FormState> _newpassFormKey = GlobalKey<FormState>();
  final TextEditingController _tokenTextController = TextEditingController();
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
                key: _newpassFormKey,
                child: Column(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: "Forgot Password",
                            fontsize: 32,
                          ),
                          TextWidget(
                            text:
                                "Please check your email to know your reset password token, and insert your token below",
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
                    height: (_haserror) ? 38.h : 30.h,
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
                                text: "Token",
                                fontsize: 12,
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                height: (_emailerror) ? 10.h : 6.h,
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  controller: _tokenTextController,
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
                                ),
                              ),
                              SizedBox(height: 3.h),
                              const TextWidget(
                                text: "New Password",
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
                        if (!_newpassFormKey.currentState!.validate()) {
                          Navigator.pop(context);
                        }
                        if (_newpassFormKey.currentState!.validate()) {
                          Map<String, dynamic> mdata;
                          mdata = {
                            'token': _tokenTextController.text,
                            'password': sha1
                                .convert(
                                    utf8.encode(_passwordTextController.text))
                                .toString(),
                          };
                          var url = Uri.parse("$urlapi/auth/updatepassword");
                          await satoshiAPI(url, jsonEncode(mdata)).then((ress) {
                            var result = jsonDecode(ress);

                            if ((result['code'] == "200")) {
                              _newpassFormKey.currentState?.reset();
                              _tokenTextController.clear();
                              _passwordTextController.clear();
                              var psnerr = result['message'];
                              // Navigator.pop(context);
                              showAlert(psnerr, context);
                              Get.toNamed("/front-screen/login");
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
        ));
  }
}
