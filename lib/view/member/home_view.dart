import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/event_bus.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  WebViewController? _controller;
  late String lang = "en";
  String urltranslated = "";
  bool _isError = false;
  bool _isWebViewLoaded = false;
  bool _isInitialLoad = true;
  bool _isDataReady = true;
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 20);
  dynamic email;
  dynamic ref;
  late final StreamSubscription _eventBusSubscription;

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email") ?? "";
    if (email.isEmpty){
      Get.toNamed("/front-screen/login");
    }

    lang = prefs.getString('selected_language') ?? 'en';
    prefs.setBool('hasNewSignal', false);
    // Only initialize FCM if running on Android or iOS
    String? token = await FirebaseMessaging.instance.getToken();
    log("FCM Token: $token");
    if (Platform.isAndroid || Platform.isIOS) {
      FirebaseMessaging.instance.subscribeToTopic('signal').then((_) {
        log("Successfully subscribed to topic 'signal'");
      }).catchError((error, stackTrace) {
        log("Error subscribing to topic 'signal': $error");
        log("Stack Trace: $stackTrace");
      });
    } else {
      log("FCM is not supported on this platform.");
    }

    // Update the URL after getting preferences
    urltranslated = "$urlbase/widget/signal";

    // Initialize the WebViewController after lang is updated
    setState(() {
      _controller = WebViewController()
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
                  _isError = false; // Reset error state on new page load
                });
              }
            },
            onPageFinished: (url) {
              //Inject JavaScript to hide the toolbar inside the iframe with ID 'gt-nvframe'
              if (mounted) {
                setState(() {
                  _isWebViewLoaded = true;
                  if (_isInitialLoad) {
                    _isInitialLoad = false;
                    final duration = DateTime.now().difference(_loadStartTime);
                    if (duration < _initialLoadTimeout) {
                      _isError = false;
                      _isDataReady = false;
                    } else if (_isError) {}
                  }
                });
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  if (_isWebViewLoaded) {
                    final duration = DateTime.now().difference(_loadStartTime);
                    if (duration < _initialLoadTimeout) {
                      _isError =
                          false; // Ensure initial load is considered successful if it completed
                    } else {}
                  }
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(urltranslated));
    });
  }

  @override
  void initState() {
    super.initState();
    getPrefer(); // Fetch preferences before initializing the WebView
    WidgetsBinding.instance.addObserver(this);
    // Subscribe to the EventBus event to reload the WebView when notified
    _eventBusSubscription = eventBus.on<ReloadSignalViewEvent>().listen((event) {
      log('ReloadWebViewEvent received. Reloading WebView...');
      if (_controller != null) {
        _controller!.reload();
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
  void didChangeAppLifecycleState(AppLifecycleState state) async {
      _controller!.reload();
    if (state == AppLifecycleState.paused) {
      if (mounted) {
        _controller!
            .runJavaScript("document.body.style.visibility = 'hidden';");
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _controller!
            .runJavaScript("document.body.style.visibility = 'visible';");
            
      }
      _controller!.reload();
    }
  }

  void _showErrorBottomSheet() {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connection error. Please check your internet and try again.',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ButtonWidget(
                    text: "Retry",
                    onTap: () {
                      Navigator.pop(context); // Close the BottomSheet
                      if (mounted) {
                        _controller!.reload(); // Retry loading the page
                        setState(() {
                          _isError = false;
                          _isWebViewLoaded = false; // Reset the loaded state
                          _isInitialLoad =
                              true; // Allow initial load check again
                        });
                      }
                    },
                    textcolor: const Color(0xFF000000),
                    backcolor: const Color(0xFFBFA573),
                    width: 150,
                    radiuscolor: const Color(0xFFFFFFFF),
                    fontsize: 16,
                    radius: 5),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _isError && !_isWebViewLoaded
              ? const Center(
                  child: TextWidget(
                    text:
                        'Failed to load the page. Please check your internet connection.',
                    fontsize: 16,
                  ),
                )
              : Stack(
                  children: [
                    _controller == null
                        ? const Center(
                            child:
                                CircularProgressIndicator()) // Show a loading indicator while _controller is null
                        : WebViewWidget(controller: _controller!),
                    (_isDataReady)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Container(),
                  ],
                ),
        ),
        bottomNavigationBar: const Satoshinav(
          number: 0,
        ));
  }
}
