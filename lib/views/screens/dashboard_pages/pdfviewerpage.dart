import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:pdfx/pdfx.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {
  final String title;
  final String pdfPath;

  const PDFViewerPage({
    super.key,
    required this.title,
    required this.pdfPath,
  });

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfController _pdfController;
  final Logger _logger = Logger();
  final FlutterTts _tts = FlutterTts();
  bool _isTtsInitialized = false;
  bool _isTtsPlaying = false;
  bool _isTtsPaused = false;
  bool _isLoadingText = false;
  String? _ttsError;
  String _extractedText = '';
  int _currentPage = 1;
  int _totalPages = 1;
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String _language = 'en-US';

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.pdfPath),
    );
    _initializeTts();
    _loadPdfText();
  }

  Future<void> _initializeTts() async {
    _logger.i('Initializing TTS');
    try {
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
          _changePage(_currentPage + 1).then((_) => _playTts());
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS error: $msg')),
        );
      });

      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(_pitch);

      setState(() => _isTtsInitialized = true);
    } catch (e) {
      _logger.e('Failed to initialize TTS: $e');
      setState(() => _ttsError = 'Failed to initialize TTS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize TTS: $e')),
      );
    }
  }

  Future<void> _loadPdfText() async {
    setState(() => _isLoadingText = true);
    try {
      _logger.i('Loading PDF text from: ${widget.pdfPath}');
      if (!await File(widget.pdfPath).existsSync()) {
        throw Exception('PDF file not found at ${widget.pdfPath}');
      }

      // Since pdfx doesn't support text extraction, rely on OCR
      await _loadPdfTextWithOCR();
      setState(() => _isLoadingText = false);
    } catch (e) {
      _logger.e('Failed to load PDF text: $e');
      setState(() {
        _ttsError = 'Failed to load PDF text: $e';
        _isLoadingText = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF text: $e')),
      );
    }
  }

  Future<void> _loadPdfTextWithOCR() async {
    try {
      _logger.i('Loading PDF for OCR from: ${widget.pdfPath}');
      final pdfDoc = await PdfDocument.openFile(widget.pdfPath);
      _totalPages = pdfDoc.pagesCount;
      final page = await pdfDoc.getPage(_currentPage);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.png,
      );
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/page_$_currentPage.png');
      await tempFile.writeAsBytes(pageImage!.bytes);
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      _extractedText = recognizedText.text;
      if (_extractedText.isEmpty) {
        _logger.w('No text found on page $_currentPage via OCR');
        setState(() => _ttsError = 'No text found on this page via OCR');
      } else {
        _logger.i('OCR extracted text (page $_currentPage): ${_extractedText.length} characters');
      }
      await page.close();
      await pdfDoc.close();
      await textRecognizer.close();
      await tempFile.delete();
    } catch (e) {
      _logger.e('Failed to load PDF text with OCR: $e');
      setState(() {
        _ttsError = 'Failed to load PDF text with OCR: $e';
        _isLoadingText = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF text with OCR: $e')),
      );
    }
  }

  Future<void> _playTts() async {
    if (_ttsError != null || _extractedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_ttsError ?? 'No text available to read')),
      );
      return;
    }

    try {
      _logger.i('Starting TTS for page $_currentPage');
      await _tts.speak(_extractedText);
    } catch (e) {
      _logger.e('TTS playback error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS playback error: $e')),
      );
    }
  }

  Future<void> _pauseTts() async {
    try {
      _logger.i('Pausing TTS');
      await _tts.pause();
    } catch (e) {
      _logger.e('TTS pause error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS pause error: $e')),
      );
    }
  }

  Future<void> _stopTts() async {
    try {
      _logger.i('Stopping TTS');
      await _tts.stop();
      setState(() {
        _isTtsPlaying = false;
        _isTtsPaused = false;
      });
    } catch (e) {
      _logger.e('TTS stop error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('TTS stop error: $e')),
      );
    }
  }

  Future<void> _changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    await _stopTts();
    setState(() => _currentPage = page);
    _pdfController.jumpToPage(page - 1);
    await _loadPdfText();
  }

  @override
  void dispose() {
    _logger.i('Disposing PDFViewerPage');
    _pdfController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Semantics(
            label: _isTtsPlaying && !_isTtsPaused ? 'Pause reading' : 'Play reading',
            child: IconButton(
              icon: Icon(
                _isTtsPlaying && !_isTtsPaused ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: _isTtsPlaying && !_isTtsPaused ? _pauseTts : _playTts,
              tooltip: _isTtsPlaying && !_isTtsPaused ? 'Pause TTS' : 'Play TTS',
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
            child: PdfView(
              controller: _pdfController,
              onDocumentError: (error) {
                _logger.e('Failed to load PDF: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load PDF: $error')),
                );
              },
              onPageChanged: (page) {
                if (page + 1 != _currentPage) {
                  _changePage(page + 1);
                }
              },
            ),
          ),
          if (_isLoadingText)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
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
                  items: ['en-US', 'es-ES', 'fr-FR']
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ))
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Semantics(
                  label: 'Previous page',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
                    tooltip: 'Previous Page',
                  ),
                ),
                Text('Page $_currentPage of $_totalPages'),
                Semantics(
                  label: 'Next page',
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _totalPages ? () => _changePage(_currentPage + 1) : null,
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