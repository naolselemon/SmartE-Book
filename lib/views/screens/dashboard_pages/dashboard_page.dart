import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/drawerComponent/profile.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/library_page.dart';
import 'package:smart_ebook/views/screens/searches_pages/search_page.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/drawer_page.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/home_page.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() {
    return _DashboardScreenState();
  }
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).fetchUser();
      ref.invalidate(favoriteBooksWithRatingProvider);
    });
  }

  int _selectedIndex = 0;

  List<Widget> _buildPages(String? userId) {
    return [HomePage(userId: userId ?? ''), SearchScreen(), LibraryPage()];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);
    final pages = _buildPages(profile.user?.id); // Get userId from profile

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(35, 8, 90, 1),
        title: Center(
          child: Text(
            localizations.appTitle,
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage:
                    profile.user?.profileImageUrl != null
                        ? NetworkImage(profile.user!.profileImageUrl!)
                        : AssetImage('assets/images/profile_picture.jpg'),
                radius: 16,
              ),
            ),
          ),
        ],
      ),
      drawer: DrawerPage(),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: localizations.home,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: localizations.search,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: localizations.library,
          ),
        ],
      ),
    );
  }
}
