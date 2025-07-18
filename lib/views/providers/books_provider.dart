import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/controllers/book_services.dart';
import 'package:smart_ebook/controllers/file_download_services.dart';
import 'package:smart_ebook/models/book.dart';
import 'package:smart_ebook/models/review.dart';

import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/models/book_with_rating.dart';

// Provider for Appwrite Client
final appwriteClientProvider = Provider<Client>((ref) {
  final userServices = ref.watch(userProvider);
  return userServices.client;
});

final fileDownloadServiceProvider = Provider<FileDownloadService>((ref) {
  return FileDownloadService();
});

final downloadedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookServices = ref.watch(bookServicesProvider);
  return await bookServices.getDownloadedBooks();
});

// Providers
final bookServicesProvider = Provider<BookServices>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return BookServices(
    client: client,
    fileDownloadService: ref.watch(fileDownloadServiceProvider),
  );
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

final reviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  bookId,
) async {
  final bookServices = ref.watch(bookServicesProvider);
  final reviewsList = await bookServices.getReviews(bookId);
  return reviewsList.documents
      .map((doc) => Review.fromDocument(doc.data))
      .toList();
});

// Favorite Status Provider
final favoriteStatusProvider = FutureProvider.family<String?, String>((
  ref,
  bookId,
) async {
  final profileState = ref.watch(profileProvider);
  if (profileState.user == null) {
    return null;
  }
  final userId = profileState.user!.id;
  final bookServices = ref.watch(bookServicesProvider);
  return await bookServices.getFavoriteId(userId, bookId);
});
