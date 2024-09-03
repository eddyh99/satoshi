import 'package:flutter/material.dart';
import 'package:satoshi/utils/extensions.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
   Future<void> _launchURL() async {
    const url = 'https://google.com';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 3.w),
        child: Scaffold(
          backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            body: Column(
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
                      child:Image(image: AssetImage("assets/images/background-profile.png")) 
                    ) 
                  ),
                  Positioned(
                    top: 100,
                    child : Image.asset("assets/images/logo.png",
            width: 100,  // Set the width of the image
            height: 100, // Set the height of the image
            fit: BoxFit.cover))                  
                ],
              ),
              const TextWidget( text: "gaga@yahoo.com", fontsize: 15),
Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextWidget(text:
            "Subscription",
              fontsize: 16,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text:"1 Month (€100)",
                    fontsize: 16,

                ),
                TextWidget(
                  text:"3 days remaining",
                  fontsize: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.email, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    TextWidget(
                       text: 'Message', fontsize: 16,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextWidget(text: "2", fontsize: 14
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
      onTap: _launchURL,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue, size: 24),
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
            Icon(Icons.open_in_new, color: Colors.white, size: 24),
          ],
        ),
      ),
    )
          
        ],
      ),
    )              
              ],
            ),
            bottomNavigationBar: const Satoshinav(
              number: 2,
            )));
  }
}
