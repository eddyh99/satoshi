import 'package:flutter/material.dart';
import 'package:satoshi/view/widget/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() {
    return _LanguageViewState();
  }
}

class _LanguageViewState extends State<LanguageView>
    with WidgetsBindingObserver {
  String selectedLanguage = 'en'; // Default selected language

  // List of supported languages and their language codes
  final List<Map<String, String>> languages = [
    {'name': 'Deutsch', 'code': 'de'},
    {'name': 'English', 'code': 'en'},
    {'name': 'Español', 'code': 'es'},
    {'name': 'Français', 'code': 'fr'},
    {'name': 'हिंदी', 'code': 'hi'},
    {'name': 'Bahasa Indonesia', 'code': 'id'},
    {'name': 'Português', 'code': 'pt'},
    {'name': 'Русский', 'code': 'ru'},
    {'name': 'Italian', 'code': 'it'},
    {'name': 'Arabic', 'code': 'ar'},
    {'name': 'Chinese', 'code': 'zh-CN'},
    {'name': 'Japanese', 'code': 'ja'},
    {'name': 'Turkish', 'code': 'tr'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  // Save selected language to shared preferences
  Future<void> _saveSelectedLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const TextWidget(text: "Choose Language", fontsize: 16),
        elevation: 0, // Remove the default AppBar shadow
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(1.0), // Height of the bottom border
          child: Container(
            color: Colors.grey, // Color of the bottom border
            height: 1.0, // Thickness of the bottom border
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            var language = languages[index];
            return ListTile(
              title: TextWidget(
                  text: '${language['name']} (${language['code']})',
                  fontsize: 16),
              trailing: selectedLanguage == language['code']
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () async {
                setState(() {
                  selectedLanguage = language['code']!;
                });
                await _saveSelectedLanguage(
                    language['code']!); // Save selection
              },
            );
          },
        ),
      ),
    );
  }
}
