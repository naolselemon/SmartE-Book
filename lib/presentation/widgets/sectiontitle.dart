import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final bool showViewAll;

  const SectionTitle({super.key, required this.title, this.showViewAll = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (showViewAll)
            TextButton(
              onPressed: () {},
              child:Text('View All', style: TextStyle(color: Colors.deepPurple)),
            ),
        ],
      ),
    );
  }
}