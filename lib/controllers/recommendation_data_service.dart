import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecommendationDataService {
  late final Client client;
  late final Databases databases;
  late final Account account;

  RecommendationDataService() {
    client =
        Client()
          ..setEndpoint(dotenv.env['API_ENDPOINT']!)
          ..setProject(dotenv.env['PROJECT_ID']!);
    databases = Databases(client);
    account = Account(client);
  }

  Future<List<Map<String, dynamic>>> getUserSearchHistory(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['SEARCH_HISTORY_COLLECTION_ID']!,
        queries: [Query.equal('userId', userId)],
      );
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['FAVORITES_COLLECTION_ID']!,
        queries: [Query.equal('userId', userId)],
      );
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['REVIEWS_COLLECTION_ID']!,
        queries: [Query.equal('userId', userId)],
      );
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await databases.listDocuments(
        databaseId: dotenv.env['DATABASE_ID']!,
        collectionId: dotenv.env['BOOKS_COLLECTION_ID']!,
      );
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final user = await account.get();
      return user.$id;
    } catch (e) {
      throw Exception('Failed to get user ID: $e');
    }
  }
}
