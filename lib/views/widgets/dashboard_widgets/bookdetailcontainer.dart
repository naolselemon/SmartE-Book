import 'package:flutter/material.dart';
import '../../screens/dashboard_pages/bookdetailpage.dart';

class BookDetailContainer extends StatelessWidget {
  final String imagePath;
  final String title;
  final String author;
  final double rating;
  final int reviews;
  final String summary;

  const BookDetailContainer({
    super.key,
    required this.imagePath,
    this.title = '',
    this.author = '',
    this.rating = 0.0,
    this.reviews = 0,
    this.summary = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookDetailPage(
                  title: title,
                  author: author,
                  imagePath: imagePath,
                  rating: rating,
                  reviews: reviews,
                  summary: summary,
                ),
          ),
        );
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
