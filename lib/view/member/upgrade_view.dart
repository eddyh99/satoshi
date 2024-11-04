import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/errorbuttom_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

class UpgradeView extends StatefulWidget {
  const UpgradeView({super.key});

  @override
  State<UpgradeView> createState() {
    return _UpgradeViewState();
  }
}

class _UpgradeViewState extends State<UpgradeView> with WidgetsBindingObserver {
  WebViewController? webViewMobile;
  final WebviewController webViewDesktop = WebviewController();
  var _email = Get.arguments[0]["email"];
  String url = "";
  bool isError = false;
  bool isWebViewLoaded = false;
  bool isInitialLoad = true;
  bool isDataReady = true;
  bool isWindowsWebViewReady = false;
  String _status = 'upgrading';
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 20);

  Future<void> loadWebViewMobile() async {
    // Update the URL after getting preferences
    print(_email);
    url =
        // "https://pnglobalinternational.com/widget/subscription/upgrade/$_email";
        "https://pnglobalinternational.com/widget/subscription/upgrade_success";

    // Initialize the WebViewController after lang is updated
    setState(() {
      webViewMobile = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..clearCache()
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              _loadStartTime = DateTime.now();
              if (mounted) {
                setState(() {
                  isError = false;
                });
              }
            },
            onPageFinished: (url) {
              if (mounted) {
                setState(() {
                  isWebViewLoaded = true;
                  if (isInitialLoad) {
                    isInitialLoad = false;
                    final duration = DateTime.now().difference(_loadStartTime);
                    if (duration < _initialLoadTimeout) {
                      isError = false;
                      isDataReady = false;
                    } else if (isError) {
                      ErrorBottomSheet(
                        onRetry: () {
                          Navigator.pop(context);
                          if (mounted) {
                            webViewMobile!.reload();
                            setState(() {
                              isError = false;
                              isWebViewLoaded = false;
                              isInitialLoad = true;
                            });
                          }
                        },
                      );
                    }
                  }
                });
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  if (isWebViewLoaded) {
                    final duration = DateTime.now().difference(_loadStartTime);
                    if (duration < _initialLoadTimeout) {
                      isError = false;
                    } else {
                      isError = true;
                      ErrorBottomSheet(
                        onRetry: () {
                          Navigator.pop(context);
                          if (mounted) {
                            webViewMobile!.reload();
                            setState(() {
                              isError = false;
                              isWebViewLoaded = false;
                              isInitialLoad = true;
                            });
                          }
                        },
                      );
                    }
                  }
                });
              }
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
        )
        ..loadRequest(Uri.parse(url));
    });
  }

  Future<void> loadWebViewDesktop() async {
    try {
      await webViewDesktop.initialize();
      await webViewDesktop.loadUrl(url);
      await webViewDesktop.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await webViewDesktop.setBackgroundColor(Colors.black);
      await webViewDesktop.clearCache();
      webViewDesktop.loadingState.listen((state) {
        if (state == LoadingState.navigationCompleted) {
          setState(() {
            isWindowsWebViewReady = true;
          });
        }
      });
      webViewDesktop.webMessage.listen((event) {
        print("CEK DATA DI WINDOWS");
        print(event);
      });

      // webViewDesktop.url.listen((url) {
      //   // Debug: Print the URL to check the output
      //   if (url
      //       .startsWith("https://pnglobalinternational.com?status=success")) {
      //     final status = Uri.parse(url).queryParameters['status'];
      //     if (status != null) {
      //       setState(() {
      //         _status = status;
      //         print(_status);
      //       });
      //     }
      //   }

      // Check if the URL starts with your custom scheme
      // if (url.startsWith("myapp://status=")) {
      //   final status = Uri.parse(url).queryParameters['status'];
      //   if (status != null) {
      //     setState(() {
      //       _status = status;
      //     });
      //   }
      // }
      // });
      if (!mounted) return;
      print("INI DARI WINDOWS");
    } catch (e) {
      ErrorBottomSheet(onRetry: () {
        Navigator.pop(context);
        if (mounted) {
          webViewDesktop.reload();
        }
      });
    }
  }

  void loadWebView() {
    setState(() {
      if (Platform.isAndroid || Platform.isIOS) {
        loadWebViewMobile();
      } else {
        loadWebViewDesktop();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadWebView();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget renderWebView() {
    if (Platform.isAndroid || Platform.isIOS) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: (_status == 'upgrading')
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.toNamed('front-screen/setting'),
                )
              : SizedBox.shrink(),
          centerTitle: true,
          title: (_status == 'upgrading')
              ? Text(
                  "Upgrade Your Plan",
                  style: TextStyle(fontSize: 20),
                )
              : SizedBox.shrink(),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SafeArea(
          child: isError && !isWebViewLoaded
              ? const Center(
                  child: TextWidget(
                    text:
                        'Failed to load the page. Please check your internet connection.',
                    fontsize: 16,
                  ),
                )
              : Stack(
                  children: [
                    webViewMobile == null
                        ? const Center(
                            child:
                                CircularProgressIndicator()) // Show a loading indicator while _controller is null
                        : WebViewWidget(controller: webViewMobile!),
                    (isDataReady)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Container(),
                  ],
                ),
        ),
        floatingActionButton: (_status == 'success')
            ? FloatingActionButton.extended(
                onPressed: () {
                  Get.toNamed(
                    "/front-screen/home",
                  );
                },
                icon: const Icon(Icons.login_outlined),
                label: Text(
                  "Homepage",
                  style: TextStyle(fontSize: 18),
                ),
                backgroundColor: const Color(0xFFBFA573),
                foregroundColor: Colors.black,
              )
            : SizedBox.shrink(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: const Satoshinav(
          number: 3,
        ),
      );
    } else {
      return (Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            ((isWindowsWebViewReady)
                ? Webview(
                    webViewDesktop,
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )),
          ],
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return renderWebView();
  }
}
