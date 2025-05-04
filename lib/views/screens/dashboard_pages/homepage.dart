import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/bookdetailcontainer.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/sectiontitle.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Books Section
            const SectionTitle(title: 'Trending Books'),
            _buildTrendingBooks(ref),

            // Your Favourites Section
            const SectionTitle(title: 'Your Favourites', showViewAll: true),
            _buildFavoriteBooks(ref),

            // New Books Section
            const SectionTitle(title: 'New', showViewAll: true),
            _buildNewBooks(ref),

            // Free Books Section
            const SectionTitle(title: 'Free'),
            _buildFreeBooks(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingBooks(WidgetRef ref) {
    final booksWithRatingAsync = ref.watch(booksWithRatingProvider);
    return SizedBox(
      height: 180,
      child: booksWithRatingAsync.when(
        data: (books) {
          // Sort by review count (trending)
          final trendingBooks =
              books..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
          final displayBooks = trendingBooks.take(4).toList(); // Show top 4
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayBooks.length,
            itemBuilder: (context, index) {
              final bookWithRating = displayBooks[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
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

  Widget _buildFavoriteBooks(WidgetRef ref) {
    final favoriteBooksAsync = ref.watch(favoriteBooksWithRatingProvider);
    return SizedBox(
      height: 180,
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
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
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
      height: 180,
      child: newBooksAsync.when(
        data: (books) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookWithRating = books[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
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
      height: 180,
      child: freeBooksAsync.when(
        data: (books) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final bookWithRating = books[index];
              final book = bookWithRating.book;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: BookDetailContainer(
                  imagePath: book.coverPageUrl,
                  title: book.title,
                  author: book.author,
                  rating: bookWithRating.rating,
                  reviews: bookWithRating.reviewCount,
                  summary: book.description,
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
