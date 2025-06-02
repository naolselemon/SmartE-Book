import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/reviewspage.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final logger = Logger();
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
                                    SnackBar(
                                      content: Text(
                                        localizations.loginToFavorite,
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
                  tabs: [
                    Tab(text: localizations.description),
                    Tab(text: localizations.reviews),
                  ],
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
                            Text(
                              localizations.summary,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(summary),
                            const SizedBox(height: 10),
                            Text(
                              audioId.isNotEmpty || audioUrl.isNotEmpty
                                  ? localizations.audioAvailable
                                  : localizations.noAudioAvailable,
                              style: TextStyle(
                                color:
                                    audioId.isNotEmpty || audioUrl.isNotEmpty
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
                                    bookServices.isFileDownloaded(pdfId, 'pdf'),
                                    bookServices.isFileDownloaded(
                                      audioId,
                                      'mp4',
                                    ),
                                  ]),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const CircularProgressIndicator();
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
                                                  // Log permission status
                                                  final storageStatus =
                                                      await Permission
                                                          .storage
                                                          .status;
                                                  final photosStatus =
                                                      await Permission
                                                          .photos
                                                          .status;
                                                  final audioStatus =
                                                      await Permission
                                                          .audio
                                                          .status;
                                                  debugPrint(
                                                    'Permissions: storage=$storageStatus, photos=$photosStatus, audio=$audioStatus',
                                                  );

                                                  // Request permissions
                                                  bool permissionGranted =
                                                      true; // Assume true for app-specific storage
                                                  if (Platform.isAndroid) {
                                                    final deviceInfo =
                                                        DeviceInfoPlugin();
                                                    final androidInfo =
                                                        await deviceInfo
                                                            .androidInfo;
                                                    final sdkInt =
                                                        androidInfo
                                                            .version
                                                            .sdkInt;
                                                    if (sdkInt >= 33) {
                                                      // Android 13+: Request media permissions
                                                      final statuses =
                                                          await [
                                                            Permission.photos
                                                                .request(),
                                                            Permission.audio
                                                                .request(),
                                                          ].wait;
                                                      permissionGranted =
                                                          statuses.every(
                                                            (status) =>
                                                                status
                                                                    .isGranted,
                                                          );
                                                      if (!permissionGranted &&
                                                          statuses.any(
                                                            (status) =>
                                                                status
                                                                    .isPermanentlyDenied,
                                                          )) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              localizations
                                                                  .enableMediaPermissions,
                                                            ),
                                                            action: SnackBarAction(
                                                              label:
                                                                  'Open Settings',
                                                              onPressed:
                                                                  () =>
                                                                      openAppSettings(),
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                    } else {
                                                      // Android 12 and below: Request storage
                                                      final status =
                                                          await Permission
                                                              .storage
                                                              .request();
                                                      permissionGranted =
                                                          status.isGranted;
                                                      if (!permissionGranted &&
                                                          status
                                                              .isPermanentlyDenied) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              localizations
                                                                  .enableStoragePermissions,
                                                            ),
                                                            action: SnackBarAction(
                                                              label:
                                                                  'Open Settings',
                                                              onPressed:
                                                                  () =>
                                                                      openAppSettings(),
                                                            ),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                    }
                                                  } else if (Platform.isIOS) {
                                                    // iOS: Request storage (optional, as app-specific storage doesn't require it)
                                                    final status =
                                                        await Permission.storage
                                                            .request();
                                                    permissionGranted =
                                                        status.isGranted;
                                                    if (!permissionGranted &&
                                                        status
                                                            .isPermanentlyDenied) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            localizations
                                                                .enableFileAccess,
                                                          ),
                                                          action: SnackBarAction(
                                                            label:
                                                                'Open Settings',
                                                            onPressed:
                                                                () =>
                                                                    openAppSettings(),
                                                          ),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                  }

                                                  if (!permissionGranted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          localizations
                                                              .permissionDenied,
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  // Log file IDs
                                                  logger.i(
                                                    'Starting download: bookId=$bookId, pdfId=$pdfId, audioId=$audioId, audioUrl=$audioUrl',
                                                  );

                                                  // Show loading dialog
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          content: Row(
                                                            children: [
                                                              CircularProgressIndicator(),
                                                              SizedBox(
                                                                width: 16,
                                                              ),
                                                              Text(
                                                                localizations
                                                                    .downloading,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  );

                                                  // Download PDF and audio
                                                  final downloadFutures =
                                                      <Future<void>>[];
                                                  if (!isPdfDownloaded &&
                                                      pdfId.isNotEmpty) {
                                                    downloadFutures.add(
                                                      bookServices.downloadFile(
                                                        pdfId,
                                                        pdfId,
                                                        'pdf',
                                                      ),
                                                    );
                                                  }
                                                  if (!isAudioDownloaded &&
                                                      audioId.isNotEmpty) {
                                                    downloadFutures.add(
                                                      bookServices.downloadFile(
                                                        audioId,
                                                        audioId,
                                                        'mp4',
                                                      ),
                                                    );
                                                    logger.i(
                                                      'Audio downloaded via audioId: $audioId',
                                                    );
                                                  } else if (!isAudioDownloaded &&
                                                      audioId.isEmpty &&
                                                      audioUrl.isNotEmpty) {
                                                    final response = await http
                                                        .get(
                                                          Uri.parse(audioUrl),
                                                        );
                                                    if (response.statusCode ==
                                                        200) {
                                                      final dir =
                                                          await getApplicationDocumentsDirectory();
                                                      final audioFileId =
                                                          bookId; // Use bookId as fallback if audioId is empty
                                                      final file = File(
                                                        '${dir.path}/$audioFileId.mp4',
                                                      );
                                                      await file.writeAsBytes(
                                                        response.bodyBytes,
                                                      );
                                                      logger.i(
                                                        'Audio downloaded via audioUrl: $audioUrl, saved as $audioFileId.mp4',
                                                      );
                                                    } else {
                                                      throw Exception(
                                                        'Failed to download audio from $audioUrl',
                                                      );
                                                    }
                                                  }
                                                  await Future.wait(
                                                    downloadFutures,
                                                  );

                                                  // Verify downloads
                                                  final pdfExists =
                                                      await bookServices
                                                          .isFileDownloaded(
                                                            pdfId,
                                                            'pdf',
                                                          );
                                                  final audioExists =
                                                      audioId.isEmpty ||
                                                      await bookServices
                                                          .isFileDownloaded(
                                                            audioId.isNotEmpty
                                                                ? audioId
                                                                : bookId,
                                                            'mp4',
                                                          );
                                                  if (!pdfExists ||
                                                      (audioId.isNotEmpty &&
                                                          !audioExists)) {
                                                    throw Exception(
                                                      'Verification failed: Files not found after download',
                                                    );
                                                  }

                                                  // Close dialog
                                                  Navigator.of(context).pop();

                                                  // Refresh library
                                                  ref.invalidate(
                                                    downloadedBooksProvider,
                                                  );

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        localizations
                                                            .downloadCompleted,
                                                      ),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  Navigator.of(context).pop();
                                                  logger.e(
                                                    'Download failed: $e',
                                                  );
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
                                            ? localizations.downloaded
                                            : localizations.download,
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
