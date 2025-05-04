import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/controllers/book_services.dart';

import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/models/bookwithrating.dart';

// Provider for Appwrite Client
final appwriteClientProvider = Provider<Client>((ref) {
  final userServices = ref.watch(userProvider);
  return userServices.client;
});

// Providers
final bookServicesProvider = Provider<BookServices>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return BookServices(client: client);
});

final booksWithRatingProvider = FutureProvider<List<BookWithRating>>((
  ref,
) async {
  final bookServices = ref.watch(bookServicesProvider);
  return await bookServices.getBooksWithRatings();
});

final favoriteBooksWithRatingProvider = FutureProvider<List<BookWithRating>>((
  ref,
) async {
  final profileState = ref.watch(profileProvider);
  if (profileState.user == null) {
    return [];
  }
  final userId = profileState.user!.id;
  final bookServices = ref.watch(bookServicesProvider);
  return await bookServices.getFavoriteBooksWithRatings(userId);
});

final newBooksProvider = FutureProvider<List<BookWithRating>>((ref) async {
  final bookServices = ref.watch(bookServicesProvider);
  final booksWithRating = await ref.watch(booksWithRatingProvider.future);
  final booksMap = {for (var b in booksWithRating) b.book.bookId: b};
  final documents = await bookServices.getBooks(
    queries: [Query.orderDesc('createdAt'), Query.limit(5)],
  );
  return documents.map((book) {
    final bwr = booksMap[book.bookId];
    return bwr ?? BookWithRating(book: book, rating: 0.0, reviewCount: 0);
  }).toList();
});

final freeBooksProvider = FutureProvider<List<BookWithRating>>((ref) async {
  final bookServices = ref.watch(bookServicesProvider);
  final booksWithRating = await ref.watch(booksWithRatingProvider.future);
  final booksMap = {for (var b in booksWithRating) b.book.bookId: b};
  final documents = await bookServices.getBooks(
    queries: [Query.equal('price', 0.0)],
  );
  return documents.map((book) {
    final bwr = booksMap[book.bookId];
    return bwr ?? BookWithRating(book: book, rating: 0.0, reviewCount: 0);
  }).toList();
});
