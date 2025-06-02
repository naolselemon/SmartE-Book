import 'dart:convert';
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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_ebook/views/screens/dashboard_pages/payment_method.dart';

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
  final double price;

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
    required this.price,
  });

  Future<bool> initiateChapaPayment(
    BuildContext context,
    Logger logger,
    WidgetRef ref,
  ) async {
    try {
      // Fetch user information from profileProvider
      final profileState = ref.read(profileProvider);
      if (profileState.user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to purchase')),
          );
        }
        return false;
      }
      final userEmail = profileState.user!.email ?? 'user@example.com';
      final userName = profileState.user!.name ?? 'Anonymous';
      final firstName = userName.split(' ').first;
      final lastName =
          userName.split(' ').length > 1 ? userName.split(' ').last : '';

      var headers = {
        'Authorization': dotenv.env['CHAPA_SECRET_KEY']!,
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(dotenv.env['CHAPA_API_URL']!),
      );

      request.body = json.encode({
        "amount": price.toString(),
        "currency": "ETB",
        "email": userEmail,
        "first_name": firstName,
        "last_name": lastName,
        "tx_ref": "book-${DateTime.now().millisecondsSinceEpoch}-$bookId",
        "callback_url": "https://webhook.site/your-custom-callback",
        "return_url": "https://www.liben.com/",
        "customization[title]": "Payment for $title",
        "customization[description]": "Purchase eBook: $title by $author",
        "meta[hide_receipt]": "true",
      });

      request.headers.addAll(headers);

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Redirecting to payment...'),
                  ],
                ),
              ),
        );
      }

      http.StreamedResponse response = await request.send();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseJson = json.decode(responseBody);
        final checkoutUrl = responseJson['data']['checkout_url'];
        logger.i("Checkout URL: $checkoutUrl");

        if (checkoutUrl != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(url: checkoutUrl),
            ),
          );

          if (result == true) {
            // Payment successful, proceed with download
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Payment successful!')),
              );
            }
            return await _downloadFiles(context, logger, ref);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Payment failed or cancelled')),
              );
            }
            return false;
          }
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize payment')),
        );
      }
      return false;
    } catch (e) {
      logger.e("Payment initiation failed: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiation failed: $e')),
        );
      }
      return false;
    }
  }

  Future<bool> _downloadFiles(
    BuildContext context,
    Logger logger,
    WidgetRef ref,
  ) async {
    final bookServices = ref.read(bookServicesProvider);
    try {
      // Log permission status
      final storageStatus = await Permission.storage.status;
      final photosStatus = await Permission.photos.status;
      final audioStatus = await Permission.audio.status;
      debugPrint(
        'Permissions: storage=$storageStatus, photos=$photosStatus, audio=$audioStatus',
      );

      // Request permissions
      bool permissionGranted = true;
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        if (sdkInt >= 33) {
          final statuses =
              await [
                Permission.photos.request(),
                Permission.audio.request(),
              ].wait;
          permissionGranted = statuses.every((status) => status.isGranted);
          if (!permissionGranted &&
              statuses.any((status) => status.isPermanentlyDenied)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please enable media permissions in app settings.',
                  ),
                  action: SnackBarAction(
                    label: 'Open Settings',
                    onPressed: () => openAppSettings(),
                  ),
                ),
              );
            }
            return false;
          }
        } else {
          final status = await Permission.storage.request();
          permissionGranted = status.isGranted;
          if (!permissionGranted && status.isPermanentlyDenied) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Please enable storage permissions in app settings.',
                  ),
                  action: SnackBarAction(
                    label: 'Open Settings',
                    onPressed: () => openAppSettings(),
                  ),
                ),
              );
            }
            return false;
          }
        }
      } else if (Platform.isIOS) {
        final status = await Permission.storage.request();
        permissionGranted = status.isGranted;
        if (!permissionGranted && status.isPermanentlyDenied) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Please enable file access in Settings.'),
                action: SnackBarAction(
                  label: 'Open Settings',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
          return false;
        }
      }

      if (!permissionGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permissions denied')));
        }
        return false;
      }

      // Log file IDs
      logger.i(
        'Starting download: bookId=$bookId, pdfId=$pdfId, audioId=$audioId, audioUrl=$audioUrl',
      );

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Downloading...'),
                  ],
                ),
              ),
        );
      }

      // Download PDF and audio
      final downloadFutures = <Future<void>>[];
      final isPdfDownloaded = await bookServices.isFileDownloaded(pdfId, 'pdf');
      final isAudioDownloaded =
          audioId.isEmpty ||
          await bookServices.isFileDownloaded(audioId, 'mp4');
      if (!isPdfDownloaded && pdfId.isNotEmpty) {
        downloadFutures.add(bookServices.downloadFile(pdfId, pdfId, 'pdf'));
      }
      if (!isAudioDownloaded && audioId.isNotEmpty) {
        downloadFutures.add(bookServices.downloadFile(audioId, audioId, 'mp4'));
        logger.i('Audio downloaded via audioId: $audioId');
      } else if (!isAudioDownloaded && audioId.isEmpty && audioUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(audioUrl));
        if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final audioFileId = bookId;
          final file = File('${dir.path}/$audioFileId.mp4');
          await file.writeAsBytes(response.bodyBytes);
          logger.i(
            'Audio downloaded via audioUrl: $audioUrl, saved as $audioFileId.mp4',
          );
        } else {
          throw Exception('Failed to download audio from $audioUrl');
        }
      }
      await Future.wait(downloadFutures);

      // Verify downloads
      final pdfExists = await bookServices.isFileDownloaded(pdfId, 'pdf');
      final audioExists =
          audioId.isEmpty ||
          await bookServices.isFileDownloaded(
            audioId.isNotEmpty ? audioId : bookId,
            'mp4',
          );
      if (!pdfExists || (audioId.isNotEmpty && !audioExists)) {
        throw Exception('Verification failed: Files not found after download');
      }

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Refresh library
      ref.invalidate(downloadedBooksProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download completed')));
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
      logger.e('Download failed: $e');
      return false;
    }
  }

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
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          localizations.loginToFavorite,
                                        ),
                                      ),
                                    );
                                  }
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                            const SizedBox(height: 10),
                            // Price display
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Price: ${price == 0.0 ? 'Free' : '${price.toStringAsFixed(2)} ETB'}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
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
                                                  if (price > 0) {
                                                    // Paid book: Initiate payment
                                                    final paymentSuccess =
                                                        await initiateChapaPayment(
                                                          context,
                                                          logger,
                                                          ref,
                                                        );
                                                    if (!paymentSuccess) {
                                                      return;
                                                    }
                                                  } else {
                                                    // Free book: Directly download
                                                    final downloadSuccess =
                                                        await _downloadFiles(
                                                          context,
                                                          logger,
                                                          ref,
                                                        );
                                                    if (!downloadSuccess) {
                                                      return;
                                                    }
                                                  }
                                                } catch (e) {
                                                  logger.e('Error: $e');
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error: $e',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                      icon: Icon(
                                        allDownloaded
                                            ? Icons.check
                                            : Icons.download,
                                      ),
                                      label: Text(
                                        price == 0.0 && allDownloaded
                                            ? 'Downloaded'
                                            : allDownloaded
                                            ? 'Bought'
                                            : (price == 0.0
                                                ? 'Download'
                                                : 'Buy'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            allDownloaded
                                                ? Colors.green
                                                : Colors.blueAccent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
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
