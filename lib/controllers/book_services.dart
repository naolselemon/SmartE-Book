import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_ebook/models/book.dart';
import 'package:smart_ebook/models/bookwithrating.dart';

class BookServices {
  final Client _client;
  late Databases _databases;
  late Storage _storage;

  BookServices({required Client client})
    : _client =
          client
            ..setEndpoint(dotenv.env['API_ENDPOINT']!)
            ..setProject(dotenv.env['PROJECT_ID']!)
            ..setSelfSigned(status: true) {
    _databases = Databases(_client);
    _storage = Storage(_client);
  }

  Future<List<BookWithRating>> getBooksWithRatings() async {
    try {
      final reviewsList = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['REVIEWS_COLLECTION_ID']!,
      );
      final reviews = reviewsList.documents;

      final ratingMap = <String, double>{};
      final reviewCountMap = <String, int>{};
      for (var review in reviews) {
        final bookId = review.data['bookId'] as String;
        final rating = (review.data['rating'] as num).toDouble();
        ratingMap[bookId] =
            ((ratingMap[bookId] ?? 0) * (reviewCountMap[bookId] ?? 0) +
                rating) /
            ((reviewCountMap[bookId] ?? 0) + 1);
        reviewCountMap[bookId] = (reviewCountMap[bookId] ?? 0) + 1;
      }

      final books = await getBooks();
      return books.map((book) {
        final rating = ratingMap[book.bookId] ?? 0.0;
        final reviewCount = reviewCountMap[book.bookId] ?? 0;
        return BookWithRating(
          book: book,
          rating: rating,
          reviewCount: reviewCount,
        );
      }).toList();
    } catch (e) {
      print('Failed to fetch books with ratings: $e');
      throw Exception('Failed to fetch books with ratings: $e');
    }
  }

  Future<List<BookWithRating>> getFavoriteBooksWithRatings(
    String userId,
  ) async {
    try {
      final favoritesList = await getFavorites(userId);
      final favoriteBookIds =
          favoritesList.documents
              .map((doc) => doc.data['bookId'] as String)
              .toList();
      if (favoriteBookIds.isEmpty) return [];

      final books = await getBooks(
        queries: favoriteBookIds.map((id) => Query.equal('\$id', id)).toList(),
      );
      final booksWithRating = await getBooksWithRatings();
      final booksMap = {for (var b in booksWithRating) b.book.bookId: b};
      return books.map((book) {
        final bwr = booksMap[book.bookId];
        return bwr ?? BookWithRating(book: book, rating: 0.0, reviewCount: 0);
      }).toList();
    } catch (e) {
      print('Failed to fetch favorite books with ratings: $e');
      throw Exception('Failed to fetch favorite books with ratings: $e');
    }
  }

  //fallback to empty list
  Book buildBookWithUrls(Map<String, dynamic> data) {
    if (data['coverPageUrl'] == null || data['coverPageUrl'].isEmpty) {
      final fileId = data['coverPageId'];
      if (fileId != null && fileId.isNotEmpty) {
        data['coverPageUrl'] =
            '${dotenv.env['API_ENDPOINT']}/v1/storage/buckets/${dotenv.env['BUCKET_ID']}/files/$fileId/view?project=${dotenv.env['PROJECT_ID']}';
      } else {
        data['coverPageUrl'] = '';
      }
    }
    if (data['authorImageUrl'] == null || data['authorImageUrl'].isEmpty) {
      final authorImageId = data['authorImageId'];
      if (authorImageId != null && authorImageId.isNotEmpty) {
        data['authorImageUrl'] =
            '${dotenv.env['API_ENDPOINT']}/v1/storage/buckets/${dotenv.env['BUCKET_ID']}/files/$authorImageId/view?project=${dotenv.env['PROJECT_ID']}';
      } else {
        data['authorImageUrl'] = '';
      }
    }
    return Book.fromDocument(data);
  }

  Future<List<Book>> getBooks({List<String>? queries}) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
        queries: queries,
      );
      return documents.documents
          .map((doc) => buildBookWithUrls(doc.data))
          .toList();
    } catch (e) {
      print('Failed to fetch books: $e');
      throw Exception('Failed to fetch books: $e');
    }
  }

  Future<List<Book>> getTopRatedBooks({int limit = 10}) async {
    try {
      final reviewsList = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['REVIEWS_COLLECTION_ID']!,
      );
      final reviews = reviewsList.documents;

      final ratingMap = <String, double>{};
      final reviewCountMap = <String, int>{};
      for (var review in reviews) {
        final bookId = review.data['bookId'] as String;
        final rating = (review.data['rating'] as num).toDouble();
        ratingMap[bookId] =
            ((ratingMap[bookId] ?? 0) * (reviewCountMap[bookId] ?? 0) +
                rating) /
            ((reviewCountMap[bookId] ?? 0) + 1);
        reviewCountMap[bookId] = (reviewCountMap[bookId] ?? 0) + 1;
      }

      final booksList = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
      );
      final books =
          booksList.documents
              .map((doc) => buildBookWithUrls(doc.data))
              .toList();

      books.sort((a, b) {
        final ratingA = ratingMap[a.bookId] ?? 0.0;
        final ratingB = ratingMap[b.bookId] ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      return books.take(limit).toList();
    } catch (e) {
      print('Failed to fetch top-rated books: $e');
      throw Exception('Failed to fetch top-rated books: $e');
    }
  }

  Future<Document> addFavorite(String userId, String bookId) async {
    try {
      return await _databases.createDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['FAVORITES_COLLECTION_ID']!,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'bookId': bookId,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to add favorite: $e');
      throw Exception('Failed to add favorite: $e');
    }
  }

  Future<void> removeFavorite(String favoriteId) async {
    try {
      await _databases.deleteDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['FAVORITES_COLLECTION_ID']!,
        documentId: favoriteId,
      );
    } catch (e) {
      print('Failed to remove favorite: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }

  Future<DocumentList> getFavorites(String userId) async {
    try {
      return await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['FAVORITES_COLLECTION_ID']!,
        queries: [Query.equal('userId', userId)],
      );
    } catch (e) {
      print('Failed to fetch favorites: $e');
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  Future<Document> addReview(
    String userId,
    String bookId,
    double rating,
    String comment,
  ) async {
    try {
      return await _databases.createDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['REVIEWS_COLLECTION_ID']!,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'bookId': bookId,
          'rating': rating,
          'comment': comment,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Failed to add review: $e');
      throw Exception('Failed to add review: $e');
    }
  }

  Future<DocumentList> getReviews(String bookId) async {
    try {
      return await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['REVIEWS_COLLECTION_ID']!,
        queries: [Query.equal('bookId', bookId)],
      );
    } catch (e) {
      print('Failed to fetch reviews: $e');
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<Map<String, dynamic>> getBookRatingAndReviewCount(
    String bookId,
  ) async {
    try {
      final reviews = await getReviews(bookId);
      final reviewCount = reviews.documents.length;
      final averageRating =
          reviewCount > 0
              ? reviews.documents
                      .map((doc) => (doc.data['rating'] as num).toDouble())
                      .reduce((a, b) => a + b) /
                  reviewCount
              : 0.0;
      return {'rating': averageRating, 'reviewCount': reviewCount};
    } catch (e) {
      return {'rating': 0.0, 'reviewCount': 0};
    }
  }

  Future<List<int>> getFile(String fileId) async {
    try {
      final fileData = await _storage.getFileDownload(
        bucketId: dotenv.env['BUCKET_ID']!,
        fileId: fileId,
      );
      return fileData.toList();
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
}
