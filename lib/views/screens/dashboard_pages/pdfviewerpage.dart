import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFViewerPage extends StatefulWidget {
  final String title;
  final String pdfPath;

  const PDFViewerPage({super.key, required this.title, required this.pdfPath});

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late pdfx.PdfController _pdfController;
  late Future<pdfx.PdfDocument> _pdfDocumentFuture;
  final Logger _logger = Logger();
  final FlutterTts _tts = FlutterTts();
  bool _isTtsPlaying = false;
  bool _isTtsPaused = false;
  bool _isLoadingText = false;
  bool _isScannedPdf = false; // Flag to track if PDF is scanned
  String? _ttsError;
  String _extractedText = '';
  int _currentPage = 1;
  int _totalPages = 1;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _language = 'en-US';
  final Map<int, String> _textCache = {};
  static const int _maxCacheSize = 20;

  @override
  void initState() {
    super.initState();
    _pdfDocumentFuture = pdfx.PdfDocument.openFile(widget.pdfPath);
    _pdfController = pdfx.PdfController(document: _pdfDocumentFuture);
    _checkIfScannedPdf(); // Check if PDF is scanned
    _initializeTts();
    if (!_isScannedPdf) {
      _loadPdfText(); // Load text only for text-based PDFs
    }
  }

  Future<void> _checkIfScannedPdf() async {
    try {
      _logger.i('Checking if PDF is scanned: ${widget.pdfPath}');
      final file = File(widget.pdfPath);
      if (!await file.exists()) {
        throw Exception('PDF file not found at ${widget.pdfPath}');
      }

      final pdfBytes = await file.readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: pdfBytes);
      final textExtractor = PdfTextExtractor(pdfDocument);
      final text = textExtractor.extractText(
        startPageIndex: 0,
        endPageIndex: 0,
      );
      pdfDocument.dispose();

      setState(() {
        _isScannedPdf = text.isEmpty; // If no text is extracted, assume scanned
        _logger.i('PDF is ${_isScannedPdf ? "scanned" : "text-based"}');
      });
    } catch (e, stack) {
      _logger.e('Failed to check PDF type: $e', stackTrace: stack);
      setState(() {
        _ttsError = 'Failed to check PDF type: $e';
        _isScannedPdf = true; // Default to scanned on error to avoid crashes
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to check PDF type: $e')));
      }
    }
  }

  Future<void> _initializeTts() async {
    if (_isScannedPdf) return; // Skip TTS initialization for scanned PDFs
    _logger.i('Initializing TTS');
    try {
      final availableLanguages = await _tts.getLanguages;
      _logger.i('Available TTS languages: $availableLanguages');
      if (!availableLanguages.contains(_language)) {
        _logger.w(
          'Selected language $_language not supported, defaulting to en-US',
        );
        _language = 'en-US';
      }

      _tts.setStartHandler(() {
        _logger.i('TTS started');
        setState(() => _isTtsPlaying = true);
      });

      _tts.setCompletionHandler(() {
        _logger.i('TTS completed');
        setState(() {
          _isTtsPlaying = false;
          _isTtsPaused = false;
        });
        if (_currentPage < _totalPages) {
          try {
            _changePage(_currentPage + 1).then((_) {
              // Ensure UI is updated before starting TTS
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _playTts();
              });
            });
          } catch (e, stack) {
            _logger.e('Error in TTS completion: $e', stackTrace: stack);
            setState(() => _ttsError = 'Failed to process next page: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to process next page: $e')),
              );
            }
          }
        }
      });

      _tts.setPauseHandler(() {
        _logger.i('TTS paused');
        setState(() => _isTtsPaused = true);
      });

      _tts.setContinueHandler(() {
        _logger.i('TTS resumed');
        setState(() => _isTtsPaused = false);
      });

      _tts.setErrorHandler((msg) {
        _logger.e('TTS error: $msg');
        setState(() {
          _ttsError = 'TTS error: $msg';
          _isTtsPlaying = false;
          _isTtsPaused = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('TTS error: $msg')));
        }
      });

      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(_pitch);
    } catch (e, stack) {
      _logger.e('Failed to initialize TTS: $e', stackTrace: stack);
      setState(() => _ttsError = 'Failed to initialize TTS: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to initialize TTS: $e')));
      }
    }
  }

  Future<void> _loadPdfText() async {
    if (_isScannedPdf) return; // Skip text loading for scanned PDFs
    setState(() => _isLoadingText = true);
    try {
      _logger.i(
        'Loading PDF text for page $_currentPage from: ${widget.pdfPath}',
      );
      final file = File(widget.pdfPath);
      if (!await file.exists()) {
        throw Exception('PDF file not found at ${widget.pdfPath}');
      }

      if (_textCache.containsKey(_currentPage)) {
        _extractedText = _textCache[_currentPage]!;
        _logger.i(
          'Loaded cached text (page $_currentPage): ${_extractedText.length} characters',
        );
        setState(() => _isLoadingText = false);
        return;
      }

      final pdfBytes = await file.readAsBytes();
      final pdfDocument = PdfDocument(inputBytes: pdfBytes);
      final textExtractor = PdfTextExtractor(pdfDocument);
      _extractedText = textExtractor.extractText(
        startPageIndex: _currentPage - 1,
        endPageIndex: _currentPage - 1,
      );
      _totalPages = pdfDocument.pages.count;
      pdfDocument.dispose();

      if (_extractedText.isNotEmpty) {
        _textCache[_currentPage] = _extractedText;
        _logger.i(
          'Extracted text directly from PDF (page $_currentPage): ${_extractedText.length} characters',
        );
      } else {
        _logger.w(
          'No text extracted directly from page $_currentPage, falling back to OCR',
        );
        await _loadPdfTextWithOCR();
      }

      if (_textCache.length > _maxCacheSize) {
        _textCache.remove(_textCache.keys.first);
        _logger.i('Evicted oldest cache entry');
      }
    } catch (e, stack) {
      _logger.e('Failed to load PDF text: $e', stackTrace: stack);
      setState(() {
        _ttsError = 'Failed to load PDF text: $e';
        _isLoadingText = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load PDF text: $e')));
      }
    } finally {
      setState(() => _isLoadingText = false);
    }
  }

  Future<void> _loadPdfTextWithOCR() async {
    pdfx.PdfPage? page;
    File? tempFile;
    try {
      _logger.i('Loading PDF for OCR from: ${widget.pdfPath}');
      final pdfDoc = await _pdfDocumentFuture;
      page = await pdfDoc.getPage(_currentPage);

      if (page.width * page.height > 5000 * 5000) {
        _logger.w('Page $_currentPage too large for OCR');
        setState(() => _ttsError = 'Page too large for OCR processing');
        return;
      }

      final pageImage = await page.render(
        width: page.width * 0.1,
        height: page.height * 0.1,
        format: pdfx.PdfPageImageFormat.png,
        quality: 20,
      );
      if (pageImage == null) {
        _logger.e('Failed to render page image');
        setState(() => _ttsError = 'Failed to render page image');
        return;
      }
      _logger.i('Rendered image size: ${pageImage.width}x${pageImage.height}');

      final tempDir = await getTemporaryDirectory();
      _logger.i('Temp directory: ${tempDir.path}');
      tempFile = File('${tempDir.path}/page$_currentPage.png');
      await tempFile.writeAsBytes(pageImage.bytes);
      _logger.i('Wrote temp file: ${tempFile.path}');

      final inputImage = InputImage.fromFilePath(tempFile.path);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final retrievedText = await textRecognizer
          .processImage(inputImage)
          .timeout(
            const Duration(seconds: 5),
            onTimeout:
                () => throw TimeoutException('OCR timed out for Latin script'),
          );
      _extractedText = retrievedText.text;
      await textRecognizer.close();

      if (_extractedText.isNotEmpty) {
        _textCache[_currentPage] = _extractedText;
        _logger.i(
          'OCR extracted text (page $_currentPage, script: latin): ${_extractedText.length} characters',
        );
        setState(() => _ttsError = null);
      } else {
        _logger.w('No text found on page $_currentPage via OCR');
        setState(
          () =>
              _ttsError =
                  'This page appears to be blank or contains no recognizable text',
        );
      }
    } catch (e, stack) {
      _logger.e('Failed to load PDF text with OCR: $e', stackTrace: stack);
      setState(() => _ttsError = 'Failed to load PDF text with OCR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF text with OCR: $e')),
        );
      }
    } finally {
      await page?.close();
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
          _logger.i('Deleted temp file: ${tempFile.path}');
        } catch (e) {
          _logger.e('Failed to delete temp file: $e');
        }
      }
    }
  }

  Future<void> _playTts() async {
    if (_isScannedPdf) return; // Skip TTS for scanned PDFs
    if (_ttsError != null || _extractedText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_ttsError ?? 'No text available to read')),
        );
      }
      return;
    }

    try {
      _logger.i('Starting TTS for page $_currentPage');
      await _tts.speak(_extractedText);
    } catch (e, stack) {
      _logger.e('TTS playback error: $e', stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS playback error: $e')));
      }
    }
  }

  Future<void> _pauseTts() async {
    if (_isScannedPdf) return; // Skip TTS for scanned PDFs
    try {
      _logger.i('Pausing TTS');
      await _tts.pause();
    } catch (e, stack) {
      _logger.e('TTS pause error: $e', stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS pause error: $e')));
      }
    }
  }

  Future<void> _stopTts() async {
    if (_isScannedPdf) return; // Skip TTS for scanned PDFs
    try {
      _logger.i('Stopping TTS');
      await _tts.stop();
      setState(() {
        _isTtsPlaying = false;
        _isTtsPaused = false;
      });
    } catch (e, stack) {
      _logger.e('TTS stop error: $e', stackTrace: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TTS stop error: $e')));
      }
    }
  }

  Future<void> _changePage(int page) async {
    if (_isScannedPdf) {
      // For scanned PDFs, only change the page without loading text
      if (page < 1 || page > _totalPages) return;
      setState(() => _currentPage = page);
      try {
        _pdfController.jumpToPage(page - 1);
      } catch (e, stack) {
        _logger.e('Failed to change page: $e', stackTrace: stack);
        setState(() => _ttsError = 'Failed to load page $page: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load page $page: $e')),
          );
        }
      }
      return;
    }

    // Existing logic for text-based PDFs
    if (page < 1 || page > _totalPages) return;
    await _stopTts();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _currentPage = page);
    try {
      _pdfController.jumpToPage(page - 1);
      await _loadPdfText();
    } catch (e, stack) {
      _logger.e('Failed to change page: $e', stackTrace: stack);
      setState(() => _ttsError = 'Failed to load page $page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load page $page: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _logger.i('Disposing PDFViewerPage');
    _pdfController.dispose();
    if (!_isScannedPdf) {
      _tts.stop();
      _textCache.clear();
    }
    _pdfDocumentFuture.then((doc) => doc.close()).catchError((e) {
      _logger.e('Failed to close PdfDocument: $e');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions:
            _isScannedPdf
                ? [] // No TTS controls for scanned PDFs
                : [
                  Semantics(
                    label:
                        _isTtsPlaying && !_isTtsPaused
                            ? 'Pause reading'
                            : 'Play reading',
                    child: IconButton(
                      icon: Icon(
                        _isTtsPlaying && !_isTtsPaused
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed:
                          _isTtsPlaying && !_isTtsPaused ? _pauseTts : _playTts,
                      tooltip:
                          _isTtsPlaying && !_isTtsPaused
                              ? 'Pause TTS'
                              : 'Play TTS',
                    ),
                  ),
                  Semantics(
                    label: 'Stop reading',
                    child: IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: _stopTts,
                      tooltip: 'Stop TTS',
                    ),
                  ),
                ],
      ),
      body: Column(
        children: [
          Expanded(
            child: pdfx.PdfView(
              controller: _pdfController,
              onDocumentError: (error) {
                _logger.e('Failed to load PDF: $error');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load PDF: $error')),
                  );
                }
              },
              onPageChanged: (page) {
                if (page != _currentPage) {
                  _changePage(page + 1);
                }
              },
            ),
          ),
          if (!_isScannedPdf) ...[
            // Existing UI elements for text-based PDFs
            if (_isLoadingText)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 8),
                    Text('Processing page...'),
                  ],
                ),
              ),
            if (_ttsError != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _ttsError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _language,
                    items:
                        ['en-US', 'es-ES', 'fr-FR']
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                    onChanged: (value) async {
                      setState(() => _language = value!);
                      await _tts.setLanguage(value!);
                    },
                    hint: const Text('Select Language'),
                  ),
                  Slider(
                    value: _speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: 'Speed: ${_speechRate.toStringAsFixed(1)}',
                    onChanged: (value) async {
                      setState(() => _speechRate = value);
                      await _tts.setSpeechRate(value);
                    },
                  ),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: 'Pitch: ${_pitch.toStringAsFixed(1)}',
                    onChanged: (value) async {
                      setState(() => _pitch = value);
                      await _tts.setPitch(value);
                    },
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  label: 'Previous page',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed:
                        _currentPage > 1
                            ? () => _changePage(_currentPage - 1)
                            : null,
                    tooltip: 'Previous Page',
                  ),
                ),
                Text('Page $_currentPage of $_totalPages'),
                Semantics(
                  label: 'Next page',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed:
                        _currentPage < _totalPages
                            ? () => _changePage(_currentPage + 1)
                            : null,
                    tooltip: 'Next Page',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
