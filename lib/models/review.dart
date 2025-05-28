class Review {
  final String reviewId;
  final String userId;
  final String bookId;
  final double rating;
  final String comment;
  final String createdAt;

  Review({
    required this.reviewId,
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromDocument(Map<String, dynamic> doc) {
    return Review(
      reviewId: doc['\$id'] ?? '',
      userId: doc['userId'] ?? '',
      bookId: doc['bookId'] ?? '',
      rating: (doc['rating'] ?? 0.0).toDouble(),
      comment: doc['comment'] ?? '',
      createdAt: doc['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': reviewId,
      'userId': userId,
      'bookId': bookId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
