import 'package:flutter/material.dart';

import 'package:smart_ebook/presentation/screens/authentication_pages/signin.dart';
import 'package:smart_ebook/presentation/screens/authentication_pages/signup.dart';
import 'package:smart_ebook/presentation/screens/authentication_pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      routes: {
        'signup': (context) => const SignUp(),
        'signin': (context) => const SignIn(),
      },

    );
  }
}
