import 'package:flutter/material.dart';
import 'package:satoshi/view/widget/bottomnav_widget.dart';
import 'package:satoshi/view/widget/webview_widget.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() {
    return _HistoryViewState();
  }
}

class _HistoryViewState extends State<HistoryView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: WebviewWidget(
          url: "https://pnglobalinternational.com/widget/signal/history",
        )),
        bottomNavigationBar: const Satoshinav(
          number: 1,
        ));
  }
}
