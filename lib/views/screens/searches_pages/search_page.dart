import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/search_providers.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/book_detail_page.dart';
import 'package:smart_ebook/views/widgets/dashboard_widgets/book_detail_container.dart';
import 'package:smart_ebook/views/widgets/searches_widgets/authors_images.dart';
import 'package:smart_ebook/views/widgets/searches_widgets/categories_card.dart';
import 'package:logger/logger.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterByGenre(String genre) {
    ref.read(searchQueryProvider.notifier).state = genre;
    _searchController.text = genre; // Set search bar text to trigger overlay
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final genresAsync = ref.watch(genresProvider);
    final authorsAsync = ref.watch(authorsProvider);
    final trendingBooksAsync = ref.watch(booksWithRatingProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                    const SizedBox(height: 10),
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Search books by title, author, or genre',
                      leading: const Icon(Icons.search),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.inversePrimary,
                      ),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(0),
                      onChanged: (value) {
                        ref.read(searchQueryProvider.notifier).state = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    genresAsync.when(
                      data:
                          (genres) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Categories",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children:
                                    genres.map((genre) {
                                      return CategoriesCard(
                                        text: genre,
                                        onCategoryClicked: _filterByGenre,
                                        isSelected:
                                            genre ==
                                            ref.watch(searchQueryProvider),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Text('Error loading categories: $error'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Famous Authors",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    authorsAsync.when(
                      data:
                          (authors) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children:
                                  authors
                                      .map(
                                        (author) => AuthorsImages(
                                          image: author['imageUrl']!,
                                          name: author['name']!,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Text('Error loading authors: $error'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Trending Books",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 180,
                      child: trendingBooksAsync.when(
                        data: (books) {
                          final trendingBooks =
                              books.where((b) => b.reviewCount >= 0).toList();
                          if (trendingBooks.isEmpty) {
                            return const Center(
                              child: Text('No trending books available'),
                            );
                          }
                          trendingBooks.sort(
                            (a, b) => b.reviewCount.compareTo(a.reviewCount),
                          );
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
                                ),
                              );
                            },
                          );
                        },
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (error, stack) =>
                                Center(child: Text('Error: $error')),
                      ),
                    ),
                  ],
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Positioned(
                  top: 120,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.only(top: 16),
                      color: Theme.of(context).colorScheme.surfaceBright,
                      child: searchResultsAsync.when(
                        data:
                            (books) =>
                                books.isEmpty
                                    ? const Center(
                                      child: Text(
                                        'No books found. Try a different search term.',
                                      ),
                                    )
                                    : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: books.length,
                                      itemBuilder: (context, index) {
                                        final bookWithRating = books[index];
                                        final book = bookWithRating.book;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primaryFixedDim,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 16,
                                                ),
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                book.coverPageUrl,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.broken_image,
                                                    ),
                                              ),
                                            ),
                                            title: Text(
                                              book.title,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                            subtitle: Text(
                                              book.genre,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                            trailing: Text(
                                              book.author,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                              ),
                                            ),
                                            onTap: () async {
                                              try {
                                                final user =
                                                    await ref
                                                        .read(userProvider)
                                                        .getCurrentUser();
                                                if (user != null) {
                                                  await ref
                                                      .read(
                                                        searchHistoryServiceProvider,
                                                      )
                                                      .logSearch(
                                                        userId: user.id,
                                                        query:
                                                            _searchController
                                                                .text,
                                                        desc: {
                                                          'genre': book.genre,
                                                        },
                                                        bookId: book.bookId,
                                                      );
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => BookDetailPage(
                                                          bookId: book.bookId,
                                                          title: book.title,
                                                          author: book.author,
                                                          imagePath:
                                                              book.coverPageUrl,
                                                          rating:
                                                              bookWithRating
                                                                  .rating,
                                                          reviewCount:
                                                              bookWithRating
                                                                  .reviewCount,
                                                          summary:
                                                              book.description,
                                                          audioId: book.audioId,
                                                          audioUrl:
                                                              book.audioUrl,
                                                          pdfId: book.fileId,
                                                          price: book.price,
                                                        ),
                                                  ),
                                                );
                                              } catch (e) {
                                                _logger.e(
                                                  'Failed to log search: $e',
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error logging search: $e',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (error, stack) => Center(
                              child: Text(
                                error.toString().contains('fulltext index')
                                    ? 'Search is currently unavailable. Please try again later.'
                                    : 'Error loading search results: $error',
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
