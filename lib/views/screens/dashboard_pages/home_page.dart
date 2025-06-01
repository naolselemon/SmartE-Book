import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/recommendation_provider.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/book_detail_container.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/sectiontitle.dart';

class HomePage extends ConsumerWidget {
  final String userId;
  const HomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(booksWithRatingProvider);
          ref.invalidate(favoriteBooksWithRatingProvider);
          ref.invalidate(newBooksProvider);
          ref.invalidate(freeBooksProvider);
          ref.invalidate(recommendationsProvider);
          await Future.wait([
            ref.read(booksWithRatingProvider.future),
            ref.read(favoriteBooksWithRatingProvider.future),
            ref.read(newBooksProvider.future),
            ref.read(freeBooksProvider.future),
            ref.read(recommendationsProvider(userId).future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommendation Section
              const SectionTitle(title: 'Recommendations'),
              _buildRecommendations(ref),

              // All Books Section
              const SectionTitle(title: 'All Books'),
              _buildAllBooks(ref),

              // New Books Section
              const SectionTitle(title: 'New', showViewAll: true),
              _buildNewBooks(ref),

              // Trending Books Section
              const SectionTitle(title: 'Trending Books'),
              _buildTrendingBooks(ref),

              // Your Favourites Section
              const SectionTitle(title: 'Your Favourites', showViewAll: true),
              _buildFavoriteBooks(ref),

              // Free Books Section
              const SectionTitle(title: 'Free'),
              _buildFreeBooks(ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendations(WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider(userId));
    return recommendationsAsync.when(
      data: (recommendations) {
        print("Recommendations: $recommendations");
        if (recommendations.isEmpty) {
          return const Center(child: Text('No recommendations available'));
        }
        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final book = recommendations[index];
              return BookDetailContainer(
                bookId: book['bookId']?.toString() ?? '',
                imagePath:
                    book['imageUrl']?.toString() ??
                    'assets/images/placeholder.png',
                title: book['title']?.toString() ?? 'Unknown',
                author: book['author']?.toString() ?? 'Unknown',
                rating:
                    (book['rating'] is num ? book['rating'].toDouble() : 0.0),
                reviews: (book['reviews'] is num ? book['reviews'] as int : 0),
                summary: book['reason']?.toString() ?? '',
                audioId: book['audioId']?.toString() ?? '',
                audioUrl: book['audioUrl']?.toString() ?? '',
                fileId: book['fileId']?.toString() ?? '',
                price: (book['price'] is num ? book['price'].toDouble() : 0.0),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        print("Error fetching recommendations: $error");
        return Center(child: Text('Error: $error'));
      },
    );
  }

  Widget _buildTrendingBooks(WidgetRef ref) {
    final booksWithRatingAsync = ref.watch(booksWithRatingProvider);
    return SizedBox(
      height: 280,
      child: booksWithRatingAsync.when(
        data: (books) {
          final trendingBooks = books.where((b) => b.reviewCount >= 0).toList();
          if (trendingBooks.isEmpty) {
            return const Center(child: Text('No trending books available'));
          }
          trendingBooks.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
          final displayBooks = trendingBooks.take(4).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayBooks.length,
            itemBuilder: (context, index) {
              final bookWithRating = displayBooks[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  bookId: book.bookId,
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
                  audioId: book.audioId,
                  audioUrl: book.audioUrl,
                  fileId: book.fileId,
                  price: book.price,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          print("Error $error");
          return Center(child: Text('Error: $error'));
        },
      ),
    );
  }

  Widget _buildFavoriteBooks(WidgetRef ref) {
    final favoriteBooksAsync = ref.watch(favoriteBooksWithRatingProvider);
    return SizedBox(
      height: 280,
      child: favoriteBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No favorite books yet'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookWithRating = books[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  bookId: book.bookId,
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
                  audioId: book.audioId,
                  audioUrl: book.audioUrl,
                  fileId: book.fileId,
                  price: book.price,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildNewBooks(WidgetRef ref) {
    final newBooksAsync = ref.watch(newBooksProvider);
    return SizedBox(
      height: 280,
      child: newBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No new books available'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookWithRating = books[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  bookId: book.bookId,
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
                  audioId: book.audioId,
                  audioUrl: book.audioUrl,
                  fileId: book.fileId,
                  price: book.price,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFreeBooks(WidgetRef ref) {
    final freeBooksAsync = ref.watch(freeBooksProvider);
    return SizedBox(
      height: 280,
      child: freeBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No free books available'));
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookWithRating = books[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  bookId: book.bookId,
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
                  audioId: book.audioId,
                  audioUrl: book.audioUrl,
                  fileId: book.fileId,
                  price: book.price,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildAllBooks(WidgetRef ref) {
    final booksWithRatingAsync = ref.watch(booksWithRatingProvider);
    return SizedBox(
      height: 280,
      child: booksWithRatingAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('No books available'));
          }
          books.sort((a, b) => b.book.createdAt.compareTo(a.book.createdAt));
          final displayBooks = books.take(20).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayBooks.length,
            itemBuilder: (context, index) {
              final bookWithRating = displayBooks[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  bookId: book.bookId,
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
                  audioId: book.audioId,
                  audioUrl: book.audioUrl,
                  fileId: book.fileId,
                  price: book.price,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
