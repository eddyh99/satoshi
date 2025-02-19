import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() {
    return _HistoryViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _HistoryViewState extends State<HistoryView> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  late String lang = "en";
  String urltranslated = "";
  bool _isError = false;
  bool _isWebViewLoaded = false;
  bool _isInitialLoad = true;
  bool _isDataReady = true;
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 20);

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('selected_language') ?? 'en';
    String? email = prefs.getString("email") ?? "";
    if (email.isEmpty) {
      Get.toNamed("/front-screen/login");
    }
    // Update the URL after getting preferences
    urltranslated = "$urlbase/widget/signal/history";

    // Initialize the WebViewController after lang is updated
    setState(() {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..clearCache()
        ..enableZoom(false)
        ..setNavigationDelegate
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              _webViewController!.runJavaScript('''
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
              //Inject JavaScript to hide the toolbar inside the iframe with ID 'gt-nvframe'
              _webViewController!.runJavaScript('''
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
                  _isWebViewLoaded = true; // Set the flag to hide the loader
                  _isError = false; // Reset the error state
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
                _webViewController!.reload();

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
      _webViewController!.reload();
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
        child: _isError
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ) // Show a loading indicator while the controller is null
                      : WebViewWidget(controller: _webViewController!),
                  !_isWebViewLoaded
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Container(), // Hide loading indicator when the WebView is loaded
                ],
              ),
      ),
      bottomNavigationBar: const Satoshinav(
        number: 1,
      ),
    );
  }
}
