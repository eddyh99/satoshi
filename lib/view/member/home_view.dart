import 'package:flutter/material.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() {
    return _HomeViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _HomeViewState extends State<HomeView>with WidgetsBindingObserver {
  late final WebViewController _webViewController;
  bool _isError = false;
  bool _isWebViewLoaded = false;
  bool _isInitialLoad = true;
  late final DateTime _loadStartTime;
  static const Duration _initialLoadTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
                    _isError =
                        false; // Ensure initial load is considered successful if it completed
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
      ..loadRequest(Uri.parse('https://flutter.dev'));
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
    return SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 3.w),
        child: Scaffold(
            backgroundColor: Colors.black,
            body: _isError && !_isWebViewLoaded
          ? const Center(
              child: TextWidget(
                text:
                    'Failed to load the page. Please check your internet connection.',
                fontsize: 16,
              ),
            )
          : WebViewWidget(controller: _webViewController),
             bottomNavigationBar: const Satoshinav(
          number: 0,
        ))
    );
            
  }
}
