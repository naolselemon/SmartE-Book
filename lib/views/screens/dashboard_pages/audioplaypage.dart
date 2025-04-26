import 'package:flutter/material.dart';
import '../../widgets/dashboard_widgets/audioplayerwidget.dart';

class AudioPlayScreen extends StatelessWidget {
  final String title;
  final String author;
  final String imagePath;
  final String localAudioPath;

  const AudioPlayScreen({
    super.key,
    required this.title,
    required this.author,
    required this.imagePath,
    required this.localAudioPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade700,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.grey.shade300)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 250,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Image.asset(imagePath, height: 200),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    author,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  AudioPlayerWidget(localAudioPath: localAudioPath),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
