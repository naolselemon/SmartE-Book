import 'package:flutter/material.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/l10n/l10n.dart';
import 'package:smart_ebook/views/providers/settings_provider.dart';
import 'package:smart_ebook/views/screens/authentication_pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'poppins',
        fontFamilyFallback: const ['NotoSansEthiopic'],
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'poppins',
        fontFamilyFallback: const ['NotoSansEthiopic'],
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: settingsState.themeMode,
    );
  }
}
