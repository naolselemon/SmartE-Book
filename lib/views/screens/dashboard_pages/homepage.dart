import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/bookdetailcontainer.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/sectiontitle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(booksWithRatingProvider);
          ref.invalidate(favoriteBooksWithRatingProvider);
          ref.invalidate(newBooksProvider);
          ref.invalidate(freeBooksProvider);
          await Future.wait([
            ref.read(booksWithRatingProvider.future),
            ref.read(favoriteBooksWithRatingProvider.future),
            ref.read(newBooksProvider.future),
            ref.read(freeBooksProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // All Books Section
              SectionTitle(title: localizations.allBooks),
              _buildAllBooks(ref, context),

              // New Books Section
              SectionTitle(title: localizations.newBooks, showViewAll: true),
              _buildNewBooks(ref, context),

              // Trending Books Section
              SectionTitle(title: localizations.trendingBooks),
              _buildTrendingBooks(ref, context),

              // Your Favourites Section
              SectionTitle(title: localizations.yourFavourites),
              _buildFavoriteBooks(ref, context),

              // Free Books Section
              SectionTitle(title: localizations.freeBooks),
              _buildFreeBooks(ref, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingBooks(WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final booksWithRatingAsync = ref.watch(booksWithRatingProvider);
    return SizedBox(
      height: 180,
      child: booksWithRatingAsync.when(
        data: (books) {
          final trendingBooks = books.where((b) => b.reviewCount >= 0).toList();
          if (trendingBooks.isEmpty) {
            return Center(child: Text(localizations.noTrendingBooks));
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
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildFavoriteBooks(WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final favoriteBooksAsync = ref.watch(favoriteBooksWithRatingProvider);
    return SizedBox(
      height: 180,
      child: favoriteBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Text(localizations.noFavoriteBooks));
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

  Widget _buildNewBooks(WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final newBooksAsync = ref.watch(newBooksProvider);
    return SizedBox(
      height: 180,
      child: newBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Text(localizations.newBooks));
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

  Widget _buildFreeBooks(WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final freeBooksAsync = ref.watch(freeBooksProvider);
    return SizedBox(
      height: 180,
      child: freeBooksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Text(localizations.freeBooks));
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

  Widget _buildAllBooks(WidgetRef ref, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final booksWithRatingAsync = ref.watch(booksWithRatingProvider);
    return SizedBox(
      height: 180,
      child: booksWithRatingAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(child: Text(localizations.allBooks));
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
