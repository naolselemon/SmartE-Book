import 'dart:io' show File, Platform;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadService {
  final Logger _logger = Logger();

  Future<String> downloadFile(
    List<int> fileData,
    String fileId,
    String extension, {
    int retries = 3,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      _logger.w('File operations are not supported on this platform');
      throw Exception('File operations are not supported on this platform');
    }
    for (var attempt = 1; attempt <= retries; attempt++) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileId.$extension';
        final file = File(filePath);
        await file.writeAsBytes(fileData);
        _logger.i('File downloaded to $filePath');
        return filePath;
      } catch (e) {
        if (attempt == retries) {
          _logger.e('Failed to download file after $retries attempts: $e');
          throw Exception('Failed to download file: $e');
        }
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw Exception('Unexpected error in downloadFile');
  }

  Future<bool> isFileDownloaded(String fileId, String extension) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileId.$extension';
    final exists = File(filePath).existsSync();
    return exists;
  }

  Future<String?> getLocalFilePath(String fileId, String extension) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return null;
    }
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileId.$extension';
    final exists = File(filePath).existsSync();
    return exists ? filePath : null;
  }

  Future<void> deleteFile(String fileId, String extension) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileId.$extension';
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        _logger.i('Deleted file $filePath');
      }
    } catch (e) {
      _logger.e('Failed to delete file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }
}
