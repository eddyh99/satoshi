import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/shimmer_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vibration/vibration.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() {
    return _SettingViewState();
  }
}

// Future<void> _launchInWebViewOrVC(Uri url) async {
//   if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
//     throw Exception('Could not launch $url');
//   }
// }

class _SettingViewState extends State<SettingView> {
  dynamic email;
  dynamic idRef;
  bool _isLoading = true;
  DateTime? currentDate;
  DateTime? endDate;
  Duration? difference;
  int? period;
  double? amount;
  bool isSoundEnabled = true;
  bool isVibrationEnabled = true;
  late String lang = "en";

  Future<void> _launchURL() async {
    const url =
        'https://www.pnglobalinternational.com/homepage/service?service=c2F0b3NoaV9zaWduYWw=';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<dynamic> getPrefer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve email and id_referral
    email = prefs.getString("email")!;
    idRef = prefs.getString("id_referral")!;
    lang = prefs.getString('selected_language') ?? 'en';
    String periodString =
        prefs.getString("period") ?? '0'; // Get the string or default to '0'
    int periode = int.parse(periodString); // Parse the string to an integer

    period = periode ~/ 30;

    String amountString =
        prefs.getString("amount") ?? '0'; // Get the string or default to '0'
    amount = double.parse(amountString); // Parse the string to an integer

    // Parse endDate from the shared preferences
    String? endDateString = prefs.getString("end_date");
    if (endDateString != null) {
      endDate = DateTime.parse(endDateString);
    }

    // Get the current date and calculate the difference
    currentDate = DateTime.now();
    if (endDate != null && currentDate != null) {
      difference = endDate!.difference(currentDate!);
    }
    setState(() {
      _isLoading = false;
      isSoundEnabled = prefs.getBool('sound') ?? true;
      isVibrationEnabled = prefs.getBool('vibration') ?? true;
    });
  }

  @override
  void initState() {
    super.initState();
    getPrefer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('sound', isSoundEnabled);
    prefs.setBool('vibration', isVibrationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                          width: 100.w,
                          height: 35.h,
                          child: const Align(
                              alignment: Alignment.topCenter,
                              child: Image(
                                  image: AssetImage(
                                      "assets/images/background-profile.png")))),
                      Positioned(
                        top: 100,
                        child: Image.asset("assets/images/logo.png",
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    ],
                  ),
                  (_isLoading)
                      ? ShimmerWidget(tinggi: 2.h, lebar: 50.w)
                      : TextWidget(text: email, fontsize: 15),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: "Subscription",
                          fontsize: 16,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: "$period Month (€ $amount)",
                                fontsize: 16,
                              ),
                              TextWidget(
                                text: "${difference?.inDays} days remaining",
                                fontsize: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTile(
                          icon: Icons.language,
                          text: 'Language ($lang)',
                          onTap: () {
                            Get.toNamed("/front-screen/language");
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildTile(
                          icon: Icons.volume_up,
                          text: 'Sound',
                          trailing: Switch(
                            value: isSoundEnabled,
                            onChanged: (value) {
                              setState(() {
                                isSoundEnabled = value;
                                _savePreferences();
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTile(
                          icon: Icons.vibration,
                          text: 'Vibrate',
                          trailing: Switch(
                            value: isVibrationEnabled,
                            onChanged: (value) {
                              setState(() {
                                isVibrationEnabled = value;
                                _savePreferences();
                                if (value) {
                                  Vibration.vibrate(
                                      duration: 500); // Test vibration
                                }
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _launchURL,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.help_outline,
                                        color: Colors.blue, size: 24),
                                    SizedBox(width: 8),
                                    Text(
                                      "How To",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.open_in_new,
                                    color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                            onTap: () async {
                              List<String> keysToKeep = [
                                'sound',
                                'vibration',
                                'selected_language'
                              ];
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              // Store the values of the keys you want to keep
                              Map<String, dynamic> valuesToKeep = {};
                              for (String key in keysToKeep) {
                                if (prefs.containsKey(key)) {
                                  valuesToKeep[key] =
                                      prefs.get(key); // Store the value
                                }
                              }
                              await prefs.clear();
                              for (String key in valuesToKeep.keys) {
                                dynamic value = valuesToKeep[key];
                                if (value is bool) {
                                  await prefs.setBool(key, value);
                                }
                              }
                              Get.toNamed("/front-screen/login");
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.logout,
                                      color: Colors.white, size: 24),
                                  SizedBox(width: 8),
                                  TextWidget(
                                    text: 'Logout',
                                    fontsize: 16,
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                          height: 5.h,
                        ),
                        _buildTile(
                          icon: Icons.delete_forever,
                          text: 'Delete Account',
                          onTap: () {
                            // Handle account deletion logic
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          )),
        ),
        bottomNavigationBar: const Satoshinav(
          number: 3,
        ));
  }
}

Widget _buildTile(
    {required IconData icon,
    required String text,
    Widget? trailing,
    VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.white, size: 30),
    title:
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
    trailing:
        trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.white),
    onTap: onTap,
    tileColor: Colors.black,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: Colors.amber, width: 2.0),
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
