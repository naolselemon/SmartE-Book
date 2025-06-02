import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/views/screens/authentication_pages/signin.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/drawerComponent/profile.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/drawerComponent/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/librarypage.dart';

class DrawerPage extends ConsumerWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(35, 8, 90, 1),
            ),
            child: Text(
              localizations.appTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'poppins',
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(localizations.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(localizations.library),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LibraryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(localizations.profile),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.settingsTitle),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(localizations.signOut),
            onTap: () async {
              try {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Signing out...')));
                await ref.read(profileProvider.notifier).signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              } catch (e) {
                print('Error signing out: $e');
              }
            },
          ),
        ],
      ),
    );
  }
}
