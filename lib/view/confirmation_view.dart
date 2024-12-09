import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';

class ConfirmationView extends StatefulWidget {
  const ConfirmationView({super.key});

  @override
  State<ConfirmationView> createState() {
    return _ConfirmationViewState();
  }
}

class _ConfirmationViewState extends State<ConfirmationView> {
  var email = Get.arguments[0]["email"];
  final GlobalKey<FormState> _confirmFormKey = GlobalKey<FormState>();
  final TextEditingController pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Prevents the page from being popped
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.toNamed("/front-screen/signin"),
            ),
            backgroundColor: Colors.black,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _confirmFormKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Please Check Your Email",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24)),
                        Text("We've sent a code to $email",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        SizedBox(
                          height: 3.h,
                        ),
                        Pinput(
                          controller: pinController,
                          focusNode: focusNode,
                          length: 4,
                          obscureText: false,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          defaultPinTheme: PinTheme(
                            height: 50.0,
                            width: 50.0,
                            textStyle: TextStyle(color: Colors.white),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black,
                              border: Border.all(color: Colors.white),
                            ),
                          ),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (value) async {
                            showLoaderDialog(context);
                            if (_confirmFormKey.currentState!.validate()) {
                              var url = Uri.parse(
                                  "$urlapi/auth/activate?token=$value&email=$email");
                              var result =
                                  jsonDecode(await satoshiAPI(url, ""));
                              if (result["code"] == "200") {
                                if (Platform.isAndroid) {
                                  Get.toNamed("/front-screen/subscribe",
                                      arguments: [
                                        {
                                          "email": email,
                                        },
                                      ]);
                                }
                                if (Platform.isIOS) {
                                  Get.toNamed("/front-screen/inapp",
                                      arguments: [
                                        {
                                          "email": email,
                                        },
                                      ]);
                                }
                              } else {
                                var psnerr = result['message'];
                                Navigator.pop(context);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      psnerr,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        const Color.fromRGBO(114, 162, 138, 1),
                                  ));
                                }
                              }
                            }
                          },
                        )
                      ]),
                ),
              ),
            ),
          ),
        ));
  }
}
