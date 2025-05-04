class Book {
  final String bookId;
  final String title;
  final String author;
  final double price;
  final String genre;
  final String date;
  final String description;
  final String coverPageId;
  final String coverPageUrl;
  final String fileId;
  final String audioId;
  final String authorImageId;
  final String authorImageUrl;
  final String createdAt;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.genre,
    required this.date,
    required this.description,
    required this.coverPageId,
    required this.coverPageUrl,
    required this.fileId,
    required this.audioId,
    required this.authorImageId,
    required this.authorImageUrl,
    required this.createdAt,
  });

  factory Book.fromDocument(Map<String, dynamic> doc) {
    return Book(
      bookId: doc['\$id'] ?? '',
      title: doc['title'] ?? '',
      author: doc['author'] ?? '',
      price: (doc['price'] ?? 0.0).toDouble(),
      genre: doc['genre'] ?? '',
      date: doc['date'] ?? '',
      description: doc['description'] ?? '',
      coverPageId: doc['coverPageId'] ?? '',
      coverPageUrl: doc['coverPageUrl'] ?? '',
      fileId: doc['fileId'] ?? '',
      audioId: doc['audioId'] ?? '',
      authorImageId: doc['authorImageId'] ?? '',
      authorImageUrl: doc['authorImageUrl'] ?? '',
      createdAt: doc['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '\$id': bookId,
      'title': title,
      'author': author,
      'price': price,
      'genre': genre,
      'date': date,
      'description': description,
      'coverPageId': coverPageId,
      'coverPageUrl': coverPageUrl,
      'fileId': fileId,
      'audioId': audioId,
      'authorImageId': authorImageId,
      'authorImageUrl': authorImageUrl,
      'createdAt': createdAt,
    };
  }
}
