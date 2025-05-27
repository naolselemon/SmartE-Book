import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/librarypage.dart';
import 'package:smart_ebook/views/screens/searches_pages/search_page.dart';

import 'drawerpage.dart';
import 'homepage.dart';

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
    });
  }

  int _selectedIndex = 0;

  final List<Widget> _pages = [HomePage(), SearchScreen(), LibraryPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(35, 8, 90, 1),
        title: Center(
          child: Text('ReadLink', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage:
                  profile.user?.profileImageUrl != null
                      ? NetworkImage(profile.user!.profileImageUrl!)
                      : AssetImage('assets/images/profile_picture.jpg'),
              radius: 16,
            ),
          ),
        ],
      ),
      drawer: DrawerPage(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
