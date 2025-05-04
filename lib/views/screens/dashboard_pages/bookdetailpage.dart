import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/reviewspage.dart';
import 'audioplaypage.dart';

class BookDetailPage extends ConsumerWidget {
  final String bookId;
  final String title;
  final String author;
  final String imagePath;
  final double rating;
  final int reviewCount;
  final String summary;
  final String audioId;
  final String audioUrl;

  const BookDetailPage({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    required this.imagePath,
    required this.rating,
    required this.reviewCount,
    required this.summary,
    required this.audioId,
    required this.audioUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: const Color.fromRGBO(35, 8, 90, 1),
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final favoriteStatusAsync = ref.watch(
                              favoriteStatusProvider(bookId),
                            );
                            return IconButton(
                              icon: favoriteStatusAsync.when(
                                data:
                                    (favoriteId) => Icon(
                                      favoriteId != null
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                loading:
                                    () => const Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                                error:
                                    (err, stack) => const Icon(
                                      Icons.favorite_border,
                                      color: Colors.white,
                                    ),
                              ),
                              onPressed: () async {
                                final profileState = ref.read(profileProvider);
                                if (profileState.user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please log in to favorite a book',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final userId = profileState.user!.id;
                                final bookServices = ref.read(
                                  bookServicesProvider,
                                );
                                favoriteStatusAsync.whenData((
                                  favoriteId,
                                ) async {
                                  if (favoriteId != null) {
                                    await bookServices.removeFavorite(
                                      favoriteId,
                                    );
                                    ref.invalidate(
                                      favoriteStatusProvider(bookId),
                                    );
                                  } else {
                                    await bookServices.addFavorite(
                                      userId,
                                      bookId,
                                    );
                                    ref.invalidate(
                                      favoriteStatusProvider(bookId),
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Image.network(
                      imagePath,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  tabs: [Tab(text: "Description"), Tab(text: "Reviews")],
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              // Tab content
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  children: [
                    // Description tab
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "by $author",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "$rating",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text("($reviewCount Reviews)"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Summary",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(summary),
                            const SizedBox(height: 10),
                            Text(
                              audioId.isNotEmpty
                                  ? "Audio Available by the Author"
                                  : "No Audio Available by the Author",
                              style: TextStyle(
                                color:
                                    audioId.isNotEmpty
                                        ? Colors.green
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Reading and Listening buttons
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.menu_book,
                                      color: Colors.deepPurple,
                                    ),
                                    label: const Text("Reading"),
                                  ),
                                  TextButton.icon(
                                    onPressed:
                                        audioId.isNotEmpty
                                            ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          AudioPlayScreen(
                                                            title: title,
                                                            author: author,
                                                            imagePath:
                                                                imagePath,
                                                            localAudioPath:
                                                                audioUrl,
                                                          ),
                                                ),
                                              );
                                            }
                                            : null,
                                    icon: Icon(
                                      Icons.headphones,
                                      color:
                                          audioId.isNotEmpty
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                    ),
                                    label: Text(
                                      "Listening",
                                      style: TextStyle(
                                        color:
                                            audioId.isNotEmpty
                                                ? Colors.deepPurple
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Reviews tab
                    ReviewsTab(bookId: bookId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
