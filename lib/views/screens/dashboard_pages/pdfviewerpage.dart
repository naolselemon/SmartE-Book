import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PDFViewerPage extends StatefulWidget {
  final String title;
  final String pdfPath;

  const PDFViewerPage({super.key, required this.title, required this.pdfPath});

  @override
  State createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.pdfPath),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PdfView(
        controller: _pdfController,
        onDocumentError: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load PDF: $error')));
        },
      ),
    );
  }
}
