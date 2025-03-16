import 'package:flutter/material.dart';
import 'package:smart_ebook/presentation/screens/searchs/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 157, 131, 210),
        ),
      ),

      home: LandingPageScreens(),
    );
  }
}
