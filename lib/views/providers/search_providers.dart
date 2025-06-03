import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:smart_ebook/controllers/search_history_services.dart';
import 'package:smart_ebook/controllers/search_service.dart';
import 'package:smart_ebook/models/book.dart';
import 'package:smart_ebook/models/book_with_rating.dart';

import 'package:smart_ebook/views/providers/books_provider.dart';

// Providers
final searchServiceProvider = Provider<SearchService>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return SearchService(client);
});

final searchHistoryServiceProvider = Provider<SearchHistoryServices>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return SearchHistoryServices(client);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final genresProvider = FutureProvider<List<String>>((ref) async {
  final bookServices = ref.watch(bookServicesProvider);
  try {
    final books = await bookServices.getBooks();
    final genres = books.map((book) => book.genre).toSet().toList();
    return genres..sort();
  } catch (e) {
    ref.read(loggerProvider).e('Failed to fetch genres: $e');
    return [];
  }
});

final authorsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  try {
    return await searchService.getUniqueAuthors();
  } catch (e) {
    ref.read(loggerProvider).e('Failed to fetch authors: $e');
    return [];
  }
});

final searchResultsProvider = FutureProvider<List<BookWithRating>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final searchService = ref.watch(searchServiceProvider);
  final booksWithRating = await ref.watch(booksWithRatingProvider.future);
  final logger = ref.watch(loggerProvider);

  if (query.isEmpty) return [];

  try {
    return await searchService.searchBooks(query, booksWithRating);
  } catch (e) {
    logger.e('Failed to fetch search results: $e');
    return [];
  }
});

final trendingBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookServices = ref.watch(bookServicesProvider);
  try {
    return await bookServices.getTopRatedBooks(limit: 5);
  } catch (e) {
    ref.read(loggerProvider).e('Failed to fetch trending books: $e');
    return [];
  }
});

final searchHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      userId,
    ) async {
      final searchHistoryService = ref.watch(searchHistoryServiceProvider);
      try {
        return await searchHistoryService.getSearchHistory(userId);
      } catch (e) {
        ref
            .read(loggerProvider)
            .e('Failed to fetch search history for user $userId: $e');
        return [];
      }
    });

final loggerProvider = Provider<Logger>((ref) => Logger());
