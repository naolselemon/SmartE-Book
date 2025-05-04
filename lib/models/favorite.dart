class Favorite {
  final String favoriteId;
  final String userId;
  final String bookId;
  final String createdAt;

  Favorite({
    required this.favoriteId,
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  factory Favorite.fromDocument(Map<String, dynamic> doc) {
    return Favorite(
      favoriteId: doc['\$id'] ?? '',
      userId: doc['userId'] ?? '',
      bookId: doc['bookId'] ?? '',
      createdAt: doc['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': favoriteId,
      'userId': userId,
      'bookId': bookId,
      'createdAt': createdAt,
    };
  }
}
