import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/event_bus.dart';
import 'package:satoshi/utils/firebase_messaging_service.dart';
import 'package:satoshi/utils/globalvar.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  late final StreamSubscription _eventBusSubscription;
  String selectedLanguage = 'en'; // Default language is English
  String lastMessageId = "";

// List of supported languages, their codes, and corresponding country codes
  final List<Map<String, String>> languages = [
    {'name': 'Deutsch', 'code': 'de', 'countryCode': 'de'},
    {'name': 'English', 'code': 'en', 'countryCode': 'gb'},
    {'name': 'Español', 'code': 'es', 'countryCode': 'es'},
    {'name': 'Français', 'code': 'fr', 'countryCode': 'fr'},
    {'name': 'हिंदी', 'code': 'hi', 'countryCode': 'in'},
    {'name': 'Bahasa Indonesia', 'code': 'id', 'countryCode': 'id'},
    {'name': 'Português', 'code': 'pt', 'countryCode': 'pt'},
    {'name': 'Русский', 'code': 'ru', 'countryCode': 'ru'},
    {'name': 'Italian', 'code': 'it', 'countryCode': 'it'},
    {'name': 'Arabic', 'code': 'ar', 'countryCode': 'sa'},
    {'name': 'Chinese', 'code': 'zh-CN', 'countryCode': 'cn'},
    {'name': 'Japanese', 'code': 'ja', 'countryCode': 'jp'},
    {'name': 'Turkish', 'code': 'tr', 'countryCode': 'tr'},
  ];

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email") ?? "";
    if (email.isEmpty) {
      Get.toNamed("/front-screen/login");
    }

    final savedLang = prefs.getString('selected_language') ?? 'en';
    final msgid = prefs.getString('lastMessageId') ?? '';
    prefs.setString('lastMessageId', "");
    prefs.setBool('hasNewMessage', false);

    log('Loaded language from preferences: $savedLang');
    setState(() {
      lang = savedLang;
      selectedLanguage = savedLang;
      lastMessageId = msgid;
      log(lastMessageId);

      // Update the URL after getting preferences

      if (lastMessageId.isEmpty) {
        urltranslated =
            "https://translate.google.com/translate?sl=auto&tl=$lang&hl=$lang&u=$urlbase/widget/message";
      } else {
        urltranslated =
            "https://translate.google.com/translate?sl=auto&tl=$lang&hl=$lang&u=$urlbase/widget/message/detailmessage/$lastMessageId";
      }
      log(urltranslated);
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
            },
          ),
        )
        ..loadRequest(Uri.parse(urltranslated));
    });
  }

  @override
  void initState() {
    super.initState();
    log('Initializing MessageView...');
    getPrefer(); // Fetch and apply preferences during initialization
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
// Reset the loaded state
// Allow initial load check again
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

  Future<void> _savePreferences(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    final cek = prefs.getString('selected_language');
    log('isi pref language:$cek');
  }

  void _updateTranslationUrl() {
    if (lastMessageId.isEmpty) {
      urltranslated =
          "https://translate.google.com/translate?sl=auto&tl=$lang&hl=$lang&u=$urlbase/widget/message";
    } else {
      urltranslated =
          "https://translate.google.com/translate?sl=auto&tl=$lang&hl=$lang&u=$urlbase/widget/message/detailmessage/$lastMessageId";
    }
    setState(() {
      // Reinitialize WebViewController with the new URL
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..clearCache()
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              log("Page started loading: $url");
            },
            onPageFinished: (String url) {
              log("Page finished loading: $url");

              // Inject JavaScript to hide Google Translate bar
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
            },
            onWebResourceError: (error) {
              log("Page resource error: ${error.description}");
            },
          ),
        )
        ..loadRequest(Uri.parse(urltranslated));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:
              Colors.black, // Set the background color of the AppBar
          automaticallyImplyLeading: false, // Remove the back arrow
          actions: [
            Expanded(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the DropdownButton
                children: [
                  DropdownButton<String>(
                      value: selectedLanguage,
                      icon: const Icon(Icons.language, color: Colors.white),
                      dropdownColor: Colors.black,
                      items: languages.map((language) {
                        return DropdownMenuItem<String>(
                          value: language['code'],
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'packages/country_icons/icons/flags/svg/${language['countryCode']}.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                language['name']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() {
                            selectedLanguage = value;
                          });
                          await _savePreferences(selectedLanguage);
                          setState(() {
                            lang = selectedLanguage; // Ensure lang is updated
                          });
                          _updateTranslationUrl(); // Reload the WebView with the new language
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _webViewController == null
              ? const Center(child: CircularProgressIndicator())
              : WebViewWidget(controller: _webViewController!),
        ),
        bottomNavigationBar: const Satoshinav(
          number: 2,
        ));
  }
}
