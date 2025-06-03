import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;

import 'package:logger/logger.dart';
import 'package:smart_ebook/models/book.dart';
import 'package:smart_ebook/models/book_with_rating.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchService {
  final Client _client;
  late final Databases _databases;
  final Logger _logger = Logger();

  SearchService(this._client) {
    _databases = Databases(_client);
  }

  Future<List<BookWithRating>> searchBooks(
    String query,
    List<BookWithRating> booksWithRating,
  ) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      // Perform searches concurrently with error handling
      final results = await Future.wait([
        _databases
            .listDocuments(
              databaseId: dotenv.env['DATABASE_ID']!,
              collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
              queries: [Query.search('title', query)],
            )
            .catchError((e) {
              _logger.e('Title search failed: $e');
              return appwrite_models.DocumentList(total: 0, documents: []);
            }),
        _databases
            .listDocuments(
              databaseId: dotenv.env['DATABASE_ID']!,
              collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
              queries: [Query.search('author', query)],
            )
            .catchError((e) {
              _logger.e('Author search failed: $e');
              return appwrite_models.DocumentList(total: 0, documents: []);
            }),
        _databases
            .listDocuments(
              databaseId: dotenv.env['DATABASE_ID']!,
              collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
              queries: [Query.search('genre', query)],
            )
            .catchError((e) {
              _logger.e('Genre search failed: $e');
              return appwrite_models.DocumentList(total: 0, documents: []);
            }),
      ]);

      // Combine and deduplicate results using $id
      final allBooks = <String, Book>{};
      for (final search in results) {
        for (final doc in search.documents) {
          allBooks[doc.$id] = Book.fromDocument(doc.data);
        }
      }

      // Map to BookWithRating using booksWithRatingProvider data
      final booksMap = {
        for (final bwr in booksWithRating) bwr.book.bookId: bwr,
      };
      return allBooks.values.map((book) {
        final bwr = booksMap[book.bookId];
        return bwr ?? BookWithRating(book: book, rating: 0.0, reviewCount: 0);
      }).toList();
    } catch (e) {
      _logger.e('Failed to search: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getUniqueAuthors() async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
      );
      final authorMap = <String, String>{};
      for (final doc in documents.documents) {
        final author = doc.data['author'] as String;
        final authorImageUrl = doc.data['authorImageUrl'] as String? ?? '';
        if (!authorMap.containsKey(author) || authorImageUrl.isNotEmpty) {
          authorMap[author] = authorImageUrl;
        }
      }
      return authorMap.entries
          .map((entry) => {'name': entry.key, 'imageUrl': entry.value})
          .toList()
        ..sort((a, b) => a['name']!.compareTo(b['name']!));
    } catch (e) {
      _logger.e('Failed to fetch authors: $e');
      return [];
    }
  }
}
