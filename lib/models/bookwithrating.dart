import 'package:smart_ebook/models/book.dart';

class BookWithRating {
  final Book book;
  final double rating;
  final int reviewCount;

  BookWithRating({
    required this.book,
    required this.rating,
    required this.reviewCount,
  });
}
