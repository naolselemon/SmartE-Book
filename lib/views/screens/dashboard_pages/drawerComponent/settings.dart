import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/views/providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          localizations.settingsTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.language,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<Locale>(
              value: settingsState.locale,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('am'), child: Text('Amharic')),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  settingsNotifier.setLocale(locale);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              localizations.theme,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(localizations.lightTheme),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: settingsState.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.setThemeMode(value);
                  }
                },
              ),
            ),
            ListTile(
              title: Text(localizations.darkTheme),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: settingsState.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.setThemeMode(value);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('System'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: settingsState.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settingsNotifier.setThemeMode(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
