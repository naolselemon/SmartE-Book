import "package:flutter/material.dart";

class BookCoverpage extends StatelessWidget {
  const BookCoverpage({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      height: 200,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
    );
  }
}
