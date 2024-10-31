import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() {
    return _MessageViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _MessageViewState extends State<MessageView> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  late String lang = "en";
  String urltranslated = "";
  bool _isError = false;
  bool _isWebViewLoaded = false;
  bool _isInitialLoad = true;
  bool _isDataReady = true;
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 20);
  late final StreamSubscription _eventBusSubscription;

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('selected_language') ?? 'en';

    // Update the URL after getting preferences
    urltranslated =
        "https://translate.google.com/translate?sl=auto&tl=en&hl=en&u=https://pnglobalinternational.com/widget/message";

    // Initialize the WebViewController after lang is updated
    setState(() {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..clearCache()
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              _webViewController!.runJavaScript('''
                (function() {
                  var style = document.createElement('style');
                  style.innerHTML = '.goog-te-banner-frame, #gt-nvframe { display: block !important; }';
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
              //Inject JavaScript to hide the toolbar inside the iframe with ID 'gt-nvframe'
              _webViewController!.runJavaScript('''
                (function() {
                  var translateBar = document.querySelector('.goog-te-banner-frame');
                  if (translateBar) {
                    translateBar.style.display = 'block';
                  }

                  var iframe = document.getElementById('gt-nvframe');
                  if (iframe) {
                    iframe.style.display = 'block'; // Hide iframe if found
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
    _eventBusSubscription = eventBus.on<ReloadWebViewEvent>().listen((event) {
      log('ReloadWebViewEvent received. Reloading WebView...');
      if (_webViewController != null) {
        _webViewController!.reload();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (mounted) {
        _webViewController!
            .runJavaScript("document.body.style.visibility = 'hidden';");
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _webViewController!
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
                        _webViewController!.reload(); // Retry loading the page
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
                    _webViewController == null
                        ? const Center(
                            child:
                                CircularProgressIndicator()) // Show a loading indicator while _controller is null
                        : WebViewWidget(controller: _webViewController!),
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
          number: 2,
        ));
  }
}
