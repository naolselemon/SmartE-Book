import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_ebook/views/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.settingsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w600,
          ),
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
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Locale>(
              value: settingsState.locale,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text(
                    'English',
                    style: TextStyle(fontFamily: 'poppins'),
                  ),
                ),
                DropdownMenuItem(
                  value: Locale('am'),
                  child: Text(
                    'አማርኛ',
                    style: TextStyle(fontFamily: 'NotoSansEthiopic'),
                  ),
                ),
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
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(
                localizations.darkTheme,
                style: const TextStyle(fontFamily: 'poppins', fontSize: 16),
              ),
              value: settingsState.themeMode == ThemeMode.dark,
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                settingsNotifier.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
          ],
        ),
      ),
    );
  }
}
