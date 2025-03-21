import 'package:flutter/material.dart';

import 'audioplaypage.dart';

class BookDetailPage extends StatelessWidget {
  final String title;
  final String author;
  final String imagePath;
  final double rating;
  final int reviews;
  final String summary;
  final String? localAudioPath;

  const BookDetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.imagePath,
    required this.rating,
    required this.reviews,
    required this.summary,
    this.localAudioPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.deepPurple,
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.bookmark_border, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Image.asset(imagePath, height: 200),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "by $author",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      SizedBox(width: 5),
                      Text(
                        "$rating",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text("($reviews Reviews)"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(summary),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.menu_book, color: Colors.deepPurple),
                    label: Text("Reading"),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AudioPlayScreen(
                                title: title,
                                author: author,
                                imagePath: imagePath,
                                localAudioPath:
                                    "assets/audio/ChaAtomicHabits.wav",
                              ),
                        ),
                      );
                    },
                    icon: Icon(Icons.headphones, color: Colors.deepPurple),
                    label: Text("Listening"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
