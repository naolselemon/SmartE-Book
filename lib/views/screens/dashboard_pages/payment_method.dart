import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                log("navigated to: $url");
                if (url.startsWith("https://www.liben.com/")) {
                  // ✅ Successful payment, go back and return true
                  Navigator.pop(context, true);
                }
              },
              onWebResourceError: (error) {
                // Handle error if needed
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
