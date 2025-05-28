// import 'package:flutter/material.dart';
// import 'package:pdfx/pdfx.dart';
// import 'package:pdf_text/pdf_text.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:logger/logger.dart';

// class PDFViewerPage extends StatefulWidget {
//   final String title;
//   final String pdfPath;

//   const PDFViewerPage({super.key, required this.title, required this.pdfPath});

//   @override
//   State<PDFViewerPage> createState() => _PDFViewerPageState();
// }

// class _PDFViewerPageState extends State<PDFViewerPage> {
//   late PdfController _pdfController;
//   final Logger _logger = Logger();
//   late PDFDoc _pdfDoc;
//   final FlutterTts _tts = FlutterTts();
//   bool _isTtsPlaying = false;
//   bool _isTtsPaused = false;
//   bool _isLoadingText = false;
//   String? _ttsError;
//   String _extractedText = '';
//   int _currentPage = 1;
//   int _totalPages = 1;

//   @override
//   void initState() {
//     super.initState();
//     _pdfController = PdfController(
//       document: PdfDocument.openFile(widget.pdfPath),
//     );
//     _initializeTts();
//     _loadPdfText();
//   }

//   Future<void> _initializeTts() async {
//     _logger.i('Initializing TTS');
//     try {
//       _tts.setStartHandler(() {
//         _logger.i('TTS started');
//         if (mounted) {
//           setState(() => _isTtsPlaying = true);
//         }
//       });

//       _tts.setCompletionHandler(() {
//         _logger.i('TTS completed');
//         if (mounted) {
//           setState(() {
//             _isTtsPlaying = false;
//             _isTtsPaused = false;
//           });
//         }
//       });

//       _tts.setPauseHandler(() {
//         _logger.i('TTS paused');
//         if (mounted) {
//           setState(() => _isTtsPaused = true);
//         }
//       });

//       _tts.setContinueHandler(() {
//         _logger.i('TTS resumed');
//         if (mounted) {
//           setState(() => _isTtsPaused = false);
//         }
//       });

//       _tts.setErrorHandler((msg) {
//         _logger.e('TTS error: $msg');
//         if (mounted) {
//           setState(() {
//             _ttsError = 'TTS error: $msg';
//             _isTtsPlaying = false;
//             _isTtsPaused = false;
//           });
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('TTS error: $msg')));
//         }
//       });

//       await _tts.setLanguage('en-US');
//       await _tts.setSpeechRate(0.5);
//       await _tts.setVolume(1.0);
//       await _tts.setPitch(1.0);
//     } catch (e) {
//       _logger.e('Failed to initialize TTS: $e');
//       if (mounted) {
//         setState(() => _ttsError = 'Failed to initialize TTS: $e');
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to initialize TTS: $e')));
//       }
//     }
//   }

//   Future<void> _loadPdfText() async {
//     setState(() => _isLoadingText = true);
//     try {
//       _logger.i('Loading PDF text from: ${widget.pdfPath}');
//       _pdfDoc = await PDFDoc.fromPath(widget.pdfPath);
//       _totalPages = _pdfDoc.length;
//       final page = _pdfDoc.pageAt(_currentPage);
//       _extractedText = await page.text;
//       if (_extractedText.isEmpty) {
//         _logger.w('No text found on page $_currentPage');
//         setState(() => _ttsError = 'No text found on this page');
//       }
//       _logger.i(
//         'Extracted text (page $_currentPage): ${_extractedText.length} characters',
//       );
//       setState(() => _isLoadingText = false);
//     } catch (e) {
//       _logger.e('Failed to load PDF text: $e');
//       if (mounted) {
//         setState(() {
//           _ttsError = 'Failed to load PDF text: $e';
//           _isLoadingText = false;
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load PDF text: $e')));
//       }
//     }
//   }

//   Future<void> _playTts() async {
//     if (_ttsError != null || _extractedText.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(_ttsError ?? 'No text available to read')),
//         );
//       }
//       return;
//     }

//     try {
//       _logger.i('Starting TTS for page $_currentPage');
//       await _tts.speak(_extractedText);
//     } catch (e) {
//       _logger.e('TTS playback error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('TTS playback error: $e')));
//       }
//     }
//   }

//   Future<void> _pauseTts() async {
//     try {
//       _logger.i('Pausing TTS');
//       await _tts.pause();
//     } catch (e) {
//       _logger.e('TTS pause error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('TTS pause error: $e')));
//       }
//     }
//   }

//   Future<void> _stopTts() async {
//     try {
//       _logger.i('Stopping TTS');
//       await _tts.stop();
//       if (mounted) {
//         setState(() {
//           _isTtsPlaying = false;
//           _isTtsPaused = false;
//         });
//       }
//     } catch (e) {
//       _logger.e('TTS stop error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('TTS stop error: $e')));
//       }
//     }
//   }

//   Future<void> _changePage(int page) async {
//     if (page < 1 || page > _totalPages) return;
//     await _stopTts();
//     if (mounted) {
//       setState(() => _currentPage = page);
//     }
//     _pdfController.jumpToPage(page - 1);
//     await _loadPdfText();
//   }

//   @override
//   void dispose() {
//     _logger.i('Disposing PDFViewerPage');
//     _pdfController.dispose();
//     _tts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isTtsPlaying && !_isTtsPaused ? Icons.pause : Icons.play_arrow,
//             ),
//             onPressed: _isTtsPlaying && !_isTtsPaused ? _pauseTts : _playTts,
//             tooltip: _isTtsPlaying && !_isTtsPaused ? 'Pause TTS' : 'Play TTS',
//           ),
//           IconButton(
//             icon: const Icon(Icons.stop),
//             onPressed: _stopTts,
//             tooltip: 'Stop TTS',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PdfView(
//               controller: _pdfController,
//               onDocumentError: (error) {
//                 _logger.e('Failed to load PDF: $error');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to load PDF: $error')),
//                 );
//               },
//               onPageChanged: (page) {
//                 if (page + 1 != _currentPage) {
//                   _changePage(page + 1);
//                 }
//               },
//             ),
//           ),
//           if (_isLoadingText)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(),
//             ),
//           if (_ttsError != null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 _ttsError!,
//                 style: const TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back),
//                   onPressed:
//                       _currentPage > 1
//                           ? () => _changePage(_currentPage - 1)
//                           : null,
//                   tooltip: 'Previous Page',
//                 ),
//                 Text('Page $_currentPage of $_totalPages'),
//                 IconButton(
//                   icon: const Icon(Icons.arrow_forward),
//                   onPressed:
//                       _currentPage < _totalPages
//                           ? () => _changePage(_currentPage + 1)
//                           : null,
//                   tooltip: 'Next Page',
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
