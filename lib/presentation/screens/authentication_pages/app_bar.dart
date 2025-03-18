import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 109,
      backgroundColor: const Color.fromRGBO(35, 8, 90, 1),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(109);
}
