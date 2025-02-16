import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class SubscribeView extends StatefulWidget {
  const SubscribeView({super.key});

  @override
  State<SubscribeView> createState() {
    return _SubscribeViewState();
  }
}

class _SubscribeViewState extends State<SubscribeView> {
  late final WebViewController wvcontroller;
  final _email = Get.arguments[0]["email"];
  //var _password = Get.arguments[0]["password"];
  //var _referral = Get.arguments[0]["referral"];
  String token = "";
  int value = 0;
  String _status = 'pending';
  bool isDataReady = true;

  @override
  void initState() {
    super.initState();
    print(_email);
    //print(_password);
    //print(_referral);

    wvcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isDataReady = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // print(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            log("100-${request.url}");
            // Check if the URL is the one that should open in the browser
            if (request.url == "$urlbase/referral/auth/signin") {
              log("-Bisa disini-");
              // Launch the URL in the default browser
              _launchURL(request.url);
              // Block WebView from loading this URL
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'Total',
        onMessageReceived: (JavaScriptMessage message) async {
          setState(() {
            _status = message.message;
          });
        },
      );

    wvcontroller
        .loadRequest(Uri.parse("$urlbase/widget/subscription?mail=$_email"));
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
          canPop: false, // Prevents the page from being popped
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  WebViewWidget(controller: wvcontroller),
                  if (isDataReady)
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: (_status == 'success')
                ? FloatingActionButton.extended(
                    onPressed: () {
                      Get.toNamed(
                        "/front-screen/login",
                      );
                    },
                    icon: const Icon(Icons.login_outlined),
                    label: Text(
                      "Re Login",
                      style: TextStyle(fontSize: 18),
                    ),
                    backgroundColor: const Color(0xFFBFA573),
                    foregroundColor: Colors.black,
                  )
                : SizedBox.shrink(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          )),
    );
  }
}
