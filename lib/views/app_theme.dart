import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.light(
      primary: Colors.deepPurple,
      primaryContainer: Colors.deepPurple[300]!,
      secondary: Colors.amber,
      secondaryContainer: Colors.amber[300]!,
      surface: Colors.grey[100]!,
      error: Colors.red[700]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.grey[900]!,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(35, 8, 90, 1),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontFamily: 'poppins',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      displayMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      displaySmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      titleLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        color: Colors.grey,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 14,
        color: Colors.grey,
      ),
      bodySmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 12,
        color: Colors.grey,
      ),
      labelLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        side: const BorderSide(color: Colors.deepPurple),
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      labelStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
      hintStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[100],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titleTextStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        color: Colors.grey,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.deepPurple[800],
      contentTextStyle: const TextStyle(
        fontFamily: 'poppins',
        color: Colors.white,
      ),
      actionTextColor: Colors.amber,
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 1),
    iconTheme: const IconThemeData(color: Colors.deepPurple),
    fontFamily: 'poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    primaryColor: Colors.deepPurple,
    colorScheme: ColorScheme.dark(
      primary: Colors.deepPurple,
      primaryContainer: Colors.deepPurple[700]!,
      secondary: Colors.amber,
      secondaryContainer: Colors.amber[700]!,
      surface: Colors.grey[800]!,
      error: Colors.red[700]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black38,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(35, 8, 90, 1),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontFamily: 'poppins',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'poppins',
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontFamily: 'poppins',
        fontSize: 12,
        color: Colors.grey,
      ),
      labelLarge: TextStyle(
        fontFamily: 'poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.deepPurple,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.deepPurple),
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: const TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      labelStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
      hintStyle: const TextStyle(fontFamily: 'poppins', color: Colors.grey),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titleTextStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.deepPurple[800],
      contentTextStyle: const TextStyle(
        fontFamily: 'poppins',
        color: Colors.white,
      ),
      actionTextColor: Colors.amber,
    ),
    dividerTheme: const DividerThemeData(color: Colors.grey, thickness: 1),
    iconTheme: const IconThemeData(color: Colors.grey),
    fontFamily: 'poppins',
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
