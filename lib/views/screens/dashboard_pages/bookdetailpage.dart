import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/reviewspage.dart';

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
  final String pdfId;

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
    required this.pdfId,
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
                                  ? "Audio Available By The Author"
                                  : "No Audio Available By The Author",
                              style: TextStyle(
                                color:
                                    audioId.isNotEmpty
                                        ? Colors.green
                                        : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Download button
                            Consumer(
                              builder: (context, ref, child) {
                                final bookServices = ref.read(
                                  bookServicesProvider,
                                );
                                return FutureBuilder<List<bool>>(
                                  future: Future.wait([
                                    bookServices.isFileDownloaded(
                                      bookId,
                                      'pdf',
                                    ),
                                    bookServices.isFileDownloaded(
                                      bookId,
                                      'mp3',
                                    ),
                                  ]),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return ElevatedButton(
                                        onPressed: null,
                                        child: const Text("Checking..."),
                                      );
                                    }
                                    final isPdfDownloaded = snapshot.data![0];
                                    final isAudioDownloaded =
                                        snapshot.data![1] || audioId.isEmpty;
                                    final allDownloaded =
                                        isPdfDownloaded && isAudioDownloaded;
                                    return ElevatedButton.icon(
                                      onPressed:
                                          allDownloaded
                                              ? null
                                              : () async {
                                                try {
                                                  if (!isPdfDownloaded &&
                                                      pdfId.isNotEmpty) {
                                                    await bookServices
                                                        .downloadFile(
                                                          pdfId,
                                                          bookId,
                                                          'pdf',
                                                        );
                                                  }
                                                  if (!isAudioDownloaded &&
                                                      audioId.isNotEmpty) {
                                                    await bookServices
                                                        .downloadFile(
                                                          audioId,
                                                          bookId,
                                                          'mp3',
                                                        );
                                                  }
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Download completed',
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Download failed: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                      icon: Icon(
                                        allDownloaded
                                            ? Icons.check
                                            : Icons.download,
                                      ),
                                      label: Text(
                                        allDownloaded
                                            ? "Downloaded"
                                            : "Download",
                                      ),
                                    );
                                  },
                                );
                              },
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
