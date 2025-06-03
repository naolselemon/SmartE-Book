import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_ebook/models/book.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:smart_ebook/views/screens/dashboard_pages/pdfviewer_page.dart';
import 'audioplay_page.dart';

import 'package:logger/logger.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final logger = Logger();
    return Scaffold(
      body: FutureBuilder<List<Book>>(
        future: ref.read(bookServicesProvider).getDownloadedBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return Center(child: Text(localizations.noDownloadedBooks));
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: Image.network(
                  book.coverPageUrl,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                ),
                title: Text(
                  book.title.isNotEmpty
                      ? book.title
                      : localizations.unknownTitle,
                ),
                subtitle: Text(
                  book.author.isNotEmpty
                      ? book.author
                      : localizations.unknownAuthor,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () async {
                        final pdfPath = await ref
                            .read(bookServicesProvider)
                            .getLocalFilePath(book.fileId, 'pdf');
                        if (pdfPath != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PDFViewerPage(
                                    title: book.title,
                                    pdfPath: pdfPath,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.pdfNotFound)),
                          );
                        }
                      },
                    ),
                    if (book.audioId.isNotEmpty || book.audioUrl.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          final audioFileId =
                              book.audioId.isNotEmpty
                                  ? book.audioId
                                  : book.bookId;
                          logger.i(
                            'Looking for audio: $audioFileId.mp4 or $audioFileId.mp3',
                          );
                          String? audioPath = await ref
                              .read(bookServicesProvider)
                              .getLocalFilePath(audioFileId, 'mp4');
                          audioPath ??= await ref
                              .read(bookServicesProvider)
                              .getLocalFilePath(audioFileId, 'mp3');
                          if (audioPath != null) {
                            logger.i('Audio found: $audioPath');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AudioPlayScreen(
                                      title: book.title,
                                      author: book.author,
                                      imagePath: book.coverPageUrl,
                                      localAudioPath: audioPath!,
                                    ),
                              ),
                            );
                          } else {
                            logger.w('Audio not found for $audioFileId');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.audioNotFound),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
