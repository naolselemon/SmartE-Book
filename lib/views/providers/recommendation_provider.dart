import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/controllers/gemini_services.dart';
import 'package:smart_ebook/controllers/recommendation_data_service.dart';

final appwriteServiceProvider = Provider((ref) => RecommendationDataService());
final geminiServiceProvider = Provider((ref) => GeminiService());

final recommendationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final appwriteService = ref.watch(appwriteServiceProvider);
      final geminiService = ref.watch(geminiServiceProvider);

      final searchHistory = await appwriteService.getUserSearchHistory(userId);
      final favorites = await appwriteService.getUserFavorites(userId);
      final reviews = await appwriteService.getUserReviews(userId);
      final books = await appwriteService.getBooks();

      return geminiService.getBookRecommendations(
        searchHistory: searchHistory,
        favorites: favorites,
        reviews: reviews,
        books: books,
      );
    });
