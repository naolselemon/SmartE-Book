import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Book {
  final String id;
  final String title;
  final String author;
  final String authorImage;
  final String category;
  final String description;
  final double rating;
  final double price;
  final int sold;
  final String coverImage;

  Book({
    required this.title,
    required this.author,
    required this.authorImage,
    required this.category,
    required this.description,
    required this.rating,
    required this.price,
    required this.sold,
    required this.coverImage,
  }) : id = uuid.v4();
}
