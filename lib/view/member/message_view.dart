import 'package:flutter/material.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/webview_widget.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() {
    return _MessageViewState();
  }
}

class _MessageViewState extends State<MessageView> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: WebviewWidget(
          url:
              "https://translate.google.com/translate?sl=auto&tl=en&hl=en&u=https://pnglobalinternational.com/widget/message",
        )),
        bottomNavigationBar: const Satoshinav(
          number: 2,
        ));
  }
}
