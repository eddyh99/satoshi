import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:satoshi/utils/functions.dart';
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

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    String? getToken = prefs.getString("devicetoken");
    final isSoundEnabled = prefs.getBool('sound') ?? true; // default to true
    final isVibrationEnabled =
        prefs.getBool('vibration') ?? true; // default to true
    log(isSoundEnabled.toString());
    log(isVibrationEnabled.toString());

    lang = prefs.getString('selected_language') ?? 'en';
    log("100-${getToken!}");
      FirebaseMessaging.instance.subscribeToTopic('signal').then((_) {
        log("Successfully subscribed to topic 'signal'");
      }).catchError((error) {
        log("Error subscribing to topic 'signal': $error");
      });

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      log("100-$fcmToken");
      if (fcmToken != null) {
        Map<String, dynamic> mdata;
        mdata = {'email': email, 'devicetoken': fcmToken};
        var url = Uri.parse("$urlapi/v1/member/add_device");
        await satoshiAPI(url, jsonEncode(mdata));
        prefs.setString("devicetoken", fcmToken);
    }

    // Update the URL after getting preferences
    urltranslated =
        "https://translate.google.com/translate?sl=auto&tl=$lang&hl=en&u=https://pnglobalinternational.com/widget/signal";
    log(urltranslated);
    log(lang);

    // Initialize the WebViewController after lang is updated
    setState(() {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..clearCache()
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              _controller!.runJavaScript('''
                (function() {
                  var style = document.createElement('style');
                  style.innerHTML = '.goog-te-banner-frame, #gt-nvframe { display: none !important; }';
                  document.head.appendChild(style);
                })();
              ''');
              _loadStartTime = DateTime.now();
              if (mounted) {
                setState(() {
                  _isError = false; // Reset error state on new page load
                });
              }
            },
            onPageFinished: (url) {
              // Log the current URL and lang to ensure translation is correct
              log('Current URL: $url');
              log('Language Code (lang): $lang'); // Ensure this logs 'es' or any other valid language code

              //Inject JavaScript to hide the toolbar inside the iframe with ID 'gt-nvframe'
              _controller!.runJavaScript('''
                (function() {
                  var translateBar = document.querySelector('.goog-te-banner-frame');
                  if (translateBar) {
                    translateBar.style.display = 'none';
                  }

                  var iframe = document.getElementById('gt-nvframe');
                  if (iframe) {
                    iframe.style.display = 'none'; // Hide iframe if found
                  }
                  document.body.style.top = '0px'; // Adjust body top to avoid gap
                })();
              ''');

              if (mounted) {
                setState(() {
                  _isWebViewLoaded = true;
                  if (_isInitialLoad) {
                    _isInitialLoad = false;
                    final duration = DateTime.now().difference(_loadStartTime);
                    if (duration < _initialLoadTimeout) {
                      _isError = false;
                      _isDataReady = false;
                    } else if (_isError) {
                      _showErrorBottomSheet();
                    }
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
                    } else {
                      _isError = true;
                      _showErrorBottomSheet();
                    }
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
