import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;

  SettingsState({required this.locale, required this.themeMode});

  SettingsState copyWith({Locale? locale, ThemeMode? themeMode}) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _localKey = 'locale';
  static const _themeKey = 'themeMode';

  SettingsNotifier()
    : super(
        SettingsState(locale: const Locale('en'), themeMode: ThemeMode.system),
      ) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final localCode = prefs.getString(_localKey) ?? 'en';
    final themeCode = prefs.getString(_themeKey) ?? 'system';

    state = state.copyWith(
      locale: Locale(localCode),
      themeMode:
          themeCode == 'light'
              ? ThemeMode.light
              : themeCode == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system,
    );
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localKey, locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _themeKey,
      themeMode == ThemeMode.light
          ? 'light'
          : themeMode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
  }
}

final settingsProvider = StateNotifierProvider((ref) {
  return SettingsNotifier();
});
