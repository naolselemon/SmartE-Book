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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromRGBO(35, 8, 90, 1),
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_border,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Image.network(
                    imagePath,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                  ),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "by $author",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        "$rating",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Text("($reviews Reviews)"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(summary),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_book, color: Colors.deepPurple),
                    label: const Text("Reading"),
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
                    icon: const Icon(
                      Icons.headphones,
                      color: Colors.deepPurple,
                    ),
                    label: const Text("Listening"),
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
