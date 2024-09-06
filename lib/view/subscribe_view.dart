import 'package:flutter/material.dart';
import 'package:satoshi/utils/globalvar.dart';
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
  var idcabang = Get.arguments[0]["idcabang"];
  String token = "";
  int value = 0;
  String totalorder = '';
  bool isDataReady = true;

  @override
  void initState() {
    super.initState();

    wvcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
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
          onWebResourceError: (WebResourceError error) {},
        ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed(
              "/front-screen/allmenu",
              arguments: [
                {"idcabang": idcabang}
              ],
            );
          },
          icon: const Icon(Icons.restaurant_menu),
          label: Text(
            "All Menu",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Color.fromRGBO(131, 173, 152, 1),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
