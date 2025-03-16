import "package:flutter/material.dart";

class AuthorsImages extends StatelessWidget {
  const AuthorsImages({super.key, required this.image, required this.name});

  final String image;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        spacing: 4,
        children: [
          CircleAvatar(radius: 40, foregroundImage: AssetImage(image)),
          Text(name),
        ],
      ),
    );
  }
}
