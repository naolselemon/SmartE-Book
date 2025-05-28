import 'dart:convert';

import 'package:appwrite/appwrite.dart';

import 'package:logger/logger.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchHistoryServices {
  final Client _client;
  late final Databases _databases;
  final Logger _logger = Logger();

  SearchHistoryServices(this._client) {
    _databases = Databases(_client);
  }

  Future<void> logSearch({
    required String userId,
    required String query,
    required Map<String, dynamic> desc,
    required String bookId,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['SEARCH_HISTORY_COLLECTION_ID']!,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'query': query,
          'description': jsonEncode(desc),
          'bookId': bookId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.e('Failed to log search: $e');
      throw Exception('Failed to log search: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSearchHistory(String userId) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['SEARCH_HISTORY_COLLECTION_ID']!,
        queries: [Query.equal('userId', userId), Query.orderDesc('timestamp')],
      );
      return documents.documents.map((doc) => doc.data).toList();
    } catch (e) {
      _logger.e('Failed to fetch search history: $e');
      return [];
    }
  }
}
