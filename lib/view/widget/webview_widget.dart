import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:satoshi/utils/functions.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/errorbuttom_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

class WebviewWidget extends StatefulWidget {
  final String url;

  const WebviewWidget({
    super.key,
    required this.url,
  });

  @override
  // ignore: library_private_types_in_public_api
  _WebviewWidgetState createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget>
    with WidgetsBindingObserver {
  final WebviewController webViewDesktop = WebviewController();
  WebViewController? webViewMobile;
  late final DateTime loadStartTime;
  static const Duration initialLoadTimeout = Duration(seconds: 20);
  bool isError = false;
  bool isWebViewLoaded = false;
  bool isInitialLoad = true;
  bool isDataReady = true;
  bool isWindowsWebViewReady = false;

  late final StreamSubscription _eventBusSubscription;
  dynamic email;
  dynamic ref;

  Future<void> loadWebViewMobile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");

    FirebaseMessaging.instance.subscribeToTopic('signal').then((_) {
      log("Successfully subscribed to topic 'signal'");
    }).catchError((error) {
      log("Error subscribing to topic 'signal': $error");
    });

    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      Map<String, dynamic> mdata = {'email': email, 'devicetoken': fcmToken};
      var url = Uri.parse("$urlapi/v1/member/add_device");
      await satoshiAPI(url, jsonEncode(mdata));
      prefs.setString("devicetoken", fcmToken);
    }

    webViewMobile = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..clearCache()
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            loadStartTime = DateTime.now();
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
                  final duration = DateTime.now().difference(loadStartTime);
                  if (duration < initialLoadTimeout) {
                    isError = false;
                    isDataReady = false;
                  } else if (isError) {
                    // Call Widget ErrorBottomSheet
                    ErrorBottomSheet(onRetry: () {
                      Navigator.pop(context);
                      if (mounted) {
                        webViewMobile!.reload();
                        setState(() {
                          isError = false;
                          isWebViewLoaded = false;
                          isInitialLoad = true;
                        });
                      }
                    });
                  }
                }
              });
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                if (isWebViewLoaded) {
                  final duration = DateTime.now().difference(loadStartTime);
                  if (duration < initialLoadTimeout) {
                    isError = false;
                  } else {
                    isError = true;
                    ErrorBottomSheet(onRetry: () {
                      Navigator.pop(context);
                      if (mounted) {
                        webViewMobile!.reload();
                        setState(() {
                          isError = false;
                          isWebViewLoaded = false;
                          isInitialLoad = true;
                        });
                      }
                    });
                  }
                }
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> loadWebViewDesktop() async {
    try {
      await webViewDesktop.initialize();
      await webViewDesktop.loadUrl(widget.url);
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

      if (!mounted) return;
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
    // Subscribe to the EventBus event to reload the WebView when notified
    _eventBusSubscription = eventBus.on<ReloadWebViewEvent>().listen((event) {
      log('ReloadWebViewEvent received. Reloading WebView...');
      if (webViewMobile != null) {
        webViewMobile!.reload();
      } else {
        log('Error: WebViewController is null, cannot reload.');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventBusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return renderWebView();
  }

  // ADDITIONAL WIDGET
  Widget renderWebView() {
    if (Platform.isAndroid || Platform.isIOS) {
      return ((isError && !isWebViewLoaded)
          ? const Center(
              child: TextWidget(
                text:
                    'Failed to load the page. Please check your internet connection.',
                fontsize: 16,
              ),
            )
          : Stack(
              children: [
                // ignore: unnecessary_null_comparison
                webViewMobile == null
                    ? const Center(child: CircularProgressIndicator())
                    : WebViewWidget(controller: webViewMobile!),
                (isDataReady)
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ));
    } else {
      return Stack(
        children: <Widget>[
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
      );
    }
  }
}
