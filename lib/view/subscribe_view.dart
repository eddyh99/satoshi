import 'package:flutter/material.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubscribeView extends StatefulWidget {
  const SubscribeView({super.key});

  @override
  State<SubscribeView> createState() {
    return _SubscribeViewState();
  }
}

class _SubscribeViewState extends State<SubscribeView> {
  late final WebViewController wvcontroller;
  // var idcabang = Get.arguments[0]["idcabang"];
  String token = "";
  int value = 0;
  String _status = 'pending';
  bool isDataReady = true;

  @override
  void initState() {
    super.initState();

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
        ),
      )
      ..addJavaScriptChannel(
        'Total',
        onMessageReceived: (JavaScriptMessage message) async {
          setState(() {
            _status = message.message;
            print(_status);
          });
        },
      );

    wvcontroller.loadRequest(Uri.parse("$urlbase/widget/subscription"));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: WebViewWidget(controller: wvcontroller),
        ),
      ),
    );
  }
}
