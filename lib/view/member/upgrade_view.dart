import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UpgradeView extends StatefulWidget {
  const UpgradeView({super.key});

  @override
  State<UpgradeView> createState() {
    return _UpgradeViewState();
  }
}

class _UpgradeViewState extends State<UpgradeView> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  var _email = Get.arguments[0]["email"];
  late String lang = "en";
  String urltranslated = "";
  bool _isError = false;
  bool _isWebViewLoaded = false;
  bool _isInitialLoad = true;
  bool _isDataReady = true;
  String _status = 'upgrading';
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 20);

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('selected_language') ?? 'en';

    // Update the URL after getting preferences
    urltranslated =
        "https://satoshisignal.app/widget/subscription/upgrade/$_email";

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
                  style.innerHTML = '.goog-te-banner-frame, #gt-nvframe { display: none !important; }';
                  document.head.appendChild(style);
                })();
              ''');
              _loadStartTime = DateTime.now();
              if (mounted) {
                setState(() {
                  _isError = false;
                });
              }
            },
            onPageFinished: (url) {
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
                      _isError = false;
                    } else {
                      _isError = true;
                      _showErrorBottomSheet();
                    }
                  }
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Check if the URL is the one that should open in the browser
              if (request.url == "$urlbase/referral/auth/signin") {
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
        )
        ..loadRequest(Uri.parse(urltranslated));
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getPrefer();

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
                      Navigator.pop(context);
                      if (mounted) {
                        _webViewController!.reload();
                        setState(() {
                          _isError = false;
                          _isWebViewLoaded = false;
                          _isInitialLoad = true;
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
        ));
  }
}
