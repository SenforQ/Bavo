import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const BavoApp());
}

class BavoApp extends StatelessWidget {
  const BavoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bavo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFFFFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
    );
  }
}
