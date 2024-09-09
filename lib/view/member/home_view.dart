import 'package:flutter/material.dart';
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
  late final WebViewController _webViewController;
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
    var getEmail = prefs.getString("email");
    email = getEmail!;
    var getRef = prefs.getString("refcode");
    ref = getRef!;
  }

  @override
  void initState() {
    super.initState();
    getPrefer();
    WidgetsBinding.instance.addObserver(this);

    // Initialize WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
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
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isWebViewLoaded = true;
                if (_isInitialLoad) {
                  _isInitialLoad = false;
                  // Check if initial load timeout has passed
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
                  // Show error only if WebView has finished loading
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
      ..loadRequest(
          Uri.parse('https://pnglobalinternational.com/widget/signal'));
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
        _webViewController
            .runJavaScript("document.body.style.visibility = 'hidden';");
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _webViewController
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
                        _webViewController.reload(); // Retry loading the page
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
                    WebViewWidget(controller: _webViewController),
                    (_isDataReady)
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Stack(),
                  ],
                ),
        ),
        bottomNavigationBar: const Satoshinav(
          number: 0,
        ));
  }
}
